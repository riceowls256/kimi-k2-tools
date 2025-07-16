# Changelog

All notable changes to Kimi K2 Tools will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2024-07-16

### Added
- Initial release of Kimi K2 Tools for Claude Code
- **Core Tools**:
  - `kimi-claude` - Main wrapper for Claude Code with Kimi K2
  - `kimi-dashboard` - Interactive cost monitoring dashboard
  - `kimi-usage` - Command-line usage tracking and reports
  - `claude-switcher` - Provider switching between Anthropic and Kimi K2
  - `init-kimi-project` - Project initialization with Kimi K2 configuration

- **Cost Monitoring System**:
  - Real-time usage tracking with Python-based tracker
  - Automatic cost calculation (100x cheaper than Claude Opus)
  - Daily/weekly/monthly usage reports
  - Spending alerts and budget management
  - Interactive dashboard with cost comparisons

- **Configuration Management**:
  - `.env` file support with priority loading
  - Global and per-project configuration options
  - API key management and validation
  - Environment variable support
  - Secure file permissions

- **Installation & Setup**:
  - Automated `install.sh` script
  - Health check diagnostics (`health-check.sh`)
  - Project templates and initialization
  - PATH integration and shell profile updates

- **Multi-Project Support**:
  - Project-specific configurations
  - Isolated environments per project
  - Easy provider switching
  - Team collaboration tools

- **Documentation**:
  - Comprehensive user guide
  - Installation instructions
  - Troubleshooting guides
  - Security best practices
  - API reference

- **Security Features**:
  - API key encryption and secure storage
  - Automatic `.gitignore` setup
  - File permission management
  - Environment variable protection

### Features
- **100x cost savings** compared to Claude Opus
- **Similar performance** (65.8% SWE-bench score)
- **Seamless integration** with existing Claude Code workflows
- **Comprehensive monitoring** and cost tracking
- **Multi-project management** capabilities
- **Production-ready** installation and setup

### Cost Benefits
- Input tokens: $0.15/1M vs $15.00/1M (100x cheaper)
- Output tokens: $2.50/1M vs $75.00/1M (30x cheaper)
- Real-world savings: $6.50 vs $300 for typical development session

### Supported Platforms
- macOS (bash/zsh)
- Linux (bash/zsh)
- Windows Subsystem for Linux (WSL)

### Requirements
- Claude Code installed
- Python 3.6+
- bash shell
- curl

[Unreleased]: https://github.com/yourusername/kimi-k2-tools/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/yourusername/kimi-k2-tools/releases/tag/v1.0.0