#!/bin/bash
# This script pauses AWS resources (ECS service and RDS Aurora cluster) in the current AWS account.

set -e  # Exit on error
trap 'echo "Error occurred at line $LINENO while executing function $FUNCNAME"' ERR
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
    local status=$(aws rds describe-db-clusters --db-cluster-identifier "$cluster_id" \
                  --query 'DBClusters[0].Status' --output text 2>/dev/null || echo "false")
    echo "$status"
}

# Pause Aurora DB cluster if available
function pause_aurora_cluster() {
    local cluster_id="${STACK_PREFIX}-aurora-${ENVIRONMENT}"
    local status=$1
    
    if [ "$status" = "false" ]; then
        echo "Skipping Aurora pause operation: DB cluster does not exist"
        return
    elif [ "$status" = "available" ]; then
        echo "Pausing Aurora cluster: $cluster_id"
        aws rds stop-db-cluster --db-cluster-identifier "$cluster_id" --no-cli-pager --output json
    else
        echo "DB cluster is not in an available state. Current state: $status"
    fi
}

# Check if ECS cluster exists
function check_ecs_cluster() {
    local cluster_name="ecs-cluster-${STACK_PREFIX}-node-api-${ENVIRONMENT}"
    local status=$(aws ecs describe-clusters --clusters "$cluster_name" \
                  --query 'clusters[0].status' --output text 2>/dev/null || echo "INACTIVE")
    echo "$status"
}

# Pause ECS service by setting min/max capacity to 0
function pause_ecs_service() {
    local cluster_name="ecs-cluster-${STACK_PREFIX}-node-api-${ENVIRONMENT}"
    local service_name="${STACK_PREFIX}-node-api-${ENVIRONMENT}-service"
    local cluster_status=$1
    
    if [ "$cluster_status" != "ACTIVE" ]; then
        echo "Skipping ECS pause operation: Cluster $cluster_name does not exist"
        return
    fi
    
    local service_status=$(aws ecs describe-services --cluster "$cluster_name" --services "$service_name" \
                          --query 'services[0].status' --output text 2>/dev/null || echo "INACTIVE")
    
    if [ "$service_status" = "ACTIVE" ]; then
        echo "Scaling down ECS service: $service_name"
        aws application-autoscaling register-scalable-target \
            --service-namespace ecs \
            --resource-id "service/$cluster_name/$service_name" \
            --scalable-dimension ecs:service:DesiredCount \
            --min-capacity 0 \
            --max-capacity 0 \
            --no-cli-pager \
            --output json
    else
        echo "ECS service $service_name does not exist in cluster $cluster_name"
    fi
}

# Main execution
validate_args

# Check and pause Aurora cluster
aurora_status=$(check_aurora_cluster)
[ "$aurora_status" = "false" ] || echo "Aurora cluster status: $aurora_status"

# Check and pause ECS service
ecs_status=$(check_ecs_cluster)
[ "$ecs_status" = "INACTIVE" ] || echo "ECS cluster status: $ecs_status"

# Perform pause operations
pause_ecs_service "$ecs_status"
pause_aurora_cluster "$aurora_status"

echo "Pause operations completed"