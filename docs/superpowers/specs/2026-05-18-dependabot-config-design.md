# netballR Dependabot Configuration Design

## Summary

Refine the existing Dependabot setup so GitHub Actions dependency updates keep the current weekly schedule while adding basic triage controls.

This is a configuration-only change.

## Goals

- Keep Dependabot enabled for the `github-actions` ecosystem only.
- Keep the existing weekly update schedule.
- Automatically label Dependabot PRs with:
  - `dependencies`
  - `github-actions`
- Limit the number of open Dependabot PRs for this ecosystem to `5`.

## Non-goals

- No package dependency updates for R packages or other ecosystems.
- No reviewers or assignees.
- No grouping rules.
- No ignore rules.
- No workflow or package code changes.

## Design Decisions

### 1. Preserve the current scope

The repo already has a valid Dependabot file at `.github/dependabot.yml` covering GitHub Actions. This change should extend that config rather than broaden it.

### 2. Keep the weekly schedule

The user explicitly chose to keep weekly updates, so the `schedule.interval` remains unchanged.

### 3. Add basic PR hygiene controls

Add two standard controls:

- `labels`
  - `dependencies`
  - `github-actions`
- `open-pull-requests-limit: 5`

These improve triage without introducing repo-specific policy assumptions.

## File Impact

### Source config

- `.github/dependabot.yml`

## Acceptance Criteria

- `.github/dependabot.yml` still contains one `github-actions` update block.
- The schedule remains weekly.
- Dependabot PRs for GitHub Actions receive `dependencies` and `github-actions` labels.
- The config limits open Dependabot PRs to `5`.
- No other repository files are changed.

## Risks

- If the repository does not already have the referenced labels, GitHub may not apply them until they exist.
- Over-configuring beyond this scope would add unnecessary maintenance burden.
