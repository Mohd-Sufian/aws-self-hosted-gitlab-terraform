# Deployment

## Prerequisites

- Terraform >= 1.7
- An AWS account + credentials configured locally (`aws configure` or env vars)
- Your public IP, for `ssh_allowed_cidr`

## First apply

```bash
cd terraform/environments/prod
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars: ssh_allowed_cidr, gitlab_external_url, key_name, etc.

terraform init
terraform plan
terraform apply
```

`gitlab_external_url` needs the GitLab server's Elastic IP, which Terraform
only knows after the first apply. Two options:

1. Apply once with a placeholder URL, note the `gitlab_public_ip` output,
   update `gitlab_external_url` in `terraform.tfvars`, `terraform apply`
   again (GitLab will re-run `gitlab-ctl reconfigure` via a config change —
   or SSH in and run it manually to avoid a reboot).
2. Reserve an Elastic IP out of band first and hardcode it into
   `gitlab_external_url` from the start.

## Runner registration

The GitLab Runner registration token is **not** stored in Terraform or this
repo. On the Runner Manager instance:

```bash
# fetch the token securely (Secrets Manager, or copy-paste from
# GitLab Admin Area > CI/CD > Runners for a first pass)
gitlab-runner register \
  --non-interactive \
  --url "http://<gitlab-eip>" \
  --registration-token "<token>" \
  --executor "instance" \
  --name "aws-instance-executor"
```

Then configure the `[runners.autoscaler]` section of
`/etc/gitlab-runner/config.toml` to point the `fleeting-plugin-aws` at the
worker ASG (`ASG_NAME` / `AWS_REGION` are dropped into
`/etc/gitlab-runner/fleeting.env` by the bootstrap script as a starting
point) and restart `gitlab-runner`.

## Destroying

```bash
cd terraform/environments/prod
terraform destroy
```

## Remote state (recommended before this goes on GitHub long-term)

1. Create an S3 bucket for state (versioning + encryption enabled) by hand
   or in a one-off bootstrap `.tf`.
2. Uncomment the `backend "s3"` block in `backend.tf`, fill in the bucket
   name.
3. `terraform init -migrate-state`

## Next steps (intentionally out of scope for this first pass)

- Split workers across 2 AZs once single-AZ is validated end-to-end
- Packer pipeline (`packer/worker.pkr.hcl`) to bake CI dependencies into a
  worker AMI instead of installing them at boot
- HTTPS via Let's Encrypt once a domain points at the GitLab Elastic IP
- S3 GitLab backups + lifecycle policy
- CloudWatch dashboards/alarms for ASG capacity and instance health
- Spot instances for workers
- Secrets Manager for the runner registration token
