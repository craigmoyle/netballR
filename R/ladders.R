safe_percentage <- function(goals_for, goals_against) {
  ifelse(goals_against == 0, Inf, goals_for / goals_against)
}

limit_match_results <- function(match_results, round_num = NULL, game_num = NULL) {
  if (!is.null(game_num) && is.null(round_num)) {
    stop("If game number is supplied, round number must also be supplied.")
  }
  if (is.null(round_num)) {
    return(match_results)
  }
  if (is.null(game_num)) {
    return(dplyr::filter(match_results, round <= round_num))
  }

  dplyr::filter(match_results, round < round_num | (round == round_num & game <= game_num))
}

sort_ladder <- function(ladder, points_col) {
  ladder[order(-ladder[[points_col]], -ladder$percentage, ladder$squadName), , drop = FALSE]
}

#' Calculates ladder positions
#'
#' \code{ladders} calculates ladder positions at the end of a match.
#'
#' @param df Data frame containing season match statistics.
#' @param round_num Round at which to calculate ladder positions. Optional.
#' @param game_num Game at which to calculate ladder positions. Optional.
#' @param old_system Logical. For \code{ladders()}, retained for compatibility
#'     and ignored (2020+ scoring always applies). For
#'     \code{ladders_pre_2020()}, if \code{TRUE} sorts the ladder by the
#'     legacy 2-point win system (\code{points}); if \code{FALSE} (default)
#'     sorts by the updated 4-point win system (\code{points_new}).
#'
#' @return Data frame containing the ladder position of all teams. If round and
#'     game are not supplied, the ladder position is calculated using all match
#'     data present in the \code{df} supplied.
#' @details
#' \code{ladders()} uses the current 2020+ scoring helpers, while
#' \code{ladders_pre_2020()} uses the legacy scoring pipeline. Ladder
#' percentages are protected against divide-by-zero by returning \code{Inf}
#' when a team has not conceded. Legacy ladders break ties on percentage after
#' ordering by either \code{points_new} or \code{points}.
#'
#' When a tidy input data frame includes \code{matchId}, the internal
#' match-result helpers use it as the grouping key; otherwise they fall back to
#' the legacy \code{round}/\code{game} grouping used by bundled datasets.
#'
#' \strong{ANZ Championship}: ANZ Championship matches record scores in the
#' \code{goals} statistic rather than the \code{goal_from_zone1} /
#' \code{goal_from_zone2} statistics used by the 2020+ Super Netball super-shot
#' era. Use \code{\link{ladders_pre_2020}} (and
#' \code{\link{matchPoints_pre_2020}}) for all ANZ Championship seasons.
#'
#' @export
ladders <- function(df, round_num = NULL, game_num = NULL, old_system = FALSE) {
  match_results <- limit_match_results(
    matchResults(df = df),
    round_num = round_num,
    game_num = game_num
  )
  ladder <- match_results |>
    dplyr::group_by(squadName) |>
    dplyr::summarise(
      games = dplyr::n(),
      goals_for = sum(goals),
      goals_against = sum(goals - score_diff),
      percentage = safe_percentage(goals_for, goals_against),
      points = as.integer(sum(points)),
      .groups = "drop"
    )
  sort_ladder(ladder, "points")
}

group_match_data <- function(df) {
  if ("matchId" %in% names(df)) {
    return(dplyr::group_by(df, matchId, round, game))
  }

  dplyr::group_by(df, round, game)
}

#' @rdname ladders
#' @export
matchResults <- function(df) {
  df |>
    group_match_data() |>
    tidyr::nest() |>
    dplyr::mutate(game_results = purrr::map(data, matchPoints)) |>
    dplyr::select(-data) |>
    tidyr::unnest(cols = c(game_results))
}

matchResults_pre_2020 <- function(df) {
  df |>
    group_match_data() |>
    tidyr::nest() |>
    dplyr::mutate(game_results = purrr::map(data, matchPoints_pre_2020)) |>
    dplyr::select(-data) |>
    tidyr::unnest(cols = c(game_results))
}

#' @rdname ladders
#' @export
ladders_pre_2020 <- function(df, round_num = NULL, game_num = NULL, old_system = FALSE) {
  match_results <- limit_match_results(
    matchResults_pre_2020(df = df),
    round_num = round_num,
    game_num = game_num
  )
  ladder <- match_results |>
    dplyr::group_by(squadName) |>
    dplyr::summarise(
      games = dplyr::n(),
      goals_for = sum(goals),
      goals_against = sum(goals - score_diff),
      percentage = safe_percentage(goals_for, goals_against),
      points = as.integer(sum(points)),
      points_new = as.integer(sum(points_new)),
      .groups = "drop"
    )
  points_col <- if (old_system) "points" else "points_new"
  sort_ladder(ladder, points_col)
}
