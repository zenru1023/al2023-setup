#!/usr/bin/env bash
# modules/k6.sh

check_k6() {
  command -v k6 &>/dev/null && k6 version 2>&1 | head -1
}

install_k6() {
  sudo dnf install -y https://dl.k6.io/rpm/repo.rpm
  sudo dnf install -y k6
}