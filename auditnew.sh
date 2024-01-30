#!/bin/bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Function to print section headers
print_header() {
    echo -e "${GREEN}$1${NC}"
    echo "-----------------"
}

# Function to print key-value pairs
print_kv() {
    printf "${YELLOW}%-50s${NC} %s\n" "$1:" "$2"
}

# Function to print a separator line
print_separator() {
    echo "-----------------"
}

DATE=$(date +%m/%d/%Y)

print_big_header() {
    echo -e "\n*********************************************************************"
    echo -e "********************* SPOTLIGHT AUDIT $DATE*********************"
    echo -e "*********************************************************************\n"
}

print_big_header

# Elastic IP
print_header "Elastic IP"
VIRGINIA_EIP=$(aws ec2 describe-addresses --region us-east-1 --profile im --output json | jq -r '[.Addresses[] | select(.AssociationId == null)] | length')
OREGON_EIP=$(aws ec2 describe-addresses --region us-west-2 --profile im --output json | jq -r '[.Addresses[] | select(.AssociationId == null)] | length')
SUM_EIP=$(($VIRGINIA_EIP + $OREGON_EIP))

print_kv "Number of Unused EIPs in us-east-1 production" "$VIRGINIA_EIP"
print_kv "Number of Unused EIPs in us-west-2 Dev/Qa" "$OREGON_EIP"
print_kv "Total number of unused Elastic IPs " "$SUM_EIP"
print_separator

# EBS Volumes
print_header "EBS"
VIRGINIA_EBS=$(aws ec2 describe-volumes --query 'length(Volumes)' --output text --region us-east-1 --profile im)
OREGON_EBS=$(aws ec2 describe-volumes --query 'length(Volumes)' --output text --region us-west-2 --profile im)
SUM_EBS=$(($VIRGINIA_EBS + $OREGON_EBS))

print_kv "Number of EBS volumes in us-east-1 production" "$VIRGINIA_EBS"
print_kv "Number of EBS volumes in us-west-2 Dev/QA" "$OREGON_EBS"
print_kv "Total number of EBS volumes " "$SUM_EBS"
print_separator

# RDS Backup Verification
print_header "RDS Backup"
VIRGINIA_RDS=$(aws rds describe-db-snapshots --query 'DBSnapshots | sort_by(@, &SnapshotCreateTime) | [-1].SnapshotCreateTime' --output text --region us-east-1 --profile im | cut -c 1-10)
OREGON_RDS=$(aws rds describe-db-snapshots --query 'DBSnapshots | sort_by(@, &SnapshotCreateTime) | [-1].SnapshotCreateTime' --output text --region us-west-2 --profile im | cut -c 1-10)

print_kv "Latest RDS backup for us-east-1 production" "$VIRGINIA_RDS"
print_kv "Latest RDS backup for us-west-2 Dev/Qa" "$OREGON_RDS"
print_separator

# EBS Snapshot
print_header "EBS Snapshot"
VIRGINIA_EBS_SNAP=$(aws ec2 describe-snapshots --owner-ids self --query 'length(Snapshots)' --region us-east-1 --profile im)
OREGON_EBS_SNAP=$(aws ec2 describe-snapshots --owner-ids self --query 'length(Snapshots)' --region us-west-2 --profile im)
SUM_EBS_SNAP=$(( $VIRGINIA_EBS_SNAP + $OREGON_EBS_SNAP ))

print_kv "Number of EBS snapshots in us-east-1 production" "$VIRGINIA_EBS_SNAP"
print_kv "Number of EBS snapshots in us-west-2 DEv/Qa" "$OREGON_EBS_SNAP"
print_kv "Total number of EBS snapshots" "$SUM_EBS_SNAP"
print_separator

# AMI count
print_header "AMI"
VIRGINIA_AMI=$(aws ec2 describe-images --owner self --query 'length(Images)' --region us-east-1 --profile im)
OREGON_AMI=$(aws ec2 describe-images --owner self --query 'length(Images)' --region us-west-2 --profile im)
SUM_AMI=$(( $VIRGINIA_AMI + $OREGON_AMI ))

print_kv "Number of AMIs in us-east-1 production" "$VIRGINIA_AMI"
print_kv "Number of AMIs in us-west-2 Dev/Qa" "$OREGON_AMI"
print_kv "Total number of AMIs" "$SUM_AMI"
print_separator

#Load balancer
print_header "Load Balencer"
VIRGINIA_ALB=$(aws elbv2 describe-load-balancers --query "LoadBalancers[?State.Code == 'active'].LoadBalancerArn" --output text --profile im --region us-east-1 |   tr '\t' '\n' |   xargs -I {} aws elbv2 describe-listeners --load-balancer-arn {} --query "Listeners[?DefaultActions[?Type == 'forward' && TargetGroupArn == null]].ListenerArn" --output text --profile im --region us-east-1 |   wc -w)
OREGON_ALB=$(aws elbv2 describe-load-balancers --query "LoadBalancers[?State.Code == 'active'].LoadBalancerArn" --output text --profile im --region us-west-2 |   tr '\t' '\n' |   xargs -I {} aws elbv2 describe-listeners --load-balancer-arn {} --query "Listeners[?DefaultActions[?Type == 'forward' && TargetGroupArn == null]].ListenerArn" --output text --profile im --region us-west-2 |   wc -w)

print_kv "Number of unused Loadbalancers in us-east-1 production:" "$VIRGINIA_ALB"
print_kv "Number of unused Loadbalancers in us-west-2 Dev/Qa:" "$OREGON_ALB"
print_separator

#IAM Audit
print_header "IAM Users"
VIRGINIA_IAM_COUNT=$(aws iam list-users --output json --profile im --region us-east-1|   jq -r '.Users[] | select((.PasswordLastUsed == null or ((now - (.PasswordLastUsed | strptime("%Y-%m-%dT%H:%M:%S%z") | mktime)) / 86400) >= 90)) | .UserName' |wc -l)
VIRGINIA_IAM_USERS=$(aws iam list-users --output json --profile im --region us-east-1|   jq -r '.Users[] | select((.PasswordLastUsed == null or ((now - (.PasswordLastUsed | strptime("%Y-%m-%dT%H:%M:%S%z") | mktime)) / 86400) >= 90)) | .UserName')

print_kv "NUmber of users that haven't used password for 90 days or more" "$VIRGINIA_IAM_COUNT"
print_kv "List of users that haven't used password for 90 days or more" 
echo "$VIRGINIA_IAM_USERS"
print_separator

