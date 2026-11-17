# Collaboration workflow

How work moves from your machine into `main` in this repository.

> **The short rule:** `main` is read-only for everyone. You work on a branch,
> push the branch, open a pull request, get it reviewed, and merge. Nobody —
> including the maintainer — commits or pushes directly to `main`.

---

## Contents

1. [Why branches and pull requests](#why-branches-and-pull-requests)
2. [One-time setup](#one-time-setup)
3. [The daily loop](#the-daily-loop)
4. [Opening the pull request](#opening-the-pull-request)
5. [Review, update, merge](#review-update-merge)
6. [Enforcing the workflow](#enforcing-the-workflow)
7. [Troubleshooting](#troubleshooting)
8. [FAQ](#faq)

---

## Why branches and pull requests

| Problem without PRs | What the PR process gives you |
| --- | --- |
| `git push origin main` fails halfway through someone's work and `main` is broken for everyone | `main` only ever receives commits that passed CI and review |
| Nobody knows what changed or why | Every change has a description, a diff, and a review thread |
| Two people edit the same file and overwrite each other | Conflicts surface on the branch, before merge |
| "Who broke this?" | `git log main` lists one squashed commit per PR, linked to the discussion |

This is not ceremony — with several people in one small codebase, it is the
difference between a project that stays shippable and one that stalls.

---

## One-time setup

```bash
# Clone (or use the clone you already have)
git clone https://github.com/TensorTrail766/Computer_Store_MS.git
cd Computer_Store_MS

# Turn on the local guards: blocks pushes to main, sanity-checks commit messages
bash scripts/setup-hooks.sh

# Python environment
python3 -m venv .venv
source .venv/bin/activate          # Windows: .venv\Scripts\activate
[ -f requirements.txt ] && pip install -r requirements.txt
```

Set your identity so commit attribution is correct:

```bash
git config user.name  "Your Name"
git config user.email "you@example.com"
```

Verify the guards are active — this should print the hooks path:

```bash
git config core.hooksPath        # → .githooks
```

---

## The daily loop

### 1. Always start from a fresh `main`

```bash
git switch main
git pull --ff-only
```

`--ff-only` refuses to create a merge commit on `main` by accident. If it
complains, your local `main` has diverged — see
[Troubleshooting](#i-committed-to-main-by-mistake).

### 2. Create a branch for your task

```bash
git switch -c feature/add-checkout-total
```

Naming convention:

| Prefix | Use for | Example |
| --- | --- | --- |
| `feature/` | new functionality | `feature/add-checkout-total` |
| `fix/` | bug fixes | `fix/order-total-rounding` |
| `docs/` | documentation only | `docs/setup-instructions` |
| `refactor/` | restructuring, no behaviour change | `refactor/split-query-layer` |
| `chore/` | tooling, dependencies, CI | `chore/bump-dependencies` |
| `test/` | tests only | `test/order-total-coverage` |

Use lowercase words separated by hyphens. `my-branch` or `patch-1` tells a
reviewer nothing.

### 3. Commit in small, honest steps

```bash
git status                      # know what you are about to add
git add -p                      # stage deliberately, hunk by hunk
git commit -m "add checkout total calculation"
```

Check the message reads like an instruction to your future self:

```
✓ add checkout total calculation to checkout page
✓ fix rounding error in subtotal display
✓ document Oracle connection setup
✗ wip
✗ update
✗ asdf
✗ fixed stuff
```

The `commit-msg` hook rejects empty messages and warns about vague or overly
long subjects.

### 4. Keep your branch current

If `main` moved while you worked:

```bash
git fetch origin
git rebase origin/main          # or: git merge origin/main
```

Prefer `rebase` on your own branch: it keeps history linear and avoids the
"merge branch 'main' into feature/…" noise. Conflicts are yours to resolve —
do not merge a branch that has conflict markers left in it.

### 5. Push the branch

```bash
git push -u origin feature/add-checkout-total
```

The `pre-push` hook permits this. It blocks `git push origin main` and
`git push origin HEAD:main`.

---

## Opening the pull request

```bash
gh pr create --fill --base main
```

Or open the compare page in the browser and click **Create pull request**.

The template (`.github/PULL_REQUEST_TEMPLATE.md`) appears automatically.
Fill it in:

- **What this changes** — one or two sentences.
- **Why** — the bug, task, or need. Link the issue: `Closes #12`.
- **How I tested it** — commands you ran, pages you clicked. "Tested locally"
  is not enough.
- **Author checklist** — actually tick it.

A pull request whose description is empty fails the `pull request hygiene`
check. This is deliberate: a reviewer should never have to reverse-engineer
your intent from a diff.

**Keep pull requests small.** Under ~400 changed lines gets reviewed in
minutes. A 2,000-line PR that touches five unrelated things gets reviewed
never — split it.

Draft while you are still working:

```bash
gh pr create --draft --fill
gh pr ready            # when it is ready for review
```

---

## Review, update, merge

### As the author

1. Wait for **`checks`** (CI) to go green. Click into the failing step if not.
2. Answer every comment. Push fixes to the *same branch* — the PR updates itself:
   ```bash
   git add -p && git commit -m "handle empty cart in total calculation"
   git push
   ```
3. Once your reviewer resolves their comments, merge.

### As the reviewer

- Read the description first, then the diff.
- Be specific and kind: "this query returns rows in insertion order, so the
  receipt order will look random — add `ORDER BY id`" is a review comment.
  "wrong" is not.
- Approve when your concerns are addressed. Do not block on personal style
  preferences that the project has not adopted.
- Respond within a day or two when you can.

### Merging

Use **Squash and merge** — one clean, described commit per pull request on
`main`:

```bash
gh pr merge --squash --delete-branch
```

Then confirm `main` is healthy and your local copy is back in sync:

```bash
git switch main && git pull --ff-only
```

Never merge your own PR without review if the project has other contributors
available; if you are the only maintainer, `--approvals 0` is configured so you
can merge your own (still through a PR).

---

## Enforcing the workflow

Three layers guard `main`. The first two work immediately; the third is the
authoritative one and needs a maintainer with admin rights.

### Layer 1 — Local hooks (works today)

`bash scripts/setup-hooks.sh` installs:

| Hook | Effect |
| --- | --- |
| `pre-push` | Refuses to push to `main` / `master`. Maintainer override: `ALLOW_MAIN_PUSH=1 git push origin main`. |
| `commit-msg` | Blocks empty messages; warns on vague, very short, or over-long subjects. |

### Layer 2 — CI (works today)

`.github/workflows/ci.yml` runs on every pull request into `main`:

| Job | Checks |
| --- | --- |
| `checks` | Python compiles (`compileall`), tests pass (`pytest`), obvious hard-coded credentials are flagged |
| `pull request hygiene` | PR targets `main`, does not come from `main` itself, and has a real description |

### Layer 3 — GitHub branch protection (the real wall)

This is what makes `main` genuinely unpushable. Apply it once, from a machine
where `gh` is logged in as a repository admin:

```bash
bash scripts/setup-branch-protection.sh --approvals 1
```

What it turns on for `main`:

- Require a pull request before merging (0 or more approvals)
- Dismiss stale approvals when new commits are pushed
- Require the `checks` status check to pass
- Require all conversations to be resolved
- Apply the rules to administrators too — no bypassing
- No force pushes, no branch deletion
- Merged branches are deleted automatically

Flags: `--approvals N`, `--strict` (branch must be up to date with `main`),
`--dry-run`, `--remove`, `--branch <name>`.

#### Doing it in the browser

1. <https://github.com/TensorTrail766/Computer_Store_MS/settings/branches>
2. **Add branch protection rule**
3. Branch name pattern: `main`
4. Tick:
   - ☑ Require a pull request before merging → required approvals: 1
   - ☑ Dismiss stale pull request approvals when new commits are pushed
   - ☑ Require status checks to pass before merging → add `checks`
   - ☑ Require conversation resolution before merging
   - ☑ Do not allow bypassing the above settings
   - ☐ Allow force pushes (off)
   - ☐ Allow deletions (off)
5. **Save**.

#### If GitHub refuses

Branch protection and rulesets require **GitHub Pro** while the repository is
private. On the Free plan GitHub answers either

```
Resource not accessible by integration            (HTTP 403)
Upgrade to GitHub Pro or make this repository public to enable this feature.
```

Either upgrade the account, or make the repository public, then re-run the
script. Until then, Layers 1 and 2 still apply — they catch the mistake locally
and on every PR, they just cannot stop a determined direct push.

#### Optional extras

- **Require review from Code Owners**: tick it in the protection rule so
  `.github/CODEOWNERS` becomes binding. Only enable this when there is a second
  reviewer — a sole maintainer cannot approve their own PR and would be locked out.
- **Auto-merge**: `allow_auto_merge` is enabled by the script, so on a green PR
  you can run `gh pr merge --squash --auto`.
- **Rulesets** (Settings → Rules → Rulesets) are the newer equivalent, and are
  a better choice once the repository is in an organisation.

---

## Troubleshooting

### I committed to `main` by mistake

Nothing is lost — move the commits to a new branch and reset `main`:

```bash
git branch feature/my-work          # save the commits on a branch
git fetch origin
git reset --hard origin/main        # main is clean again
git switch feature/my-work
git push -u origin feature/my-work
```

If you had already pushed to `main` (you bypassed the hook), tell the
maintainer before doing anything else. Do not force-push `main` on your own.

### `git pull --ff-only` fails on `main`

Your local `main` has commits that `origin/main` does not. That means you
committed on `main` locally. Follow the recipe above.

### "Updates were rejected because the remote contains work you do not have"

Someone else changed the branch you pushed to. Fetch and rebase:

```bash
git fetch origin
git rebase origin/main
git push --force-with-lease     # only on your own branch, never on main
```

`--force-with-lease` refuses to overwrite work you have not seen; plain
`--force` does not.

### The `pre-push` hook blocked me and I am sure I need to push to `main`

You almost certainly do not. If it is a genuine emergency (repository
recovery), a maintainer can run:

```bash
ALLOW_MAIN_PUSH=1 git push origin main
```

…and should follow up with the branch protection step above.

### My pull request has conflicts

```bash
git fetch origin
git rebase origin/main          # resolve conflicts file by file
git add <resolved files>
git rebase --continue
git push --force-with-lease
```

Check that no conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`) are left:
`git grep -n '^<<<<<<<'`.

### CI failed but it passes on my machine

Read the failing step in the Actions tab, not just the red X. Usually it is a
missing dependency (add it to `requirements.txt`) or a file committed with the
wrong path casing.

### I need to undo my last commit (not pushed)

```bash
git reset --soft HEAD~1     # keep the changes staged
git reset HEAD~1            # keep the changes unstaged
```

---

## FAQ

**Can the maintainer push to `main`?**
No. Protection is applied to administrators as well. Emergencies use the
explicit `ALLOW_MAIN_PUSH=1` override and are documented in the PR afterwards.

**Do I need to fork?**
No — contributors with write access push branches to this repository. Fork only
if you are an outside contributor without access.

**Can I have more than one branch?**
Yes, but one branch per pull request. `feature/checkout` and
`fix/rounding` are two branches, even if you are working on both today.

**What if my change is one line?**
Still a branch and a pull request. Small PRs cost seconds and keep `main`
auditable.

**Should I merge or rebase `main` into my branch?**
Rebase to stay current, unless your branch is shared with someone else — then
merge, because rebasing rewrites commits they may have pulled.

**Who reviews?**
`.github/CODEOWNERS` requests the maintainer automatically. Once there are
several contributors, add them there and the right person gets pinged.
