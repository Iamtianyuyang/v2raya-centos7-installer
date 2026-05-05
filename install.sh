#!/usr/bin/env bash
set -euo pipefail

# ── helpers ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info()  { echo -e "${GREEN}[INFO]${NC}  $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*" >&2; exit 1; }

require_root() {
    [[ $EUID -eq 0 ]] || error "Run as root or via sudo."
}

require_cmd() {
    command -v "$1" &>/dev/null || error "Required command not found: $1"
}

# ── fetch latest release tag from GitHub API ──────────────────────────────────
latest_tag() {
    local repo="$1"
    curl -fsSL "https://api.github.com/repos/${repo}/releases/latest" \
        | grep '"tag_name"' | head -1 | sed 's/.*"tag_name": *"\(.*\)".*/\1/'
}

# ── install v2ray-core ────────────────────────────────────────────────────────
install_v2ray() {
    local repo="v2fly/v2ray-core"
    info "Fetching latest v2ray-core tag from ${repo}…"
    local tag
    tag=$(latest_tag "$repo")
    [[ -n "$tag" ]] || error "Could not determine latest v2ray-core version."
    info "Latest v2ray-core: ${tag}"

    local zip="v2ray-linux-64.zip"
    local url="https://github.com/${repo}/releases/download/${tag}/${zip}"
    local tmp
    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' RETURN

    info "Downloading ${url}…"
    curl -fsSL -o "${tmp}/${zip}" "$url"

    require_cmd unzip
    info "Extracting…"
    unzip -q "${tmp}/${zip}" -d "${tmp}/v2ray"

    install -d /usr/local/bin /usr/local/share/v2ray

    install -m 755 "${tmp}/v2ray/v2ray" /usr/local/bin/v2ray
    install -m 644 "${tmp}/v2ray/geoip.dat"   /usr/local/share/v2ray/geoip.dat
    install -m 644 "${tmp}/v2ray/geosite.dat" /usr/local/share/v2ray/geosite.dat

    info "v2ray-core ${tag} installed → /usr/local/bin/v2ray"
}

# ── install v2raya ────────────────────────────────────────────────────────────
install_v2raya() {
    local repo="v2rayA/v2rayA"
    info "Fetching latest v2raya tag from ${repo}…"
    local tag
    tag=$(latest_tag "$repo")
    [[ -n "$tag" ]] || error "Could not determine latest v2raya version."
    # strip leading 'v' for the filename
    local ver="${tag#v}"
    info "Latest v2raya: ${tag}"

    local rpm="installer_redhat_x64_${ver}.rpm"
    local url="https://github.com/${repo}/releases/download/${tag}/${rpm}"
    local tmp
    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' RETURN

    info "Downloading ${url}…"
    curl -fsSL -o "${tmp}/${rpm}" "$url"

    info "Installing RPM…"
    yum install -y "${tmp}/${rpm}"

    info "v2raya ${tag} installed."
}

# ── enable & start v2raya service ─────────────────────────────────────────────
setup_service() {
    info "Enabling and starting v2raya.service…"
    systemctl daemon-reload
    systemctl enable --now v2raya.service
    info "v2raya is running. Open http://localhost:2017 in your browser."
    info "If you ever forget your password, run:  v2raya --reset-password"
}

# ── main ──────────────────────────────────────────────────────────────────────
main() {
    require_root
    require_cmd curl
    require_cmd unzip

    info "=== CentOS 7 v2rayA installer ==="
    install_v2ray
    install_v2raya
    setup_service
    info "=== Done! ==="
}

main "$@"
