# Troubleshooting

**GitLab EC2 up but web UI unreachable**
- Check `gitlab-ctl status` over SSH/SSM — give `gitlab-ctl reconfigure`
  a few minutes on first boot.
- Confirm the security group allows your IP/0.0.0.0/0 on 80/443 as expected.

**Runner Manager can't scale the ASG**
- Check `journalctl -u gitlab-runner -f` on the Runner Manager.
- Confirm `ASG_NAME`/`AWS_REGION` in `/etc/gitlab-runner/fleeting.env`
  (or however you've wired them into `config.toml`) match the real ASG name
  (`terraform output worker_asg_name`).
- Confirm the Runner Manager's IAM role has the `autoscaling:*` actions in
  `modules/iam` — least-privilege policies are the most common cause of
  silent scaling failures.

**Worker launches but jobs never start**
- Worker security group only allows SSH from the Runner Manager SG — if
  you changed that, jobs will hang waiting for a connection.
- Check `scripts/worker.sh` actually finished (`cloud-init status` on the
  worker) before the Runner Manager tries to SSH in.

**terraform apply fails on GitLab EC2 user_data**
- `templatefile()` paths in the modules are relative to the module
  directory (`${path.module}/../../../scripts/...`) — if you move the repo
  layout, update those paths.
