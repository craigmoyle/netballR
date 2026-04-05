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
#' @param old_system Logical. Retained for compatibility and ignored for
#'     2020+ ladders.
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
#' @export
ladders <- function(df, round_num = NULL, game_num = NULL, old_system = FALSE) {
  match_results <- limit_match_results(
    matchResults(df = df),
    round_num = round_num,
    game_num = game_num
  )
  ladder <- match_results %>%
    dplyr::group_by(squadName) %>%
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

#' @rdname ladders
#' @export
matchResults <- function(df) {
  df <- df %>%
    dplyr::group_by(round, game) %>%
    tidyr::nest() %>%
    dplyr::group_by(round, game) %>%
    dplyr::mutate(game_results = purrr::map(data, matchPoints)) %>%
    dplyr::select(-data) %>%
    tidyr::unnest(cols = c(game_results))
  df
}

matchResults_pre_2020 <- function(df) {
  df <- df %>%
    dplyr::group_by(round, game) %>%
    tidyr::nest() %>%
    dplyr::group_by(round, game) %>%
    dplyr::mutate(game_results = purrr::map(data, matchPoints_pre_2020)) %>%
    dplyr::select(-data) %>%
    tidyr::unnest(cols = c(game_results))
  df
}

#' @rdname ladders
#' @export
ladders_pre_2020 <- function(df, round_num = NULL, game_num = NULL, old_system = FALSE) {
  match_results <- limit_match_results(
    matchResults_pre_2020(df = df),
    round_num = round_num,
    game_num = game_num
  )
  ladder <- match_results %>%
    dplyr::group_by(squadName) %>%
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
