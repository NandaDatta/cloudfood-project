#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${RED}⚠️  DESTROY SCRIPT - This will delete all AWS resources${NC}"
echo -e "${RED}⚠️  This action cannot be undone!${NC}"
echo -e "${YELLOW}Are you sure you want to continue? (yes/no)${NC}"
read -r response

if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo -e "${GREEN}Operation cancelled.${NC}"
    exit 0
fi

echo -e "${YELLOW}🔍 Checking AWS credentials...${NC}"
if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${RED}❌ Not logged into AWS. Please run 'aws configure' first.${NC}"
    exit 1
fi
echo -e "${GREEN}✅ AWS credentials verified${NC}"

echo -e "${YELLOW}🗑️  Destroying Terraform infrastructure...${NC}"

cd terraform

# Initialize if not already done
terraform init

# Destroy all resources
echo -e "${RED}Destroying all resources...${NC}"
terraform destroy -auto-approve

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Infrastructure destroyed successfully!${NC}"
else
    echo -e "${RED}❌ Failed to destroy infrastructure. Please check errors above.${NC}"
    exit 1
fi

cd ..

echo -e "${YELLOW}🧹 Cleaning up local Docker images...${NC}"

# Remove local images
docker rmi order-service:latest payment-service:latest 2>/dev/null || true

echo -e "${GREEN}🎉 Cleanup completed!${NC}"