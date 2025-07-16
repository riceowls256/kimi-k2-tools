#!/bin/bash

# Kimi K2 Health Check and Diagnostic Tool
# Comprehensive system check for Kimi K2 configuration

set -euo pipefail

CONFIG_DIR="${KIMI_CONFIG_DIR:-$HOME/.kimi-claude}"
GLOBAL_CONFIG="$HOME/.claude/settings.json"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

PASS_COUNT=0
WARN_COUNT=0
FAIL_COUNT=0

check_pass() {
    echo -e "${GREEN}✓${NC} $1"
    ((PASS_COUNT++))
}

check_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARN_COUNT++))
}

check_fail() {
    echo -e "${RED}✗${NC} $1"
    ((FAIL_COUNT++))
}

section_header() {
    echo
    echo -e "${BOLD}${BLUE}$1${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

check_claude_code() {
    section_header "Claude Code Installation"
    
    if command -v claude >/dev/null 2>&1; then
        check_pass "Claude Code is installed"
        
        # Check version if possible
        if claude --version >/dev/null 2>&1; then
            VERSION=$(claude --version 2>/dev/null || echo "unknown")
            echo "  Version: $VERSION"
        fi
    else
        check_fail "Claude Code not found in PATH"
        echo "  Install from: https://docs.anthropic.com/en/docs/claude-code/quickstart"
    fi
}

check_api_connectivity() {
    section_header "API Connectivity"
    
    # Test Moonshot API
    if curl -s --max-time 10 "https://api.moonshot.ai" >/dev/null 2>&1; then
        check_pass "Moonshot API is reachable"
    else
        check_fail "Cannot reach Moonshot API"
        echo "  Check your internet connection"
    fi
    
    # Test Anthropic API for comparison
    if curl -s --max-time 10 "https://api.anthropic.com" >/dev/null 2>&1; then
        check_pass "Anthropic API is reachable"
    else
        check_warn "Cannot reach Anthropic API (this is okay if using Kimi K2)"
    fi
}

check_api_key() {
    section_header "API Key Configuration"
    
    API_KEY=""
    
    # Check environment variable
    if [[ -n "${ANTHROPIC_AUTH_TOKEN:-}" ]]; then
        API_KEY="$ANTHROPIC_AUTH_TOKEN"
        check_pass "API key found in ANTHROPIC_AUTH_TOKEN"
    elif [[ -f "$CONFIG_DIR/api_key" ]]; then
        API_KEY=$(cat "$CONFIG_DIR/api_key")
        check_pass "API key found in $CONFIG_DIR/api_key"
    else
        check_fail "No API key found"
        echo "  Set ANTHROPIC_AUTH_TOKEN or create $CONFIG_DIR/api_key"
        return
    fi
    
    # Validate key format
    if [[ "$API_KEY" =~ ^sk- ]]; then
        check_pass "API key format is valid"
        echo "  Key: ${API_KEY:0:10}..."
    else
        check_fail "API key format is invalid (should start with sk-)"
    fi
    
    # Check key length (Moonshot keys are typically 64+ characters)
    if [[ ${#API_KEY} -ge 32 ]]; then
        check_pass "API key length looks good"
    else
        check_warn "API key seems short (${#API_KEY} characters)"
    fi
}

check_configuration() {
    section_header "Configuration Files"
    
    # Check global Claude settings
    if [[ -f "$GLOBAL_CONFIG" ]]; then
        check_pass "Global Claude settings found"
        
        # Check if it contains Kimi K2 configuration
        if grep -q "moonshot.ai" "$GLOBAL_CONFIG" 2>/dev/null; then
            check_pass "Global configuration uses Kimi K2"
        else
            check_warn "Global configuration doesn't use Kimi K2"
            echo "  You can use kimi-claude command instead"
        fi
        
        # Validate JSON
        if python3 -m json.tool "$GLOBAL_CONFIG" >/dev/null 2>&1; then
            check_pass "Global configuration JSON is valid"
        else
            check_fail "Global configuration JSON is invalid"
        fi
    else
        check_warn "No global Claude configuration found"
    fi
    
    # Check project-specific configuration
    if [[ -f "./.claude/settings.json" ]]; then
        check_pass "Project-specific configuration found"
        
        if grep -q "moonshot.ai" "./.claude/settings.json" 2>/dev/null; then
            check_pass "Project configuration uses Kimi K2"
        else
            check_warn "Project configuration doesn't use Kimi K2"
        fi
    fi
}

check_tools() {
    section_header "Kimi K2 Tools"
    
    # Check for required tools
    local tools=(
        "kimi-claude:Kimi Claude wrapper"
        "kimi-dashboard:Cost dashboard"  
        "kimi-usage:Usage tracker"
        "python3:Python 3"
        "curl:HTTP client"
    )
    
    for tool_info in "${tools[@]}"; do
        IFS=':' read -r tool desc <<< "$tool_info"
        if command -v "$tool" >/dev/null 2>&1; then
            check_pass "$desc is available"
        else
            if [[ "$tool" =~ ^kimi- ]]; then
                check_warn "$desc not found"
                echo "  Run install.sh to set up tools"
            else
                check_fail "$desc not found"
            fi
        fi
    done
}

check_environment() {
    section_header "Environment Variables"
    
    # Check relevant environment variables
    local env_vars=(
        "ANTHROPIC_AUTH_TOKEN:API authentication token"
        "ANTHROPIC_BASE_URL:API base URL" 
        "ANTHROPIC_LOG:Debug logging"
        "KIMI_CONFIG_DIR:Config directory"
        "KIMI_DEBUG:Debug mode"
    )
    
    for var_info in "${env_vars[@]}"; do
        IFS=':' read -r var desc <<< "$var_info"
        if [[ -n "${!var:-}" ]]; then
            if [[ "$var" == "ANTHROPIC_AUTH_TOKEN" ]]; then
                check_pass "$desc is set (${!var:0:10}...)"
            else
                check_pass "$desc is set (${!var})"
            fi
        else
            if [[ "$var" == "ANTHROPIC_BASE_URL" ]]; then
                check_warn "$desc not set (will use default)"
            else
                check_pass "$desc not set (optional)"
            fi
        fi
    done
}

check_usage_tracking() {
    section_header "Usage Tracking"
    
    if [[ -f "$CONFIG_DIR/usage.log" ]]; then
        check_pass "Usage log exists"
        
        local log_size=$(wc -l < "$CONFIG_DIR/usage.log" 2>/dev/null || echo "0")
        echo "  Log entries: $log_size"
        
        if [[ $log_size -gt 0 ]]; then
            local last_entry=$(tail -1 "$CONFIG_DIR/usage.log" 2>/dev/null || echo "")
            if [[ -n "$last_entry" ]]; then
                echo "  Last entry: $(echo "$last_entry" | cut -d' ' -f1-2)"
            fi
        fi
    else
        check_warn "No usage log found"
        echo "  Will be created on first use"
    fi
    
    if [[ -f "$CONFIG_DIR/usage_stats.json" ]]; then
        check_pass "Usage statistics file exists"
        
        if python3 -c "import json; json.load(open('$CONFIG_DIR/usage_stats.json'))" 2>/dev/null; then
            check_pass "Usage statistics JSON is valid"
        else
            check_fail "Usage statistics JSON is invalid"
        fi
    else
        check_warn "No usage statistics found"
        echo "  Will be created on first tracked usage"
    fi
}

run_quick_test() {
    section_header "Quick API Test"
    
    echo -n "Testing API configuration... "
    
    # This is a simple test - we can't actually call the API without making a real request
    # So we just check if all configuration looks correct
    
    local test_passed=true
    
    # Check API key
    if [[ -z "${ANTHROPIC_AUTH_TOKEN:-}" ]] && [[ ! -f "$CONFIG_DIR/api_key" ]]; then
        test_passed=false
    fi
    
    # Check if we can resolve the API endpoint
    if ! nslookup api.moonshot.ai >/dev/null 2>&1; then
        test_passed=false
    fi
    
    if $test_passed; then
        check_pass "Configuration appears correct"
        echo "  To test actual API calls, run: kimi-claude"
    else
        check_fail "Configuration issues detected"
        echo "  Fix the issues above and try again"
    fi
}

show_summary() {
    section_header "Summary"
    
    echo -e "Results: ${GREEN}$PASS_COUNT passed${NC}, ${YELLOW}$WARN_COUNT warnings${NC}, ${RED}$FAIL_COUNT failed${NC}"
    echo
    
    if [[ $FAIL_COUNT -eq 0 ]]; then
        if [[ $WARN_COUNT -eq 0 ]]; then
            echo -e "${GREEN}✓ Everything looks great! Kimi K2 is ready to use.${NC}"
        else
            echo -e "${YELLOW}⚠ Minor issues detected, but Kimi K2 should work.${NC}"
        fi
        echo
        echo "Next steps:"
        echo "  1. Run: kimi-claude"
        echo "  2. Monitor costs: kimi-dashboard"
        echo "  3. View usage: kimi-usage --report 7"
    else
        echo -e "${RED}✗ Issues detected that may prevent Kimi K2 from working.${NC}"
        echo
        echo "Common fixes:"
        echo "  • Install Claude Code: https://docs.anthropic.com/en/docs/claude-code/quickstart"
        echo "  • Set API key: echo 'sk-your-key' > $CONFIG_DIR/api_key"
        echo "  • Run installer: ./install.sh"
    fi
}

main() {
    echo -e "${BOLD}${BLUE}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                    Kimi K2 Health Check                      ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    check_claude_code
    check_api_connectivity  
    check_api_key
    check_configuration
    check_tools
    check_environment
    check_usage_tracking
    run_quick_test
    show_summary
}

main "$@"