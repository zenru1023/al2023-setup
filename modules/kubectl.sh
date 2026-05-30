#!/usr/bin/env bash
# modules/kubectl.sh

check_kubectl() {
  command -v kubectl &>/dev/null && kubectl version --client --short 2>/dev/null | head -1
}

install_kubectl() {
  local arch url version tmp_dir
  arch="$(uname -m)"
  version="$(curl -fsSL https://dl.k8s.io/release/stable.txt)"

  case "$arch" in
    x86_64)  url="https://dl.k8s.io/release/${version}/bin/linux/amd64/kubectl" ;;
    aarch64) url="https://dl.k8s.io/release/${version}/bin/linux/arm64/kubectl" ;;
    *)       die "kubectl: unsupported architecture: $arch" ;;
  esac

  tmp_dir="$(mktemp -d)"
  trap 'rm -rf "$tmp_dir"' RETURN

  curl -fsSL "$url" -o "$tmp_dir/kubectl"
  sudo install -o root -g root -m 0755 "$tmp_dir/kubectl" /usr/local/bin/kubectl
}