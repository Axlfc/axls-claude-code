#!/bin/bash
# Plugin Verification Script for axls-claude-code
# Run before committing changes to ensure plugin works

set -e

echo "🔍 Verifying axls-claude-code plugin structure..."

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0

# Task 1: Verify plugin.json exists and is valid
echo -n "Checking plugin.json... "
if [ ! -f ".claude-plugin/plugin.json" ]; then
  echo -e "${RED}FAIL${NC} - File not found"
  ERRORS=$((ERRORS + 1))
elif ! jq empty .claude-plugin/plugin.json 2>/dev/null; then
  echo -e "${RED}FAIL${NC} - Invalid JSON"
  ERRORS=$((ERRORS + 1))
else
  echo -e "${GREEN}OK${NC}"
fi

# Task 2: Verify version is correct
echo -n "Checking version... "
VERSION=$(jq -r '.version' .claude-plugin/plugin.json 2>/dev/null || echo "unknown")
if [ "$VERSION" != "1.2.1" ]; then
  echo -e "${YELLOW}WARN${NC} - Version is $VERSION, expected 1.2.1"
  WARNINGS=$((WARNINGS + 1))
else
  echo -e "${GREEN}OK${NC} ($VERSION)"
fi

# Task 3: Count skills
echo -n "Counting skills... "
SKILL_COUNT=$(ls -d .claude/skills/*/ 2>/dev/null | wc -l | tr -d ' ')
EXPECTED_SKILLS=16  # Updated: 2026-01-24 (12 original + 4 converted agents)
if [ "$SKILL_COUNT" != "$EXPECTED_SKILLS" ]; then
  echo -e "${YELLOW}WARN${NC} - Found $SKILL_COUNT, expected $EXPECTED_SKILLS"
  WARNINGS=$((WARNINGS + 1))
else
  echo -e "${GREEN}OK${NC} ($EXPECTED_SKILLS skills)"
fi

# Task 4: Count commands
echo -n "Counting commands... "
CMD_COUNT=$(ls -1 .claude/commands/*.md 2>/dev/null | wc -l | tr -d ' ')
EXPECTED_COMMANDS=10  # Updated: 2026-01-24
if [ "$CMD_COUNT" != "$EXPECTED_COMMANDS" ]; then
  echo -e "${YELLOW}WARN${NC} - Found $CMD_COUNT, expected $EXPECTED_COMMANDS"
  WARNINGS=$((WARNINGS + 1))
else
  echo -e "${GREEN}OK${NC} ($EXPECTED_COMMANDS commands)"
fi

# Task 5: Count agents
echo -n "Counting agents... "
AGENT_COUNT=$(ls -1 .claude/agents/*.md 2>/dev/null | wc -l | tr -d ' ')
EXPECTED_AGENTS=2  # Updated: 2026-01-24 (after agent-to-skill conversion)
if [ "$AGENT_COUNT" != "$EXPECTED_AGENTS" ]; then
  echo -e "${YELLOW}WARN${NC} - Found $AGENT_COUNT, expected $EXPECTED_AGENTS"
  WARNINGS=$((WARNINGS + 1))
else
  echo -e "${GREEN}OK${NC} ($EXPECTED_AGENTS agents)"
fi

# Task 6: Verify command frontmatters
echo "Checking command frontmatters..."
for cmd in .claude/commands/*.md; do
  CMD_NAME=$(basename "$cmd")
  if ! head -10 "$cmd" | grep -q "^description:"; then
    echo -e "  ${RED}FAIL${NC} - $CMD_NAME missing 'description:' in frontmatter"
    ERRORS=$((ERRORS + 1))
  else
    echo -e "  ${GREEN}OK${NC} - $CMD_NAME"
  fi
done

# Task 7: Verify skill frontmatters (sample)
echo "Checking skill frontmatters (sample)..."
for skill_dir in .claude/skills/devops-engineer .claude/skills/postgres-expert .claude/skills/n8n-workflow-expert .claude/skills/zustand-expert; do
  SKILL_NAME=$(basename "$skill_dir")
  SKILL_FILE="$skill_dir/SKILL.md"

  if [ ! -f "$SKILL_FILE" ]; then
    echo -e "  ${RED}FAIL${NC} - $SKILL_NAME: SKILL.md not found"
    ERRORS=$((ERRORS + 1))
    continue
  fi

  HAS_NAME=$(head -10 "$SKILL_FILE" | grep -c "^name:" || true)
  HAS_DESC=$(head -10 "$SKILL_FILE" | grep -c "^description:" || true)

  if [ "$HAS_NAME" = "0" ] || [ "$HAS_DESC" = "0" ]; then
    echo -e "  ${RED}FAIL${NC} - $SKILL_NAME: Missing name or description in frontmatter"
    ERRORS=$((ERRORS + 1))
  else
    echo -e "  ${GREEN}OK${NC} - $SKILL_NAME"
  fi
done

# Task 8: Check for non-standard files (old hooks)
echo "Checking for non-standard files..."
if [ -f ".claude/hooks/skill-rules.json" ]; then
  echo -e "  ${RED}ERROR${NC} - Found skill-rules.json (should be removed)"
  ERRORS=$((ERRORS + 1))
fi
if [ -f ".claude/hooks/skill-activation-prompt.md" ]; then
  echo -e "  ${RED}ERROR${NC} - Found skill-activation-prompt.md (should be removed)"
  ERRORS=$((ERRORS + 1))
fi

# Final report
echo ""
echo "=========================="
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
  echo -e "${GREEN}✅ ALL CHECKS PASSED${NC}"
  echo "Plugin is ready to use!"
  exit 0
elif [ $ERRORS -eq 0 ]; then
  echo -e "${YELLOW}⚠️  $WARNINGS WARNING(S)${NC}"
  echo "Plugin will work but some counts may be off"
  exit 0
else
  echo -e "${RED}❌ $ERRORS ERROR(S), $WARNINGS WARNING(S)${NC}"
  echo "Plugin may not work correctly. Fix errors above."
  exit 1
fi
