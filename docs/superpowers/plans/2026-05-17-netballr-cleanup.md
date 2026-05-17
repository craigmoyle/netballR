# netballR Post-Rename Cleanup Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Clean up the remaining post-rename metadata and documentation issues so active package/docs metadata consistently reflects `netballR` while preserving only intentional historical references.

**Architecture:** Fix source-of-truth metadata first (`DESCRIPTION`, `_pkgdown.yml`, `R/zzz.R`, `changelog.md`), then regenerate roxygen and pkgdown artifacts so generated outputs match the cleaned source. Preserve rename/upstream references only where they explain history, not where they imply the current package still uses old file names or branding.

**Tech Stack:** R package metadata, roxygen2, pkgdown, testthat, Makefile-based verification

---

## File map

- `DESCRIPTION` — add package website URL expected by pkgdown metadata.
- `_pkgdown.yml` — keep site metadata aligned with the renamed package.
- `R/zzz.R` — remove stale reference to old package-doc filename.
- `changelog.md` — keep historical rename/upstream notes, but normalize misleading old file references.
- `man/netballR-package.Rd` — regenerated package docs after metadata cleanup.
- `docs/` — regenerated pkgdown site output after cleanup.

### Task 1: Clean source metadata and historical wording

**Files:**
- Modify: `DESCRIPTION`
- Modify: `R/zzz.R`
- Modify: `changelog.md`
- Test: source grep / metadata review

- [ ] **Step 1: Write the failing metadata/history checks**

Run these inspection commands before changing anything:

```bash
rg -n "superNetballR_updated|superNetballR" changelog.md R/zzz.R
python - <<'PY'
from pathlib import Path
text = Path('DESCRIPTION').read_text()
print('Has pkgdown website URL:', 'https://craigmoyle.github.io/netballR/' in text)
print(text)
PY
```

Expected: 
- `R/zzz.R` still refers to `superNetballR.R`
- `changelog.md` still contains a misleading internal-file reference like `superNetballR.R`
- `DESCRIPTION` does not yet include the pkgdown website URL `https://craigmoyle.github.io/netballR/`

- [ ] **Step 2: Update `DESCRIPTION` to include the pkgdown website URL**

In `DESCRIPTION`, replace:

```dcf
URL: https://github.com/craigmoyle/netballR
BugReports: https://github.com/craigmoyle/netballR/issues
```

with:

```dcf
URL: https://craigmoyle.github.io/netballR/,
    https://github.com/craigmoyle/netballR
BugReports: https://github.com/craigmoyle/netballR/issues
```

- [ ] **Step 3: Remove the stale old-file reference from `R/zzz.R`**

Replace the contents of `R/zzz.R` with:

```r
## Nothing required here — see netballR-package.R for globalVariables declarations.
```

- [ ] **Step 4: Normalize misleading changelog references while preserving history**

In `changelog.md`, replace:

```md
- `globalVariables()` declarations consolidated from `zzz.R` + `superNetballR.R` into a single call; missing names (`goals2`, `isHome`, `games`, `qtr_diff`) added.
```

with:

```md
- `globalVariables()` declarations consolidated into a single package-level call; missing names (`goals2`, `isHome`, `games`, `qtr_diff`) added.
```

Keep these historical references unchanged because they are intentional lineage notes:

- upstream project identity `SteveLane/superNetballR`
- rename history `superNetballR` / `superNetballR_updated` to `netballR`

- [ ] **Step 5: Re-run the source checks to verify they now pass**

Run:

```bash
rg -n "superNetballR_updated|superNetballR" changelog.md R/zzz.R
python - <<'PY'
from pathlib import Path
text = Path('DESCRIPTION').read_text()
assert 'https://craigmoyle.github.io/netballR/' in text
print('DESCRIPTION now includes pkgdown website URL')
PY
```

Expected:
- `R/zzz.R` no longer contains `superNetballR`
- `changelog.md` retains only intentional historical `superNetballR` mentions
- the DESCRIPTION assertion passes

- [ ] **Step 6: Commit**

```bash
git add DESCRIPTION R/zzz.R changelog.md
git commit -m "docs: clean post-rename metadata and history references"
```

### Task 2: Regenerate roxygen and pkgdown artifacts from the cleaned source

**Files:**
- Modify: `man/netballR-package.Rd`
- Modify: `docs/`
- Test: grep on generated output

- [ ] **Step 1: Regenerate roxygen docs from the cleaned source**

Run:

```bash
Rscript -e "roxygen2::roxygenise()"
```

Expected: roxygen rewrites package docs such as `man/netballR-package.Rd` using the current cleaned metadata.

- [ ] **Step 2: Rebuild the pkgdown site**

Run:

```bash
Rscript -e "pkgdown::build_site()"
```

Expected:
- site rebuild completes
- the pkgdown complaint about missing package URL is gone
- Bootstrap 3 deprecation may still be reported and is acceptable for this cleanup pass

- [ ] **Step 3: Search generated output for stale active references**

Run:

```bash
rg -n "superNetballR_updated|superNetballR" man docs --glob '!docs/superpowers/**'
```

Expected:
- no stale active references remain in generated package docs/site output
- any remaining mentions must be clearly historical and intentional; if unexpected generated stale references appear, stop and fix the source before proceeding

- [ ] **Step 4: Commit**

```bash
git add man docs
git commit -m "docs: regenerate site after netballR cleanup"
```

### Task 3: Verify the cleaned package state end-to-end

**Files:**
- Test only: full repository verification commands

- [ ] **Step 1: Run the focused stale-reference scan**

Run:

```bash
rg -n "superNetballR_updated|superNetballR" . --glob '!docs/superpowers/**' --glob '!superNetballR.Rcheck/**' --glob '!netballR.Rcheck/**'
```

Expected:
- only intentional historical references remain, primarily in `changelog.md`
- no active code/config/package-doc references remain

- [ ] **Step 2: Run the full test suite**

Run:

```bash
make test
```

Expected: all tests pass.

- [ ] **Step 3: Run package check**

Run:

```bash
make check
```

Expected:
- `R CMD build` and `R CMD check --no-manual --as-cran` succeed
- the previous pkgdown metadata-related issue is gone
- the GitHub URL NOTE may still remain until the external repository rename actually happens on GitHub, which is acceptable for now

- [ ] **Step 4: Review the exact NOTE content**

Run:

```bash
grep -n "Found the following (possibly) invalid URLs\|Status:" netballR.Rcheck/00check.log || true
```

Expected: any remaining NOTE is limited to GitHub URLs that will stop 404ing only after the external repository rename is completed.

- [ ] **Step 5: Commit**

```bash
git commit --allow-empty -m "test: verify netballR cleanup"
```

## Self-review

- Spec coverage:
  - active metadata cleanup: Task 1
  - pkgdown/doc regeneration: Task 2
  - verification with only expected historical references left: Task 3
- Placeholder scan: no `TBD`, `TODO`, or content-free steps remain.
- Type consistency:
  - package website URL is consistently `https://craigmoyle.github.io/netballR/`
  - current package name is consistently `netballR`
  - historical references are preserved only in changelog lineage notes
