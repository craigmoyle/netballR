make_sample_match <- function(period_completed = 2) {
  list(
    matchInfo = list(
      homeSquadId = 10L,
      awaySquadId = 20L,
      periodCompleted = period_completed,
      roundNumber = 5L,
      matchNumber = 3L,
      matchId = 500503L
    ),
    teamInfo = list(
      team = list(
        list(
          squadId = 10L,
          squadName = "Home",
          squadNickname = "Homes",
          squadCode = "HOM"
        ),
        list(
          squadId = 20L,
          squadName = "Away",
          squadNickname = "Aways",
          squadCode = "AWY"
        )
      )
    ),
    teamPeriodStats = list(
      team = list(
        list(squadId = 10L, period = 1L, gains = 2L, goalAttempts = 10L),
        list(squadId = 10L, period = 2L, gains = 3L, goalAttempts = 11L),
        list(squadId = 10L, period = 3L, gains = 4L, goalAttempts = 12L),
        list(squadId = 20L, period = 1L, gains = 1L, goalAttempts = 8L),
        list(squadId = 20L, period = 2L, gains = 2L, goalAttempts = 9L),
        list(squadId = 20L, period = 3L, gains = 3L, goalAttempts = 10L)
      )
    ),
    playerInfo = list(
      player = list(
        list(
          playerId = 1L,
          squadId = 10L,
          displayName = "Home Shooter",
          shortDisplayName = "Shooter, Home",
          firstname = "Home",
          surname = "Shooter"
        ),
        list(
          playerId = 2L,
          squadId = 20L,
          displayName = "Away Shooter",
          shortDisplayName = "Shooter, Away",
          firstname = "Away",
          surname = "Shooter"
        )
      )
    ),
    playerPeriodStats = list(
      player = list(
        list(
          playerId = 1L, squadId = 10L, period = 1L, goals = 5L, feeds = 2L,
          startingPositionCode = "GS", currentPositionCode = "GS"
        ),
        list(
          playerId = 1L, squadId = 10L, period = 2L, goals = 6L, feeds = 3L,
          startingPositionCode = "GS", currentPositionCode = "GS"
        ),
        list(
          playerId = 1L, squadId = 10L, period = 3L, goals = 7L, feeds = 4L,
          startingPositionCode = "GS", currentPositionCode = "GS"
        ),
        list(
          playerId = 2L, squadId = 20L, period = 1L, goals = 4L, feeds = 1L,
          startingPositionCode = "GA", currentPositionCode = "GA"
        ),
        list(
          playerId = 2L, squadId = 20L, period = 2L, goals = 3L, feeds = 2L,
          startingPositionCode = "GA", currentPositionCode = "GA"
        ),
        list(
          playerId = 2L, squadId = 20L, period = 3L, goals = 2L, feeds = 3L,
          startingPositionCode = "GA", currentPositionCode = "GA"
        )
      )
    )
  )
}

make_modern_match_stats <- function(
  round,
  game,
  home_team,
  away_team,
  home_zone1,
  home_zone2 = 0,
  away_zone1,
  away_zone2 = 0
) {
  make_stat_row <- function(team, stat_name, stat_value) {
    data.frame(
      squadName = team,
      stat = stat_name,
      value = stat_value,
      period = 1L,
      round = round,
      game = game,
      stringsAsFactors = FALSE
    )
  }

  rows <- list(
    data.frame(
      squadName = c(home_team, away_team),
      stat = c("homeTeam", "homeTeam"),
      value = c(1L, 0L),
      period = c(1L, 1L),
      round = c(round, round),
      game = c(game, game),
      stringsAsFactors = FALSE
    )
  )

  if (!is.null(home_zone1)) {
    rows[[length(rows) + 1L]] <- make_stat_row(home_team, "goal_from_zone1", home_zone1)
  }

  if (!is.null(away_zone1)) {
    rows[[length(rows) + 1L]] <- make_stat_row(away_team, "goal_from_zone1", away_zone1)
  }

  if (!is.null(home_zone2)) {
    rows[[length(rows) + 1L]] <- make_stat_row(home_team, "goal_from_zone2", home_zone2)
  }

  if (!is.null(away_zone2)) {
    rows[[length(rows) + 1L]] <- make_stat_row(away_team, "goal_from_zone2", away_zone2)
  }

  do.call(rbind, rows)
}

make_pre_2020_match_stats <- function(
  round,
  game,
  home_team,
  away_team,
  home_goals,
  away_goals
) {
  stopifnot(length(home_goals) == length(away_goals))

  periods <- seq_along(home_goals)
  do.call(
    rbind,
    list(
      data.frame(
        squadName = c(rep(home_team, length(periods)), rep(away_team, length(periods))),
        stat = "goals",
        value = c(home_goals, away_goals),
        period = c(periods, periods),
        round = round,
        game = game,
        stringsAsFactors = FALSE
      ),
      data.frame(
        squadName = c(rep(home_team, length(periods)), rep(away_team, length(periods))),
        stat = "homeTeam",
        value = c(rep(1L, length(periods)), rep(0L, length(periods))),
        period = c(periods, periods),
        round = round,
        game = game,
        stringsAsFactors = FALSE
      )
    )
  )
}

make_modern_match_stats_with_id <- function(
  match_id,
  round,
  game,
  home_team,
  away_team,
  home_zone1,
  home_zone2 = 0,
  away_zone1,
  away_zone2 = 0
) {
  out <- make_modern_match_stats(
    round = round,
    game = game,
    home_team = home_team,
    away_team = away_team,
    home_zone1 = home_zone1,
    home_zone2 = home_zone2,
    away_zone1 = away_zone1,
    away_zone2 = away_zone2
  )
  out$matchId <- match_id
  out
}

make_pre_2020_match_stats_with_id <- function(
  match_id,
  round,
  game,
  home_team,
  away_team,
  home_goals,
  away_goals
) {
  out <- make_pre_2020_match_stats(
    round = round,
    game = game,
    home_team = home_team,
    away_team = away_team,
    home_goals = home_goals,
    away_goals = away_goals
  )
  out$matchId <- match_id
  out
}
