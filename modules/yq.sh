#!/usr/bin/env bash
# modules/yq.sh

check_yq() {
  command -v yq &>/dev/null && yq --version 2>&1
}

install_yq() {
  local arch arch_tag version url tmp_dir
  arch="$(uname -m)"
  case "$arch" in
    x86_64)  arch_tag="amd64" ;;
    aarch64) arch_tag="arm64" ;;
    *)       die "yq: unsupported architecture: $arch" ;;
  esac

  version="$(curl -fsSL https://api.github.com/repos/mikefarah/yq/releases/latest \
    | grep '"tag_name"' | cut -d'"' -f4)"
  url="https://github.com/mikefarah/yq/releases/download/${version}/yq_linux_${arch_tag}"

  tmp_dir="$(mktemp -d)"
  trap 'rm -rf "$tmp_dir"' RETURN

  curl -fsSL "$url" -o "$tmp_dir/yq"
  sudo install -o root -g root -m 0755 "$tmp_dir/yq" /usr/local/bin/yq
}