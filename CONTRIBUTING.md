# Contributing to Computer Store MS

Thanks for helping out. **`main` is protected: nobody pushes to it, and nobody
commits to it directly — not even the maintainer.** Every change arrives as a
pull request from a branch, and every pull request is reviewed before it is
merged.

The complete step-by-step workflow, with copy-paste commands, lives in
[docs/collaboration.md](docs/collaboration.md). This page is the short version.

---

## The 60-second version

```bash
# 1. Clone and turn on the local guards (once per machine)
git clone https://github.com/TensorTrail766/Computer_Store_MS.git
cd Computer_Store_MS
bash scripts/setup-hooks.sh

# 2. Start from an up-to-date main and make your own branch
git switch main && git pull
git switch -c feature/add-checkout-total

# 3. Work, commit in small steps
git add -p
git commit -m "add checkout total calculation"

# 4. Push the branch (never main) and open the pull request
git push -u origin feature/add-checkout-total
gh pr create --fill --base main
```

Then: wait for CI, address review comments, and merge with **Squash and merge**.
Delete the branch afterwards.

---

## Rules

| Rule | Why |
| --- | --- |
| Never push or commit to `main` | A broken `main` blocks everyone. The `pre-push` hook and GitHub both refuse it. |
| One branch = one purpose | Small pull requests get reviewed in minutes; giant ones sit for days. |
| Target `main` with your PR | PRs into other feature branches create tangled history. |
| A PR needs a real description | Reviewers should not have to reverse-engineer the diff. Accept the template and fill it in. |
| Keep CI green | `checks` must pass before merge. Do not merge red. |
| Never commit secrets | No passwords, tokens, connection strings, or `.env` files. See below. |

### Branch naming

Use a prefix so branches are self-explanatory:

```
feature/<short-description>     feature/add-checkout-total
fix/<short-description>         fix/order-total-rounding
docs/<short-description>        docs/setup-instructions
refactor/<short-description>    refactor/split-query-layer
chore/<short-description>       chore/bump-dependencies
test/<short-description>        test/order-total-coverage
```

### Commit messages

Write the subject as a short instruction to your future self — what the change
does, not which files you touched.

```
add order total calculation to checkout
fix rounding error in subtotal display
document Oracle connection setup
```

No `wip`, no `temp`, no `asdf`, no empty messages (the `commit-msg` hook blocks
empty ones and warns about the rest). If you want more detail, leave a blank
line and write a body.

### Merging

- **Squash and merge** is the default: one clean commit per pull request on `main`.
- A reviewer closes conversations before merge; unresolved conversations block it.
- Delete your branch after merge (GitHub does this automatically once enabled).

---

## Local setup

```bash
python3 -m venv .venv
source .venv/bin/activate          # Windows: .venv\Scripts\activate
pip install -r requirements.txt    # if the file exists
bash scripts/setup-hooks.sh        # enables pre-push + commit-msg guards
```

Database scripts live in `scripts/` (`init_db.sql`, `seed_data.sql`). Run them
against your **own local** Oracle instance.

### Credentials

Connection settings belong in `src/db/connection.py` **only** as values read
from environment variables or a local `.env` file, and `.env` is git-ignored.
If you need to test against a real database, keep those values on your machine.
Anything that looks like a password in a diff will be sent back.

If you accidentally commit a secret: rotate it immediately, then tell the
maintainer — deleting the commit is not enough, because history keeps the value.

---

## Checks that run on your pull request

| Check | What it means |
| --- | --- |
| `checks` | Python files compile and the test suite passes (`pytest`). |
| `pull request hygiene` | Your PR targets `main`, comes from a real branch, and has a filled-in description. |

Run the same things locally before opening the PR:

```bash
python -m compileall -q src tests
python -m pytest -q
```

---

## Review etiquette

- **Authors:** keep PRs under ~400 changed lines when you can, self-review the
  diff first, and answer every comment (resolve it once addressed).
- **Reviewers:** respond within a day or two if you can, be specific
  ("this query returns rows in insertion order, not by date" beats "wrong"),
  and approve once your concerns are addressed rather than nitpicking forever.

---

## Repository maintainers

Enforcement settings (branch protection, required checks) are applied with:

```bash
bash scripts/setup-branch-protection.sh --approvals 1
```

See [docs/collaboration.md#enforcing-the-workflow](docs/collaboration.md#enforcing-the-workflow)
for the details, the browser equivalent, and what to do when GitHub's plan
limits block it.
