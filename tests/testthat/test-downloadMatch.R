test_that("build_match_url validates and formats request identifiers", {
  expect_equal(
    superNetballR:::build_match_url("10083", 5, 3),
    "https://mc.championdata.com/data/10083/100830503.json"
  )
  expect_equal(
    superNetballR:::build_match_url(10083, "5", "3"),
    "https://mc.championdata.com/data/10083/100830503.json"
  )

  expect_error(
    superNetballR:::build_match_url("season-2025", 5, 3),
    "comp_id must contain digits only"
  )
  expect_error(
    superNetballR:::build_match_url("10083", 0, 3),
    "round_id must be greater than or equal to 1"
  )
  expect_error(
    superNetballR:::build_match_url("10083", 5, 1.5),
    "game_id must contain digits only"
  )
})

test_that("extract_match_stats fails loudly when matchStats is absent", {
  payload <- list(matchStats = list(matchInfo = list(matchNumber = 3L)))

  expect_equal(superNetballR:::extract_match_stats(payload), payload$matchStats)
  expect_error(
    superNetballR:::extract_match_stats(list()),
    "did not include matchStats"
  )
})

test_that("downloadMatch validates identifiers before requesting data", {
  expect_error(
    downloadMatch("season-2025", 5, 3),
    "comp_id must contain digits only"
  )
  expect_error(
    downloadMatch("10083", 0, 3),
    "round_id must be greater than or equal to 1"
  )
  expect_error(
    downloadMatch("10083", 5, 1.5),
    "game_id must contain digits only"
  )
})
