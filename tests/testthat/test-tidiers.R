test_that("tidyMatch returns completed periods in long format", {
  result <- tidyMatch(make_sample_match(period_completed = 2))

  expect_true(all(result$period <= 2))
  expect_equal(nrow(result), 12)
  expect_setequal(unique(result$stat), c("gains", "goalAttempts", "homeTeam"))
  expect_equal(unique(result$value[result$squadName == "Home" & result$stat == "homeTeam"]), 1)
  expect_equal(unique(result$value[result$squadName == "Away" & result$stat == "homeTeam"]), 0)
  expect_true("matchId" %in% names(result))
  expect_equal(tail(names(result), 3), c("round", "game", "matchId"))
  expect_equal(unique(result$matchId), 500503L)
})

test_that("tidyPlayers keeps player identity columns and drops displayName", {
  result <- tidyPlayers(make_sample_match(period_completed = 2))

  expect_true(all(result$period <= 2))
  expect_equal(nrow(result), 16)
  expect_false("displayName" %in% names(result))
  expect_type(result$value, "character")
  expect_setequal(
    unique(result$stat),
    c("feeds", "goals", "startingPositionCode", "currentPositionCode")
  )
  expect_equal(unique(result$squadName[result$playerId == 1]), "Home")
  expect_equal(
    result$value[result$playerId == 1 & result$stat == "goals" & result$period == 1],
    "5"
  )
  expect_equal(
    result$value[result$playerId == 1 & result$stat == "startingPositionCode" & result$period == 1],
    "GS"
  )
  expect_true("matchId" %in% names(result))
  expect_equal(tail(names(result), 3), c("round", "game", "matchId"))
  expect_equal(unique(result$matchId), 500503L)
})
