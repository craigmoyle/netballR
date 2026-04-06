# Changelog

All notable changes in this fork are documented here.

This changelog covers the changes introduced in `craigmoyle/superNetballR_updated` since the fork diverged from the original `SteveLane/superNetballR` project published at <https://stevelane.github.io/superNetballR/>.

## 0.3.1 - 2026-04-07

Code quality and correctness improvements from a full package review.

### Fixed

- `matchPoints()` now warns when called on data that contains neither `goal_from_zone1` nor `goal_from_zone2`, guiding users to `matchPoints_pre_2020()` for ANZ Championship or pre-2020 data instead of silently returning a spurious 0-0 result.
- `ladders_pre_2020()` documentation for `old_system` parameter now correctly describes its effect (selects the 2-point vs 4-point sort column) rather than incorrectly stating it is ignored.
- `season_2017` dataset documentation corrected: `value` column is integer, not character.
- Removed dead `.unUnload` hook in `zzz.R` (typo for `.onUnload`; would have errored if called since the package has no compiled code).
- Removed spurious `group_by(squadName)` in `matchPoints_pre_2020()` that left grouped state on the `home` data frame.
- Removed redundant second `group_by(round, game)` after `nest()` in `matchResults()` and `matchResults_pre_2020()`.

### Changed

- Replaced `magrittr` pipe (`%>%`) with the native R pipe (`|>`) throughout. Minimum R version bumped from 4.0.0 to 4.1.0.
- `magrittr` removed from `Imports`; `dplyr (>= 1.1.0)` version constraint added.
- `case_when(TRUE ~ ...)` fallthrough sentinels updated to the modern `.default =` idiom in `matchPoints.R`.
- `globalVariables()` declarations consolidated from `zzz.R` + `superNetballR.R` into a single call; missing names (`goals2`, `isHome`, `games`, `qtr_diff`) added.
- Added Craig Moyle as package author/maintainer in `DESCRIPTION`.
- `%||%` null-coalescing operator annotated with `@noRd`.
- CI: removed the `roxygenise()` step from the GitHub Actions workflow — committed `.Rd` files are used directly by `R CMD check`.
- Dependabot configured for weekly GitHub Actions version updates.

## 0.3.0 - 2025-07-30

ANZ Championship and NZ National Netball League support.

### Added

- `downloadFixture(comp_id)` — fetches the full match schedule for any Champion Data competition and returns a tidy tibble of round, game, team names, scores, and match status.
- `anzc_comp_ids` dataset — a lookup table of 35 competition IDs covering every ANZ Championship season (2008–2016) and NZ National Netball League season (2017–2025), with `season`, `competition`, and `season_type` columns.  Use `?anzc_comp_ids` for details and scoring guidance.
- `inst/create_anzc_comp_ids.R` — reproducible script used to generate `data/anzc_comp_ids.rda`.
- `tests/testthat/test-downloadFixture.R` — offline test suite for URL construction, input validation, error handling, and fixture parsing.

### Changed

- `downloadMatch()` documentation updated to reference ANZ Championship support and `anzc_comp_ids`.
- `ladders()` documentation now includes a `@details` note directing ANZ Championship users to `ladders_pre_2020()` (ANZ data uses a `goals` stat, not the 2020+ super-shot zones).
- `DESCRIPTION` version bumped to 0.3.0 and description updated to mention ANZ Championship / NZ National Netball League.
- `README.md` updated with a new ANZ Championship workflow example and `downloadFixture()` in the current behaviour summary.



First tagged release of the maintained fork.

### Added

- Support for the 2020+ super shot scoring model in match and ladder calculations.
- Legacy `_pre_2020` helpers so historical seasons can still be analysed with the original scoring system.
- A packaged Shiny example app for comparing team statistics.
- Bundled `team_colours` data, including the historical Magpies row and the current Melbourne Mavericks entry.
- A `testthat` regression suite covering downloads, tidiers, match scoring, and ladder calculations.
- A GitHub Actions `R-CMD-check` workflow plus Makefile targets for local `test`, `build`, and `check` runs.

### Changed

- `downloadMatch()` now validates match identifiers before issuing requests, retries transient HTTP failures, and errors clearly when Champion Data responses omit `matchStats`.
- `tidyPlayers()` now carries player-team context consistently while preserving the mixed-type player-stat contract used by the bundled data.
- Modern and legacy ladder calculations now apply deterministic ordering and correct round/game cutoffs.
- Match scoring now handles edge cases such as teams that only record `goal_from_zone2` rows.
- The README, vignette, and generated reference documentation have been refreshed for the forked project and current workflow.
- Package metadata has been modernized for the fork, including namespace hygiene, build ignores, and pkgdown configuration.

### Fixed

- Reliability issues in score aggregation and ladder generation that could drop teams or include the wrong matches in filtered ladders.
- Shiny app startup behavior so the packaged example no longer relies on fragile sourcing into the user workspace.
- Documentation mismatches for bundled datasets and package reference pages.
- Team colour data and bundled assets needed for current Super Netball analysis.

### Imported from upstream branches after the fork point

- The 2020 scoring updates from the original project's feature branch work.
- Player tidying improvements that attach team names and match details to player stats.
- The initial Shiny example app and supporting package data.

### Fork maintenance highlights

- Fork-specific installation and repository documentation.
- Ongoing package hardening and compatibility fixes for the current Champion Data feed.
- Test coverage and CI so the fork can be maintained independently of the original project.
