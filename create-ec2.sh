#!/bin/bash

# Variables
INSTANCE_NAME="elk"
PUBLIC_NAME="elk"
PRIVATE_NAME="elks"
DOMAIN_NAME="neelareddy.store"
HOSTED_ZONE_ID="Z001712433NLPH2AI8HH5"
AMI_ID="ami-041e2ea9402c46c32"
INSTANCE_TYPE="t3.medium"
SECURITY_GROUP_ID="sg-0cd5626364cf1e071"
SUBNET_ID="subnet-045b66b79d1f5cc3f"

# Launch instance
echo "Creating instance..."
INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID --instance-type $INSTANCE_TYPE --security-group-ids $SECURITY_GROUP_ID --subnet-id $SUBNET_ID --query 'Instances[0].InstanceId' --output text)
echo "Instance created: $INSTANCE_ID"

# Tag the instance
aws ec2 create-tags --resources $INSTANCE_ID --tags Key=Name,Value=$INSTANCE_NAME

# Wait for the instance to be in running state
aws ec2 wait instance-running --instance-ids $INSTANCE_ID

# Get public and private IP addresses
PUBLIC_IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
PRIVATE_IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
echo "Public IP: $PUBLIC_IP"
echo "Private IP: $PRIVATE_IP"

# Create Route 53 record for public IP
echo "Creating Route 53 record for public IP..."
aws route53 change-resource-record-sets --hosted-zone-id $HOSTED_ZONE_ID --change-batch '{
    "Comment": "Creating a record set for public IP",
    "Changes": [{
        "Action": "UPSERT",
        "ResourceRecordSet": {
            "Name": "'$INSTANCE_NAME'.'$DOMAIN_NAME'",
            "Type": "A",
            "TTL": 300,
            "ResourceRecords": [{"Value": "'$PUBLIC_IP'"}]
        }
    }]
}'

# Create Route 53 record for private IP
echo "Creating Route 53 record for private IP..."
aws route53 change-resource-record-sets --hosted-zone-id $HOSTED_ZONE_ID --change-batch '{
    "Comment": "Creating a record set for private IP",
    "Changes": [{
        "Action": "UPSERT",
        "ResourceRecordSet": {
            "Name": "private-'$INSTANCE_NAME'.'$DOMAIN_NAME'",
            "Type": "A",
            "TTL": 1,
            "ResourceRecords": [{"Value": "'$PRIVATE_IP'"}]
        }
    }]
}'

echo "DNS records created successfully."