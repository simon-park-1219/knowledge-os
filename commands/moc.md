Generate or update a Maps of Content (MOC) file.

Target: $ARGUMENTS (folder path, topic name, or "all" to regenerate all MOCs)

Follow this process:

1. **Determine Scope**:
   - If $ARGUMENTS is a folder path → MOC for that folder
   - If $ARGUMENTS is a topic → Find related notes across vault
   - If $ARGUMENTS is "all" → Regenerate all `_*-moc.md` files

2. **Scan**: Use `Glob` and `Read` to find all .md files in the target area
   - Read frontmatter from each file
   - Collect: title, type, status, tags, updated, project

3. **Categorize notes by**:
   - Status (active, draft, archived)
   - Type (spec, bug, meeting, decision, etc.)
   - Recent activity (sorted by updated date)

4. **Generate/Update MOC** (`_[folder-name]-moc.md`):
   - Use the template from `templates/moc-template.md` as base
   - Include Dataview queries for dynamic content
   - Add manually curated sections for key notes
   - Include statistics (total count, active count)
   - List orphan notes in the area

5. **Preserve Manual Content**: If the MOC already exists:
   - Keep any manually curated sections
   - Update auto-generated sections only
   - Update the `updated` date in frontmatter

6. **Set proper frontmatter**:
   ```yaml
   ---
   title: "MOC: [Area Name]"
   created: [original or today]
   updated: [today]
   tags: [type/moc]
   type: moc
   status: active
   ---
   ```

Output: List all MOCs created/updated and the note count in each.
