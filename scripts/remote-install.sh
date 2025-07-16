#!/bin/bash

# Remote installation script for Kimi K2 Tools
# Usage: bash -c "$(curl -fsSL https://raw.githubusercontent.com/riceowls256/kimi-k2-tools/main/scripts/remote-install.sh)"

set -euo pipefail

REPO_URL="https://github.com/riceowls256/kimi-k2-tools.git"
INSTALL_DIR="$HOME/.kimi-k2-tools"
TEMP_DIR="/tmp/kimi-k2-tools-install"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

cleanup() {
    rm -rf "$TEMP_DIR"
}

trap cleanup EXIT

main() {
    echo -e "${BOLD}${BLUE}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║              Kimi K2 Tools Remote Installer                  ║"
    echo "║                                                               ║"
    echo "║  Installing from: $REPO_URL"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo

    # Check prerequisites
    if ! command -v git >/dev/null 2>&1; then
        log_error "Git is required but not found. Please install git first."
        exit 1
    fi

    # Clone repository to temporary directory
    log_info "Cloning Kimi K2 Tools repository..."
    rm -rf "$TEMP_DIR"
    git clone "$REPO_URL" "$TEMP_DIR"

    # Run the installation script
    log_info "Running installation script..."
    cd "$TEMP_DIR"
    ./install.sh

    log_success "Remote installation complete!"
    echo
    echo "Next steps:"
    echo "  1. Set your API key: echo 'YOUR_API_KEY' > ~/.kimi-claude/api_key"
    echo "  2. Run: kimi-claude --check"
    echo "  3. Start coding: kimi-claude"
}

main "$@"