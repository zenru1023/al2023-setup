#!/usr/bin/env bash
# modules/eksctl.sh

check_eksctl() {
  command -v eksctl &>/dev/null && eksctl version
}

install_eksctl() {
  local arch platform url tmp_dir
  case "$(uname -m)" in
    x86_64)  arch="amd64" ;;
    aarch64) arch="arm64" ;;
    *)       die "eksctl: unsupported architecture: $(uname -m)" ;;
  esac
  platform="$(uname -s)_${arch}"
  url="https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_${platform}.tar.gz"

  tmp_dir="$(mktemp -d)"
  curl -fsSL "$url" -o "$tmp_dir/eksctl.tar.gz"
  tar -xzf "$tmp_dir/eksctl.tar.gz" -C "$tmp_dir"
  sudo install -o root -g root -m 0755 "$tmp_dir/eksctl" /usr/local/bin/eksctl
  rm -rf "$tmp_dir"
}