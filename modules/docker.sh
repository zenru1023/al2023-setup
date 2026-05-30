#!/usr/bin/env bash
# modules/docker.sh

check_docker() {
  command -v docker &>/dev/null && docker --version
}

install_docker() {
  sudo dnf install -y docker
  sudo systemctl enable --now docker
  local user="${SUDO_USER:-${USER:-ec2-user}}"
  sudo usermod -aG docker "$user"
}