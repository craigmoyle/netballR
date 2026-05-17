# netballR Rename and netball_aus Support Design

## Summary

Evolve the project from a Super Netball-focused fork into a broader `netballR` package that supports competition discovery from the `netball_aus` iStats application while retaining the existing Champion Data `/data/<competitionID>/...` match and fixture transport.

This is a clean-break rename:

- repository becomes `netballR`
- package becomes `netballR`
- docs and positioning shift from `superNetballR` to broader netball coverage
- no backward-compatibility layer is required for the old package name or branding

## Goals

- Rename the repository, package, docs, and metadata from `superNetballR` / `superNetballR_updated` to `netballR`.
- Reposition the package as a general netball statistics package rather than a Super Netball-only package.
- Add support for discovering competitions from `https://mc.championdata.com/netball_aus/settings/application_settings.json`.
- Continue to download fixtures and match feeds using the existing Champion Data `/data/<competitionID>/...` endpoints.
- Support all competitions listed in the `netball_aus` application settings catalogue.
- Preserve the current `downloadMatch()` / `downloadFixture()` usage pattern based on `comp_id`.

## Non-goals

- No compatibility alias package named `superNetballR`.
- No major redesign of `downloadMatch()` / `downloadFixture()` signatures.
- No replacement of the underlying `/data/<competitionID>/...` transport format.
- No attempt to freeze the full `netball_aus` live competition catalogue into a static packaged dataset unless later requested.

## Key Findings

### 1. `netball_aus` is a discovery source, not a new match transport

Inspection of the public iStats application scripts showed that `https://mc.championdata.com/netball_aus/` still loads data from the same transport currently used by the package:

- fixture: `/data/<competitionID>/fixture.json`
- match: `/data/<competitionID>/<matchID>.json`

The `netball_aus` application adds a broader competition catalogue through:

- `https://mc.championdata.com/netball_aus/settings/application_settings.json`

Therefore, the package should treat `netball_aus` as a catalogue/discovery layer, while keeping current fixture and match downloads on `/data/...`.

### 2. The package rename is broader than code only

A clean rename affects multiple layers:

- `DESCRIPTION` package name
- test bootstrap (`tests/testthat.R`)
- package docs and roxygen titles
- shiny example paths that currently reference `superNetballR`
- README installation instructions and badges
- pkgdown/site metadata
- repository URLs and bug-report links
- text in vignettes, changelog, and package descriptions

## Design Decisions

### 1. Keep the transport model simple and stable

Current transport helpers remain the canonical way to fetch match and fixture JSON:

- `downloadFixture(comp_id)`
- `downloadMatch(comp_id, round_id, game_id)`

These functions should continue building URLs under `https://mc.championdata.com/data/...` because that is the transport still used by the `netball_aus` application.

This avoids overengineering and keeps the core API stable.

### 2. Add explicit catalogue/discovery helpers for `netball_aus`

Introduce a discovery layer for live competitions exposed by the `netball_aus` application settings.

Proposed helper responsibilities:

- fetch raw application settings JSON from `netball_aus/settings/application_settings.json`
- extract/tidy the competition list into a tibble
- expose a user-facing helper to list available `netball_aus` competitions

At minimum, the tidy output should include:

- `comp_id`
- `competition_name`
- `application_source`

Where available from the settings payload, also include:

- `season`
- `competition_type`
- `squad_id`
- `application_logo`
- any other low-risk metadata that is already present and useful for filtering

`application_source` should explicitly identify `netball_aus` so future discovery sources can coexist cleanly.

### 3. Preserve existing historical helpers where still useful

Existing historical ANZ/NZ helpers and datasets remain useful and should not be removed merely because the package is being broadened.

In practice:

- keep `anzc_comp_ids`
- keep legacy ladder/match-point helpers
- reframe docs so these are documented as supported historical/netball-specific workflows, not the entire purpose of the package

### 4. Rename package/product branding to `netballR`

The rename should be comprehensive and intentional.

Expected updates include:

- package name: `netballR`
- package title/description: broader netball wording
- repository URLs: `craigmoyle/netballR` (assuming repository rename occurs)
- badges, install instructions, and bug-report links
- vignette/package titles and narrative wording
- shiny app packaging paths and error messages

The clean-break decision means we do not preserve the old package name in exported package metadata or installation instructions.

### 5. Keep current function names unless they are overly branded

Functions such as `downloadMatch()`, `downloadFixture()`, `tidyMatch()`, and `tidyPlayers()` are already generic and should stay.

Brand-heavy or package-name-bound references should be renamed only where needed, for example:

- package title and package-level docs
- `shinySuperNetballR()` should be reviewed because its name is explicitly branded around the old package identity

The design choice for branded helpers is:

- if a helper name is package-branded but still worth keeping, rename it to a neutral equivalent
- if it is only a demo convenience wrapper, either rename it or consider de-emphasizing it in docs

## Proposed API Additions

The exact function names can be finalized in implementation planning, but the discovery layer should likely expose one or both of these user-facing helpers:

1. a raw settings fetcher (internal or exported)
2. a tidy competition listing helper for `netball_aus`

Candidate design:

- internal: fetch `application_settings.json`
- exported: return a tibble of competitions ready for filtering and use with `downloadFixture()` / `downloadMatch()`

The user workflow should look like:

1. list competitions from `netball_aus`
2. choose a `comp_id`
3. call `downloadFixture(comp_id)`
4. call `downloadMatch(comp_id, round_id, game_id)`

## File Impact

### Core package metadata and branding

- `DESCRIPTION`
- `NAMESPACE`
- `README.md`
- `_pkgdown.yml`
- `changelog.md`
- `tests/testthat.R`
- `R/superNetballR.R` (package-level docs file; may be renamed)
- package-level man files generated from roxygen

### Download/discovery logic

- `R/downloadMatch.R`
- likely new file for catalogue/discovery helpers, e.g. `R/competitions.R`
- possibly `inst/create_anzc_comp_ids.R` if docs or comments need repositioning

### Tests

- `tests/testthat/test-downloadMatch.R`
- `tests/testthat/test-downloadFixture.R`
- new tests for `netball_aus` catalogue parsing/discovery
- `tests/testthat/helper-fixtures.R` for settings fixtures if needed

### Demo app / package-internal paths

- `R/shinySuperNetballR.R`
- `inst/shiny-examples/superNetballR/...`

### Documentation

- `vignettes/getting-started.Rmd`
- `man/*.Rd` after roxygen regeneration
- pkgdown site config and generated site if maintained in-repo

## Testing Strategy

Follow TDD for the feature work.

Required coverage areas:

1. existing `downloadMatch()` and `downloadFixture()` URL builders still point to `/data/...`
2. `netball_aus` settings discovery fetch/parsing works for representative payloads
3. competition listing helper returns a tidy, predictable schema
4. package rename does not break test bootstrap or namespace loading
5. any renamed branded helper (for example the shiny launcher) has updated coverage if kept

Prefer fixture-based tests for the `netball_aus` settings structure so the test suite does not depend on live network access.

## Migration / Release Considerations

Because this is a clean break:

- version bump should reflect a breaking release
- README/install docs should direct users to the new repository/package name only
- changelog should clearly call out the rename and broadened scope
- users may need to reinstall under the new package name

If repository rename happens outside the codebase, code/docs should assume the new canonical URLs once the rename is complete.

## Risks

- The `netball_aus` application settings payload may evolve independently of the current package assumptions, so parsing should be defensive.
- A clean package rename touches many files and increases the chance of missing stale references.
- Branded helper functions like `shinySuperNetballR()` need a deliberate decision to avoid leaving the API in a partially renamed state.
- Generated docs/site output may create a large diff after the rename.

## Acceptance Criteria

- Package metadata, docs, and references are renamed to `netballR`.
- The package is positioned as a general netball statistics package.
- Users can discover all `netball_aus` competitions through a tidy helper.
- Users can still fetch fixtures/matches via the existing `comp_id`-based download functions.
- Tests cover the new discovery layer and the unchanged transport behavior.
- Documentation explains the discovery → fixture → match workflow clearly.
