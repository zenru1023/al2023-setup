#!/usr/bin/env bash
# modules/k6.sh

check_k6() {
  command -v k6 &>/dev/null && k6 version 2>&1 | head -1
}

install_k6() {
  sudo tee /etc/yum.repos.d/k6.repo > /dev/null << 'EOF'
[k6]
name=k6
baseurl=https://dl.k6.io/rpm/el8/$basearch
enabled=1
gpgcheck=0
EOF
  sudo dnf install -y k6
}