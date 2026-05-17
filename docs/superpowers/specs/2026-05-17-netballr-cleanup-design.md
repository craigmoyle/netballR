# netballR Post-Rename Cleanup Design

## Summary

Perform a balanced cleanup pass after the `netballR` rename and `netball_aus` discovery work.

This pass should:

- fix active metadata and documentation issues left by the rename
- remove stale `superNetballR` references from active package code/docs/site output
- preserve intentional historical references where they explain lineage or release history
- improve pkgdown metadata consistency without over-refactoring the broader documentation set

## Goals

- Add missing pkgdown package URL metadata so site generation is internally consistent.
- Remove stale active references to `superNetballR` from package code, docs, and generated site output.
- Keep historical rename/upstream references only where they are intentionally explanatory.
- Update changelog wording where older entries refer to now-renamed internal files in a misleading way.
- Rebuild generated documentation/site outputs so the repository reflects the cleaned state.

## Non-goals

- No further package API redesign.
- No new features beyond cleanup.
- No repository-remote changes; GitHub rename remains an external administrative step.
- No wholesale rewrite of the full changelog/history unless required for accuracy.

## Design Decisions

### 1. Fix active metadata first

The cleanup should prioritize active metadata problems that still affect tooling:

- `DESCRIPTION` should include the package website URL expected by pkgdown
- pkgdown configuration and generated site output should align with the renamed package
- active package docs/man pages should reflect `netballR` consistently

This is the highest-value cleanup because it reduces noise in verification output and keeps published artifacts coherent.

### 2. Preserve historical references selectively

Not every `superNetballR` string should be removed.

These references should remain when they describe historical facts:

- original upstream project identity
- rename history from `superNetballR` / `superNetballR_updated` to `netballR`
- historical release notes that are explicitly framed as legacy context

However, references that imply the current package still uses old names, old files, or old branding should be updated.

### 3. Normalize misleading changelog references

The changelog currently includes some older entries that mention now-renamed internal files such as `superNetballR.R`. Those mentions are historically understandable, but after the rename they read like current file references.

The cleanup should rewrite those specific mentions into neutral historical wording, for example:

- refer to package-level docs or global variable declarations generically
- avoid naming obsolete files unless the filename itself is historically important

This keeps the historical record while reducing confusion.

### 4. Regenerate derived artifacts after source cleanup

After source/doc cleanup, regenerate:

- roxygen docs
- pkgdown site

This ensures generated files do not preserve stale references that were already removed from source files.

## File Impact

### Source metadata and docs

- `DESCRIPTION`
- `_pkgdown.yml`
- `R/netballR-package.R` if package-level wording still needs cleanup
- `R/zzz.R` if any stale historical file references remain there
- `changelog.md`

### Generated artifacts

- `man/*.Rd`
- `docs/` pkgdown output

## Acceptance Criteria

- Active package/docs metadata no longer implies the package is `superNetballR`.
- `DESCRIPTION` and pkgdown metadata are aligned for the `netballR` site.
- Historical references remain only where they are intentional and explanatory.
- Misleading old internal file references are rewritten to neutral historical wording.
- Generated `man/` and `docs/` outputs are refreshed after cleanup.
- Verification remains green aside from the known GitHub-rename-dependent URL note until the external repository rename happens.

## Risks

- Over-cleaning could erase useful historical context from the changelog.
- Generated docs may still contain stale references if source cleanup is incomplete before regeneration.
- pkgdown may continue to warn about unrelated configuration modernization (for example Bootstrap 3) even after this cleanup pass.
