#!/bin/bash
# Daily Autopilot — cron으로 매일 자동 실행
# 사용자 입력 없이 vault 유지보수를 수행하고 결과를 Daily Note에 기록

set -e

VAULT_DIR="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
TODAY=$(date +%Y-%m-%d)
YEAR=$(date +%Y)
MONTH=$(date +%m)
LOG_DIR="$VAULT_DIR/.claude/logs"
LOG_FILE="$LOG_DIR/autopilot-$TODAY.log"

mkdir -p "$LOG_DIR"

echo "[$TODAY $(date +%H:%M)] Daily Autopilot 시작" >> "$LOG_FILE"

# 1. Daily Note 자동 생성 (없으면)
DAILY_DIR="$VAULT_DIR/60-Daily/$YEAR/$MONTH"
DAILY_NOTE="$DAILY_DIR/$TODAY.md"

if [ ! -f "$DAILY_NOTE" ]; then
  mkdir -p "$DAILY_DIR"
  cat > "$DAILY_NOTE" << DAILYEOF
---
title: "$TODAY"
created: $TODAY
updated: $TODAY
tags: [type/daily]
type: daily
status: active
---

# $TODAY

## Plan / 오늘의 계획
-

## Work Log / 작업 기록
-

## TIL / 오늘의 인사이트
-

## Related Notes
-
DAILYEOF
  echo "  Daily Note 생성: $DAILY_NOTE" >> "$LOG_FILE"
fi

# 2. Claude CLI로 vault 점검 실행 (비대화형, 90초 timeout)
cd "$VAULT_DIR"
# gtimeout (coreutils) 있으면 사용, 없으면 직접 실행
TIMEOUT_CMD=""
command -v gtimeout &>/dev/null && TIMEOUT_CMD="gtimeout 90"
CLAUDE_RESULT=$($TIMEOUT_CMD claude -p "다음을 수행하고 결과만 간결히 보고하세요 (파일 수정은 안전한 auto-fix만):
1. 00-Inbox/ 에 미분류 노트가 있으면 개수와 제목 나열
2. frontmatter에 updated: 필드가 누락된 노트가 있으면 오늘 날짜로 auto-fix
3. _world-model.md를 현재 프로젝트 상태 기반으로 갱신
4. 결과를 3줄 이내로 요약" 2>>"$LOG_FILE" || echo "Claude CLI 실행 실패 (exit $?)")

# 3. 결과를 Daily Note에 기록
if [ -n "$CLAUDE_RESULT" ] && [ "$CLAUDE_RESULT" != "Claude CLI 실행 실패" ]; then
  cat >> "$DAILY_NOTE" << RESULTEOF

## 🤖 Daily Autopilot (자동 실행 $(date +%H:%M))

$CLAUDE_RESULT
RESULTEOF
  echo "  결과를 Daily Note에 기록 완료" >> "$LOG_FILE"
fi

# 4. 미커밋 변경이 있으면 자동 커밋
CHANGED=$(git -C "$VAULT_DIR" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
if [ "$CHANGED" -gt 0 ]; then
  git -C "$VAULT_DIR" add -A
  git -C "$VAULT_DIR" commit -m "chore: daily autopilot — auto-fix $CHANGED files ($TODAY)" 2>>"$LOG_FILE" || true
  echo "  자동 커밋: $CHANGED files" >> "$LOG_FILE"
fi

echo "[$TODAY $(date +%H:%M)] Daily Autopilot 완료" >> "$LOG_FILE"
