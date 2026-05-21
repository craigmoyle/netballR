# netballR

[![R-CMD-check](https://github.com/craigmoyle/netballR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/craigmoyle/netballR/actions/workflows/R-CMD-check.yaml)

## Description

`netballR` provides tools to discover netball competitions, download Champion Data match feeds, and transform team and player statistics into tidy data for analysis.

This package supports two complementary competition-discovery pathways that feed the same download workflow:

1. use the Champion Data application catalogue functions to discover current competitions:
   - `listCompetitionsNetballAus()` — Super Netball, Australian Diamonds internationals, and other Australian competitions
   - `listCompetitionsNetballNZ()` — NZ National Netball League, Silver Ferns internationals, and domestic NZ competitions
   - `listCompetitionsEnglandNetball()` — England Netball competitions
   - `listCompetitionsWorldCup(year)` — Netball World Cup catalogues for 2015, 2019, and 2023
   - `listCompetitions(source)` — generic function for any named Champion Data catalogue
   - `listAllCompetitions()` — query all catalogues at once, with optional deduplication
2. use `anzc_comp_ids` as a historical lookup for ANZ Championship and NZ National Netball League competition IDs

Current / active Australian coverage includes Super Netball plus Australian Diamonds international matches and other competitions surfaced by the live `netball_aus` catalogue. Historical coverage includes ANZ Championship and NZ National Netball League workflows.

Once you know a `comp_id`, use `downloadFixture()` and `downloadMatch()` to retrieve data from the Champion Data `/data/<comp_id>/...` feed.

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
- `listCompetitions(source)` returns competitions from any named Champion Data application catalogue. Named convenience wrappers exist for each catalogue (`listCompetitionsNetballAus()`, `listCompetitionsNetballNZ()`, `listCompetitionsEnglandNetball()`, `listCompetitionsWorldCup(year)`).
- `listAllCompetitions()` queries all known catalogues at once. The same competition can appear in multiple catalogues (e.g. the Constellation Cup appears in both `netball_aus` and `netball_nz`); `deduplicate = TRUE` (default) keeps one row per `comp_id`.
- `matchPoints()` and `ladders()` implement the current super-shot scoring model for 2020+ data.
- `matchPoints_pre_2020()` and `ladders_pre_2020()` remain available for legacy seasons and older points systems.
- `tidyMatch()` and `tidyPlayers()` append the Champion Data `matchId` so combined live tidy outputs can keep distinct matches separate.

## Discover competitions across all catalogues

Use `listAllCompetitions()` to query every known Champion Data catalogue in one call. Duplicate `comp_id` values (international competitions listed by multiple countries) are removed by default, with the first-matched source taking precedence.

```r
library(netballR)

## All competitions, deduplicated
all_comps <- listAllCompetitions()

## Inspect cross-catalogue duplicates
all_comps_raw <- listAllCompetitions(deduplicate = FALSE)
all_comps_raw[all_comps_raw$comp_id == 9315, c("comp_id", "competition_name", "application_source")]
```

## Discover competitions by region or tournament

```r
library(netballR)

## New Zealand competitions
listCompetitionsNetballNZ()

## England Netball competitions
listCompetitionsEnglandNetball()

## Netball World Cup catalogues (2015, 2019, or 2023)
listCompetitionsWorldCup(2023)

## Any named catalogue
listCompetitions("nwc2019")
```

## Discover current competitions from `netball_aus`

Use `listCompetitionsNetballAus()` to inspect the live competition catalogue exposed by the Champion Data `netball_aus` application. This is the recommended discovery path for current / active Super Netball seasons, Australian Diamonds international matches, and other broader Australian competitions.

```r
library(netballR)

competitions <- listCompetitionsNetballAus()
competitions

subset(competitions, grepl("Diamonds", competition_name, ignore.case = TRUE))
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

## Historical competition lookups with `anzc_comp_ids`

`anzc_comp_ids` is a historical lookup dataset for ANZ Championship and NZ National Netball League workflows. Super Netball is current coverage and should be discovered through `listCompetitionsNetballAus()` when you need active competition IDs.

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
