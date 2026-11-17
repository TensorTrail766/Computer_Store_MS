# Computer Store MS

A management system for a computer store — inventory, customers, orders, and
sales — built as a small Python web application on top of an Oracle database.

The project is under active construction: the module layout and database
scripts are in place, and features are being added through pull requests.

> **Contributing?** `main` is protected. Nobody pushes or commits to it
> directly — every change lands through a pull request from your own branch.
> Start with **[CONTRIBUTING.md](CONTRIBUTING.md)**, and read
> **[docs/collaboration.md](docs/collaboration.md)** for the full workflow.

---

## Layout

```
src/
  web/          HTTP layer — router and request handlers
  logic/        business rules (pricing, stock, order totals)
  db/           Oracle connection and query modules
  templates/    HTML templates
static/
  css/          Stylesheets
scripts/
  init_db.sql   Schema creation
  seed_data.sql Sample data
  setup-hooks.sh, setup-branch-protection.sh
tests/
  test_db/      Database layer tests
  test_logic/   Business logic tests
docs/
  collaboration.md  Branch / pull request workflow (read this first)
  db-schema.md      Schema documentation
.githooks/      pre-push and commit-msg guards (installed by setup-hooks.sh)
.github/        CI workflows, pull request template, CODEOWNERS
```

---

## Getting started

```bash
git clone https://github.com/TensorTrail766/Computer_Store_MS.git
cd Computer_Store_MS

python3 -m venv .venv
source .venv/bin/activate        # Windows: .venv\Scripts\activate
[ -f requirements.txt ] && pip install -r requirements.txt

bash scripts/setup-hooks.sh      # blocks accidental pushes to main
```

### Database

The application expects an Oracle instance you can reach locally. Create the
schema and load sample data with your own client:

```bash
sqlplus <user>/<password>@<host>:<port>/<service> @scripts/init_db.sql
sqlplus <user>/<password>@<host>:<port>/<service> @scripts/seed_data.sql
```

Connection settings are read from the environment (host, port, service name,
user, password). Keep real credentials in a local `.env` file, which is
git-ignored — never in a tracked source file.

### Tests

```bash
python -m compileall -q src tests
python -m pytest -q
```

---

## Workflow in one breath

```bash
git switch main && git pull --ff-only
git switch -c feature/short-description
# ... edit, add, commit ...
git push -u origin feature/short-description
gh pr create --fill --base main
```

CI runs on the pull request, a reviewer approves, and it merges with a squash.
Details, rules, and troubleshooting: **[docs/collaboration.md](docs/collaboration.md)**.

Maintainers apply branch protection once with:

```bash
bash scripts/setup-branch-protection.sh --approvals 1
```
