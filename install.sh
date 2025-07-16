#!/bin/bash

# Kimi K2 Setup Script for Claude Code
# Automated installation and configuration

set -euo pipefail

# Configuration
TOOLS_DIR="$HOME/.kimi-k2-tools"
BIN_DIR="$HOME/bin"
CONFIG_DIR="$HOME/.kimi-claude"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_step() {
    echo -e "${BOLD}${BLUE}$1${NC}"
}

# Check prerequisites
check_prerequisites() {
    log_step "Checking prerequisites..."
    
    # Check for Claude Code
    if ! command -v claude >/dev/null 2>&1; then
        log_error "Claude Code not found. Please install Claude Code first:"
        echo "  Visit: https://docs.anthropic.com/en/docs/claude-code/quickstart"
        exit 1
    fi
    log_success "Claude Code found"
    
    # Check for Python 3
    if ! command -v python3 >/dev/null 2>&1; then
        log_error "Python 3 is required but not found"
        exit 1
    fi
    log_success "Python 3 found"
    
    # Check for curl
    if ! command -v curl >/dev/null 2>&1; then
        log_error "curl is required but not found"
        exit 1
    fi
    log_success "curl found"
}

# Create directory structure
setup_directories() {
    log_step "Setting up directories..."
    
    mkdir -p "$TOOLS_DIR"/{bin,config,monitoring,docs}
    mkdir -p "$BIN_DIR"
    mkdir -p "$CONFIG_DIR"
    
    log_success "Directories created"
}

# Install tools
install_tools() {
    log_step "Installing Kimi K2 tools..."
    
    # Determine the source directory (where this script is located)
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    # Copy tools
    cp -r "$SCRIPT_DIR"/* "$TOOLS_DIR/"
    
    # Create symlinks in user's bin directory
    ln -sf "$TOOLS_DIR/bin/kimi-claude" "$BIN_DIR/kimi-claude"
    ln -sf "$TOOLS_DIR/monitoring/cost-dashboard.sh" "$BIN_DIR/kimi-dashboard"
    ln -sf "$TOOLS_DIR/monitoring/usage-tracker.py" "$BIN_DIR/kimi-usage"
    
    # Make sure everything is executable
    chmod +x "$TOOLS_DIR"/bin/*
    chmod +x "$TOOLS_DIR"/monitoring/*
    
    log_success "Tools installed to $TOOLS_DIR"
}

# Setup API key
setup_api_key() {
    log_step "Setting up API key..."
    
    echo "You need a Moonshot AI API key to use Kimi K2."
    echo "1. Visit https://platform.moonshot.ai/"
    echo "2. Sign up (you'll get \$5 in free credits)"
    echo "3. Go to API Keys section"
    echo "4. Create a new API key"
    echo
    
    while true; do
        echo -n "Enter your Moonshot API key (starts with sk-) or press Enter to skip: "
        read -r api_key
        
        if [[ -z "$api_key" ]]; then
            log_warn "Skipping API key setup. You can set it later with: echo 'sk-your-key' > $CONFIG_DIR/api_key"
            break
        elif [[ "$api_key" =~ ^sk- ]]; then
            # Save to both api_key file and .env file
            echo "$api_key" > "$CONFIG_DIR/api_key"
            chmod 600 "$CONFIG_DIR/api_key"
            
            # Create .env file from template
            cp "$TOOLS_DIR/config/.env.example" "$CONFIG_DIR/.env"
            sed -i.bak "s/sk-your-moonshot-api-key-here/$api_key/g" "$CONFIG_DIR/.env"
            rm "$CONFIG_DIR/.env.bak" 2>/dev/null || true
            chmod 600 "$CONFIG_DIR/.env"
            
            log_success "API key saved to $CONFIG_DIR/api_key and $CONFIG_DIR/.env"
            break
        else
            log_error "Invalid API key format. Must start with 'sk-'"
        fi
    done
}

# Test connectivity
test_connectivity() {
    log_step "Testing connectivity..."
    
    if curl -s --max-time 10 "https://api.moonshot.ai" >/dev/null; then
        log_success "Moonshot API is reachable"
    else
        log_warn "Could not reach Moonshot API. Check your internet connection."
    fi
}

# Update PATH
update_path() {
    log_step "Updating PATH..."
    
    # Check if ~/bin is already in PATH
    if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
        # Add to shell profile
        SHELL_PROFILE=""
        if [[ -f "$HOME/.zshrc" ]]; then
            SHELL_PROFILE="$HOME/.zshrc"
        elif [[ -f "$HOME/.bashrc" ]]; then
            SHELL_PROFILE="$HOME/.bashrc"
        elif [[ -f "$HOME/.bash_profile" ]]; then
            SHELL_PROFILE="$HOME/.bash_profile"
        fi
        
        if [[ -n "$SHELL_PROFILE" ]]; then
            echo 'export PATH="$HOME/bin:$PATH"' >> "$SHELL_PROFILE"
            log_success "Added ~/bin to PATH in $SHELL_PROFILE"
            log_info "Please run: source $SHELL_PROFILE"
        else
            log_warn "Could not find shell profile. Please add ~/bin to your PATH manually"
        fi
    else
        log_success "~/bin already in PATH"
    fi
}

# Create global configuration
setup_global_config() {
    log_step "Setting up global configuration..."
    
    # Backup existing settings
    if [[ -f "$HOME/.claude/settings.json" ]]; then
        cp "$HOME/.claude/settings.json" "$HOME/.claude/settings.json.backup.$(date +%Y%m%d_%H%M%S)"
        log_info "Backed up existing Claude settings"
    fi
    
    # Ask user about global configuration
    echo
    echo "Configuration options:"
    echo "1. Global Kimi K2 (all Claude sessions use Kimi K2)"
    echo "2. Per-project setup (keep current global, use kimi-claude for Kimi K2)"
    echo "3. Skip global configuration"
    echo
    echo -n "Choose option (1-3) [2]: "
    read -r config_choice
    
    case "${config_choice:-2}" in
        1)
            # Global Kimi K2 configuration
            cat > "$HOME/.claude/settings.json" << EOF
{
  "model": "sonnet",
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "\$(cat $CONFIG_DIR/api_key 2>/dev/null || echo 'sk-your-key-here')",
    "ANTHROPIC_BASE_URL": "https://api.moonshot.ai/anthropic/"
  }
}
EOF
            log_success "Global Kimi K2 configuration created"
            ;;
        2)
            log_info "Keeping per-project setup. Use 'kimi-claude' command for Kimi K2"
            ;;
        3)
            log_info "Skipping global configuration"
            ;;
        *)
            log_warn "Invalid choice. Keeping per-project setup."
            ;;
    esac
}

# Show completion message
show_completion() {
    log_step "Installation complete!"
    echo
    echo -e "${BOLD}Available commands:${NC}"
    echo "  kimi-claude        - Run Claude Code with Kimi K2"
    echo "  kimi-dashboard     - Cost monitoring dashboard"  
    echo "  kimi-usage         - Usage tracking and reports"
    echo
    echo -e "${BOLD}Quick start:${NC}"
    echo "1. Run: kimi-claude --info    (check configuration)"
    echo "2. Run: kimi-claude --check   (health check)"
    echo "3. Run: kimi-claude           (start Claude with Kimi K2)"
    echo "4. Run: kimi-dashboard        (monitor costs)"
    echo
    echo -e "${BOLD}Cost monitoring:${NC}"
    echo "• Daily cost tracking and alerts"
    echo "• 100x cheaper than Claude Opus (\$0.15 vs \$15 per 1M input tokens)"
    echo "• Similar performance (65.8% on SWE-bench)"
    echo
    log_success "Setup complete! Enjoy using Kimi K2 with Claude Code!"
}

# Main installation flow
main() {
    echo -e "${BOLD}${BLUE}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║          Kimi K2 Setup for Claude Code                       ║"
    echo "║                                                               ║"
    echo "║  This will install tools to use Kimi K2 as an alternative    ║"
    echo "║  to Anthropic's API with 100x cost savings!                  ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo
    
    check_prerequisites
    setup_directories
    install_tools
    setup_api_key
    test_connectivity
    update_path
    setup_global_config
    show_completion
}

# Handle interrupts
trap 'echo; log_error "Installation interrupted"; exit 1' INT

# Run main function
main "$@"