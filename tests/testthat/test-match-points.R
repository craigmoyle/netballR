test_that("matchPoints handles missing zone-two rows and awards modern points", {
  df <- make_modern_match_stats(
    round = 1L,
    game = 1L,
    home_team = "Home",
    away_team = "Away",
    home_zone1 = 10L,
    home_zone2 = 2L,
    away_zone1 = 9L,
    away_zone2 = NULL
  )

  result <- matchPoints(df)

  expect_equal(result$goals[result$squadName == "Home"], 14)
  expect_equal(result$goals[result$squadName == "Away"], 9)
  expect_equal(result$points[result$squadName == "Home"], 4)
  expect_equal(result$points[result$squadName == "Away"], 0)
})

test_that("matchPoints returns draw points for tied matches", {
  df <- make_modern_match_stats(
    round = 1L,
    game = 1L,
    home_team = "Home",
    away_team = "Away",
    home_zone1 = 10L,
    home_zone2 = 1L,
    away_zone1 = 12L,
    away_zone2 = 0L
  )

  result <- matchPoints(df)

  expect_true(all(result$score_diff == 0))
  expect_true(all(result$points == 2))
})

test_that("matchPoints keeps teams that only score from zone two", {
  df <- make_modern_match_stats(
    round = 1L,
    game = 1L,
    home_team = "Home",
    away_team = "Away",
    home_zone1 = NULL,
    home_zone2 = 5L,
    away_zone1 = 4L,
    away_zone2 = NULL
  )

  result <- matchPoints(df)

  expect_setequal(result$squadName, c("Home", "Away"))
  expect_equal(result$goals[result$squadName == "Home"], 10)
  expect_equal(result$points[result$squadName == "Home"], 4)
  expect_equal(result$score_diff[result$squadName == "Away"], -6)
})

test_that("matchPoints_pre_2020 keeps old and new scoring totals", {
  df <- make_pre_2020_match_stats(
    round = 1L,
    game = 1L,
    home_team = "Home",
    away_team = "Away",
    home_goals = c(10L, 8L),
    away_goals = c(8L, 9L)
  )

  result <- matchPoints_pre_2020(df)

  expect_equal(result$points[result$squadName == "Home"], 2)
  expect_equal(result$points_new[result$squadName == "Home"], 5)
  expect_equal(result$points_new[result$squadName == "Away"], 1)
})

test_that("matchPoints_pre_2020 ignores overtime periods for quarter bonus points", {
  df <- make_pre_2020_match_stats(
    round = 1L,
    game = 1L,
    home_team = "Home",
    away_team = "Away",
    home_goals = c(10L, 8L, 7L, 9L, 2L, 4L),
    away_goals = c(8L, 9L, 11L, 6L, 3L, 2L)
  )

  result <- matchPoints_pre_2020(df)

  expect_equal(result$points[result$squadName == "Home"], 2)
  expect_equal(result$points[result$squadName == "Away"], 0)
  expect_equal(result$points_new[result$squadName == "Home"], 6)
  expect_equal(result$points_new[result$squadName == "Away"], 2)
})
