#!/bin/bash
# This script resumes AWS resources (ECS service and RDS Aurora cluster) in the specified AWS account.

set -e  # Exit on error

# Error handling function
error_handler() {
    local line=$1
    local func=$2
    echo "Error occurred at line ${line} in function ${func}"
    exit 1
}

# Set trap for error handling
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
    local status=$(aws rds describe-db-clusters --db-cluster-identifier ${cluster_id} --query 'DBClusters[0].Status' --output text 2>/dev/null || echo "not-found")
    echo "$status"
}

# Function to start DB cluster
start_db_cluster() {
    local prefix=$1
    local env=$2
    local cluster_id="${prefix}-aurora-${env}"
    
    echo "Starting DB cluster ${cluster_id}..."
    aws rds start-db-cluster --db-cluster-identifier ${cluster_id} --no-cli-pager --output json
    
    echo "Waiting for DB cluster to be available..."
    if ! aws rds wait db-cluster-available --db-cluster-identifier ${cluster_id}; then
        echo "Timeout waiting for DB cluster to become available"
        return 1
    fi
    
    echo "DB cluster is now available"
    return 0
}

# Function to resume ECS service
resume_ecs_service() {
    local prefix=$1
    local env=$2
    local cluster="${prefix}-node-api-${env}"
    local service="${prefix}-node-api-${env}"
    
    echo "Resuming ECS service ${service} on cluster ${cluster}..."
    # Check if the ECS cluster exists
    if ! aws ecs describe-clusters --clusters "${cluster}" --query 'clusters[0]' --output text &>/dev/null; then
        echo "ECS cluster ${cluster} does not exist. Skipping service resume."
        return 0
    fi

    # Check if the ECS service exists
    if ! aws ecs describe-services --cluster "${cluster}" --services "${service}" --query 'services[0]' --output text &>/dev/null; then
        echo "ECS service ${service} does not exist in cluster ${cluster}. Skipping service resume."
        return 0
    fi
    # Update scaling policy
    aws application-autoscaling register-scalable-target \
        --service-namespace ecs \
        --resource-id service/${cluster}/${service} \
        --scalable-dimension ecs:service:DesiredCount \
        --min-capacity 1 \
        --max-capacity 2 \
        --no-cli-pager \
        --output json
    
    # Update service desired count
    aws ecs update-service \
        --cluster ${cluster} \
        --service ${service} \
        --desired-count 1 \
        --no-cli-pager \
        --output json
        
    echo "ECS service has been resumed"
}

# Main function
main() {
    local env=$1
    local prefix=$2
    
    echo "Starting to resume resources for environment: ${env} with stack prefix: ${prefix}"
    
    # Check DB cluster status
    local db_status=$(check_db_cluster "$prefix" "$env")
    
    if [ "$db_status" == "not-found" ]; then
        echo "Skipping resume operation, DB cluster does not exist"
        return 0
    elif [ "$db_status" == "stopped" ]; then
        start_db_cluster "$prefix" "$env" || return 1
    else
        echo "DB cluster is not in a stopped state. Current state: $db_status"
    fi
    
    # Resume ECS service
    resume_ecs_service "$prefix" "$env"
    
    echo "Resources have been resumed successfully"
}

# Parse and check arguments
ENVIRONMENT=${1}
STACK_PREFIX=${2}
check_parameters "$ENVIRONMENT" "$STACK_PREFIX"

# Execute main function
main "$ENVIRONMENT" "$STACK_PREFIX"