#!/usr/bin/env bash
#
# Turn on the repository's local git hooks (pre-push + commit-msg).
#
#   bash scripts/setup-hooks.sh            # install / re-install
#   bash scripts/setup-hooks.sh --uninstall
#
# Run this once after cloning. It points git at the tracked .githooks/
# directory, so the hooks stay in sync with the repository.

set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
hooks_dir=".githooks"

usage() {
  cat <<'EOF'
Usage: bash scripts/setup-hooks.sh [--uninstall]

  (no flags)   Install the repo git hooks (pre-push, commit-msg).
  --uninstall  Remove the hooks-path setting and go back to default git hooks.
EOF
}

case "${1:-}" in
  -h|--help)
    usage
    exit 0
    ;;
  --uninstall)
    git -C "$repo_root" config --unset core.hooksPath 2>/dev/null || true
    echo "✓ Git hooks disabled (core.hooksPath removed)."
    exit 0
    ;;
  "")
    ;;
  *)
    echo "Unknown option: $1" >&2
    usage >&2
    exit 1
    ;;
esac

if [[ ! -d "$repo_root/$hooks_dir" ]]; then
  echo "✖ $hooks_dir/ not found. Run this script from inside the repository." >&2
  exit 1
fi

chmod +x "$repo_root/$hooks_dir"/* 2>/dev/null || true
git -C "$repo_root" config core.hooksPath "$hooks_dir"

echo "✓ Git hooks installed from $hooks_dir/"
echo ""
echo "  Active guards:"
echo "    • pre-push  — blocks direct pushes to main / master"
echo "    • commit-msg — rejects empty messages, warns on vague ones"
echo ""
echo "  Bypass once (maintainers only):  ALLOW_MAIN_PUSH=1 git push origin main"
echo "  Turn off again:                  bash scripts/setup-hooks.sh --uninstall"
