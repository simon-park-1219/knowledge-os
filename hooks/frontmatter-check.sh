#!/bin/bash
# PostToolUse(Write) hook: 새 .md 파일 frontmatter 검증
# Write 도구로 vault 내 .md 파일 생성 시 frontmatter 필수 필드 확인

# 환경변수에서 파일 경로 추출 (tool_input에서)
FILE_PATH="${TOOL_INPUT_FILE_PATH:-}"

# .md 파일이 아니면 무시
case "$FILE_PATH" in
  *.md) ;;
  *) exit 0 ;;
esac

# vault 내부 파일이 아니면 무시
VAULT_DIR="${CLAUDE_PROJECT_DIR:-.}"
case "$FILE_PATH" in
  "$VAULT_DIR"/*) ;;
  *) exit 0 ;;
esac

# 템플릿, .claude, 시스템 파일 제외
case "$FILE_PATH" in
  */50-Templates/*|*/.claude/*|*/_changelog.md|*/_master-index.md|*/_world-model.md|*/_Home.md|*/*-moc.md)
    exit 0 ;;
esac

# 파일이 존재하는지 확인
if [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

# frontmatter 검증
MISSING=""
HEAD=$(head -20 "$FILE_PATH")

if ! echo "$HEAD" | grep -q "^---" ; then
  echo "⚠️ Frontmatter 누락: $FILE_PATH"
  echo "YAML frontmatter(---로 시작)가 필요합니다. CLAUDE.md 규칙을 확인하세요."
  exit 0
fi

for FIELD in "title:" "created:" "type:" "status:" "tags:"; do
  if ! echo "$HEAD" | grep -q "$FIELD"; then
    MISSING="$MISSING $FIELD"
  fi
done

if [ -n "$MISSING" ]; then
  echo "⚠️ Frontmatter 필수 필드 누락:$MISSING (파일: $(basename "$FILE_PATH"))"
  echo "CLAUDE.md의 Note Creation Standards를 참조하세요."
fi

exit 0
