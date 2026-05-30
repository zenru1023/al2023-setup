#!/usr/bin/env bash
# al2023-setup/setup.sh
# Usage:
#   bash setup.sh
#   bash setup.sh --only kubectl,helm,k6
#   bash setup.sh --exclude docker,k9s
#   curl -fsSL https://raw.githubusercontent.com/zenru/al2023-setup/main/setup.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/zenru/al2023-setup/main/setup.sh | bash -s -- --only kubectl,helm

set -euo pipefail

# ─────────────────────────────────────────────
# Config
# ─────────────────────────────────────────────

REPO_RAW="https://raw.githubusercontent.com/zenru1023/al2023-setup/main"

# Canonical module order
ALL_MODULES=(docker kubectl helm eksctl k9s k6 yq jq terraform)

# ─────────────────────────────────────────────
# Colors / logging
# ─────────────────────────────────────────────

BOLD='\033[1m'
DIM='\033[2m'
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
CYAN='\033[36m'
RESET='\033[0m'

log_info()    { echo -e "${CYAN}${BOLD}[INFO]${RESET}  $*"; }
log_ok()      { echo -e "${GREEN}${BOLD}[ OK ]${RESET}  $*"; }
log_skip()    { echo -e "${DIM}[SKIP]  $*${RESET}"; }
log_warn()    { echo -e "${YELLOW}${BOLD}[WARN]${RESET}  $*"; }
log_error()   { echo -e "${RED}${BOLD}[ERR ]${RESET}  $*" >&2; }
log_section() { echo -e "\n${BOLD}━━━  $*  ━━━${RESET}"; }

die() { log_error "$*"; exit 1; }

# ─────────────────────────────────────────────
# Argument parsing
# ─────────────────────────────────────────────

ONLY_LIST=""
EXCLUDE_LIST=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --only)    [[ -n "${2:-}" ]] || die "--only requires a value"; ONLY_LIST="$2";    shift 2 ;;
    --only=*)  ONLY_LIST="${1#*=}";    shift ;;
    --exclude) [[ -n "${2:-}" ]] || die "--exclude requires a value"; EXCLUDE_LIST="$2"; shift 2 ;;
    --exclude=*) EXCLUDE_LIST="${1#*=}"; shift ;;
    --help|-h)
      echo "Usage: bash setup.sh [--only <modules>] [--exclude <modules>]"
      echo ""
      echo "Modules: ${ALL_MODULES[*]}"
      echo ""
      echo "Examples:"
      echo "  bash setup.sh                        # install everything"
      echo "  bash setup.sh --only kubectl,helm    # only these"
      echo "  bash setup.sh --exclude docker       # everything except docker"
      exit 0 ;;
    *) die "Unknown argument: $1  (run with --help)" ;;
  esac
done

[[ -n "$ONLY_LIST" && -n "$EXCLUDE_LIST" ]] && die "--only and --exclude are mutually exclusive"

# ─────────────────────────────────────────────
# Helpers
# ─────────────────────────────────────────────

csv_contains() {
  local list="$1" item="$2"
  echo "$list" | tr ',' '\n' | grep -qx "$item"
}

should_run() {
  local module="$1"
  if [[ -n "$ONLY_LIST" ]];    then csv_contains "$ONLY_LIST"    "$module" && return 0 || return 1; fi
  if [[ -n "$EXCLUDE_LIST" ]]; then csv_contains "$EXCLUDE_LIST" "$module" && return 1 || return 0; fi
  return 0
}

validate_module_list() {
  local list="$1" label="$2"
  [[ -z "$list" ]] && return
  while IFS= read -r name; do
    [[ -z "$name" ]] && continue
    local valid=false
    for m in "${ALL_MODULES[@]}"; do [[ "$m" == "$name" ]] && valid=true && break; done
    $valid || die "Unknown module '$name' in $label. Available: ${ALL_MODULES[*]}"
  done < <(echo "$list" | tr ',' '\n')
}

validate_module_list "$ONLY_LIST"    "--only"
validate_module_list "$EXCLUDE_LIST" "--exclude"

# ─────────────────────────────────────────────
# Module loader
# Load from local ./modules/ if available,
# otherwise fetch from GitHub raw.
# ─────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-./setup.sh}")" && pwd)"

load_module() {
  local name="$1"
  local local_path="$SCRIPT_DIR/modules/${name}.sh"

  if [[ -f "$local_path" ]]; then
    # shellcheck source=/dev/null
    source "$local_path"
  else
    log_info "Fetching module ${name}.sh from GitHub..."
    local url="${REPO_RAW}/modules/${name}.sh"
    local tmp_file
    tmp_file="$(mktemp /tmp/al2023-setup-${name}-XXXXXX.sh)"
    if ! curl -fsSL "$url" -o "$tmp_file"; then
      rm -f "$tmp_file"
      die "Failed to fetch module: $url"
    fi
    # shellcheck source=/dev/null
    source "$tmp_file"
    rm -f "$tmp_file"
  fi
}

main() {
  log_section "al2023-setup"

  # Build run / skip lists for display
  local to_run=() to_skip=()
  for m in "${ALL_MODULES[@]}"; do
    should_run "$m" && to_run+=("$m") || to_skip+=("$m")
  done

  echo -e "  ${GREEN}Run:${RESET}  ${to_run[*]:-none}"
  [[ ${#to_skip[@]} -gt 0 ]] && echo -e "  ${DIM}Skip: ${to_skip[*]}${RESET}"

  [[ ${#to_run[@]} -eq 0 ]] && { log_warn "Nothing to install."; exit 0; }

  log_info "Refreshing package index..."
  sudo dnf makecache --quiet 2>/dev/null

  local docker_installed=false

  for m in "${ALL_MODULES[@]}"; do
    should_run "$m" || continue
    log_section "$m"

    load_module "$m"   # sources install_<name>() and check_<name>()

    local current_version
    current_version="$(check_"${m}" 2>/dev/null || true)"

    if [[ -n "$current_version" ]]; then
      log_skip "$m already installed ($current_version)"
      continue
    fi

    if install_"${m}"; then
      current_version="$(check_"${m}" 2>/dev/null || echo "installed")"
      log_ok "$m ready ($current_version)"
      [[ "$m" == "docker" ]] && docker_installed=true
    else
      die "$m installation failed"
    fi
  done

  log_section "Done"
  echo -e "${GREEN}${BOLD}All selected modules installed successfully.${RESET}"

  $docker_installed && log_warn "Run 'newgrp docker' or re-login to use Docker without sudo."
}

main