---
name: pressbooks-pr-tldr
description: Use when writing or beautifying a pull request description for a Pressbooks org repository — generates a natural TLDR, clean "What changed" bullets, and "How to test" steps from the PR's commits and diff, then applies it with gh pr edit
---

# Pressbooks PR TLDR

## Overview

Turns a pull request into a clean, human description that people will actually
read. Reads the PR's commits and diff, drafts a short TLDR, a themed "What
changed" list, and numbered "How to test" steps, presents the draft for review,
and applies it to the PR on approval.

The whole point is to **not** look AI-generated. No link dumps, no pasted diffs,
no commit hashes, no file-path soup, no one-bullet-per-commit.

## When to Use

- "Beautify this PR", "clean up the PR description", "write a PR description"
- A PR number or URL given with that intent
- A branch with an open PR that has an empty or messy body

## When NOT to Use

- PRs in non-Pressbooks repositories
- Editing PR titles, labels, reviewers, or merge state
- Posting review comments
- Creating GitHub issues (use `generate-pressbooks-ticket`)

## Workflow

### Step 1: Identify the PR

Auto-detect from the current branch:

```bash
gh pr view --json number,title,url,headRefName 2>/dev/null
```

If that fails (no PR for the branch) or the user gave a number/URL, target that
PR explicitly. If it's genuinely ambiguous which PR is meant, ask — otherwise
proceed.

### Step 2: Gather material (run in parallel)

```bash
gh pr view <n> --json title,body,commits,headRefName,baseRefName,url,closingIssuesReferences
gh pr diff <n>
```

Read the diff and the changed-file list **for understanding only**. They inform
what the change does and how to test it — they never get quoted verbatim into
the output.

### Step 3: Draft the description

Build the body in exactly this structure:

```markdown
<TLDR paragraph>

### What changed

- <themed bullet>
- <themed bullet>

### How to test

1. <step>
2. <step>

Closes #123
```

- **TLDR** — 2–4 sentences. A human paragraph that leads with the point: what
  this change does and why it matters. Not a bullet list. Never starts with
  "This PR…".
- **What changed** — clean bullets grouped by theme (e.g. all the auth work in
  one bullet), not one bullet per commit. Describe behavior and intent, not
  files or functions.
- **How to test** — numbered steps a dev or tester can follow to verify the
  change. Derive them from the diff. When you're unsure of exact steps, make a
  sensible best guess and let the user correct it.
- **Issue links** — carry over any `Closes #N` / `Fixes #N` references found in
  the original body so GitHub auto-close still works. Put them on their own line
  at the end.

### Step 4: Present the draft

Show the full markdown body for review. Draft first, refine after — don't
interrogate the user before drafting. Let them correct what's wrong.

### Step 5: Apply on approval

```bash
gh pr edit <n> --body "$BODY"
```

Report the PR URL back.

## Style Rules (the anti-slop guardrails)

- Write like a teammate explaining the change, not a changelog bot.
- TLDR leads with the point, never "This PR…" or "This pull request…".
- No pasted diffs, no commit hashes, no file-path soup.
- No link dumps — the only links are preserved issue references.
- Bullets are grouped and meaningful, never a 1:1 echo of commit messages.
- Plain language. If a sentence reads like it was generated, rewrite it.

## Examples

**Bad TLDR (slop):**
> This PR introduces a series of changes across multiple files in order to
> implement the requested functionality. See the commits below for details.

**Good TLDR:**
> Sprint reports were silently dropping issues that had no iteration assigned.
> This pulls them into an "Unscheduled" bucket so nothing falls off the report,
> and tightens the date math that was off by a day near month boundaries.

**Bad "What changed" (one per commit, file soup):**
> - Update sprint-report.ts
> - Fix bug in projects.ts
> - Add tests
> - Address review comments

**Good "What changed" (themed, behavior):**
> - Unscheduled issues now appear in their own section instead of being dropped.
> - Iteration date ranges are computed in the project's timezone, fixing the
>   off-by-one near month ends.

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| One bullet per commit | Group bullets by theme |
| Pasting the diff or hashes | Describe behavior, never quote code |
| Link dumps in the body | Keep only preserved `Closes #` / `Fixes #` links |
| TLDR starts with "This PR…" | Lead with the point of the change |
| Dropping `Closes #123` from the old body | Carry issue refs over so auto-close still works |
| Applying without review | Always show the draft and wait for approval |
| Interrogating before drafting | Draft from the commits/diff first, refine after |
