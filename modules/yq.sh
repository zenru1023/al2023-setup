#!/usr/bin/env bash
# modules/yq.sh

check_yq() {
  command -v yq &>/dev/null && yq --version 2>&1
}

install_yq() {
  sudo dnf install -y yq
}