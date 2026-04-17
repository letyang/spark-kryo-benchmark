#!/bin/bash
# deploy.sh - Deploy EMR cluster using CloudFormation

set -e

STACK_NAME="kryo-benchmark-$(date +%Y%m%d-%H%M%S)"
TEMPLATE_FILE="emr-cluster-template.yaml"
PARAMETERS_FILE="emr-cluster-parameters.json"
REGION=${AWS_DEFAULT_REGION:-"us-east-1"}

echo "=========================================="
echo "Deploying EMR Cluster for Kryo Benchmark"
echo "=========================================="
echo "Stack name: $STACK_NAME"
echo "Region: $REGION"
echo ""

# Check if AWS CLI is configured
if ! aws sts get-caller-identity &>/dev/null; then
    echo "ERROR: AWS CLI not configured. Please run 'aws configure' first."
    exit 1
fi

# Validate template
echo "Validating CloudFormation template..."
aws cloudformation validate-template \
    --template-body file://$TEMPLATE_FILE \
    --region $REGION

if [ $? -ne 0 ]; then
    echo "Template validation failed!"
    exit 1
fi
echo "Template validation successful"
echo ""

# Check if parameters file exists
if [ ! -f "$PARAMETERS_FILE" ]; then
    echo "ERROR: Parameters file not found: $PARAMETERS_FILE"
    exit 1
fi

# Deploy stack
echo "Deploying stack..."
aws cloudformation create-stack \
    --stack-name $STACK_NAME \
    --template-body file://$TEMPLATE_FILE \
    --parameters file://$PARAMETERS_FILE \
    --capabilities CAPABILITY_IAM \
    --region $REGION

echo ""
echo "Waiting for stack creation to complete..."
echo "This may take 10-15 minutes..."

# Wait for stack completion
aws cloudformation wait stack-create-complete \
    --stack-name $STACK_NAME \
    --region $REGION

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Stack deployment successful!"
else
    echo ""
    echo "❌ Stack deployment failed!"
    echo "Check the CloudFormation console for details."
    exit 1
fi

# Get outputs
echo ""
echo "Stack Outputs:"
aws cloudformation describe-stacks \
    --stack-name $STACK_NAME \
    --region $REGION \
    --query 'Stacks[0].Outputs' \
    --output table

# Save cluster ID for later use
CLUSTER_ID=$(aws cloudformation describe-stacks \
    --stack-name $STACK_NAME \
    --region $REGION \
    --query 'Stacks[0].Outputs[?OutputKey==`ClusterId`].OutputValue' \
    --output text)

echo $CLUSTER_ID > cluster-id.txt

echo ""
echo "=========================================="
echo "DEPLOYMENT COMPLETE"
echo "=========================================="
echo "Cluster ID: $CLUSTER_ID"
echo "Cluster ID saved to: cluster-id.txt"
echo ""
echo "To SSH to master node:"
echo "  aws emr ssh --cluster-id $CLUSTER_ID --key-pair-file your-key.pem"
echo ""
echo "To view Spark UI:"
echo "  aws emr describe-cluster --cluster-id $CLUSTER_ID --query 'Cluster.MasterPublicDnsName' --output text"
echo "  Then open: http://<master-dns>:8088"
echo ""
echo "To terminate cluster when done:"
echo "  aws emr terminate-clusters --cluster-ids $CLUSTER_ID"
echo "  aws cloudformation delete-stack --stack-name $STACK_NAME"
echo "=========================================="