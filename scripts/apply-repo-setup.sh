#!/usr/bin/env bash
# Owner-only. Requires admin on bllbtnd/agentic-projects.
#
# One command for labels and branch protection. Idempotent: re-running
# updates labels in place and writes the same protection rule again.
# It does not delete labels, branches, or data, and it does not protect
# crisis-map-data (the ingest workflow pushes that branch).
#
# Do not run this from CI. The agent token cannot administer the repo.
set -euo pipefail

repo="bllbtnd/agentic-projects"

ensure_label() {
  local name="$1"
  local color="$2"
  local description="$3"
  local output
  output="$(gh label create "$name" --repo "$repo" --color "$color" --description "$description" --force 2>&1)"
  echo "label ${name}: created or updated color=${color} description=${description}"
  if [ -n "$output" ]; then
    echo "  gh: ${output}"
  fi
}

echo "repo=${repo}"
echo "labels: creating or updating"

ensure_label "reviewer-approved" "0E8A16" "Reviewer accepted this PR"
ensure_label "qa-passed" "1D76DB" "QA tested this PR and it passed"
ensure_label "architect-approved" "5319E7" "Architect accepted this PR and may squash-merge it"
ensure_label "changes-requested" "D93F0B" "Review or QA blocked this PR"

ensure_label "type:feature" "1D76DB" "PM feature or task"
ensure_label "type:bug" "D73A4A" "QA bug"
ensure_label "type:chore" "BFD4F2" "Chore"
ensure_label "correction" "F9D0C4" "Public report of wrong map data"
ensure_label "project:crisis-map" "FBCA04" "Crisis Map"

ensure_label "owner:engineer" "0E8A16" "Engineer owns this issue"
ensure_label "owner:data-analyst" "006B75" "Data Analyst owns this issue"
ensure_label "owner:sre" "6F42C1" "SRE owns this issue"

ensure_label "status:ready" "C2E0C6" "Ready for an owner to pick up"
ensure_label "status:in-progress" "E4E669" "An owner is working on this"
ensure_label "status:blocked" "000000" "Cannot move"

ensure_label "severity:S1" "B60205" "Severity S1"
ensure_label "severity:S2" "D93F0B" "Severity S2"
ensure_label "severity:S3" "E99695" "Severity S3"
ensure_label "severity:S4" "C5DEF5" "Severity S4"

echo "labels: done"

echo "repo settings: squash-only merges, delete_branch_on_merge=false"
gh api -X PATCH "/repos/${repo}" \
  -f allow_squash_merge=true \
  -f allow_merge_commit=false \
  -f allow_rebase_merge=false \
  -f delete_branch_on_merge=false \
  --jq '{allow_squash_merge,allow_merge_commit,allow_rebase_merge,delete_branch_on_merge}'
echo "repo settings: applied"

echo "branch protection: main (strict ci-ok + merge-gate, 0 approving reviews, code owners off, admins enforced, no force-push, no deletion)"
gh api -X PUT "/repos/${repo}/branches/main/protection" --input - <<'EOF'
{
  "required_status_checks": {
    "strict": true,
    "contexts": ["ci-ok", "merge-gate"]
  },
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "required_approving_review_count": 0,
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": false
  },
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "required_linear_history": true,
  "required_conversation_resolution": true
}
EOF
echo "branch protection: applied on main"
echo "crisis-map-data: left unprotected"
echo "done"
