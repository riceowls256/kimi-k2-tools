# Kimi K2 for Claude Code - Complete User Guide

A comprehensive toolkit for using Moonshot AI's Kimi K2 as a cost-effective alternative to Anthropic's Claude API with 100x cost savings.

## 🚀 Quick Start

### 1. Installation

```bash
# Clone or download the kimi-k2-tools
git clone <repository-url> kimi-k2-tools
cd kimi-k2-tools

# Run the automated installer
./install.sh
```

### 2. Get Your API Key

1. Visit [Moonshot AI Platform](https://platform.moonshot.ai/)
2. Sign up (you'll receive $5 in free credits)
3. Navigate to "API Keys" section
4. Create a new API key (starts with `sk-`)
5. Copy the key immediately (it won't be shown again)

### 3. Configure API Key

```bash
# Option 1: Set environment variable
export ANTHROPIC_AUTH_TOKEN="sk-your-moonshot-api-key"

# Option 2: Save to file
echo "sk-your-moonshot-api-key" > ~/.kimi-claude/api_key

# Option 3: Use the dashboard
kimi-dashboard  # Choose option 's' to setup
```

### 4. Start Using Kimi K2

```bash
# Start Claude Code with Kimi K2
kimi-claude

# Run health check
kimi-claude --check

# View configuration
kimi-claude --info
```

## 📊 Cost Monitoring

### Dashboard

Launch the interactive cost monitoring dashboard:

```bash
kimi-dashboard
```

Features:
- Real-time cost tracking
- Daily/weekly/monthly reports
- Spending alerts
- Cost comparison with Claude Opus
- Quick statistics

### Command Line Usage Tracking

```bash
# View usage reports
kimi-usage --report 7    # Last 7 days
kimi-usage --report 30   # Last 30 days

# Calculate costs for specific token counts
kimi-usage --cost 10000 2000  # 10k input, 2k output tokens

# Check spending alerts
kimi-usage --alerts
```

## 🛠️ Available Commands

| Command | Description |
|---------|-------------|
| `kimi-claude` | Run Claude Code with Kimi K2 |
| `kimi-dashboard` | Interactive cost monitoring dashboard |
| `kimi-usage` | Usage tracking and cost reports |
| `project-kimi-claude` | Project-specific Kimi K2 instance |

## 🔧 Configuration Options

### Global Configuration

Make all Claude Code sessions use Kimi K2 by default:

```bash
# Update ~/.claude/settings.json
{
  "model": "sonnet",
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "sk-your-moonshot-api-key",
    "ANTHROPIC_BASE_URL": "https://api.moonshot.ai/anthropic/"
  }
}
```

### Per-Project Configuration

Create isolated Kimi K2 environments for specific projects:

```bash
# In your project directory
../kimi-k2-tools/bin/project-kimi-claude

# This creates a project-specific .kimi-claude-home directory
```

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `ANTHROPIC_AUTH_TOKEN` | Your Moonshot API key | Required |
| `ANTHROPIC_BASE_URL` | API endpoint | `https://api.moonshot.ai/anthropic/` |
| `ANTHROPIC_LOG` | Debug logging level | None |
| `KIMI_CONFIG_DIR` | Config directory | `~/.kimi-claude` |
| `KIMI_DEBUG` | Enable debug mode | `false` |

## 💰 Cost Analysis

### Pricing Comparison

| Metric | Kimi K2 | Claude Opus | Savings |
|--------|---------|-------------|---------|
| Input tokens (per 1M) | $0.15 | $15.00 | **100x cheaper** |
| Output tokens (per 1M) | $2.50 | $75.00 | **30x cheaper** |
| Context window | 128K | 200K | 64% |
| Performance (SWE-bench) | 65.8% | Competitive | Similar |

### Real-World Examples

**Typical development session:**
- 10M input tokens + 2M output tokens
- Kimi K2: $6.50
- Claude Opus: $300.00
- **Savings: $293.50 (98% less)**

**Daily usage scenarios:**
- Light usage (1M input, 0.2M output): $0.65 vs $19.50
- Medium usage (5M input, 1M output): $3.25 vs $150.00  
- Heavy usage (20M input, 5M output): $15.50 vs $675.00

### Automatic Cost Tracking

The toolkit automatically tracks:
- Token usage per session
- Daily/weekly/monthly costs
- Cost trends and patterns
- Spending alerts and limits

## 🔍 Troubleshooting

### Common Issues

#### 1. "Invalid API key" Error

```bash
# Check your API key format
echo $ANTHROPIC_AUTH_TOKEN
# Should start with 'sk-' and be 50+ characters

# Verify key file
cat ~/.kimi-claude/api_key

# Test with health check
kimi-k2-tools/monitoring/health-check.sh
```

#### 2. "Connection failed" Error

```bash
# Check internet connectivity
curl -s https://api.moonshot.ai

# Verify API endpoint
echo $ANTHROPIC_BASE_URL
# Should be: https://api.moonshot.ai/anthropic/

# Check firewall/proxy settings
```

#### 3. Configuration Not Loading

```bash
# Validate JSON syntax
python3 -m json.tool ~/.claude/settings.json

# Check file permissions
ls -la ~/.claude/settings.json

# Restart Claude Code after changes
```

#### 4. "Claude Code not found"

```bash
# Install Claude Code
npm install -g @anthropic/claude-code

# Or follow official guide:
# https://docs.anthropic.com/en/docs/claude-code/quickstart
```

### Debug Mode

Enable detailed logging for troubleshooting:

```bash
# Enable debug logging
export KIMI_DEBUG=true
export ANTHROPIC_LOG=debug

# Run with debug output
kimi-claude
```

### Health Check

Run comprehensive system diagnostics:

```bash
kimi-k2-tools/monitoring/health-check.sh
```

This checks:
- Claude Code installation
- API connectivity
- Configuration validity
- Tool availability
- Environment setup

## 🎯 Performance Optimization

### Model Capabilities

Kimi K2 excels at:
- **Agentic coding tasks**: Purpose-built for autonomous software engineering
- **Multi-step reasoning**: Strong performance on complex workflows  
- **Mathematical problems**: 97.4% on MATH-500 benchmark
- **Code generation**: 53.7% on LiveCodeBench

### Temperature Adjustment

Kimi K2 applies a 0.6x multiplier to temperature settings:
- If you want temperature 0.8, set it to ~1.3
- For creative tasks, use higher temperature values
- Default temperature works well for most coding tasks

### Context Window Management

With 128K context window (vs Claude's 200K):
- Break very large files into smaller chunks
- Use project-specific contexts effectively
- Monitor token usage with `kimi-usage`

## 🔐 Security Best Practices

### API Key Security

```bash
# Set proper file permissions
chmod 600 ~/.kimi-claude/api_key

# Never commit API keys to version control
echo "*.api_key" >> .gitignore
echo ".kimi-claude/" >> .gitignore

# Use environment variables in CI/CD
export ANTHROPIC_AUTH_TOKEN="$KIMI_API_KEY"
```

### Usage Monitoring

- Monitor your Moonshot dashboard for unusual usage
- Set up spending alerts in the cost dashboard
- Rotate API keys periodically
- Review usage logs regularly

## 📈 Advanced Usage

### Batch Operations

```bash
# Process multiple files efficiently
for file in src/*.py; do
    echo "Processing $file..."
    kimi-claude "Review and optimize $file"
done
```

### Custom Scripts Integration

```bash
#!/bin/bash
# Custom deployment script with cost tracking

SESSION_ID="deploy-$(date +%s)"
echo "Starting deployment with session: $SESSION_ID"

# Your deployment commands with kimi-claude
kimi-claude "Deploy application with comprehensive testing"

# Track usage
kimi-usage --log "$SESSION_ID" 50000 10000 "deployment"
```

### Project Templates

Create reusable project configurations:

```bash
# Create template directory
mkdir -p ~/.kimi-templates/web-project

# Copy configuration
cp kimi-k2-tools/config/* ~/.kimi-templates/web-project/

# Use template for new projects
cp -r ~/.kimi-templates/web-project/.kimi-claude-home ./
```

## 🚀 Multi-Project Management

### Switching Between Providers

```bash
# Use regular Claude Code
claude

# Use Kimi K2 globally
kimi-claude

# Use Kimi K2 for specific project
cd my-project
../kimi-k2-tools/bin/project-kimi-claude
```

### Project-Specific Settings

Each project can have its own:
- API configuration
- Usage tracking
- Cost limits
- Model preferences

### Team Collaboration

Share configurations across team members:

```bash
# Export team configuration
tar -czf team-kimi-config.tar.gz kimi-k2-tools/

# Import on team member's machine
tar -xzf team-kimi-config.tar.gz
cd kimi-k2-tools && ./install.sh
```

## 📚 Resources

### Documentation
- [Moonshot AI Platform](https://platform.moonshot.ai/)
- [Claude Code Documentation](https://docs.anthropic.com/en/docs/claude-code)
- [API Reference](https://platform.moonshot.ai/docs)

### Community
- Report issues: Create GitHub issues in this repository
- Feature requests: Submit enhancement proposals
- Community discussions: Join developer forums

### Support
- Check health status: `kimi-k2-tools/monitoring/health-check.sh`
- View logs: `tail -f ~/.kimi-claude/usage.log`
- Monitor costs: `kimi-dashboard`

## 🔄 Updates and Maintenance

### Updating Tools

```bash
# Pull latest changes
cd kimi-k2-tools
git pull origin main

# Reinstall
./install.sh
```

### Backup Configuration

```bash
# Backup your settings
tar -czf kimi-backup-$(date +%Y%m%d).tar.gz ~/.kimi-claude ~/.claude/settings.json

# Restore if needed
tar -xzf kimi-backup-YYYYMMDD.tar.gz -C /
```

### Log Rotation

Prevent log files from growing too large:

```bash
# Add to crontab for automatic cleanup
0 0 * * 0 find ~/.kimi-claude -name "*.log" -size +100M -delete
```

---

## 🎉 Success! You're Ready to Go

You now have a complete Kimi K2 setup that provides:

- ✅ 100x cost savings compared to Claude Opus
- ✅ Comprehensive usage and cost monitoring
- ✅ Multi-project management capabilities
- ✅ Automated installation and health checks
- ✅ Security best practices
- ✅ Detailed troubleshooting guides

**Start coding with Kimi K2 today and enjoy massive cost savings while maintaining excellent AI performance!**