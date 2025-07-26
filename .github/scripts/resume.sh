#!/bin/bash
# This script resumes AWS resources (ECS service and RDS Aurora cluster) in the specified AWS account.
# Made idempotent - safe to run multiple times, checks resource existence before acting.

set -euo pipefail  # Exit on error, undefined variables, and pipe failures

# Error handling function
error_handler() {
    local line=$1
    local func=$2
    echo "Error occurred at line ${line} in function ${func}"
    exit 1
}

# Set trap for error handling (but not for resource not found errors)
trap 'error_handler ${LINENO} ${FUNCNAME[0]}' ERR

# Function to check if required parameters are provided
check_parameters() {
    local env=$1
    local prefix=$2
    
    if [ -z "$env" ] || [ -z "$prefix" ]; then
        echo "Usage: $0 <environment> <stack-prefix>"
        echo "Example: $0 dev myapp"
        exit 1
    fi
}

# Function to check if DB cluster exists and get its status
check_db_cluster() {
    local prefix=$1
    local env=$2
    local cluster_id="${prefix}-aurora-${env}"
    
    # Temporarily disable error exit for this check
    set +e
    local status=$(aws rds describe-db-clusters --db-cluster-identifier "${cluster_id}" --query 'DBClusters[0].Status' --output text 2>/dev/null)
    local exit_code=$?
    set -e
    
    if [ $exit_code -ne 0 ]; then
        echo "not-found"
    else
        echo "$status"
    fi
}

# Function to start DB cluster
start_db_cluster() {
    local prefix=$1
    local env=$2
    local cluster_id="${prefix}-aurora-${env}"
    
    echo "Starting DB cluster ${cluster_id}..."
    
    # Temporarily disable error exit for AWS commands
    set +e
    aws rds start-db-cluster --db-cluster-identifier "${cluster_id}" --no-cli-pager --output json
    local start_result=$?
    set -e
    
    if [ $start_result -ne 0 ]; then
        echo "Failed to start DB cluster ${cluster_id}"
        return 1
    fi
    
    echo "Waiting for DB cluster to be available..."
    set +e
    aws rds wait db-cluster-available --db-cluster-identifier "${cluster_id}"
    local wait_result=$?
    set -e
    
    if [ $wait_result -ne 0 ]; then
        echo "Timeout or error waiting for DB cluster to become available"
        return 1
    fi
    
    echo "DB cluster is now available"
    return 0
}

# Function to check if ECS cluster exists
check_ecs_cluster() {
    local cluster=$1
    
    set +e
    local status=$(aws ecs describe-clusters --clusters "${cluster}" --query 'clusters[0].status' --output text 2>/dev/null)
    local exit_code=$?
    set -e
    
    if [ $exit_code -ne 0 ] || [ "$status" = "None" ] || [ -z "$status" ]; then
        echo "not-found"
    else
        echo "$status"
    fi
}

# Function to check if ECS service exists
check_ecs_service() {
    local cluster=$1
    local service=$2
    
    set +e
    local status=$(aws ecs describe-services --cluster "${cluster}" --services "${service}" --query 'services[0].status' --output text 2>/dev/null)
    local exit_code=$?
    set -e
    
    if [ $exit_code -ne 0 ] || [ "$status" = "None" ] || [ -z "$status" ]; then
        echo "not-found"
    else
        echo "$status"
    fi
}

# Function to resume ECS service
resume_ecs_service() {
    local prefix=$1
    local env=$2
    local cluster="${prefix}-node-api-${env}"
    local service="${prefix}-node-api-${env}"
    
    echo "Checking ECS cluster ${cluster}..."
    local cluster_status=$(check_ecs_cluster "${cluster}")
    
    if [ "$cluster_status" = "not-found" ]; then
        echo "ECS cluster ${cluster} does not exist. Skipping service resume."
        return 0
    fi
    
    if [ "$cluster_status" != "ACTIVE" ]; then
        echo "ECS cluster ${cluster} is not active (status: ${cluster_status}). Skipping service resume."
        return 0
    fi

    echo "Checking ECS service ${service}..."
    local service_status=$(check_ecs_service "${cluster}" "${service}")
    
    if [ "$service_status" = "not-found" ]; then
        echo "ECS service ${service} does not exist in cluster ${cluster}. Skipping service resume."
        return 0
    fi
    
    echo "Resuming ECS service ${service} on cluster ${cluster}..."
    
    # Update scaling policy - temporarily disable error exit
    set +e
    aws application-autoscaling register-scalable-target \
        --service-namespace ecs \
        --resource-id "service/${cluster}/${service}" \
        --scalable-dimension ecs:service:DesiredCount \
        --min-capacity 1 \
        --max-capacity 2 \
        --no-cli-pager \
        --output json
    local scaling_result=$?
    set -e
    
    if [ $scaling_result -ne 0 ]; then
        echo "Warning: Failed to update scaling policy for ECS service ${service}"
    fi
    
    # Update service desired count
    set +e
    aws ecs update-service \
        --cluster "${cluster}" \
        --service "${service}" \
        --desired-count 1 \
        --no-cli-pager \
        --output json
    local update_result=$?
    set -e
    
    if [ $update_result -ne 0 ]; then
        echo "Failed to update ECS service ${service} desired count"
        return 1
    fi
        
    echo "ECS service has been resumed"
    return 0
}

# Main function
main() {
    local env=$1
    local prefix=$2
    
    echo "Starting to resume resources for environment: ${env} with stack prefix: ${prefix}"
    
    # Check DB cluster status
    local db_status=$(check_db_cluster "$prefix" "$env")
    echo "DB cluster status: ${db_status}"
    
    if [ "$db_status" = "not-found" ]; then
        echo "DB cluster does not exist - skipping DB operations"
    elif [ "$db_status" = "stopped" ]; then
        echo "DB cluster is stopped - starting it..."
        if start_db_cluster "$prefix" "$env"; then
            echo "DB cluster started successfully"
        else
            echo "Failed to start DB cluster"
            return 1
        fi
    elif [ "$db_status" = "available" ]; then
        echo "DB cluster is already available - no action needed"
    elif [ "$db_status" = "starting" ]; then
        echo "DB cluster is already starting - no action needed"
    else
        echo "DB cluster is in state: $db_status - no action taken"
    fi
    
    # Resume ECS service
    if resume_ecs_service "$prefix" "$env"; then
        echo "ECS service operations completed successfully"
    else
        echo "ECS service operations failed"
        return 1
    fi
    
    echo "Resources resume operations completed successfully"
}

# Parse and check arguments
ENVIRONMENT=${1}
STACK_PREFIX=${2}
check_parameters "$ENVIRONMENT" "$STACK_PREFIX"

# Execute main function
main "$ENVIRONMENT" "$STACK_PREFIX"