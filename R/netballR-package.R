#' superNetballR: Download and Tidy Super Netball Statistics
#'
#' Download Champion Data Super Netball match feeds and transform team and
#' player statistics into tidy data frames for analysis.
#'
#' @keywords internal
"_PACKAGE"

## Suppress R CMD check notes for variables used in dplyr/tidyr pipelines.
if (getRversion() >= "2.15.1") {
    utils::globalVariables(c(
        ## match/player column names
        "squadId", "homeTeam", "period", "stat", "value", "squadName",
        "squadNickname", "squadCode", "round", "game", "displayName",
        "matchId", "playerId", "shortDisplayName", "firstname", "surname",
        ## scoring / ladder names
        "goals", "goals2", "score_diff", "points", "points_new",
        "goals_for", "goals_against", "percentage", "isHome",
        "games", "qtr_diff", "data",
        ## period-score helper names
        "homeValue", "homeSquad", "homePoints",
        "awayValue", "awaySquad", "awayPoints",
        "points_qtr", "game_results",
        "squadId.x", "squadId.y"
    ))
}
