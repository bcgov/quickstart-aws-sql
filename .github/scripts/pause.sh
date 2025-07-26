#!/bin/bash
# This script pauses AWS resources (ECS service and RDS Aurora cluster) in the current AWS account.
# Made idempotent - safe to run multiple times, checks resource existence before acting.

set -euo pipefail  # Exit on error, undefined variables, and pipe failures

# Error handler function
function error_handler() {
    local script_name=$(basename "$0")
    echo "Error in script: $script_name"
    echo "Error occurred at line $LINENO in function ${FUNCNAME[1]}"
    exit 1
}

trap 'error_handler' ERR
# Parse arguments
ENVIRONMENT=${1}
STACK_PREFIX=${2}

# Validate required arguments
function validate_args() {
    if [ -z "$ENVIRONMENT" ]; then
        echo "Error: Environment is required as the first parameter"
        exit 1
    fi
    if [ -z "$STACK_PREFIX" ]; then
        echo "Error: Stack prefix is required as the second parameter"
        exit 1
    fi
}

# Check if Aurora DB cluster exists and get its status
function check_aurora_cluster() {
    local cluster_id="${STACK_PREFIX}-aurora-${ENVIRONMENT}"
    
    # Temporarily disable error exit for this check
    set +e
    local status=$(aws rds describe-db-clusters --db-cluster-identifier "$cluster_id" \
                  --query 'DBClusters[0].Status' --output text 2>/dev/null)
    local exit_code=$?
    set -e
    
    if [ $exit_code -ne 0 ]; then
        echo "not-found"
    else
        echo "$status"
    fi
}

# Pause Aurora DB cluster if available
function pause_aurora_cluster() {
    local cluster_id="${STACK_PREFIX}-aurora-${ENVIRONMENT}"
    local status=$1
    
    echo "Aurora cluster status: ${status}"
    
    if [ "$status" = "not-found" ]; then
        echo "Aurora cluster does not exist - skipping pause operation"
        return 0
    elif [ "$status" = "available" ]; then
        echo "Pausing Aurora cluster: $cluster_id"
        
        # Temporarily disable error exit for AWS command
        set +e
        aws rds stop-db-cluster --db-cluster-identifier "$cluster_id" --no-cli-pager --output json
        local stop_result=$?
        set -e
        
        if [ $stop_result -ne 0 ]; then
            echo "Failed to pause Aurora cluster: $cluster_id"
            return 1
        else
            echo "Aurora cluster pause initiated successfully"
        fi
    elif [ "$status" = "stopped" ]; then
        echo "Aurora cluster is already stopped - no action needed"
    elif [ "$status" = "stopping" ]; then
        echo "Aurora cluster is already stopping - no action needed"
    else
        echo "Aurora cluster is in state: $status - no action taken"
    fi
    
    return 0
}

# Check if ECS cluster exists
function check_ecs_cluster() {
    local cluster_name="${STACK_PREFIX}-node-api-${ENVIRONMENT}"
    
    # Temporarily disable error exit for this check
    set +e
    local status=$(aws ecs describe-clusters --clusters "$cluster_name" \
                  --query 'clusters[0].status' --output text 2>/dev/null)
    local exit_code=$?
    set -e
    
    if [ $exit_code -ne 0 ] || [ "$status" = "None" ] || [ -z "$status" ]; then
        echo "not-found"
    else
        echo "$status"
    fi
}

# Check if ECS service exists
function check_ecs_service() {
    local cluster_name="${STACK_PREFIX}-node-api-${ENVIRONMENT}"
    local service_name="${STACK_PREFIX}-node-api-${ENVIRONMENT}"
    
    # Temporarily disable error exit for this check
    set +e
    local status=$(aws ecs describe-services --cluster "$cluster_name" --services "$service_name" \
                  --query 'services[0].status' --output text 2>/dev/null)
    local exit_code=$?
    set -e
    
    if [ $exit_code -ne 0 ] || [ "$status" = "None" ] || [ -z "$status" ]; then
        echo "not-found"
    else
        echo "$status"
    fi
}

# Pause ECS service by setting min/max capacity to 0
function pause_ecs_service() {
    local cluster_name="${STACK_PREFIX}-node-api-${ENVIRONMENT}"
    local service_name="${STACK_PREFIX}-node-api-${ENVIRONMENT}"
    local cluster_status=$1
    
    echo "ECS cluster status: ${cluster_status}"
    
    if [ "$cluster_status" = "not-found" ]; then
        echo "ECS cluster $cluster_name does not exist - skipping pause operation"
        return 0
    fi
    
    if [ "$cluster_status" != "ACTIVE" ]; then
        echo "ECS cluster $cluster_name is not active (status: ${cluster_status}) - skipping pause operation"
        return 0
    fi
    
    local service_status=$(check_ecs_service)
    echo "ECS service status: ${service_status}"
    
    if [ "$service_status" = "not-found" ]; then
        echo "ECS service $service_name does not exist in cluster $cluster_name - skipping pause operation"
        return 0
    fi
    
    if [ "$service_status" = "ACTIVE" ]; then
        echo "Scaling down ECS service: $service_name"
        
        # Temporarily disable error exit for AWS command
        set +e
        aws application-autoscaling register-scalable-target \
            --service-namespace ecs \
            --resource-id "service/$cluster_name/$service_name" \
            --scalable-dimension ecs:service:DesiredCount \
            --min-capacity 0 \
            --max-capacity 0 \
            --no-cli-pager \
            --output json
        local scaling_result=$?
        set -e
        
        if [ $scaling_result -ne 0 ]; then
            echo "Failed to scale down ECS service: $service_name"
            return 1
        else
            echo "ECS service scaled down successfully"
        fi
    elif [ "$service_status" = "DRAINING" ]; then
        echo "ECS service is already draining - no action needed"
    else
        echo "ECS service is in state: $service_status - no action taken"
    fi
    
    return 0
}

# Main execution
validate_args

echo "Starting pause operations for environment: ${ENVIRONMENT} with stack prefix: ${STACK_PREFIX}"

# Check and pause Aurora cluster
aurora_status=$(check_aurora_cluster)
if pause_aurora_cluster "$aurora_status"; then
    echo "Aurora cluster operations completed successfully"
else
    echo "Aurora cluster operations failed"
    exit 1
fi

# Check and pause ECS service
ecs_status=$(check_ecs_cluster)
if pause_ecs_service "$ecs_status"; then
    echo "ECS service operations completed successfully"
else
    echo "ECS service operations failed"
    exit 1
fi

echo "All pause operations completed successfully"