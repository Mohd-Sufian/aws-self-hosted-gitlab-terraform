# aws-self-hosted-gitlab

Self-hosted GitLab CE on AWS, provisioned entirely with Terraform: GitLab
server + Runner Manager + a dynamically-scaled EC2 worker Auto Scaling
Group (GitLab Runner Instance Executor + AWS Fleeting plugin).

**Single-AZ by design** — everything (VPC, subnet, GitLab, Runner Manager,
worker ASG) runs in one Availability Zone (default `ap-south-1a`). See
[docs/architecture.md](docs/architecture.md) for the diagram and the
multi-AZ upgrade path.

```
Terraform → AWS infrastructure → GitLab Server + Runner Manager →
Dynamic EC2 CI workers → GitLab pipeline
```

`terraform apply` builds the whole environment from zero; `terraform
destroy` tears it down cleanly.

## Repo layout

```
terraform/
├── environments/prod/     # root module: wires everything together
└── modules/
    ├── networking/         # VPC, 1 public subnet, IGW, route table
    ├── security/            # gitlab / runner-manager / worker security groups
    ├── iam/                  # runner-manager role + worker role
    ├── gitlab/                # GitLab CE EC2 + EIP + EBS
    ├── runner-manager/        # Runner Manager EC2
    └── runner-worker/         # Launch Template + Auto Scaling Group

scripts/            # EC2 user-data: gitlab-server.sh, runner-manager.sh, worker.sh
gitlab/.gitlab-ci.yml # example pipeline for the instance executor
packer/worker.pkr.hcl # placeholder for a future baked worker AMI
docs/                # architecture, deployment, security, troubleshooting
```

## Quick start

```bash
cd terraform/environments/prod
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars — at minimum set ssh_allowed_cidr to your IP

terraform init
terraform plan
terraform apply
```

Full walkthrough, including runner registration, in
[docs/deployment.md](docs/deployment.md).

## Status

Implemented: networking, security groups, IAM, GitLab EC2, Runner Manager
EC2, worker Launch Template + ASG (boot-time bootstrap, no Packer yet).

Deferred, tracked in [docs/deployment.md](docs/deployment.md) "Next
steps": multi-AZ, HTTPS/domain, Packer worker AMI, backups, CloudWatch,
Spot workers, Secrets Manager for the runner token.
