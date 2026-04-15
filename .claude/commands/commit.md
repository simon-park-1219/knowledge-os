Commit vault changes to git.

Message: $ARGUMENTS (optional — if not provided, auto-generate from changes)

Follow this process:

1. **Check Status**: Run `git status` in the vault directory
   - Show untracked files
   - Show modified files
   - Show deleted files

2. **Review Changes**: Run `git diff` to see what changed

3. **Generate Commit Message** (if $ARGUMENTS is empty):
   - Analyze the changes
   - Use conventional commit format: `docs:`, `feat:`, `fix:`, `refactor:`, `chore:`
   - Examples:
     - `docs: add meeting notes for 2026-02-17`
     - `feat: create lean canvas for project X`
     - `chore: garden vault — fix 3 broken links`

4. **Stage & Commit**:
   - `git add` relevant files (be specific, not `git add .`)
   - `git commit -m "[message]"`

5. **Show Result**: Display the commit hash and summary

Safety:
- Never commit files matching `.gitignore` patterns
- Never commit `.env` or files with secrets
- Show changes before committing and ask for confirmation if changes are large (>10 files)
