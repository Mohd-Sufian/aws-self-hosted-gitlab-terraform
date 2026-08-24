#!/bin/bash
# ---------------------------------------------------------------------------
# GitLab CE bootstrap script - runs as EC2 user-data on Ubuntu 24.04.
# Templated by Terraform: ${gitlab_external_url}
# ---------------------------------------------------------------------------
set -euxo pipefail

apt-get update -y
apt-get upgrade -y
apt-get install -y curl openssh-server ca-certificates tzdata perl postfix

curl -sS https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | bash

EXTERNAL_URL="${gitlab_external_url}" apt-get install -y gitlab-ce

gitlab-ctl reconfigure
gitlab-ctl status

echo "GitLab bootstrap complete. Initial root password (first 24h only):"
echo "  cat /etc/gitlab/initial_root_password"
