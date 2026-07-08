#!/usr/bin/env bash
# QUICKSTART.md is the canonical onboarding guide (see
# CONTRIBUTING.md#-documentation-structure). This fails CI if onboarding
# workflow steps get copy-pasted back into the other docs instead of
# linking to QUICKSTART.md.
set -euo pipefail

CANONICAL_FILE="QUICKSTART.md"
CHECK_FILES=("README.md" "FAQ.md" "CONTRIBUTING.md")

# Workflow-step commands/markers that must only live in QUICKSTART.md
PATTERNS=(
  'git checkout -b add-your-name'
  'git commit --amend -m'
  'git push -f origin add-your-name'
  '<<<<<<< HEAD'
)

failed=0

for file in "${CHECK_FILES[@]}"; do
  for pattern in "${PATTERNS[@]}"; do
    if grep -qF -- "$pattern" "$file"; then
      echo "::error file=$file::Found onboarding-workflow content ('$pattern') that duplicates $CANONICAL_FILE. Link to $CANONICAL_FILE instead of repeating workflow steps (see CONTRIBUTING.md#-documentation-structure)."
      failed=1
    fi
  done
done

if [ "$failed" -ne 0 ]; then
  echo ""
  echo "Documentation consistency check failed. See CONTRIBUTING.md#-documentation-structure for ownership rules."
  exit 1
fi

echo "Documentation consistency check passed."
