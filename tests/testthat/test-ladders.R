test_that("matchResults and ladders summarise a simple season correctly", {
  season <- rbind(
    make_modern_match_stats(1L, 1L, "A", "B", 10L, 1L, 8L, 0L),
    make_modern_match_stats(2L, 1L, "B", "A", 10L, 0L, 10L, 0L)
  )

  match_results <- matchResults(season)
  ladder <- ladders(season)
  round_one_ladder <- ladders(season, round_num = 1L)

  expect_equal(nrow(match_results), 4)
  expect_equal(ladder$points[ladder$squadName == "A"], 6)
  expect_equal(ladder$points[ladder$squadName == "B"], 2)
  expect_equal(round_one_ladder$points[round_one_ladder$squadName == "A"], 4)
  expect_equal(ladders(season, old_system = TRUE), ladder)
})

test_that("ladders returns infinite percentage when goals against is zero", {
  season <- make_modern_match_stats(1L, 1L, "A", "B", 10L, 0L, 0L, 0L)
  ladder <- ladders(season)

  expect_true(is.infinite(ladder$percentage[ladder$squadName == "A"]))
})

test_that("ladders_pre_2020 uses the legacy match scoring pipeline", {
  season <- make_pre_2020_match_stats(
    round = 1L,
    game = 1L,
    home_team = "A",
    away_team = "B",
    home_goals = c(12L, 8L),
    away_goals = c(10L, 7L)
  )

  ladder <- ladders_pre_2020(season)

  expect_equal(ladder$points[ladder$squadName == "A"], 2)
  expect_equal(ladder$points_new[ladder$squadName == "A"], 6)
})

test_that("ladders respects round and game cutoffs without including later rounds", {
  season <- rbind(
    make_modern_match_stats(1L, 1L, "A", "B", 10L, 0L, 8L, 0L),
    make_modern_match_stats(2L, 1L, "A", "B", 8L, 0L, 10L, 0L),
    make_modern_match_stats(3L, 1L, "A", "B", 12L, 0L, 6L, 0L)
  )

  ladder <- ladders(season, round_num = 2L, game_num = 1L)

  expect_equal(sum(ladder$games), 4)
  expect_equal(sum(ladder$points), 8)
})

test_that("ladders_pre_2020 breaks ties on percentage", {
  season <- rbind(
    make_pre_2020_match_stats(
      round = 1L,
      game = 1L,
      home_team = "A",
      away_team = "B",
      home_goals = c(5L, 5L, 5L, 5L),
      away_goals = c(2L, 3L, 2L, 3L)
    ),
    make_pre_2020_match_stats(
      round = 2L,
      game = 1L,
      home_team = "B",
      away_team = "A",
      home_goals = c(4L, 4L, 4L, 3L),
      away_goals = c(2L, 2L, 3L, 2L)
    )
  )

  ladder <- ladders_pre_2020(season)

  expect_equal(ladder$points_new, c(8L, 8L))
  expect_equal(ladder$squadName[[1]], "A")
  expect_gt(ladder$percentage[[1]], ladder$percentage[[2]])
})
