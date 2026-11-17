#!/usr/bin/env bash
#
# Put `main` behind a pull-request wall on GitHub.
#
# Enables, on the default branch:
#   • Require a pull request before merging (no direct pushes, no force pushes,
#     no branch deletion)
#   • Require the "checks" status check (from .github/workflows/ci.yml)
#   • Require conversations to be resolved
#   • Apply the rules to admins too ("Do not allow bypassing")
#
# Usage:
#   bash scripts/setup-branch-protection.sh              # 0 required approvals
#   bash scripts/setup-branch-protection.sh --approvals 1  # someone else must approve
#   bash scripts/setup-branch-protection.sh --strict      # branch must be up to date
#   bash scripts/setup-branch-protection.sh --dry-run     # print, change nothing
#   bash scripts/setup-branch-protection.sh --remove      # turn protection off
#
# Requires: gh CLI logged in with admin rights on the repository.

set -euo pipefail

BRANCH="${BRANCH:-main}"
APPROVALS="${APPROVALS:-0}"
STRICT_UP_TO_DATE="${STRICT_UP_TO_DATE:-false}"
DRY_RUN=0
REMOVE=0

usage() {
  sed -n '2,25p' "$0" | sed -e 's/^# \{0,1\}//'
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --approvals)
      [[ $# -ge 2 ]] || { echo "--approvals needs a number" >&2; exit 1; }
      APPROVALS="$2"
      shift 2
      ;;
    --strict)
      STRICT_UP_TO_DATE="true"
      shift
      ;;
    --branch)
      [[ $# -ge 2 ]] || { echo "--branch needs a name" >&2; exit 1; }
      BRANCH="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --remove)
      REMOVE=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if ! [[ "$APPROVALS" =~ ^[0-9]+$ ]]; then
  echo "✖ --approvals must be a whole number (e.g. 0, 1, 2)." >&2
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "✖ GitHub CLI (gh) is not installed. See https://cli.github.com" >&2
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "✖ Not logged in to GitHub. Run: gh auth login" >&2
  exit 1
fi

REPO="$(gh repo view --json nameWithOwner --jq .nameWithOwner)"

ui_fallback() {
  cat <<EOF

──────────────────────────────────────────────────────────────────────
Set it up in the browser instead (2 minutes)
──────────────────────────────────────────────────────────────────────
1. Open: https://github.com/$REPO/settings/branches
2. "Add branch protection rule" (or "Add classic branch protection rule")
3. Branch name pattern: $BRANCH
4. Tick:
     ☑ Require a pull request before merging
         • Required approvals: $APPROVALS
         • ☑ Dismiss stale pull request approvals when new commits are pushed
     ☑ Require status checks to pass before merging
         • add the check named: checks
     ☑ Require conversation resolution before merging
     ☑ Do not allow bypassing the above settings
     ☐ Allow force pushes            (leave OFF)
     ☐ Allow deletions               (leave OFF)
5. Save.

Note: branch protection needs GitHub Pro (or the repo being public).
If this repository is private on the Free plan, upgrade the account or make
the repo public first, then re-run this script.
──────────────────────────────────────────────────────────────────────
EOF
}

if [[ "$REMOVE" == "1" ]]; then
  echo "Removing protection from '$BRANCH' on $REPO ..."
  if [[ "$DRY_RUN" == "1" ]]; then
    echo "[dry-run] gh api -X DELETE repos/$REPO/branches/$BRANCH/protection"
    exit 0
  fi
  if gh api -X DELETE "repos/$REPO/branches/$BRANCH/protection"; then
    echo "✓ Protection removed from '$BRANCH'."
  else
    echo "✖ Could not remove protection (it may not be enabled, or you lack admin rights)." >&2
    exit 1
  fi
  exit 0
fi

payload_file="$(mktemp)"
trap 'rm -f "$payload_file"' EXIT

cat >"$payload_file" <<EOF
{
  "required_status_checks": {
    "strict": $STRICT_UP_TO_DATE,
    "contexts": ["checks"]
  },
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": false,
    "required_approving_review_count": $APPROVALS,
    "require_last_push_approval": false
  },
  "restrictions": null,
  "required_linear_history": false,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "required_conversation_resolution": true,
  "block_creations": false,
  "lock_branch": false
}
EOF

echo "Repository : $REPO"
echo "Branch     : $BRANCH"
echo "Approvals  : $APPROVALS"
echo "Up-to-date : $STRICT_UP_TO_DATE"
echo ""

if [[ "$DRY_RUN" == "1" ]]; then
  echo "[dry-run] Payload that would be applied:"
  cat "$payload_file"
  echo ""
  echo "[dry-run] Repo settings that would be updated:"
  echo "  delete_branch_on_merge=true, allow_auto_merge=true"
  exit 0
fi

echo "→ Applying branch protection ..."
if ! gh api -X PUT "repos/$REPO/branches/$BRANCH/protection" --input "$payload_file" >/dev/null 2>"$payload_file.err"; then
  err="$(cat "$payload_file.err" 2>/dev/null || true)"
  rm -f "$payload_file.err"
  echo "✖ GitHub refused the request:" >&2
  echo "  $err" >&2
  ui_fallback >&2
  exit 1
fi
rm -f "$payload_file.err"

echo "✓ '$BRANCH' now requires a pull request before merging."

echo "→ Tidying repository merge settings ..."
if gh api -X PATCH "repos/$REPO" \
    -F delete_branch_on_merge=true \
    -F allow_auto_merge=true \
    -F allow_squash_merge=true >/dev/null 2>&1; then
  echo "✓ Merged branches are deleted automatically; auto-merge and squash merge allowed."
else
  echo "⚠ Could not update merge settings (needs admin scope). Optional — set them in"
  echo "  Settings → General → Pull Requests if you want them."
fi

echo ""
echo "Done. Contributors must now:"
echo "  1. git switch -c feature/short-description   # never work on main"
echo "  2. git push -u origin feature/short-description"
echo "  3. gh pr create --fill                        # or open the PR in the browser"
echo ""
echo "Full workflow: docs/collaboration.md"
