# Claude Code Memory for This Project

This project is configured to use **Kimi K2** (Moonshot AI) as the AI provider for Claude Code.

## 🎯 Current Configuration

- **Provider**: Kimi K2 (Moonshot AI)
- **API Endpoint**: https://api.moonshot.ai/anthropic/
- **Cost**: 100x cheaper than Claude Opus
- **Context Window**: 128K tokens
- **Performance**: 65.8% on SWE-bench

## 💰 Cost Benefits

| Metric | Kimi K2 | Claude Opus | Savings |
|--------|---------|-------------|---------|
| Input tokens (per 1M) | $0.15 | $15.00 | 100x |
| Output tokens (per 1M) | $2.50 | $75.00 | 30x |

## 🛠️ Project-Specific Commands

```bash
# View current configuration
kimi-claude --info

# Monitor costs for this project
kimi-usage --report 7

# Health check
kimi-claude --check

# Switch between providers
claude-switcher status
```

## 📝 Development Notes

- All Claude Code sessions in this project use Kimi K2
- Usage is automatically tracked for cost monitoring
- Configuration is isolated from other projects
- Excellent performance on coding tasks (65.8% SWE-bench score)

## 🔧 Customization

To modify this project's AI configuration:
1. Edit `.claude/settings.json`
2. Update API key if needed
3. Restart Claude Code

## 📊 Usage Tracking

This project automatically tracks:
- Token usage per session
- Daily/weekly costs
- Performance metrics
- API call patterns

View detailed reports with: `kimi-dashboard`