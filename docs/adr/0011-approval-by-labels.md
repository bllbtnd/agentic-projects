# ADR 0011: Approval by labels, Architect merges

- Status: accepted
- Date: 2026-11-24

## Context and Problem Statement

Every team bot is the GitHub user @bllbtnd. GitHub refuses an approving
review on the author's own pull request. A branch protection rule with
`required_approving_review_count` of 1 or more would make every PR
unmergeable. Code-owner review would self-lock for the same reason.

The team still needs a recorded review, a QA pass, and a final architecture
check before code reaches `main`.

## Decision Drivers

- One shared GitHub account for every bot.
- No way to buy another seat. The repo stays on free GitHub Actions.
- Botond should not have to OK each merge. Questions go to him through Boss.
- Force-push is never allowed. The only branch deletion is the merged head
  branch, done by the Architect after the squash. Delete-branch-on-merge
  stays off.

## Considered Options

1. Required approving reviews. Rejected: the shared account cannot approve
   its own PR.
2. CODEOWNERS with required code-owner reviews. Rejected: the owner is
   @bllbtnd, so the author would be blocking themselves.
3. Labels plus a COMMENT review, checked by a workflow, and the Architect
   squash-merges. Accepted.

## Decision Outcome

Chosen option 3.

A PR may be squash-merged only when `reviewer-approved`, `qa-passed`, and
`architect-approved` are present, `changes-requested` is absent, and the
`ci-ok` check is green. `.github/workflows/merge-gate.yml` (workflow name
`merge-gate`, job id and name `merge-gate`) fails otherwise. It listens to
`pull_request` types `opened`, `synchronize`, `reopened`, `labeled`, and
`unlabeled`.

On `synchronize` the workflow removes the three approval labels. New commits
are reviewed again. The workflow uses `GITHUB_TOKEN` with `contents: read`
and `issues: write` only.

The Architect applies `architect-approved` and performs the squash merge.
There is no separate "Botond OK" step.

Work enters through GitHub issues. The PM files features, QA files bugs, and
an owner picks up issues labeled `status:ready`.

Branch protection, when the owner applies it, keeps
`required_approving_review_count` at 0 and code-owner reviews off, and
requires the `ci-ok` and `merge-gate` status checks. See
`scripts/apply-branch-protection.sh`. The token that opened this PR could
not apply that protection or create labels.

## Consequences

- The merge button is available to anyone with write access once the checks
  are green. The team rule is that only the Architect merges. Protection
  cannot encode "Architect" while every bot shares one login.
- A forgotten label blocks the status check, which is what we want.
- Label changes need `issues: write` on the workflow token.

## Confirmation

Open a PR without the three labels and confirm `merge-gate` fails. Add the
labels with COMMENT reviews and confirm it passes. Push another commit and
confirm the three approval labels are removed and the check fails again.
