#!/usr/bin/env bash
# modules/jq.sh

check_jq() {
  command -v jq &>/dev/null && jq --version
}

install_jq() {
  sudo dnf install -y jq
}