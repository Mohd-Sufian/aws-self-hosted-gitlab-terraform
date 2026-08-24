#!/bin/bash
# ---------------------------------------------------------------------------
# CI Worker bootstrap - runs on every EC2 instance the Auto Scaling Group
# launches. Installs the GitLab Runner binary + CI dependencies only.
# It does NOT register itself with GitLab - the Instance Executor SSHes in
# and runs jobs directly, it doesn't need a registered runner on the box.
# ---------------------------------------------------------------------------
set -euxo pipefail

apt-get update -y
apt-get install -y curl git docker.io build-essential

curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | bash
apt-get install -y gitlab-runner

systemctl enable docker
systemctl start docker

echo "Worker bootstrap complete."
