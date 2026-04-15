---
name: plan
description: 구현 계획 생성/검토/실행 — Annotation Cycle 기반
---

Create, refine, or execute an implementation plan with annotation cycles.
Boris Tane 스타일의 "계획을 승인하기 전까지 실행하지 않는다" 원칙 적용.

Input: $ARGUMENTS

Parse the first word of $ARGUMENTS to determine the sub-command:

---

## Sub-command: `/plan [주제/설명]` (Create)

When $ARGUMENTS does NOT start with "refine" or "execute":

1. **Determine Project Context**:
   - If currently in a project context (active-context에 active_projects 존재):
     → Save to `10-Projects/[project]/plans/PLAN-YYYY-MM-DD-[slug].md`
   - If no project context or general topic:
     → Save to `30-Resources/plans/PLAN-YYYY-MM-DD-[slug].md`
   - Create `plans/` subdirectory if it doesn't exist

2. **Research Phase** (before writing plan):
   - Read existing related vault notes using `Grep` for keywords from $ARGUMENTS
   - Query `mcp__memory__search_nodes` for relevant context
   - If a research note already exists on this topic, read and incorporate it
   - Use `mcp__sequential-thinking__sequentialthinking` for complex analysis

3. **Generate Plan** using `templates/implementation-plan.md`:
   Apply frontmatter:
   ```yaml
   ---
   title: "Plan: [descriptive title]"
   created: [today YYYY-MM-DD]
   updated: [today YYYY-MM-DD]
   tags: [type/plan, project/xxx]
   type: plan
   status: draft
   project: "[project name if applicable]"
   ---
   ```

   Fill sections:
   - **Objective**: What we're trying to achieve and why
   - **Research Summary**: Key findings from vault + web (link to research notes)
   - **Approach**: Detailed implementation approach with code snippets, file paths
   - **Trade-offs**: Alternatives considered and why this approach was chosen
   - **File Changes**: Exact list of files to create/modify with expected changes
   - **Task Checklist**: Numbered `- [ ]` items for execution tracking
   - **Annotations**: Empty section — user will add inline notes here
   - **Execution Log**: Empty section — will be filled during /plan execute

4. **⛔ DO NOT IMPLEMENT ANYTHING**
   Stop here. Display:
   ```
   📋 Plan created: [file path]

   다음 단계:
   1. Obsidian(또는 에디터)에서 plan 파일을 열어 검토하세요
   2. 수정하고 싶은 부분에 인라인 주석을 추가하세요
      예: <!-- NOTE: drizzle:generate를 사용해주세요 -->
      예: <!-- TODO: 이 부분은 Redis 대신 in-memory cache로 -->
   3. 검토가 끝나면 /plan refine 을 실행하세요
   4. 만족할 때까지 refine을 반복하세요 (보통 1~3회)
   5. 최종 승인 후 /plan execute 로 실행하세요
   ```

5. **Store in mcp__memory**:
   - `mcp__memory__add_observations` to "active-context":
     `"active_plan: [file path] (status: draft)"`

---

## Sub-command: `/plan refine` (Annotation Cycle)

When $ARGUMENTS starts with "refine":

1. **Find Active Plan**:
   - Query `mcp__memory__open_nodes` for "active-context"
   - Parse `active_plan` observation for file path
   - If no active plan found → error: "활성 plan이 없습니다. /plan [주제]로 먼저 생성하세요."

2. **Read Current Plan**:
   - Read the plan file completely
   - Parse `## Annotations` section for user-added comments
   - Detect inline HTML comments: `<!-- NOTE: ... -->`, `<!-- TODO: ... -->`, `<!-- CHANGE: ... -->`
   - Detect direct text edits (compare with original structure)

3. **Process Annotations**:
   Use `mcp__sequential-thinking__sequentialthinking` to:
   - Categorize each annotation (correction, preference, constraint, question)
   - Determine impact on Approach, File Changes, and Task Checklist
   - Resolve conflicts between annotations

4. **Update Plan**:
   - Revise affected sections based on annotations
   - Move processed annotations to a `### Processed Annotations` subsection with responses
   - Clear the main Annotations section for next round
   - Update `updated:` frontmatter date
   - Update `status: review` (was draft)
   - Increment `revision: N` in frontmatter

5. **⛔ DO NOT IMPLEMENT ANYTHING**
   Display:
   ```
   🔄 Plan refined (revision N): [file path]

   변경 사항:
   - [annotation 1] → [반영 내용]
   - [annotation 2] → [반영 내용]

   다음 단계:
   - 추가 수정이 필요하면 → 주석 추가 후 /plan refine
   - 만족하면 → /plan execute
   ```

6. **Update mcp__memory**:
   - Update active_plan observation with revision count

---

## Sub-command: `/plan execute` (Implementation)

When $ARGUMENTS starts with "execute":

1. **Find Active Plan**:
   - Same as refine step 1
   - If plan status is "draft" → warn: "Plan이 아직 draft 상태입니다. 검토 없이 실행하시겠습니까?"

2. **Read Plan & Parse Checklist**:
   - Read the plan file
   - Extract `## Task Checklist` items
   - Parse `- [ ]` items as pending, `- [x]` as completed

3. **Update Status**:
   - Change frontmatter `status: in-progress`
   - Update mcp__memory active_plan status

4. **Execute Tasks Sequentially**:
   For each unchecked `- [ ]` item:
   - Execute the task (create files, edit code, run commands)
   - Mark as `- [x]` in the plan file immediately after completion
   - Add entry to `## Execution Log`:
     ```
     - [YYYY-MM-DD HH:MM] ✅ Task N: [description] — [result summary]
     ```
   - If a task fails:
     - Log the failure in Execution Log
     - Add `<!-- BLOCKED: [reason] -->` to the task
     - Continue to next task OR stop (depending on dependency)

5. **Completion**:
   - When all tasks done → change `status: completed`
   - Generate summary in Execution Log
   - Update mcp__memory:
     - Remove active_plan from active-context
     - Add to recent_topics
   - Link plan to relevant project MOC
   - Display:
     ```
     ✅ Plan executed: [file path]

     완료: N/N tasks
     실패: N tasks (see Execution Log)

     생성된 파일: [list]
     수정된 파일: [list]
     ```

---

## Post-Processing (all sub-commands)

- Update `mcp__memory` "active-context" with plan status
- If plan references a project, ensure project MOC is aware
- Link plan to related vault notes discovered during research

Output: Show the plan file path, current status, and appropriate next-step guidance.
