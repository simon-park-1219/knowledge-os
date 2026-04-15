---
name: garden
description: 지식 정원 관리 — orphan 노트, stale 콘텐츠, 링크 정리, 건강 점수 계산
---

Perform knowledge gardening on the vault.

Scope: $ARGUMENTS (default: "full" — runs all checks)

Run the Gardener Agent to perform these checks:

### 1. Orphan Note Detection
- Find notes with no incoming [[wikilinks]] from other notes
- Exclude: `60-Daily/*`, `50-Templates/*`, `*_*-moc.md` files
- Report each orphan with a suggested MOC or note to link from

### 2. Stale Content Check
- Find notes with `status: active` not updated in >30 days
- Suggest for each: update content / archive / leave as-is

### 3. Broken Link Detection
- Scan all `[[wikilinks]]` in the vault
- Find links pointing to non-existent notes
- Suggest: create a stub note / fix the link text

### 4. Frontmatter Validation
- Scan all .md files (excluding `50-Templates/`)
- Check for required fields: title, created, updated, tags, type, status
- Report missing fields per note

### 5. Tag Consistency
- Collect all tags used in the vault
- Compare against taxonomy in CLAUDE.md (type/, status/, project/, area/, priority/, person/)
- Suggest standardized replacements for non-standard tags

### 6. Inbox Triage
- List items in `00-Inbox/` that are >3 days old
- Suggest PARA destination for each

### 7. MOC Freshness
- Check all `_*-moc.md` files
- Flag MOCs that don't reflect recently added notes in their folder

### Before/After 스냅샷
가드닝 작업 전후로 상태를 기록한다:

**작업 전 (Before)**:
1. 현재 health score 계산 (7-point formula)
2. 카테고리별 이슈 수 기록: orphans, stale, broken, missing_fm, bad_tags, old_inbox, stale_moc
3. `mcp__memory` health-history에서 이전 score 조회하여 추세 확인

**작업 후 (After)**:
1. 동일 기준으로 health score 재계산
2. 변화량 산출: 각 카테고리별 before→after
3. `mcp__memory__add_observations`로 health-history에 기록:
   `"YYYY-MM-DD garden: score XX→YY (+Z), fixed: N orphans, M stale, K broken"`

**가드닝 리포트에 포함**:
```markdown
## 📊 Before / After

| 항목 | Before | After | 변화 |
|------|--------|-------|------|
| Health Score | XX | YY | +Z |
| Orphan Notes | N | N' | -K |
| Stale Notes | N | N' | -K |
| Broken Links | N | N' | -K |
| 추세 | 이전 3회: XX, YY, ZZ | | ↑ 개선 / → 유지 / ↓ 악화 |
```

Output a structured gardening report:

```markdown
## 🌱 Gardening Report

| Category | Count | Action Needed |
|----------|-------|---------------|
| Orphan Notes | X | Link or archive |
| Stale Notes | X | Review |
| Broken Links | X | Fix |
| Missing Frontmatter | X | Add |
| Non-standard Tags | X | Rename |
| Inbox Items | X | Triage |
| Stale MOCs | X | Regenerate |

**Health Score**: X/100
```

### 전문 영역: 가드닝 품질 기준
- **Before/After 스냅샷**: 작업 시작 전 health score를 기록하고, 작업 완료 후 변화량을 보고
- **우선순위 기반**: broken links(×5) > stale(×3) > missing frontmatter(×3) > orphans(×2) 순으로 처리
- **안전 우선**: 자동 수정은 frontmatter만. 본문 변경이나 삭제는 보고만
- **추세 분석**: mcp__memory health-history와 비교하여 개선/악화 추세를 포함

Store gardening results in `mcp__memory` for trend tracking across sessions.
