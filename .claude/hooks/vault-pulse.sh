#!/bin/bash
# SessionStart hook: vault 상태 빠른 펄스 체크
# /autopilot보다 가볍게, 세션 시작 시 핵심 상태만 표시

VAULT_DIR="${CLAUDE_PROJECT_DIR:-/Users/jwpark95/Documents/Knowledge-OS}"
TODAY=$(date +%Y-%m-%d)

# 1. Inbox 미처리 항목 수
INBOX_COUNT=$(find "$VAULT_DIR/00-Inbox" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')

# 2. 미커밋 변경 수
UNCOMMITTED=$(git -C "$VAULT_DIR" status --porcelain 2>/dev/null | wc -l | tr -d ' ')

# 3. 마지막 커밋 날짜
LAST_COMMIT=$(git -C "$VAULT_DIR" log -1 --format="%cd" --date=short 2>/dev/null)

# 4. 오늘 Daily Note 존재 여부
DAILY="$VAULT_DIR/60-Daily/$(date +%Y)/$(date +%m)/$TODAY.md"
if [ -f "$DAILY" ]; then
  DAILY_STATUS="exists"
else
  DAILY_STATUS="missing"
fi

# 5. World Model 최종 갱신일
WM_UPDATED=""
if [ -f "$VAULT_DIR/_world-model.md" ]; then
  WM_UPDATED=$(grep "^updated:" "$VAULT_DIR/_world-model.md" | head -1 | sed 's/updated: //')
fi

# 출력
echo "📊 Vault Pulse | Inbox: ${INBOX_COUNT} | Uncommitted: ${UNCOMMITTED} | Last commit: ${LAST_COMMIT} | Daily Note: ${DAILY_STATUS} | World Model: ${WM_UPDATED:-none}"

exit 0
