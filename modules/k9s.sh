#!/usr/bin/env bash
# modules/k9s.sh

check_k9s() {
  command -v k9s &>/dev/null && k9s version --short 2>/dev/null | head -1
}

install_k9s() {
  local arch arch_tag version url tmp_dir
  arch="$(uname -m)"
  case "$arch" in
    x86_64)  arch_tag="amd64" ;;
    aarch64) arch_tag="arm64" ;;
    *)       die "k9s: unsupported architecture: $arch" ;;
  esac

  version="$(curl -fsSL https://api.github.com/repos/derailed/k9s/releases/latest \
    | grep '"tag_name"' | cut -d'"' -f4)"
  url="https://github.com/derailed/k9s/releases/download/${version}/k9s_Linux_${arch_tag}.tar.gz"

  tmp_dir="$(mktemp -d)"
  trap 'rm -rf "$tmp_dir"' RETURN

  curl -fsSL "$url" -o "$tmp_dir/k9s.tar.gz"
  tar -xzf "$tmp_dir/k9s.tar.gz" -C "$tmp_dir" k9s
  sudo install -o root -g root -m 0755 "$tmp_dir/k9s" /usr/local/bin/k9s
}