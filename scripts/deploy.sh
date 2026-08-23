#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Starting Deployment Process...${NC}"

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo -e "${RED}❌ AWS CLI not found. Please install it first.${NC}"
    exit 1
fi

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}❌ Terraform not found. Please install it first.${NC}"
    exit 1
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker not found. Please install it first.${NC}"
    exit 1
fi

# Check if user is logged into AWS
echo -e "${YELLOW}🔍 Checking AWS credentials...${NC}"
if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${RED}❌ Not logged into AWS. Please run 'aws configure' first.${NC}"
    exit 1
fi
echo -e "${GREEN}✅ AWS credentials verified${NC}"

# Get AWS account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION="us-east-1"

echo -e "${YELLOW}📦 Building Docker images...${NC}"

# Build Order Service
echo -e "${GREEN}Building Order Service...${NC}"
cd app/order-service
docker build -t order-service:latest .
cd ../..

# Build Payment Service
echo -e "${GREEN}Building Payment Service...${NC}"
cd app/payment-service
docker build -t payment-service:latest .
cd ../..

echo -e "${YELLOW}🐳 Tagging images for ECR...${NC}"

# Tag Order Service
docker tag order-service:latest ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/cloudfood-order-service:latest

# Tag Payment Service
docker tag payment-service:latest ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/cloudfood-payment-service:latest

echo -e "${YELLOW}🔑 Logging into ECR...${NC}"
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

echo -e "${YELLOW}📤 Pushing images to ECR...${NC}"

# Push Order Service
echo -e "${GREEN}Pushing Order Service...${NC}"
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/cloudfood-order-service:latest

# Push Payment Service
echo -e "${GREEN}Pushing Payment Service...${NC}"
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/cloudfood-payment-service:latest

echo -e "${YELLOW}🏗️  Deploying Infrastructure with Terraform...${NC}"

cd terraform

# Initialize Terraform
echo -e "${GREEN}Initializing Terraform...${NC}"
terraform init

# Validate Terraform files
echo -e "${GREEN}Validating Terraform configuration...${NC}"
terraform validate

# Create terraform.tfvars if not exists
if [ ! -f "terraform.tfvars" ]; then
    echo -e "${YELLOW}Creating terraform.tfvars file...${NC}"
    cat > terraform.tfvars << 'TFVARS'
db_username = "admin"
db_password = "YourStrongPassword123!"
TFVARS
    echo -e "${YELLOW}⚠️  Please update terraform.tfvars with your actual values!${NC}"
fi

# Plan Terraform
echo -e "${GREEN}Creating Terraform plan...${NC}"
terraform plan -out=tfplan

# Apply Terraform
echo -e "${YELLOW}Apply Terraform? (y/n)${NC}"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo -e "${GREEN}Applying Terraform...${NC}"
    terraform apply tfplan
    
    # Get ALB DNS
    ALB_DNS=$(terraform output -raw alb_dns_name 2>/dev/null || echo "Not available yet")
    
    echo -e "${GREEN}✅ Deployment Complete!${NC}"
    echo -e "${GREEN}🌐 Access your service at: http://${ALB_DNS}${NC}"
else
    echo -e "${YELLOW}Deployment cancelled.${NC}"
fi

cd ..

echo -e "${GREEN}🎉 Script execution completed!${NC}"