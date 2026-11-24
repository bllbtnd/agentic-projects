#!/usr/bin/env bash
# Owner-only. The agent token could not change administration settings or
# create labels (HTTP 403). This script was NOT run.
# Running it requires admin on bllbtnd/agentic-projects.
#
# It does three things:
# 1. Squash-only merges, and leaves delete-branch-on-merge OFF.
# 2. Branch protection on main (PRs required, zero approving reviews,
#    code-owner reviews off, strict ci-ok + merge-gate, admins enforced).
# 3. The work-queue labels and the PR approval labels.
#
# Do not protect the crisis-map-data branch. The ingest workflow pushes it
# with GITHUB_TOKEN. Also set Settings > Actions > General > Workflow
# permissions to "Read and write" so that push is allowed.
#
# If step 2 fails because ci-ok or merge-gate has never been reported,
# merge the scaffold and governance PRs first, rerun CI, then run this again.
set -euo pipefail

repo="bllbtnd/agentic-projects"

gh api -X PATCH "/repos/${repo}" \
  -f allow_squash_merge=true \
  -f allow_merge_commit=false \
  -f allow_rebase_merge=false \
  -f delete_branch_on_merge=false

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

gh label create "type:feature" --repo "$repo" --color "1D76DB" --description "PM feature or task" --force
gh label create "type:bug" --repo "$repo" --color "D73A4A" --description "QA bug" --force
gh label create "type:chore" --repo "$repo" --color "BFD4F2" --description "Chore" --force
gh label create "correction" --repo "$repo" --color "F9D0C4" --description "Public report of wrong map data" --force
gh label create "project:crisis-map" --repo "$repo" --color "FBCA04" --description "Crisis Map" --force
gh label create "owner:engineer" --repo "$repo" --color "0E8A16" --description "Engineer owns this issue" --force
gh label create "owner:data-analyst" --repo "$repo" --color "006B75" --description "Data Analyst owns this issue" --force
gh label create "owner:sre" --repo "$repo" --color "6F42C1" --description "SRE owns this issue" --force
gh label create "status:ready" --repo "$repo" --color "C2E0C6" --description "Ready for an owner to pick up" --force
gh label create "status:in-progress" --repo "$repo" --color "E4E669" --description "An owner is working on this" --force
gh label create "status:blocked" --repo "$repo" --color "000000" --description "Cannot move" --force
gh label create "severity:S1" --repo "$repo" --color "B60205" --description "Severity S1" --force
gh label create "severity:S2" --repo "$repo" --color "D93F0B" --description "Severity S2" --force
gh label create "severity:S3" --repo "$repo" --color "E99695" --description "Severity S3" --force
gh label create "severity:S4" --repo "$repo" --color "C5DEF5" --description "Severity S4" --force
gh label create "reviewer-approved" --repo "$repo" --color "0E8A16" --description "Reviewer accepted this PR" --force
gh label create "qa-passed" --repo "$repo" --color "1D76DB" --description "QA tested this PR and it passed" --force
gh label create "architect-approved" --repo "$repo" --color "5319E7" --description "Architect accepted this PR and may squash-merge it" --force
gh label create "changes-requested" --repo "$repo" --color "D93F0B" --description "Review or QA blocked this PR" --force

echo "Protection, squash-only merges, and labels applied. Confirm crisis-map-data is NOT protected."
