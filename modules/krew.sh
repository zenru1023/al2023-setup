#!/usr/bin/env bash
# modules/krew.sh

check_krew() {
  kubectl krew version &>/dev/null && kubectl krew version 2>/dev/null | awk '/GitTag/{print $2}'
}

install_krew() {
  command -v kubectl &>/dev/null || die "krew requires kubectl — install kubectl first"

  local arch os tmp_dir krew_tar krew_bin
  case "$(uname -m)" in
    x86_64)  arch="amd64" ;;
    aarch64) arch="arm64" ;;
    *)       die "krew: unsupported architecture: $(uname -m)" ;;
  esac
  os="$(uname -s | tr '[:upper:]' '[:lower:]')"

  tmp_dir="$(mktemp -d)"
  krew_tar="${tmp_dir}/krew.tar.gz"

  local version
  version="$(curl -fsSL https://api.github.com/repos/kubernetes-sigs/krew/releases/latest \
    | grep '"tag_name"' | cut -d'"' -f4)"

  curl -fsSL \
    "https://github.com/kubernetes-sigs/krew/releases/download/${version}/krew-${os}_${arch}.tar.gz" \
    -o "$krew_tar"

  tar -xzf "$krew_tar" -C "$tmp_dir"
  krew_bin="${tmp_dir}/krew-${os}_${arch}"

  "$krew_bin" install krew
  rm -rf "$tmp_dir"

  local marker="# al2023-setup: krew"
  if ! grep -qF "$marker" ~/.bashrc; then
    cat >> ~/.bashrc << 'BASHRC'

# al2023-setup: krew
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
BASHRC
  fi

  export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
}