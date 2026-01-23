# Contributing to axls-claude-code

Thank you for your interest in contributing! This document provides guidelines for contributing to this Claude Code plugin.

## Development Setup

### Prerequisites
- Node.js 18+ and npm
- Claude Code CLI 2.0.13+
- Git configured with your credentials

### Getting Started
```bash
# Clone the repository
git clone https://github.com/Axlfc/axls-claude-code.git
cd axls-claude-code

# Test the plugin locally
claude --plugin-dir .
```

## How to Contribute

### Reporting Issues
- Use GitHub Issues
- Include Claude Code version
- Provide steps to reproduce
- Share error messages/screenshots

### Suggesting Features
- Open an issue with [Feature Request] prefix
- Describe the use case clearly
- Explain why it benefits the plugin

### Code Contributions

#### Branch Naming
- `feature/description` - New features
- `fix/description` - Bug fixes
- `docs/description` - Documentation
- `refactor/description` - Code refactoring

#### Commit Messages
Follow [Conventional Commits](https://www.conventionalcommits.org/):
```
feat: add new command for X
fix: resolve issue with Y
docs: update README with Z
refactor: optimize skill for better performance
test: add tests for command X
```

#### Code Standards
- **TypeScript:** Strict mode, no `any` types
- **Formatting:** Run `npm run format` before committing
- **Linting:** Run `npm run lint` and fix all errors
- **Tests:** Add tests for new features
- **Documentation:** Update relevant docs

#### Pull Request Process
1. Create a feature branch from `main`
2. Make your changes following code standards
3. Test locally with `claude --plugin-dir .`
4. Update CHANGELOG.md (Unreleased section)
5. Create PR with clear description
6. Wait for review and address feedback

### Adding Commands
```bash
# 1. Create command file
touch .claude/commands/my-command.md

# 2. Add frontmatter and instructions
cat > .claude/commands/my-command.md << 'EOF'
---
description: Brief description of what this command does
---

[Detailed instructions for Claude]
EOF

# 3. Test the command
claude --plugin-dir .
# Then: /my-command

# 4. Document in docs/COMMANDS_REFERENCE.md
```

### Adding Skills
```bash
# 1. Create skill directory
mkdir -p .claude/skills/my-skill

# 2. Create SKILL.md
touch .claude/skills/my-skill/SKILL.md

# 3. Add progressive disclosure files if needed
touch .claude/skills/my-skill/examples.md
touch .claude/skills/my-skill/reference.md

# 4. Test the skill
claude --plugin-dir .

# 5. Document in docs/SKILLS_REFERENCE.md
```

## Code Review Criteria

### All PRs Must:
- ✅ Pass all linting checks
- ✅ Include tests (for code changes)
- ✅ Update documentation
- ✅ Follow TypeScript strict mode
- ✅ Not break existing functionality
- ✅ Update CHANGELOG.md

### Quality Standards
- Functions < 50 lines
- No `any` types (use `unknown` if needed)
- Proper error handling
- Meaningful variable names
- Comments only for complex logic

## Questions?

- Open a GitHub Discussion
- Tag @Axlfc in issues
- Read existing documentation in `docs/`

Thank you for contributing! 🚀
