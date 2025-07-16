#!/usr/bin/env python3
"""
Kimi K2 Usage Tracker and Cost Calculator
Monitors Claude Code usage and calculates costs based on Kimi K2 pricing
"""

import json
import os
import re
import sys
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, List, Optional, Tuple
import argparse

# Kimi K2 Pricing (per million tokens)
PRICING = {
    'input': 0.15,   # $0.15 per 1M input tokens
    'output': 2.50   # $2.50 per 1M output tokens
}

class UsageTracker:
    def __init__(self, config_dir: str = None):
        self.config_dir = Path(config_dir or os.path.expanduser("~/.kimi-claude"))
        self.usage_log = self.config_dir / "usage.log"
        self.stats_file = self.config_dir / "usage_stats.json"
        self.config_dir.mkdir(exist_ok=True)
    
    def log_usage(self, session_id: str, input_tokens: int, output_tokens: int, 
                  model: str = "kimi-k2", operation: str = "chat"):
        """Log usage data for cost tracking"""
        timestamp = datetime.now().isoformat()
        cost = self.calculate_cost(input_tokens, output_tokens)
        
        log_entry = {
            'timestamp': timestamp,
            'session_id': session_id,
            'input_tokens': input_tokens,
            'output_tokens': output_tokens,
            'total_tokens': input_tokens + output_tokens,
            'cost_usd': cost,
            'model': model,
            'operation': operation
        }
        
        # Append to usage log
        with open(self.usage_log, 'a') as f:
            f.write(f"{timestamp} USAGE {json.dumps(log_entry)}\n")
        
        # Update running stats
        self._update_stats(log_entry)
        
        return cost
    
    def calculate_cost(self, input_tokens: int, output_tokens: int) -> float:
        """Calculate cost based on Kimi K2 pricing"""
        input_cost = (input_tokens / 1_000_000) * PRICING['input']
        output_cost = (output_tokens / 1_000_000) * PRICING['output']
        return round(input_cost + output_cost, 6)
    
    def _update_stats(self, log_entry: Dict):
        """Update running statistics"""
        stats = self.load_stats()
        
        today = datetime.now().date().isoformat()
        if today not in stats['daily']:
            stats['daily'][today] = {
                'input_tokens': 0,
                'output_tokens': 0,
                'total_cost': 0.0,
                'sessions': 0
            }
        
        day_stats = stats['daily'][today]
        day_stats['input_tokens'] += log_entry['input_tokens']
        day_stats['output_tokens'] += log_entry['output_tokens']
        day_stats['total_cost'] += log_entry['cost_usd']
        day_stats['sessions'] += 1
        
        # Update totals
        stats['total']['input_tokens'] += log_entry['input_tokens']
        stats['total']['output_tokens'] += log_entry['output_tokens']
        stats['total']['total_cost'] += log_entry['cost_usd']
        stats['total']['sessions'] += 1
        
        self.save_stats(stats)
    
    def load_stats(self) -> Dict:
        """Load usage statistics"""
        if self.stats_file.exists():
            with open(self.stats_file) as f:
                return json.load(f)
        
        return {
            'total': {
                'input_tokens': 0,
                'output_tokens': 0,
                'total_cost': 0.0,
                'sessions': 0
            },
            'daily': {}
        }
    
    def save_stats(self, stats: Dict):
        """Save usage statistics"""
        with open(self.stats_file, 'w') as f:
            json.dump(stats, f, indent=2)
    
    def get_usage_report(self, days: int = 7) -> Dict:
        """Generate usage report for specified number of days"""
        stats = self.load_stats()
        end_date = datetime.now().date()
        start_date = end_date - timedelta(days=days-1)
        
        report = {
            'period': f"{start_date} to {end_date}",
            'days': days,
            'total_cost': 0.0,
            'total_input_tokens': 0,
            'total_output_tokens': 0,
            'total_sessions': 0,
            'daily_breakdown': [],
            'average_daily_cost': 0.0
        }
        
        for i in range(days):
            date = (start_date + timedelta(days=i)).isoformat()
            day_data = stats['daily'].get(date, {
                'input_tokens': 0,
                'output_tokens': 0,
                'total_cost': 0.0,
                'sessions': 0
            })
            
            report['daily_breakdown'].append({
                'date': date,
                **day_data
            })
            
            report['total_cost'] += day_data['total_cost']
            report['total_input_tokens'] += day_data['input_tokens']
            report['total_output_tokens'] += day_data['output_tokens']
            report['total_sessions'] += day_data['sessions']
        
        if days > 0:
            report['average_daily_cost'] = report['total_cost'] / days
        
        return report
    
    def print_usage_report(self, days: int = 7):
        """Print formatted usage report"""
        report = self.get_usage_report(days)
        
        print(f"\n🎯 Kimi K2 Usage Report ({report['period']})")
        print("=" * 50)
        print(f"Total Cost: ${report['total_cost']:.4f}")
        print(f"Total Sessions: {report['total_sessions']}")
        print(f"Input Tokens: {report['total_input_tokens']:,}")
        print(f"Output Tokens: {report['total_output_tokens']:,}")
        print(f"Average Daily Cost: ${report['average_daily_cost']:.4f}")
        
        print("\nDaily Breakdown:")
        print("-" * 50)
        for day in report['daily_breakdown']:
            if day['sessions'] > 0:
                print(f"{day['date']}: ${day['total_cost']:.4f} "
                      f"({day['sessions']} sessions, "
                      f"{day['input_tokens'] + day['output_tokens']:,} tokens)")
    
    def check_spending_alert(self, daily_limit: float = 5.0, monthly_limit: float = 100.0):
        """Check if spending limits are exceeded"""
        stats = self.load_stats()
        today = datetime.now().date().isoformat()
        
        # Check daily limit
        daily_cost = stats['daily'].get(today, {}).get('total_cost', 0.0)
        if daily_cost > daily_limit:
            print(f"⚠️  Daily spending limit exceeded: ${daily_cost:.4f} > ${daily_limit:.2f}")
        
        # Check monthly limit
        start_of_month = datetime.now().date().replace(day=1)
        monthly_cost = 0.0
        
        for date_str, day_data in stats['daily'].items():
            date = datetime.fromisoformat(date_str).date()
            if date >= start_of_month:
                monthly_cost += day_data['total_cost']
        
        if monthly_cost > monthly_limit:
            print(f"⚠️  Monthly spending limit exceeded: ${monthly_cost:.4f} > ${monthly_limit:.2f}")

def main():
    parser = argparse.ArgumentParser(description="Kimi K2 Usage Tracker")
    parser.add_argument('--report', '-r', type=int, default=7, 
                       help='Generate usage report for N days (default: 7)')
    parser.add_argument('--cost', '-c', nargs=2, type=int, metavar=('INPUT', 'OUTPUT'),
                       help='Calculate cost for input and output tokens')
    parser.add_argument('--log', nargs=4, metavar=('SESSION', 'INPUT', 'OUTPUT', 'OPERATION'),
                       help='Log usage: session_id input_tokens output_tokens operation')
    parser.add_argument('--alerts', '-a', action='store_true',
                       help='Check spending alerts')
    parser.add_argument('--config-dir', help='Custom config directory')
    
    args = parser.parse_args()
    
    tracker = UsageTracker(args.config_dir)
    
    if args.cost:
        input_tokens, output_tokens = args.cost
        cost = tracker.calculate_cost(input_tokens, output_tokens)
        print(f"Cost for {input_tokens:,} input + {output_tokens:,} output tokens: ${cost:.6f}")
    
    elif args.log:
        session_id, input_tokens, output_tokens, operation = args.log
        cost = tracker.log_usage(session_id, int(input_tokens), int(output_tokens), operation=operation)
        print(f"Logged usage: ${cost:.6f}")
    
    elif args.alerts:
        tracker.check_spending_alert()
    
    else:
        tracker.print_usage_report(args.report)

if __name__ == "__main__":
    main()