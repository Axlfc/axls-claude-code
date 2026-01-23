# Troubleshooting Guide

Common issues and solutions for axls-claude-code plugin.

## Installation Issues

### Plugin Not Loading

**Symptom:** `/plugin list` doesn't show axls-claude-code

**Solutions:**
```bash
# 1. Verify you're using correct flag
claude --plugin-dir /full/path/to/axls-claude-code

# 2. Check plugin.json is valid
cat .claude-plugin/plugin.json | jq .

# 3. Check Claude Code version
claude --version
# Must be 2.0.13 or higher
```

### Commands Not Appearing

**Symptom:** Slash commands don't show up in autocomplete

**Solutions:**
1. Verify all command files have `.md` extension
2. Check frontmatter has `description:` field
3. Restart Claude Code: `/exit` then relaunch

### Skills Not Activating

**Symptom:** Skills don't auto-activate when expected

**Solutions:**
```bash
# 1. Check hooks are enabled
ls -la .claude/hooks/

# 2. Verify skill-rules.json syntax
cat .claude/hooks/skill-rules.json | jq .

# 3. Check trigger keywords match your prompt
# See .claude/hooks/skill-rules.json for keyword lists

# 4. Lower confidence_threshold temporarily for testing
# Edit .claude/hooks/skill-rules.json
```

## Runtime Issues

### Command Generates Invalid Code

**Symptom:** Generated code has TypeScript errors

**Solutions:**
1. Check if using latest version of plugin
2. Review command definition in `.claude/commands/`
3. Ensure `tsconfig.json` has `strict: true`
4. Report issue with example prompt

### Skill Returns Incomplete Response

**Symptom:** Skill stops mid-response or seems truncated

**Solutions:**
1. Use `/clear` to reset context
2. Skill might be too long - check if using progressive disclosure
3. Try invoking skill manually instead of auto-activation

## Performance Issues

### Plugin Slows Down Claude Code

**Symptom:** Claude Code is slower with plugin loaded

**Solutions:**
```bash
# 1. Check for very large skill files
find .claude/skills -name "SKILL.md" -exec wc -l {} \; | sort -n

# 2. Ensure progressive disclosure is used
# SKILL.md files should be < 500 lines

# 3. Disable auto-activation temporarily
# Edit .claude/hooks/skill-rules.json
# Set "auto_activate": false for all skills
```

### Context Window Fills Quickly

**Symptom:** "Context window full" errors

**Solutions:**
1. Use `/clear` more frequently
2. Review CLAUDE.md - should be < 100 lines
3. Check skills aren't loading huge reference files unnecessarily

## Development Issues

### Tests Failing After Changes

**Symptom:** `npm test` shows failures

**Solutions:**
```bash
# 1. Ensure dependencies are installed
npm ci

# 2. Check TypeScript compilation
npm run build

# 3. Run tests with verbose output
npm test -- --verbose

# 4. Check if jest.config.ts is correct
```

### Linting Errors

**Symptom:** ESLint reports many errors

**Solutions:**
```bash
# 1. Auto-fix what's possible
npm run lint -- --fix

# 2. Check eslint.config.js is correct

# 3. Format code with Prettier
npm run format
```

## Common Error Messages

### "Skill not found: X"

**Cause:** Skill doesn't exist or has wrong name

**Solution:**
```bash
# Check skill exists
ls .claude/skills/

# Verify name in skill-rules.json matches directory name
```

### "Invalid JSON in plugin.json"

**Cause:** Syntax error in manifest

**Solution:**
```bash
# Validate JSON
cat .claude-plugin/plugin.json | jq .

# If error, fix the JSON syntax
```

### "Permission denied" when writing files

**Cause:** Claude Code doesn't have write permission

**Solution:**
1. Check settings.json permissions
2. Ensure sandbox mode allows file writes
3. Try running from different directory

## Getting Help

If these solutions don't resolve your issue:

1. **Check CHANGELOG.md** for known issues
2. **Search GitHub Issues** for similar problems
3. **Open a new issue** with:
   - Claude Code version
   - Plugin version
   - Steps to reproduce
   - Error messages/screenshots
   - Your OS and environment

## Debugging Tips

### Enable Verbose Logging
```bash
# Set environment variable
export CLAUDE_DEBUG=true
claude --plugin-dir .
```

### Test Commands Individually
```bash
# Test one command at a time
claude --plugin-dir .
# Then: /api-endpoint
# Check output carefully
```

### Verify Plugin Structure
```bash
# Ensure all required files exist
tree .claude/
tree .claude-plugin/

# Check file sizes
find .claude/skills -name "SKILL.md" -exec wc -l {} \;
```

---

**Still having issues?** Open an issue: https://github.com/Axlfc/axls-claude-code/issues
