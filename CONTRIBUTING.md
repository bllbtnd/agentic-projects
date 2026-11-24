# Contributing

This repo is the monorepo for the team's products. Crisis Map is the first.
The project is non-commercial because some of its sources are (see the Crisis
Map license register once that project is in the tree).

Read [CODING_STANDARDS.md](CODING_STANDARDS.md) before writing code.

## Roles

The Engineer (one full-stack role; backend and frontend are not separate
seats) opens the PR and fixes review notes. The Reviewer reviews. QA tests
and passes. The Architect gives final approval and squash-merges. The Data
Analyst works on data quality and source-ingest validation, including
corrections from public reports, and uses the same PR path.

Every bot authenticates as GitHub user @bllbtnd. GitHub will not accept an
approving review on your own PR, so a required approving-review count of 1
would lock the repo. Approvals are labels plus a COMMENT review, not an
APPROVE review. Questions for Botond go through Boss. Botond does not OK each
merge.

## Workflow

1. The Engineer opens a PR from a feature branch.
2. The Reviewer reviews and leaves a COMMENT review. They add `reviewer-approved` or `changes-requested`.
3. The Engineer fixes the requested changes.
4. QA tests and, when it passes, adds `qa-passed` with a COMMENT review.
5. CI is green (`ci-ok`).
6. The Architect adds `architect-approved` with a COMMENT review and squash-merges.

All three approval labels must be present, and `changes-requested` must be
absent. The `merge-gate` workflow is the mechanical check. Pushing new
commits removes `reviewer-approved`, `qa-passed`, and `architect-approved` so
the new code is reviewed again.

No force-pushes, on any branch. The only deletion allowed is the merged
feature branch after the squash merge. The Architect may delete that branch.
Repo-level "automatically delete head branches" stays off.

## Corrections

Public users report a wrong map item with the "Report an error" issue
template (`.github/ISSUE_TEMPLATE/report_error.yml`). The field ids are
stable: `item_link`, `whats_wrong`, `source`, plus `project`. The web app
will later deep-link to:

`https://github.com/bllbtnd/agentic-projects/issues/new?template=report_error.yml&item_link=&whats_wrong=&source=`

The Data Analyst triages issues labeled `correction`. A fix goes through a
normal PR. Do not edit published data on `main`.

## Branches

- `feat/<project>/<short-name>`
- `fix/<project>/<short-name>`
- `chore/<short-name>`
- `docs/<project>/<short-name>`

`main` accepts pull requests only. The Crisis Map ingest branch
`crisis-map-data` is not protected and is written by the ingest workflow, not
by feature PRs.

## Commits and PRs

[Conventional Commits](https://www.conventionalcommits.org/) with a project
scope, for example `feat(crisis-map): publish the unrest delay`. Squash merge
only, so the PR title should already be the commit message you want on
`main`.

Keep PRs small. One project per PR where possible. Architectural changes need
an ADR under `docs/adr/` (MADR).

## Local checks

```bash
pnpm install
pnpm lint
pnpm typecheck
pnpm test
pnpm build
pnpm dev
```

`pnpm crisis-map:dev`, the gitleaks hook, and the owner script for labels and
branch protection are follow-ups. This skeleton only has the workspace and CI.

## Labels

| Label                | Meaning                                 |
| -------------------- | --------------------------------------- |
| `reviewer-approved`  | Reviewer finished and accepted          |
| `qa-passed`          | QA tested and passed                    |
| `architect-approved` | Architect accepted and may squash-merge |
| `changes-requested`  | Review or QA blocked the PR             |
| `project:crisis-map` | Work belongs to Crisis Map              |
| `correction`         | Public data-error report                |

The owner script that creates these labels is a follow-up. They are not on
the repo yet.
