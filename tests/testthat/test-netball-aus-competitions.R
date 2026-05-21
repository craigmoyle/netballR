## ── URL builder ──────────────────────────────────────────────────────────────

test_that("build_application_settings_url returns the correct endpoint for known sources", {
  expect_equal(
    netballR:::build_application_settings_url("netball_aus"),
    "https://mc.championdata.com/netball_aus/settings/application_settings.json"
  )
  expect_equal(
    netballR:::build_application_settings_url("VitalityNetballWorldCup2019"),
    "https://mc.championdata.com/VitalityNetballWorldCup2019/settings/application_settings.json"
  )
})

## ── Source resolution ─────────────────────────────────────────────────────────

test_that("resolve_application_source maps friendly names to Champion Data paths", {
  expect_equal(netballR:::resolve_application_source("netball_aus"),     "netball_aus")
  expect_equal(netballR:::resolve_application_source("netball_nz"),      "netball_nz")
  expect_equal(netballR:::resolve_application_source("england_netball"), "england_netball")
  expect_equal(netballR:::resolve_application_source("nwc2015"),         "nwc2015")
  expect_equal(netballR:::resolve_application_source("nwc2019"),         "VitalityNetballWorldCup2019")
  expect_equal(netballR:::resolve_application_source("nwc2023"),         "nwc2023")
})

test_that("resolve_application_source errors on unknown source", {
  expect_error(
    netballR:::resolve_application_source("unknown_source"),
    "not a recognised application source"
  )
})

## ── extract_competitions ─────────────────────────────────────────────────────

test_that("extract_competitions parses a full-format catalogue into a tidy tibble", {
  result <- netballR:::extract_competitions(make_netball_aus_settings(), "netball_aus")

  expect_s3_class(result, "tbl_df")
  expect_named(
    result,
    c(
      "comp_id", "competition_name", "application_source", "season",
      "competition_type", "squad_id", "application_logo"
    )
  )
  expect_equal(result$comp_id, c(9315L, 10200L, 12971L))
  expect_equal(result$competition_name[[2]], "2017 Netball Quad Series - January")
  expect_equal(result$application_source, rep("netball_aus", 3))
  expect_equal(result$season, rep(NA_integer_, 3))
  expect_equal(result$competition_type, rep(NA_character_, 3))
  expect_equal(result$squad_id, c(NA_integer_, 811L, NA_integer_))
  expect_equal(
    result$application_logo,
    c(
      "/netball_aus/images/competition/9315.png",
      "/netball_aus/images/competition/9973.png",
      NA_character_
    )
  )
})

test_that("extract_competitions parses World Cup catalogue with NA competition_name", {
  result <- netballR:::extract_competitions(make_world_cup_settings(), "nwc2023")

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 2L)
  expect_equal(result$comp_id, c(12115L, 12116L))
  expect_equal(result$competition_name, rep(NA_character_, 2))
  expect_equal(result$application_source, rep("nwc2023", 2))
})

test_that("extract_competitions fails loudly when competition list is absent", {
  expect_error(
    netballR:::extract_competitions(list(), "netball_aus"),
    "did not include competitionList\\$competition"
  )
})

test_that("extract_competitions drops competition entries that have no id", {
  result <- netballR:::extract_competitions(make_settings_with_missing_id(), "netball_aus")

  expect_equal(nrow(result), 1L)
  expect_equal(result$comp_id, 9315L)
})

test_that("extract_competitions handles a single-entry catalogue", {
  result <- netballR:::extract_competitions(make_settings_single_competition(), "netball_aus")

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 1L)
  expect_equal(result$comp_id, 9315L)
  expect_equal(result$competition_name, "2014 Constellation Cup")
})

## ── listCompetitions ──────────────────────────────────────────────────────────

test_that("listCompetitions errors on an unknown source", {
  expect_error(listCompetitions("unknown"), "not a recognised application source")
})

## ── Named wrappers ────────────────────────────────────────────────────────────

test_that("listCompetitionsNetballAus returns extracted live competitions", {
  local_mocked_bindings(
    fetch_application_settings = function(path) make_netball_aus_settings(),
    .package = "netballR"
  )

  result <- listCompetitionsNetballAus()

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 3L)
  expect_equal(result$comp_id[[1]], 9315L)
  expect_true(all(result$application_source == "netball_aus"))
})

test_that("listCompetitionsNetballNZ sets application_source to netball_nz", {
  local_mocked_bindings(
    fetch_application_settings = function(path) make_netball_aus_settings(),
    .package = "netballR"
  )

  result <- listCompetitionsNetballNZ()

  expect_true(all(result$application_source == "netball_nz"))
})

test_that("listCompetitionsEnglandNetball sets application_source to england_netball", {
  local_mocked_bindings(
    fetch_application_settings = function(path) make_netball_aus_settings(),
    .package = "netballR"
  )

  result <- listCompetitionsEnglandNetball()

  expect_true(all(result$application_source == "england_netball"))
})

## ── listCompetitionsWorldCup ──────────────────────────────────────────────────

test_that("listCompetitionsWorldCup returns World Cup competitions for supported years", {
  local_mocked_bindings(
    fetch_application_settings = function(path) make_world_cup_settings(),
    .package = "netballR"
  )

  for (yr in c(2015L, 2019L, 2023L)) {
    result <- listCompetitionsWorldCup(yr)
    expect_s3_class(result, "tbl_df")
    expect_equal(nrow(result), 2L)
    expect_equal(result$competition_name, rep(NA_character_, 2))
  }
})

test_that("listCompetitionsWorldCup errors on unsupported year", {
  expect_error(listCompetitionsWorldCup(2022), "must be one of: 2015, 2019, 2023")
  expect_error(listCompetitionsWorldCup(0),    "must be greater than or equal to 1")
})

test_that("listCompetitionsWorldCup uses correct application_source for each year", {
  local_mocked_bindings(
    fetch_application_settings = function(path) make_world_cup_settings(),
    .package = "netballR"
  )

  expect_true(all(listCompetitionsWorldCup(2015)$application_source == "nwc2015"))
  expect_true(all(listCompetitionsWorldCup(2019)$application_source == "nwc2019"))
  expect_true(all(listCompetitionsWorldCup(2023)$application_source == "nwc2023"))
})

## ── listAllCompetitions ───────────────────────────────────────────────────────

test_that("listAllCompetitions deduplicates shared comp_ids keeping first source", {
  ## Two sources, both returning the same comp_id (9315), simulating a
  ## cross-catalogue duplicate like the Constellation Cup.
  call_count <- 0L
  local_mocked_bindings(
    fetch_application_settings = function(path) {
      call_count <<- call_count + 1L
      make_netball_aus_settings()
    },
    .package = "netballR"
  )

  result <- listAllCompetitions(
    sources     = c("netball_aus", "netball_nz"),
    deduplicate = TRUE
  )

  ## Only 3 unique comp_ids (from first source); duplicates from netball_nz dropped.
  expect_equal(nrow(result), 3L)
  ## All rows should come from the first source (netball_aus wins).
  expect_true(all(result$application_source == "netball_aus"))
  expect_equal(call_count, 2L)
})

test_that("listAllCompetitions with deduplicate = FALSE retains all rows", {
  local_mocked_bindings(
    fetch_application_settings = function(path) make_netball_aus_settings(),
    .package = "netballR"
  )

  result <- listAllCompetitions(
    sources     = c("netball_aus", "netball_nz"),
    deduplicate = FALSE
  )

  expect_equal(nrow(result), 6L)
  expect_equal(unique(result$application_source), c("netball_aus", "netball_nz"))
})

test_that("listAllCompetitions warns and continues when one source fails", {
  local_mocked_bindings(
    fetch_application_settings = function(path) {
      if (path == "netball_nz") stop("simulated network failure")
      make_netball_aus_settings()
    },
    .package = "netballR"
  )

  expect_warning(
    result <- listAllCompetitions(
      sources  = c("netball_aus", "netball_nz"),
      on_error = "warn"
    ),
    "simulated network failure"
  )
  expect_s3_class(result, "tbl_df")
  expect_true(all(result$application_source == "netball_aus"))
})

test_that("listAllCompetitions errors immediately when on_error = 'error'", {
  local_mocked_bindings(
    fetch_application_settings = function(path) stop("simulated failure"),
    .package = "netballR"
  )

  expect_error(
    listAllCompetitions(sources = c("netball_aus"), on_error = "error"),
    "simulated failure"
  )
})

test_that("listAllCompetitions errors when every source fails", {
  local_mocked_bindings(
    fetch_application_settings = function(path) stop("simulated failure"),
    .package = "netballR"
  )

  expect_error(
    suppressWarnings(
      listAllCompetitions(sources = c("netball_aus", "netball_nz"), on_error = "warn")
    ),
    "Failed to fetch competitions from all sources"
  )
})
