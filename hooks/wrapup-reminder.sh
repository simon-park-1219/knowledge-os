#!/bin/bash
# Stop hook: /wrapup 리마인더
# 세션 종료 시 wrapup을 실행하지 않았으면 알림

VAULT_DIR="${CLAUDE_PROJECT_DIR:-.}"
TODAY=$(date +%Y-%m-%d)
DAILY_NOTE="$VAULT_DIR/60-Daily/$(date +%Y)/$(date +%m)/$TODAY.md"

# Daily Note에 "Session Summary" 섹션이 있으면 이미 wrapup 실행한 것
if [ -f "$DAILY_NOTE" ] && grep -q "Session Summary" "$DAILY_NOTE" 2>/dev/null; then
  exit 0
fi

# git으로 이 세션에서 변경된 파일 수 확인
CHANGED=$(git -C "$VAULT_DIR" diff --name-only 2>/dev/null | wc -l | tr -d ' ')
STAGED=$(git -C "$VAULT_DIR" diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')
TOTAL=$((CHANGED + STAGED))

if [ "$TOTAL" -gt 2 ]; then
  echo "💡 이 세션에서 ${TOTAL}개 파일이 변경되었지만 /wrapup이 실행되지 않았습니다."
  echo "TIL 기록과 컨텍스트 저장을 위해 /wrapup 실행을 권장합니다."
fi

exit 0
