# Contributing to Kimi K2 Tools

Thank you for your interest in contributing to Kimi K2 Tools! This project helps developers use Moonshot AI's Kimi K2 with Claude Code at 100x cost savings.

## 🚀 Quick Start

1. **Fork the repository**
2. **Clone your fork**:
   ```bash
   git clone https://github.com/riceowls256/kimi-k2-tools.git
   cd kimi-k2-tools
   ```
3. **Test the installation**:
   ```bash
   ./install.sh
   ```

## 🛠️ Development Setup

### Prerequisites
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code/quickstart) installed
- Python 3.x
- bash shell
- curl

### Local Development
```bash
# Make scripts executable
chmod +x bin/* monitoring/*

# Test with debug mode
export KIMI_DEBUG=true
./bin/kimi-claude --check
```

## 📝 How to Contribute

### Reporting Bugs
1. **Check existing issues** first
2. **Use our bug report template**
3. **Include**:
   - OS and shell version
   - Claude Code version
   - Complete error messages
   - Steps to reproduce

### Suggesting Features
1. **Open an issue** with the "enhancement" label
2. **Describe the use case** and expected behavior
3. **Consider backwards compatibility**

### Code Contributions

#### Areas We Welcome Help
- **Cost optimization features**
- **Additional monitoring tools**
- **Platform support** (Windows, additional shells)
- **Integration with other tools**
- **Performance improvements**
- **Documentation improvements**

#### Pull Request Process
1. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**:
   - Follow existing code style
   - Add tests if applicable
   - Update documentation

3. **Test thoroughly**:
   ```bash
   # Test installation
   ./install.sh
   
   # Test health check
   ./monitoring/health-check.sh
   
   # Test core functionality
   ./bin/kimi-claude --info
   ```

4. **Commit with clear messages**:
   ```bash
   git commit -m "feat: add new cost monitoring feature"
   git commit -m "fix: resolve .env loading issue"
   git commit -m "docs: update installation guide"
   ```

5. **Push and create PR**:
   ```bash
   git push origin feature/your-feature-name
   ```

## 📋 Code Guidelines

### Shell Scripts
- Use `#!/bin/bash`
- Enable strict mode: `set -euo pipefail`
- Quote variables: `"$variable"`
- Use meaningful function names
- Add error handling
- Include usage help

### Python Scripts
- Python 3.6+ compatibility
- Follow PEP 8 style guide
- Include type hints where appropriate
- Add docstrings for functions
- Handle exceptions gracefully

### Documentation
- Use clear, concise language
- Include code examples
- Update README.md if needed
- Keep docs in sync with code

## 🧪 Testing

### Manual Testing Checklist
- [ ] Installation script works
- [ ] `.env` file loading works
- [ ] API key configuration works
- [ ] Cost tracking functions
- [ ] Health checks pass
- [ ] Error handling works

### Automated Tests
We welcome contributions to add automated testing:
- Unit tests for Python components
- Integration tests for shell scripts
- CI/CD pipeline improvements

## 🔐 Security

### Reporting Security Issues
- **Do not** open public issues for security vulnerabilities
- Email security concerns to maintainers
- We'll respond within 48 hours

### Security Guidelines
- Never commit API keys or secrets
- Use secure file permissions (600) for sensitive files
- Validate all user inputs
- Follow principle of least privilege

## 📚 Documentation

### Areas Needing Documentation
- Advanced configuration options
- Troubleshooting guides
- Integration examples
- Performance tuning tips

### Documentation Style
- Use GitHub Flavored Markdown
- Include practical examples
- Keep it beginner-friendly
- Add screenshots when helpful

## 🎯 Project Priorities

### High Priority
- Windows/PowerShell support
- Additional cost monitoring features
- Performance optimizations
- Better error messages

### Medium Priority
- GUI dashboard
- Docker container support
- Integration with other AI tools
- Advanced usage analytics

### Low Priority
- Mobile companion app
- Web-based configuration
- Team management features

## 💬 Community

### Getting Help
- **GitHub Issues**: Bug reports and feature requests
- **Discussions**: General questions and ideas
- **Documentation**: Check the [User Guide](docs/USER_GUIDE.md)

### Code of Conduct
- Be respectful and inclusive
- Focus on constructive feedback
- Help newcomers learn
- Maintain professional communication

## 🏆 Recognition

Contributors will be:
- Listed in the README.md
- Credited in release notes
- Invited to join the maintainer team (for significant contributions)

## 📋 Release Process

1. **Version Bump**: Update version in relevant files
2. **Changelog**: Document changes in CHANGELOG.md
3. **Testing**: Run full test suite
4. **Tagging**: Create git tag with semantic versioning
5. **Release**: Create GitHub release with notes

## 🤝 Questions?

Don't hesitate to ask questions! We're here to help:
- Open a Discussion for general questions
- Open an Issue for specific problems
- Check existing documentation first

Thank you for contributing to making AI development more affordable and accessible! 🚀