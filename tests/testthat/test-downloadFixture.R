test_that("build_fixture_url validates and formats the request URL", {
  expect_equal(
    superNetballR:::build_fixture_url("10088"),
    "https://mc.championdata.com/data/10088/fixture.json"
  )
  expect_equal(
    superNetballR:::build_fixture_url(10088),
    "https://mc.championdata.com/data/10088/fixture.json"
  )

  expect_error(
    superNetballR:::build_fixture_url("anz-2017"),
    "comp_id must contain digits only"
  )
  expect_error(
    superNetballR:::build_fixture_url(NA),
    "comp_id must be a single value"
  )
})

test_that("extract_fixture fails loudly when fixture key is absent", {
  expect_error(
    superNetballR:::extract_fixture(list()),
    "did not include fixture"
  )
  expect_error(
    superNetballR:::extract_fixture(list(matchStats = list())),
    "did not include fixture"
  )
})

test_that("extract_fixture returns an empty tibble when match list is empty", {
  payload <- list(fixture = list(match = list()))
  result <- superNetballR:::extract_fixture(payload)
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0L)
  expect_true(all(c("round", "game", "matchId", "matchStatus",
                     "homeSquadName", "awaySquadName") %in% names(result)))
})

test_that("extract_fixture parses complete match rows correctly", {
  payload <- list(
    fixture = list(
      match = list(
        list(
          roundNumber    = 1L,
          matchNumber    = 2L,
          matchId        = 100880102L,
          matchStatus    = "complete",
          utcStartTime   = "2017-03-26T05:00:00+00:00",
          homeSquadId    = 808L,
          homeSquadName  = "Southern Steel",
          homeSquadScore = 55L,
          awaySquadId    = 8120L,
          awaySquadName  = "Northern Stars",
          awaySquadScore = 43L
        ),
        list(
          roundNumber    = 1L,
          matchNumber    = 1L,
          matchId        = 100880101L,
          matchStatus    = "scheduled",
          utcStartTime   = "2017-03-26T03:00:00+00:00",
          homeSquadId    = 802L,
          homeSquadName  = "Central Pulse",
          homeSquadScore = NULL,
          awaySquadId    = 806L,
          awaySquadName  = "Northern Mystics",
          awaySquadScore = NULL
        )
      )
    )
  )

  result <- superNetballR:::extract_fixture(payload)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 2L)
  expect_equal(result$round,          c(1L, 1L))
  expect_equal(result$game,           c(2L, 1L))
  expect_equal(result$homeSquadName,  c("Southern Steel", "Central Pulse"))
  expect_equal(result$awaySquadName,  c("Northern Stars", "Northern Mystics"))
  expect_equal(result$homeSquadScore, c(55L, NA_integer_))
  expect_equal(result$awaySquadScore, c(43L, NA_integer_))
  expect_equal(result$matchStatus,    c("complete", "scheduled"))
})

test_that("downloadFixture validates comp_id before requesting data", {
  expect_error(
    downloadFixture("anz-2017"),
    "comp_id must contain digits only"
  )
  expect_error(
    downloadFixture(NA),
    "comp_id must be a single value"
  )
})
