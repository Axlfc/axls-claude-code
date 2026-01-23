# 🚀 axls-claude-code - Quick Setup (2 Minutes)

## Prerequisites Check

Run this first:
```bash
# Check Claude Code installed
claude --version
# Should show: Claude Code v2.0.XX or higher

# If not installed, install now:
curl -fsSL https://claude.ai/install.sh | bash  # macOS/Linux
# OR
irm https://claude.ai/install.ps1 | iex  # Windows PowerShell
```

## Setup (3 Steps)

### Step 1: Clone Repository
```bash
git clone https://github.com/Axlfc/axls-claude-code.git
cd axls-claude-code
```

### Step 2: Verify Structure
```bash
# Quick verification
ls .claude-plugin/plugin.json  # Should exist
ls .claude/skills/             # Should show 16 directories
ls .claude/commands/           # Should show 10 files
```

### Step 3: Load Plugin
```bash
# Method A: Quick test (temporary)
claude --plugin-dir .

# Method B: Install permanently (user scope)
/plugin marketplace add /full/path/to/axls-claude-code
/plugin install axls-claude-code

# Method C: Install permanently (project scope)
# Copy plugin files to project's .claude/ directory
```

## ✅ Verification

Inside Claude Code:
```
/plugin list
# Should show: axls-claude-code v1.2.1

/api-endpoint
# Should prompt for API details (command works)

Ask: "How do I design a PostgreSQL schema?"
# Should auto-activate postgres-expert skill
```

## 🐛 Troubleshooting

### Issue: Plugin doesn't load
```bash
# Clear cache
rm -rf ~/.claude/plugins/cache
claude --plugin-dir .
```

### Issue: Commands not showing
```bash
# Verify plugin.json
cat .claude-plugin/plugin.json | jq .
# Should be valid JSON

# Check frontmatter in commands
head -5 .claude/commands/api-endpoint.md
# Should show:
# ---
# description: ...
# ---
```

### Issue: Skills don't auto-activate
Skills activate based on `description` field keywords.
Check: `.claude/skills/[skill-name]/SKILL.md` frontmatter

---

## 📚 What You Get

- **10 Slash Commands:** `/api-endpoint`, `/component-new`, etc.
- **16 Skills:** Including converted agents (devops-engineer, postgres-expert, etc.)
- **2 Agents:** mcp-finder, security-engineer
- **Full Documentation:** See `docs/` directory

---

## 🆘 Still Having Issues?

1. Run `claude doctor` for diagnostics
2. Check [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)
3. Open an issue: https://github.com/Axlfc/axls-claude-code/issues

**Happy coding!** 🚀
