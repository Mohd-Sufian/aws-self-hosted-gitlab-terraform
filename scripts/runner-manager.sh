#!/bin/bash
# ---------------------------------------------------------------------------
# Runner Manager bootstrap - installs GitLab Runner + configures the
# Instance Executor with the AWS Fleeting plugin, pointed at the worker ASG.
#
# Templated by Terraform:
#   ${aws_region}            - region the ASG lives in
#   ${asg_name}               - name of the worker Auto Scaling Group
#   ${worker_ssh_user}        - SSH user baked into the worker AMI/user-data
#
# NOTE: the GitLab Runner registration token is intentionally NOT baked in
# here. Fetch it securely at boot (e.g. from AWS Secrets Manager) and run
# `gitlab-runner register` manually or from a follow-up SSM command - see
# docs/deployment.md, "Runner registration", for the recommended flow.
# ---------------------------------------------------------------------------
set -euxo pipefail

apt-get update -y
apt-get install -y curl git openssh-client unzip

curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | bash
apt-get install -y gitlab-runner

# AWS Fleeting plugin for GitLab Runner
mkdir -p /root/.config/gitlab-runner/plugins
curl -L -o /usr/local/bin/fleeting-plugin-aws \
  "https://gitlab.com/gitlab-org/fleeting/plugins/aws/-/releases/permalink/latest/downloads/fleeting-plugin-aws-linux-amd64"
chmod +x /usr/local/bin/fleeting-plugin-aws

cat <<CFG > /etc/gitlab-runner/fleeting.env
AWS_REGION=${aws_region}
ASG_NAME=${asg_name}
WORKER_SSH_USER=${worker_ssh_user}
CFG

echo "Runner Manager base install complete."
echo "Next: fetch the runner registration token securely and run:"
echo "  gitlab-runner register --url <gitlab-url> --executor instance ..."
echo "See docs/deployment.md for the full instance-executor config.toml block."
