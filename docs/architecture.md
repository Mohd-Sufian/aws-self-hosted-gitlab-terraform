# Architecture

Everything lives in a **single public AZ** (default `ap-south-1a`), by
design — this is a deliberate simplification from the original two-AZ
proposal, at the cost of AZ-level redundancy.

```
                              Internet
                                  │
                                  ▼
                        ┌───────────────────┐
                        │   Internet GW     │
                        └─────────┬─────────┘
                                  │
                                  ▼
                         Public Subnet (1 AZ)
                                  │
                 ┌────────────────┼────────────────┐
                 ▼                ▼                 ▼
          GitLab Server    Runner Manager      Worker ASG
              EC2               EC2           (0-3 EC2, same AZ)
                                  │                 ▲
                                  ▼                 │
                            Instance Executor ──────┘
                            + AWS Fleeting
```

## Components

| Component | Terraform module | Purpose |
|---|---|---|
| Networking | `modules/networking` | VPC, 1 public subnet, IGW, route table |
| Security | `modules/security` | 3 security groups: gitlab, runner-manager, worker |
| IAM | `modules/iam` | Runner Manager role (Fleeting/ASG control), Worker role (minimal) |
| GitLab | `modules/gitlab` | GitLab CE EC2 + Elastic IP + EBS |
| Runner Manager | `modules/runner-manager` | GitLab Runner + Fleeting plugin, Instance Executor |
| Worker | `modules/runner-worker` | Launch Template + Auto Scaling Group (min 0, max 3) |

## Worker lifecycle

```
No jobs → 0 workers
Pipeline starts → 1 worker launched (build → test → lint → deploy on the
same instance) → worker goes idle → worker terminated
```

The Runner Manager scales the ASG's desired capacity up and down via the
AWS Fleeting plugin — Terraform only defines the ASG's *bounds*
(`worker_min_size` / `worker_max_size`), not its live desired capacity.

## Deliberately deferred (see "Next steps" in deployment.md)

- Multi-AZ worker pool
- HTTPS + custom domain
- Packer-baked worker AMI (workers currently bootstrap via `scripts/worker.sh` at boot)
- S3 backups, CloudWatch monitoring, Spot workers
- Secrets Manager-backed runner token retrieval
