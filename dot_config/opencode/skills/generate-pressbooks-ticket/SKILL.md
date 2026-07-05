---
name: generate-pressbooks-ticket
description: Use when creating GitHub issues for any Pressbooks organization repository, following the standard user story format
---

# Generate Pressbooks Ticket

## Overview

Creates well-formatted user story tickets for any active Pressbooks org repository. Takes the user's description, drafts a complete ticket immediately, and presents it for review. Minimal questions — only ask which repo if it's ambiguous.

**Reference template:** See `user-story.yml` bundled with this skill.

## When to Use

- User says "create a ticket", "new issue", "write a story" for a Pressbooks repo
- User describes a feature, bug, or task that needs a GitHub issue
- User wants to formalize a rough idea into a proper user story

## When NOT to Use

- Sprint goal tickets (use `generate-sprint-goal`)
- Updating existing issues (use `gh issue edit` directly)
- Issues for non-Pressbooks repos

## Workflow

### Step 1: Determine the target repo

If the user hasn't specified a repo, infer it from context:

| Keywords | Repo |
|----------|------|
| "link checker" / "content checker" | `pressbooks-content-checker` |
| "broken links" / "scan service" | `broken-link-checker` |
| "microcredentials" / "MC" / "wizard" | `pressbooks-microcredentials` |
| "lexical" / "editor" | `wp-lexical-editor` |
| "theme" / "malala" / "hamilton" / "graham" | the specific theme repo |
| "core" / "pressbooks" / "export" / "PDF" | `pressbooks` |
| "LTI" / "LMS" | `pressbooks-lti` or `pressbooks-results-for-lms` |
| "aldine" / "root theme" | `pressbooks-aldine` |
| "private" / "ops" / "internal" | `private` |

**Only ask the user if you genuinely cannot determine the repo.** If asking, fetch the list and show filtered options:
```bash
gh repo list pressbooks --no-archived --limit 100 --json name --jq '.[].name' | sort
```

### Step 2: Fetch labels and draft the ticket

Do these in parallel:

1. **Fetch valid labels** for the repo:
   ```bash
   gh label list --repo pressbooks/{repo} --json name --limit 100
   ```

2. **Draft the complete ticket** from whatever the user provided (a sentence, bullet points, a paragraph — anything). Fill in ALL sections using your best judgment:

   Follow the field structure defined in `user-story.yml`:

   - **As a / I want / So that** — Extract from the user's description. Use specific Pressbooks roles: Book Administrator, Network Manager, Content Creator, Microcredential Author, API Consumer, Student/Learner, etc.
   - **Context** — Infer the problem being solved, reference related issues if mentioned
   - **Acceptance Criteria** — Derive behavioral outcomes (see table below)
   - **Out of Scope** — Infer logical boundaries (optional — omit if empty)
   - **Additional Context** — Catch-all for anything else relevant. Structure as sub-sections when appropriate:
     - **Dependencies** — `#{number} — brief description` (use `[x]` if already completed)
     - **Testing Notes** — Test scenarios and edge cases
     - **Technical Notes** — Implementation hints only if they add value
     - **Definition of Done** — Primary deliverable + code reviewed + tests passing

3. **Pick labels** from the fetched list based on content (enhancement/bug, frontend/backend, repo-specific labels).

### Step 3: Present the draft

Show the user:
1. **Target repo** and **suggested labels**
2. **Full ticket body** in the exact format below

The user will refine, approve, or request changes. Do NOT ask clarifying questions before drafting — just make your best attempt and let the user correct it.

### Step 4: Create the issue

After user approval:
```bash
gh issue create \
  --repo pressbooks/{repo} \
  --title "{concise title}" \
  --label "{label1}" --label "{label2}" \
  --body "${BODY}"
```

Optionally add to Project #95:
```bash
gh project item-add 95 --owner pressbooks --url ${ISSUE_URL}
```

Report the created issue URL back to the user.

## Ticket Format

Follow the field structure in `user-story.yml` — that file is the source of truth for required/optional sections and field order.

**Formatting rules:**
- H3 headers (`###`) for each section, matching the YML field labels exactly
- Acceptance Criteria use checkboxes (`- [ ]`)
- Out of Scope uses plain bullets (no checkboxes)
- Additional Context uses sub-sections (bold header + content) as needed
- Always include the required fields: As a / I want / So that / Context / Acceptance Criteria
- Omit optional fields (Out of Scope, Additional Context) only if there's genuinely nothing to say

**Acceptance criteria MUST be behavior-focused, not implementation-focused:**

| Bad (implementation detail) | Good (behavior-focused) |
|----------------------------|------------------------|
| Uses `wp_update_post()` to save | Content saves correctly when edited |
| DOM manipulation via DOMDocument | Link URL is updated in the post content |
| AJAX POST to admin-ajax.php | Action completes without full page reload |
| Adds `status` column via migration | Status persists across saves and scans |
| Uses `wp.media` frame API | Opens WordPress media library for selection |

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Asking too many questions before drafting | Draft first, refine after — the user will correct what's wrong |
| Implementation details in acceptance criteria | Rewrite as behavioral outcomes |
| Vague user role ("a user") | Be specific: "book administrator", "network manager", etc. |
| Suggesting labels that don't exist on the repo | Always fetch labels first |
| Creating without user review | **Never** create without showing the draft first |
