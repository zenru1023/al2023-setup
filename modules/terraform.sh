#!/usr/bin/env bash
# modules/terraform.sh

check_terraform() {
  command -v terraform &>/dev/null && terraform version | head -1
}

install_terraform() {
  sudo dnf install -y dnf-plugins-core
  sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
  sudo dnf install -y terraform

  local marker="# al2023-setup: terraform"
  if ! grep -qF "$marker" ~/.bashrc; then
    cat >> ~/.bashrc << 'BASHRC'

# al2023-setup: terraform
terraform -install-autocomplete 2>/dev/null || true
BASHRC
  fi
}