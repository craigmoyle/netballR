# netballR

[![R-CMD-check](https://github.com/craigmoyle/netballR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/craigmoyle/netballR/actions/workflows/R-CMD-check.yaml)

## Description

`netballR` provides tools to discover netball competitions, download Champion Data match feeds, and transform team and player statistics into tidy data for analysis.

This package now supports two complementary workflows:

1. discover live competitions exposed by the Champion Data `netball_aus` iStats application
2. download fixtures and matches using the existing Champion Data `/data/<comp_id>/...` transport

Historical Super Netball, ANZ Championship, and NZ National Netball League workflows remain supported.

## Installation

Installation in R requires `remotes`. To install, run the following from an R session:

```r
install.packages("remotes")
remotes::install_github("craigmoyle/netballR")
```

To install the current `main` branch explicitly:

```r
remotes::install_github("craigmoyle/netballR@main")
```

## Current behavior

- `downloadMatch()` validates competition, round, and game identifiers, retries transient HTTP failures, and errors clearly if the Champion Data payload is missing `matchStats`.
- `downloadFixture()` fetches the full match schedule for any competition supported by the Champion Data `/data/...` feed.
- `listCompetitionsNetballAus()` returns a live competition catalogue sourced from `https://mc.championdata.com/netball_aus/settings/application_settings.json`.
- `matchPoints()` and `ladders()` implement the current super-shot scoring model for 2020+ data.
- `matchPoints_pre_2020()` and `ladders_pre_2020()` remain available for legacy seasons and older points systems.
- `tidyMatch()` and `tidyPlayers()` append the Champion Data `matchId` so combined live tidy outputs can keep distinct matches separate.

## Discover competitions from `netball_aus`

Use `listCompetitionsNetballAus()` to inspect the live competition catalogue exposed by the Champion Data `netball_aus` application.

```r
library(netballR)

competitions <- listCompetitionsNetballAus()
competitions
```

The returned `comp_id` values work directly with `downloadFixture()` and `downloadMatch()`.

```r
library(netballR)

competitions <- listCompetitionsNetballAus()
comp_id <- competitions$comp_id[[1]]

fixture <- downloadFixture(comp_id)
match <- downloadMatch(comp_id, 1, 1)
match_stats <- tidyMatch(match)
```

## Historical ANZ Championship / NZ National Netball League

The package still includes `anzc_comp_ids` for historical ANZ Championship and NZ National Netball League workflows.

```r
library(netballR)

anzc_comp_ids
fixture <- downloadFixture(12427)
match <- downloadMatch(12427, 1, 1)
match_stats <- tidyMatch(match)
match_result <- matchPoints_pre_2020(match_stats)
standings <- ladders_pre_2020(match_stats)
```

## Development

Local developer commands are available through the `Makefile`:

```sh
make test
make build
make check
```

## Notes

Champion Data's public `netball_aus` site still loads fixture and match JSON from `/data/<comp_id>/...`, so `netballR` uses `netball_aus` for competition discovery and `/data/...` for actual fixture/match downloads.
