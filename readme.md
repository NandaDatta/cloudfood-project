# CloudFood Project - DevOps Demo

## 🚀 Simple Express Microservice with AWS DevOps

### Services Used:
- **ECR** - Container Registry
- **ECS Fargate** - Container Orchestration
- **RDS** - Managed MySQL Database
- **ALB** - Load Balancer
- **Terraform** - Infrastructure as Code
- **GitHub Actions** - CI/CD Pipeline
- **Docker** - Containerization

## Local Development

```bash
# Start services
docker-compose -f docker/local/docker-compose.yml up

# Test order service
curl http://localhost:5000

# Test payment service
curl http://localhost:5001