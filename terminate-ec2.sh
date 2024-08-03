#!/bin/bash

# Path to the source file
SOURCE_FILE="source.sh"

# Ensure the source file exists
if [ ! -f "$SOURCE_FILE" ]; then
    echo "Source file $SOURCE_FILE does not exist."
    exit 1
fi

# Source the script to get functions and variables
source "$SOURCE_FILE"

# Retrieve EC2 instance IDs
INSTANCE_IDS=$(get_instance_ids)

# Terminate EC2 instances
if [ -n "$INSTANCE_IDS" ]; then
    echo "Terminating AWS instances..."
    aws ec2 terminate-instances --instance-ids $INSTANCE_IDS --region "$AWS_REGION"
    echo "AWS instances termination initiated."
else
    echo "No EC2 instance IDs found."
fi

# Retrieve Route 53 records
ROUTE53_RECORDS=$(get_route53_records)

# Delete Route 53 records
if [ -n "$ROUTE53_RECORDS" ]; then
    delete_route53_records "$ROUTE53_RECORDS"
    echo "Route 53 records deletion initiated."
else
    echo "No Route 53 records found."
fi