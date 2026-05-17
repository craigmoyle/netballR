# Code Review Fixes Design

## Summary

Address the three issues identified in code review:

1. `matchPoints_pre_2020()` incorrectly awards quarter bonus points for overtime periods.
2. Live regular-season and finals matches can collide because tidy outputs only carry `round` and `game`.
3. The README includes an incorrect standings example for pre-2020 / ANZ-style workflows.

The chosen approach is to fix the scoring bug, add `matchId` to tidy outputs, make downstream grouping prefer `matchId` when available, and update tests and documentation accordingly.

## Goals

- Correct `points_new` calculations for pre-2020 / ANZ / NZ overtime matches.
- Prevent collisions when users combine tidy live data from multiple competitions that reuse round/game numbering.
- Preserve compatibility with existing bundled tidy data that does not include `matchId`.
- Keep tidy output column order as stable as possible by appending `matchId`.
- Correct user-facing examples so they describe a valid workflow.

## Non-goals

- No new exported functions.
- No change to `downloadMatch()` arguments or return shape.
- No regeneration of bundled datasets such as `season_2017`.
- No broader refactor of ladder or tidier APIs beyond the minimum needed for correctness.

## Design Decisions

### 1. Restrict legacy quarter bonuses to regulation periods

`matchPoints_pre_2020()` currently builds quarter bonus points from all rows where `stat == "goals"`. For matches with overtime (`periodCompleted > 4`), this incorrectly awards extra quarter points for periods 5 and 6.

The fix is to calculate quarter bonuses from regulation periods only:

- keep final match score and win/draw/loss logic based on all periods
- restrict quarter bonus logic to `period <= 4`

This preserves intended full-match scoring while aligning the bonus system with regulation quarters only.

### 2. Add `matchId` to tidy outputs

`tidyMatch()` and `tidyPlayers()` will append a new `matchId` column sourced from `match$matchInfo$matchId`.

Column ordering policy:

- keep existing columns in their current order
- append `matchId` after `game`

Resulting tails:

- `tidyMatch()`: `..., round, game, matchId`
- `tidyPlayers()`: `..., round, game, matchId`

This adds a stable unique identifier without reshuffling the current output structure.

### 3. Prefer `matchId` in downstream grouping, with fallback

`matchResults()` and `matchResults_pre_2020()` currently group only by `round` and `game`. That is unsafe when different competitions reuse the same numbering.

New grouping behavior:

- if `matchId` exists in `df`, group by `matchId`
- otherwise, keep the legacy grouping by `round` and `game`

This keeps existing bundled data working unchanged while making live tidy datasets safe to combine.

### 4. Correct docs and examples

The README example currently shows an invalid flow:

```r
standings <- ladders_pre_2020(matchPoints_pre_2020(match))
```

That example passes the wrong data shape into `ladders_pre_2020()`.

Documentation updates will:

- replace the incorrect example with a valid workflow based on `tidyMatch()`
- document that `matchId` is included in tidy outputs
- clarify that `ladders_pre_2020()` expects season-style tidy match statistics, not a raw downloaded match object or a `matchPoints_pre_2020()` summary

## File Impact

### Production code

- `R/matchPoints.R`
  - restrict legacy quarter bonus calculation to regulation periods
- `R/tidiers.R`
  - append `matchId` to `tidyMatch()` output
  - append `matchId` to `tidyPlayers()` output
- `R/ladders.R`
  - make `matchResults()` and `matchResults_pre_2020()` group by `matchId` when present
- `R/data.R`
  - update dataset documentation for tidy output schema if needed
- `R/superNetballR.R`
  - add `matchId` to `utils::globalVariables()` if required by check output

### Tests

- `tests/testthat/test-match-points.R`
  - add regression coverage proving overtime periods do not contribute quarter bonus points
- `tests/testthat/test-tidiers.R`
  - assert `matchId` is appended by both tidiers
- `tests/testthat/test-ladders.R`
  - add coverage showing `matchResults()` prefers `matchId`
  - add coverage showing fallback to `round`/`game` still works when `matchId` is absent
- `tests/testthat/helper-fixtures.R`
  - include `matchId` in sample match fixtures and add any match-result fixtures needed for grouping tests

### Docs

- `README.md`
  - replace the incorrect standings example
  - note that tidy outputs now include `matchId`
- `R/downloadMatch.R`
  - update roxygen where examples or details refer to downstream workflow
- `vignettes/getting-started.Rmd`
  - update narrative or examples if they describe the old ambiguous workflow
- generated docs under `man/` only as needed after roxygen

## Compatibility and Migration

### Backward compatibility

- Existing consumers of `tidyMatch()` / `tidyPlayers()` gain one appended column only.
- Existing code that selects columns by name continues to work.
- Existing code that assumes an exact column count may need to be updated.
- Existing bundled datasets without `matchId` remain supported because grouping falls back to `round` and `game`.

### Why `matchId` instead of `comp_id`

`matchId` uniquely identifies a match across the Champion Data feed and is already present in `matchInfo`, so it solves the collision directly without expanding the public API more than necessary.

## Test Strategy

Follow TDD for each behavior change.

Required regression coverage:

1. overtime periods 5+ do not increase `points_new` in `matchPoints_pre_2020()`
2. `tidyMatch()` appends `matchId`
3. `tidyPlayers()` appends `matchId`
4. `matchResults()` uses `matchId` to keep same round/game values from different matches separate
5. `matchResults_pre_2020()` uses the same `matchId`-aware grouping behavior
6. legacy data without `matchId` still works with `ladders()` / `ladders_pre_2020()`

## Acceptance Criteria

- `matchPoints_pre_2020()` returns regulation-quarter bonus points only.
- `tidyMatch()` and `tidyPlayers()` return appended `matchId` columns.
- `matchResults()` and `matchResults_pre_2020()` no longer merge distinct matches that share the same round/game values when `matchId` is present.
- Existing season-style bundled data without `matchId` still works.
- README and vignette examples describe a valid pre-2020 workflow.
- Test suite covers the new behavior and regressions.

## Risks

- Some downstream code may assert exact output column counts. Appending `matchId` is still the least disruptive way to expose unique match identity.
- Roxygen / pkgdown outputs may need regeneration after doc changes.
- Local execution may still be limited by missing R package dependencies in this environment, so verification should use the package test/check workflow where available.
