# superNetballR

[![R-CMD-check](https://github.com/craigmoyle/superNetballR_updated/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/craigmoyle/superNetballR_updated/actions/workflows/R-CMD-check.yaml)

## Description

This fork of `superNetballR` allows the downloading of super netball statistics from the original project site: [https://stevelane.github.io/superNetballR/](https://stevelane.github.io/superNetballR/). The first super netball season was in 2017, and was eventually won by the Sunshine Coast Lightning.

`superNetballR` contains helper functions that transform the downloaded data into usable tidy data.

This repository is maintained at [craigmoyle/superNetballR_updated](https://github.com/craigmoyle/superNetballR_updated).
The current Champion Data iStats portal still exposes the same zone-based result data model used by this package, and `downloadMatch()` now validates match identifiers before requesting the JSON feed.

## Installation

Installation in R requires `remotes`. To install, run the following from an R session:

``` R
install.packages("remotes")
remotes::install_github("craigmoyle/superNetballR_updated")
```

To install the current `main` branch explicitly:

``` R
remotes::install_github("craigmoyle/superNetballR_updated@main")
```

## Current behavior

- `downloadMatch()` validates competition, round, and game identifiers, retries transient HTTP failures, and errors clearly if the Champion Data payload is missing `matchStats`.
- `downloadFixture()` fetches the full match schedule for any competition — use `?anzc_comp_ids` to find ANZ Championship and NZ National Netball League competition IDs.
- `matchPoints()` and `ladders()` implement the current super shot scoring model for 2020+ data.
- `matchPoints_pre_2020()` and `ladders_pre_2020()` remain available for legacy seasons and older points systems.
- `team_colours` includes the current Melbourne Mavericks entry while retaining the historical Magpies row needed by the bundled 2017 data.
- The package includes a `testthat` suite and a GitHub Actions `R-CMD-check` workflow for ongoing maintenance.

## ANZ Championship / NZ National Netball League

The same Champion Data feed powers both competitions. Use `anzc_comp_ids` to look up the competition ID for any season, then call `downloadFixture()` to see available matches and `downloadMatch()` to fetch match data. `tidyMatch()` now appends the Champion Data `matchId`, which helps keep regular-season and finals matches distinct when you combine live tidy outputs. Because ANZ Championship data uses a `goals` stat rather than the super-shot zones introduced in 2020, use `ladders_pre_2020()` (not `ladders()`) on season-style tidy match statistics when computing standings.

``` r
library(superNetballR)

# Browse available ANZ / NZ Netball seasons
anzc_comp_ids

# Get the fixture for the 2024 NZ National Netball League regular season
fixture <- downloadFixture(12427)

# Download and tidy a specific match (round 1, game 1)
match <- downloadMatch(12427, 1, 1)
match_stats <- tidyMatch(match)

# Summarise the single-match result using the pre-super-shot scoring model
match_result <- matchPoints_pre_2020(match_stats)

# For ladders_pre_2020(), supply season-style tidy match statistics
standings <- ladders_pre_2020(match_stats)
```

## Development

The repository now uses GitHub Actions instead of Travis CI. Local developer commands are available through the `Makefile`:

```sh
make test
make build
make check
```

`make check` uses base `R CMD build` and `R CMD check`, while CI regenerates package documentation before running `R-CMD-check`.

## Notes

The package has been updated to account for the super goal in 2020. Ladders and points have been adjusted for this. If you want to use the old scoring systems, these are available using `_pre_2020` versions of the appropriate functions.
