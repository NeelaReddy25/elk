# Define AWS region
AWS_REGION="us-east-1"

# Define Route 53 Hosted Zone ID (if needed)
HOSTED_ZONE_ID="Z001712433NLPH2AI8HH5"

# Function to get EC2 instance IDs
get_instance_ids() {
    echo "Retrieving EC2 instance IDs..."
    aws ec2 describe-instances --query 'Reservations[*].Instances[*].InstanceId' --output text --region "$AWS_REGION"
}

# Function to get Route 53 record sets
get_route53_records() {
    echo "Retrieving Route 53 records..."
    aws route53 list-resource-record-sets --hosted-zone-id "$HOSTED_ZONE_ID" --query 'ResourceRecordSets[*].[Name,Type,TTL,ResourceRecords]' --output text --region "$AWS_REGION"
}

# Function to delete Route 53 records
delete_route53_records() {
    local records="$1"
    echo "Deleting Route 53 records..."
    
    # Create a JSON file for the change batch
    CHANGE_BATCH_FILE=$(mktemp)
    echo '{"Changes": [' > "$CHANGE_BATCH_FILE"
    
    while IFS=$'\t' read -r NAME TYPE TTL VALUE; do
        echo "{\"Action\": \"DELETE\", \"ResourceRecordSet\": {\"Name\": \"$NAME\", \"Type\": \"$TYPE\", \"TTL\": $TTL, \"ResourceRecords\": [{\"Value\": \"$VALUE\"}]}}" >> "$CHANGE_BATCH_FILE"
        echo ',' >> "$CHANGE_BATCH_FILE"
    done <<< "$records"
    
    # Remove trailing comma and close JSON array
    sed -i '$ s/,$//' "$CHANGE_BATCH_FILE"
    echo ']}' >> "$CHANGE_BATCH_FILE"
    
    # Apply the change batch to Route 53
    aws route53 change-resource-record-sets --hosted-zone-id "$HOSTED_ZONE_ID" --change-batch file://"$CHANGE_BATCH_FILE" --region "$AWS_REGION"
    
    # Clean up
    rm "$CHANGE_BATCH_FILE"
}

# Export functions for main script
export -f get_instance_ids
export -f get_route53_records
export -f delete_route53_records