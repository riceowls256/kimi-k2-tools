#!/bin/bash

# Kimi K2 Cost Monitoring Dashboard
# Simple terminal-based dashboard for monitoring usage and costs

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TRACKER="$SCRIPT_DIR/usage-tracker.py"
CONFIG_DIR="${KIMI_CONFIG_DIR:-$HOME/.kimi-claude}"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

show_header() {
    clear
    echo -e "${BOLD}${BLUE}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                    Kimi K2 Cost Dashboard                     ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo "Last updated: $(date)"
    echo
}

show_quick_stats() {
    echo -e "${BOLD}Quick Stats:${NC}"
    
    # Today's usage
    if python3 "$TRACKER" --report 1 2>/dev/null | grep -q "Total Cost"; then
        TODAY_COST=$(python3 "$TRACKER" --report 1 2>/dev/null | grep "Total Cost" | awk '{print $3}' | tr -d '$')
        echo -e "Today's cost: ${GREEN}\$$TODAY_COST${NC}"
    else
        echo -e "Today's cost: ${GREEN}\$0.0000${NC}"
    fi
    
    # This week
    WEEK_COST=$(python3 "$TRACKER" --report 7 2>/dev/null | grep "Total Cost" | awk '{print $3}' | tr -d '$')
    echo -e "This week: ${YELLOW}\$$WEEK_COST${NC}"
    
    # This month
    MONTH_COST=$(python3 "$TRACKER" --report 30 2>/dev/null | grep "Total Cost" | awk '{print $3}' | tr -d '$')
    echo -e "This month: ${BLUE}\$$MONTH_COST${NC}"
    
    echo
}

show_cost_comparison() {
    echo -e "${BOLD}Cost Comparison (Kimi K2 vs Claude Opus):${NC}"
    echo "╭─────────────────┬──────────────┬──────────────┬─────────────╮"
    echo "│ Metric          │ Kimi K2      │ Claude Opus  │ Savings     │"
    echo "├─────────────────┼──────────────┼──────────────┼─────────────┤"
    echo "│ Input (per 1M)  │ \$0.15        │ \$15.00       │ 100x        │"
    echo "│ Output (per 1M) │ \$2.50        │ \$75.00       │ 30x         │"
    echo "│ Context Window  │ 128K tokens  │ 200K tokens  │ -36%        │"
    echo "│ SWE-bench Score │ 65.8%        │ Competitive  │ Similar     │"
    echo "╰─────────────────┴──────────────┴──────────────┴─────────────╯"
    echo
}

show_spending_alerts() {
    echo -e "${BOLD}Spending Alerts:${NC}"
    
    # Check if spending limits are exceeded
    ALERTS=$(python3 "$TRACKER" --alerts 2>&1 || true)
    
    if [[ -n "$ALERTS" ]]; then
        echo -e "${RED}$ALERTS${NC}"
    else
        echo -e "${GREEN}✓ All spending within limits${NC}"
    fi
    echo
}

show_recent_usage() {
    echo -e "${BOLD}Recent Usage (Last 7 days):${NC}"
    python3 "$TRACKER" --report 7 2>/dev/null || echo "No usage data available"
    echo
}

show_menu() {
    echo -e "${BOLD}Options:${NC}"
    echo "  r) Refresh dashboard"
    echo "  1) Show daily usage (1 day)"
    echo "  7) Show weekly usage (7 days)" 
    echo "  30) Show monthly usage (30 days)"
    echo "  c) Calculate cost for tokens"
    echo "  s) Setup API key"
    echo "  q) Quit"
    echo
    echo -n "Choice: "
}

calculate_cost() {
    echo
    echo -n "Input tokens: "
    read -r input_tokens
    echo -n "Output tokens: "
    read -r output_tokens
    
    echo
    python3 "$TRACKER" --cost "$input_tokens" "$output_tokens"
    echo
    echo "Press Enter to continue..."
    read -r
}

setup_api_key() {
    echo
    echo "Setting up Kimi K2 API key..."
    echo "Get your API key from: https://platform.moonshot.ai/"
    echo
    echo -n "Enter your Moonshot API key (starts with sk-): "
    read -r api_key
    
    if [[ "$api_key" =~ ^sk- ]]; then
        mkdir -p "$CONFIG_DIR"
        echo "$api_key" > "$CONFIG_DIR/api_key"
        chmod 600 "$CONFIG_DIR/api_key"
        echo -e "${GREEN}✓ API key saved to $CONFIG_DIR/api_key${NC}"
    else
        echo -e "${RED}✗ Invalid API key format${NC}"
    fi
    
    echo
    echo "Press Enter to continue..."
    read -r
}

main() {
    while true; do
        show_header
        show_quick_stats
        show_spending_alerts
        show_cost_comparison
        show_menu
        
        read -r choice
        
        case "$choice" in
            r|R) continue ;;
            1) 
                clear
                python3 "$TRACKER" --report 1
                echo
                echo "Press Enter to continue..."
                read -r
                ;;
            7)
                clear  
                python3 "$TRACKER" --report 7
                echo
                echo "Press Enter to continue..."
                read -r
                ;;
            30)
                clear
                python3 "$TRACKER" --report 30
                echo
                echo "Press Enter to continue..."
                read -r
                ;;
            c|C) calculate_cost ;;
            s|S) setup_api_key ;;
            q|Q) 
                echo "Goodbye!"
                exit 0
                ;;
            *)
                echo "Invalid choice. Press Enter to continue..."
                read -r
                ;;
        esac
    done
}

# Check if Python 3 is available
if ! command -v python3 >/dev/null 2>&1; then
    echo "Error: Python 3 is required but not found"
    exit 1
fi

main