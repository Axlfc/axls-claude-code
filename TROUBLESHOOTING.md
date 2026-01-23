## Plugin Loading Issues (Common)

### Symptom: Plugin Shows "Installed" But Not Working

**Diagnosis:**
```bash
# Check if plugin files exist
ls -la .claude-plugin/plugin.json
ls -la .claude/skills/
ls -la .claude/commands/

# Verify JSON validity
jq empty .claude-plugin/plugin.json && echo "Valid" || echo "Invalid JSON"
```

**Fix:**
```bash
# Method 1: Clear cache and reload
rm -rf ~/.claude/plugins/cache
claude --plugin-dir .

# Method 2: Reinstall plugin
/plugin uninstall axls-claude-code
/plugin install axls-claude-code
```

### Symptom: Commands Don't Appear in Autocomplete

**Cause:** Missing or invalid frontmatter in command files

**Fix:**
```bash
# Each .md file in .claude/commands/ must have:
# ---
# description: Brief description of command
# ---

# Verify all commands have frontmatter
for cmd in .claude/commands/*.md; do
  echo "Checking: $cmd"
  head -5 "$cmd" | grep -q "description:" || echo "  ❌ MISSING FRONTMATTER"
done
```

### Symptom: Skills Don't Auto-Activate

**Cause:** Skills rely on `description` field in SKILL.md frontmatter

**Fix:**
1. Open `.claude/skills/[skill-name]/SKILL.md`
2. Verify frontmatter has both `name:` and `description:`
3. Ensure `description` includes trigger keywords
4. Restart Claude Code

**Example good frontmatter:**
```yaml
---
name: postgres-expert
description: PostgreSQL DBA expertise for schema design, query optimization, and high-performance database architecture. Use when working with PostgreSQL, database schemas, SQL queries, indexes, or performance tuning.
---
```

### Symptom: "Failed to Install Marketplace" Notification

**Note:** This is a known bug in Claude Code 2.0.76+ with npm installations.

**Status:** Harmless - can be ignored if plugins load successfully

**Verify plugins loaded:**
```bash
claude --plugin-dir .
# Inside Claude:
/plugin list
# If your plugin appears, the notification is false positive
```
