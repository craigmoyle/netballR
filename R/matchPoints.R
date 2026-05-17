#' Calculates the total goals of the match
#'
#' \code{matchPoints} calculates final match goals and score difference.
#'
#' @param df Match data.
#'
#' @return A data frame containing the final scores, and points for the ladder.
#' @details
#' \code{matchPoints()} treats \code{goal_from_zone1} as one point and
#' \code{goal_from_zone2} as two points, matching the current super shot era.
#' @export
matchPoints <- function(df) {
  home <- df |>
    dplyr::filter(stat == "homeTeam") |>
    dplyr::select(-period) |>
    dplyr::distinct()
  goals1 <- df |>
    dplyr::filter(stat == "goal_from_zone1") |>
    dplyr::group_by(squadName) |>
    dplyr::summarise(goals = sum(value, na.rm = TRUE), .groups = "drop")
  goals2 <- df |>
    dplyr::filter(stat == "goal_from_zone2") |>
    dplyr::group_by(squadName) |>
    dplyr::summarise(goals2 = sum(value, na.rm = TRUE) * 2, .groups = "drop")
  goals <- home |>
    dplyr::left_join(goals1, by = "squadName") |>
    dplyr::left_join(goals2, by = "squadName") |>
    dplyr::mutate(
      goals = dplyr::coalesce(goals, 0),
      goals2 = dplyr::coalesce(goals2, 0),
      goals = goals + goals2
    ) |>
    dplyr::select(-goals2)

  if (all(goals$goals == 0) &&
      !any(df$stat %in% c("goal_from_zone1", "goal_from_zone2"))) {
    warning(
      "All goals are zero and neither 'goal_from_zone1' nor 'goal_from_zone2' ",
      "appear in the data. Did you mean to use matchPoints_pre_2020() for ",
      "pre-2020 or ANZ Championship data?",
      call. = FALSE
    )
  }

  goals <- goals |>
    dplyr::arrange(value)
  if (nrow(goals) != 2) {
    stop("Match data must include exactly two squads.", call. = FALSE)
  }
  goals |>
    dplyr::mutate(
      score_diff = goals - rev(goals),
      points = dplyr::case_when(
        score_diff > 0 ~ 4,
        score_diff < 0 ~ 0,
        .default = 2
      )
    ) |>
    dplyr::rename(isHome = value) |>
    dplyr::select(-stat)
}

#' Calculates the total goals of the match (pre 2020 season)
#'
#' \code{matchPoints_pre_2020} calculates final match goals and score
#' difference, for seasons pre-2020.
#'
#' @param df Match data.
#'
#' @return A data frame containing the final scores, and points for the ladder.
#' @details
#' \code{matchPoints_pre_2020()} uses the original goals statistic for match
#' results and also reports the newer quarter-points summary in
#' \code{points_new}.
#' @export
matchPoints_pre_2020 <- function(df) {
    goals <- df |>
        dplyr::filter(stat == "goals") |>
        dplyr::group_by(squadName) |>
        dplyr::summarise(goals = sum(value, na.rm = TRUE), .groups = "drop")
    home <- df |>
        dplyr::filter(stat == "homeTeam") |>
        dplyr::select(-period) |>
        dplyr::distinct()
    goals <- dplyr::left_join(goals, home, by = "squadName") |>
        dplyr::arrange(value)
    if (nrow(goals) != 2) {
        stop("Match data must include exactly two squads.", call. = FALSE)
    }
    goals <- goals |>
        dplyr::mutate(
            score_diff = goals - rev(goals),
            points = dplyr::case_when(
                score_diff > 0 ~ 2,
                score_diff < 0 ~ 0,
                .default = 1
            ),
            points_new = dplyr::case_when(
                score_diff > 0 ~ 4,
                score_diff < 0 ~ 0,
                .default = 2
            )
        ) |>
        dplyr::rename(isHome = value) |>
        dplyr::select(-stat)

    ## Quarter-points bonus (new system)
    goals_new <- df |>
        dplyr::filter(stat == "goals", period <= 4)
    homeScores <- goals_new |>
        dplyr::filter(squadName == home[['squadName']][home[['value']] == 1]) |>
        dplyr::select(period, homeSquad = squadName, homeValue = value)
    awayScores <- goals_new |>
        dplyr::filter(squadName == home[['squadName']][home[['value']] == 0]) |>
        dplyr::select(period, awaySquad = squadName, awayValue = value)
    scores <- dplyr::left_join(homeScores, awayScores, by = "period") |>
        dplyr::mutate(
            qtr_diff = homeValue - awayValue,
            homePoints = dplyr::case_when(qtr_diff > 0 ~ 1, .default = 0),
            awayPoints = dplyr::case_when(qtr_diff < 0 ~ 1, .default = 0)
        )
    points_new <- scores |>
        dplyr::group_by(homeSquad, awaySquad) |>
        dplyr::summarise(
            homePoints = sum(homePoints, na.rm = TRUE),
            awayPoints = sum(awayPoints, na.rm = TRUE),
            .groups = "drop"
        )
    df1 <- points_new |>
        dplyr::select(dplyr::contains("home")) |>
        dplyr::rename(squadName = homeSquad, points_qtr = homePoints)
    df2 <- points_new |>
        dplyr::select(dplyr::contains("away")) |>
        dplyr::rename(squadName = awaySquad, points_qtr = awayPoints)
    points_new <- dplyr::bind_rows(df1, df2)

    dplyr::left_join(goals, points_new, by = "squadName") |>
        dplyr::mutate(points_new = points_new + points_qtr) |>
        dplyr::select(-points_qtr)
}
