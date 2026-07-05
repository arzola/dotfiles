---
name: generate-sprint-goal
description: Use when creating a sprint goal ticket for the Pressbooks tech team at the start of a new sprint iteration
---

# Generate Sprint Goal

## Overview

Automates sprint goal ticket creation for `pressbooks/private` by pulling iteration data from GitHub Project #95 ("Tech Team Backlog"), grouping items by workstream, and generating a formatted ticket after refining questions with the user.

**Always draft for review before creating the issue.**

## When to Use

- Start of a new sprint — creating the sprint goal ticket
- User says "create sprint goal", "new sprint", "sprint ticket"
- User references the Pressbooks tech team sprint planning

## When NOT to Use

- Creating individual story/bug tickets (use `generate-pressbooks-ticket`)
- Updating an existing sprint goal
- Sprint retrospectives or reports

## Workflow

### Step 1: Detect current iteration

Query Project #95 for iteration fields. Pick the iteration whose `startDate` is closest to today (current or next upcoming).

```bash
gh api graphql -f query='
query {
  organization(login: "pressbooks") {
    projectV2(number: 95) {
      field(name: "Iteration") {
        ... on ProjectV2IterationField {
          configuration {
            iterations {
              title
              startDate
              id
            }
          }
        }
      }
    }
  }
}'
```

Ask the user to confirm the iteration (show title + dates). If multiple are close, let them pick.

### Step 2: Fetch sprint backlog items

Query all items in the selected iteration. Extract: title, repo, issue URL, issue number, status, task owner, priority.

```bash
gh api graphql --paginate -f query='
query($cursor: String) {
  organization(login: "pressbooks") {
    projectV2(number: 95) {
      items(first: 100, after: $cursor) {
        pageInfo { hasNextPage endCursor }
        nodes {
          content {
            ... on Issue {
              title
              number
              url
              repository { name }
            }
            ... on PullRequest {
              title
              number
              url
              repository { name }
            }
          }
          fieldValues(first: 20) {
            nodes {
              ... on ProjectV2ItemFieldSingleSelectValue {
                name
                field { ... on ProjectV2SingleSelectField { name } }
              }
              ... on ProjectV2ItemFieldIterationValue {
                title
                startDate
                field { ... on ProjectV2IterationField { name } }
              }
            }
          }
        }
      }
    }
  }
}'
```

Filter items where `Iteration.title` matches the selected iteration. Exclude items with Status = "Icebox" or "Closed".

### Step 3: Group by workstream

Categorize items by repository into workstreams:

| Repos | Workstream Name |
|-------|----------------|
| `pressbooks-microcredentials`, `wp-lexical-editor` | Microcredentials |
| `pressbooks-content-checker`, `broken-link-checker` | Content Toolkit |
| `pressbooks`, `pressbooks-book`, `buckram`, theme repos (`pressbooks-malala`, `pressbooks-hamilton`, `pressbooks-graham`, etc.) | Platform & Bug Fixes |
| `pressbooks-aldine`, `pressbooks-network-analytics`, `pressbooks-network-catalog` | Network |
| `pressbooks-lti`, `pressbooks-results-for-lms` | LTI & LMS |
| `pressbooks-vip`, `pressbookspub-bedrock`, `pressbooksedu-bedrock`, other bedrock repos | Infrastructure |
| `private` | Operations |

If a workstream has only 1-2 low-priority items, consider merging it into "Platform & Bug Fixes" or "Other". Use judgment — the goal is 2-5 coherent workstreams, not one per repo.

Present the grouping to the user for review. They may want to rename, merge, or split workstreams.

### Step 4: Refining questions

Ask the user:

1. **Sprint number** — Suggest auto-increment. Check the last sprint goal:
   ```bash
   gh issue list --repo pressbooks/private --label "Sprint Goal" --limit 1 --json number,title
   ```
   Extract the sprint number from the title and suggest N+1.

2. **Per-workstream narrative** — For each workstream, show the items and ask:
   - "What's the one-sentence framing for {workstream} this sprint?" (becomes the bold header line)
   - "Walk me through the items briefly — I'll turn each into a bullet."
   - "Why does each of these matter?" (one bullet per item or grouped impact)

   Bullets should be terse (one line each). If a workstream has more than ~5
   items, push back: "That's a lot — should we split this into two
   workstreams, or are some items really sub-bullets of one larger goal?"

3. **Team capacity** — Ask:
   - Who is at full capacity this sprint?
   - Any PTO, reduced availability, or holidays?
   - Suggested capacity estimate (typical full sprint = ~70, adjust for absences)

4. **Out of scope** (optional) — "Anything explicitly out of scope this sprint?"

### Step 5: Generate the ticket

Produce markdown matching this exact format. **Each workstream uses a bold
header line followed by a bulleted list of items** — no long paragraphs.
The bullets should be one per concrete deliverable, terse, and link the
relevant tickets.

```markdown
# Sprint {N}

**Team:** Tech team

## Sprint Goal

**{Workstream 1}** — {One short framing sentence: the through-line of this workstream.}
- {Concrete deliverable 1} ([{repo}#{number}]({url}))
- {Concrete deliverable 2} ([{repo}#{number}]({url}))
- {Concrete deliverable 3} ([{repo}#{number}]({url}))

**{Workstream 2}** — {Same pattern.}
- ...

...

## Why This Matters

**{Workstream 1}** — {One short framing sentence: why this workstream matters.}
- {Concrete impact / user value 1}
- {Concrete impact / user value 2}

**{Workstream 2}** — {Same pattern.}
- ...

...

## Success Criteria

- [ ] {Description of outcome} ([{repo}#{number}]({url}))
- [ ] {Description of outcome} ([{repo}#{number}]({url}))
...

## Key Stories/Work Items

- {url}
- {url}
...

## Team Capacity

- **Full Sprint:** {names}
- **{Name}:** {PTO/availability note}
...
- **Capacity estimate:** ~{number} (accounting for {reasons})

- **Sprint:** {start date} – {end date}

**[{today's date}]** - Sprint Starts
```

**Format rules:**
- Each workstream has: `**Name** — {framing sentence}` then a `- ` bullet list
- Bullets should be terse (~one line each). Aim for 2-5 bullets per workstream;
  if a workstream needs more, the work likely belongs in two workstreams.
- Bullets in **Sprint Goal** describe what will be built/shipped
- Bullets in **Why This Matters** describe user/business impact
- Success criteria descriptions should be concise summaries, not copy-pasted titles
- Cross-repo links use format: `[repo-name#number](full-url)` inside bullets
- Key Stories section is bare URLs, one per line
- Dates use format: `Mon DD, YYYY` for sprint range, `YYYY-MM-DD` for the footer stamp
- Sprint date format in the range: `Apr 13 – Apr 23, 2026`

### Step 6: Review and create

1. Present the full draft to the user
2. Wait for approval or edits
3. Create the issue:
   ```bash
   gh issue create \
     --repo pressbooks/private \
     --title "Sprint Goal [${START_DATE} – ${END_DATE}]" \
     --label "Sprint Goal" \
     --body "${BODY}"
   ```
4. Optionally add to Project #95:
   ```bash
   gh project item-add 95 --owner pressbooks --url ${ISSUE_URL}
   ```

### Step 7: Offer to generate the sprint review Google Doc

After the issue is created, **always ask the user**:

> "Want me to generate the sprint review Google Doc now? (yes / wait until end of sprint)"

If yes, run the `gh-ops` CLI:

```bash
# Auto-detect the most recent Sprint Goal in pressbooks/private
gh-ops sprint review-agenda

# Or pass the new issue explicitly
gh-ops sprint review-agenda --sprint-goal pressbooks/private#${ISSUE_NUMBER}
```

The command:
- Parses the sprint goal body (sprint number, end date, workstream summaries, key story URLs)
- Looks up Project #95 status for each key story
- Copies the template Google Doc into the destination Drive folder
- Replaces `{{meeting_date}}`, `{{sprint_goals_url}}`, `{{sprint_backlog_url}}`, `{{sprint_goals_summary}}` placeholders
- Populates the async agenda table with one row pair per key story (sorted by workstream, then issue number)
- Adds clickable hyperlinks: `Sprint Goal` / `Sprint Backlog` text in headers, and `repo#N` in the More info column

**Markdown link cleanup happens automatically.** The Doc generator strips
`[label](url)` syntax, bare URLs, and parenthetical issue refs like
`(private#2392)` from the workstream summary and per-item Summary cells —
so the markdown you write here renders as clean prose in the Doc, while
GitHub still gets the rich links. Don't pre-strip your markdown to "help"
the renderer.

First-time setup (one-off): the user needs Google OAuth credentials at
`~/.config/gh-ops/google-credentials.json` — see `AGENTS.md` "Google API
Setup" for steps. After generation, status dropdowns must be set manually
(Docs API limitation — values are pre-filled as plain text in each Status
cell to make this fast).

## Reference: Project #95 Fields

| Field | Type | Values |
|-------|------|--------|
| Status | Single select | Icebox, New Issues, Needs Review, Product Backlog, Sprint Backlog, In Progress, Code Review, Testing/QA, Blocked, Ready for release, Closed |
| Priority | Single select | P0, P1, P2 |
| Iteration | Iteration | Rolling 2-week sprints |
| Task Owner | Single select | Amanda, Basak, Christopher, Dalcin, Darrin, Elsie, Ho Man, Jenn, John, Julie, Mich, Michelle, Oscar, Ricardo, Steel |

## Reference: Previous Sprint Goals

Sprint goals live in `pressbooks/private` with the `Sprint Goal` label. To review format:
```bash
gh issue list --repo pressbooks/private --label "Sprint Goal" --limit 5 --json number,title,url
```

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Including Icebox/Closed items | Filter by status — only active sprint items |
| Too many workstreams (7+) | Merge small groups into broader categories |
| Vague "Why This Matters" | Be specific: user impact, deadlines, dependencies |
| Missing cross-repo link format | Always use `[repo#number](url)` in success criteria |
| Forgetting capacity adjustments | Always ask about PTO, holidays, reduced availability |
| Creating without user review | **Always** draft first, create only after approval |
| Skipping Step 7 | After creating the issue, **always offer** to generate the sprint review Google Doc — don't assume the user will run it later |
| Stripping markdown links to "help" the Doc | Keep `[repo#N](url)` syntax in the issue body — the Doc generator cleans it automatically and GitHub needs the links |
| Long paragraphs under each workstream | Use the bullet format: `**Name** — framing` then `- ` items. The Doc generator renders bullets natively; paragraphs become unreadable walls of text. |
| More than ~5 bullets in one workstream | Split into two workstreams or group related items. Long lists hide the through-line. |
