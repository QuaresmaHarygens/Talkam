# Talkam Liberia Infrastructure

Infrastructure-as-Code for deploying Talkam Liberia to production.

## Components

- **Terraform**: AWS infrastructure (VPC, RDS, ElastiCache, S3)
- **Kubernetes**: Container orchestration (EKS-ready manifests)

## Prerequisites

- Terraform >= 1.0
- AWS CLI configured
- kubectl (for Kubernetes)
- AWS account with appropriate permissions

## Terraform Setup

### 1. Configure Variables

Create `terraform.tfvars`:
```hcl
aws_region      = "us-east-1"
db_instance_class = "db.t3.medium"
db_username     = "talkam"
db_password     = "YOUR_SECURE_PASSWORD"
redis_node_type = "cache.t3.micro"
s3_bucket_name  = "talkam-liberia-media-prod"
environment     = "production"
```

### 2. Initialize and Apply

```bash
cd infrastructure/terraform
terraform init
terraform plan
terraform apply
```

### 3. Get Outputs

```bash
terraform output db_endpoint
terraform output redis_endpoint
terraform output s3_bucket
```

## Kubernetes Deployment

### 1. Create Secrets

```bash
cd infrastructure/kubernetes
cp secrets.yaml.template secrets.yaml
# Edit secrets.yaml with actual values
kubectl create -f secrets.yaml
```

### 2. Deploy Application

```bash
kubectl apply -f deployment.yaml
kubectl get pods -w
```

### 3. Check Status

```bash
kubectl get services
kubectl get pods
kubectl logs -f deployment/talkam-api
```

## EKS Setup (Optional)

If using AWS EKS:

```bash
# Create EKS cluster
eksctl create cluster \
  --name talkam-liberia \
  --region us-east-1 \
  --node-type t3.medium \
  --nodes 3

# Configure kubectl
aws eks update-kubeconfig --name talkam-liberia --region us-east-1

# Deploy
kubectl apply -f infrastructure/kubernetes/
```

## Cost Estimation

Approximate monthly costs (AWS us-east-1):
- RDS db.t3.medium: ~$60
- ElastiCache cache.t3.micro: ~$15
- S3 storage (100GB): ~$2
- EKS cluster: ~$73
- EC2 nodes (3x t3.medium): ~$90
- **Total**: ~$240/month

## Backup & Disaster Recovery

### Database Backups

RDS automated backups are enabled (7-day retention). Manual snapshots:

```bash
aws rds create-db-snapshot \
  --db-instance-identifier talkam-liberia-db \
  --db-snapshot-identifier talkam-backup-$(date +%Y%m%d)
```

### S3 Lifecycle Policies

Configure lifecycle policies for media:
- Standard storage for 90 days
- Glacier after 90 days
- Delete after 2 years

## Monitoring

See `../artifacts/docs/monitoring-setup.md` for Prometheus/Grafana configuration.

## Security Notes

- Never commit `secrets.yaml` or `.tfvars` with real credentials
- Use AWS Secrets Manager or Vault in production
- Enable VPC flow logs
- Use WAF for API gateway
- Enable CloudTrail for audit logging
