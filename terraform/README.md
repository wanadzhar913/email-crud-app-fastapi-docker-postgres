# Terraform layout

| Directory | Purpose | State |
|-----------|---------|--------|
| [`bootstrap/`](bootstrap/) | S3 bucket for remote Terraform state | Local |
| [`deploy/`](deploy/) | ECS, ALB, RDS, ECR, VPC, IAM | S3 (`backend.hcl`) |

**Deploy** (application infrastructure):

```bash
cd deploy
cp terraform.tfvars.example terraform.tfvars
cp backend.hcl.example backend.hcl   # after bootstrap apply
terraform init -backend-config=backend.hcl
terraform apply
```

See [DEPLOYMENT.md](../DEPLOYMENT.md) for the full guide.

### Optional (commented templates in `deploy/`)

| File | Enables |
|------|---------|
| [`deploy/optional_route53.tf`](deploy/optional_route53.tf) | Custom domain, Route 53 alias → ALB, ACM + HTTPS |
| [`deploy/optional_private_networking.tf`](deploy/optional_private_networking.tf) | NAT Gateway, private route tables, ECS in private subnets, VPC endpoints |

These files are **documentation only** (all HCL is commented). Uncomment sections and wire variables when you need them.

### IAM for local `terraform apply`

If `terraform apply` fails with `AccessDeniedException` for `terraform-user`, see [DEPLOYMENT.md § IAM permissions](../DEPLOYMENT.md#iam-permissions-for-terraform-apply) and attach [`deploy/terraform-user-iam-policy.json`](deploy/terraform-user-iam-policy.json) (or `AdministratorAccess` on a sandbox account).
