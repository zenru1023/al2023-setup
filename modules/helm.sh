#!/usr/bin/env bash
# modules/helm.sh

check_helm() {
  command -v helm &>/dev/null && helm version --short
}

install_helm() {
  local tmp_dir
  tmp_dir="$(mktemp -d)"
  trap 'rm -rf "$tmp_dir"' RETURN

  curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4 \
    -o "$tmp_dir/get-helm.sh"
  bash "$tmp_dir/get-helm.sh"
}