#' netballR: Download and Tidy Netball Statistics
#'
#' @description
#' Download Champion Data netball match feeds and transform team and player
#' statistics into tidy data frames for analysis.
#'
#' Current / active Australian coverage includes Super Netball plus Australian
#' Diamonds international matches and other competitions discoverable through
#' \code{\link{listCompetitionsNetballAus}}.
#'
#' @details
#' Use \code{\link{listCompetitionsNetballAus}} to discover live competition
#' IDs exposed by the Champion Data \code{netball_aus} application, including
#' active Super Netball seasons and Australian Diamonds internationals when
#' they appear in the live catalogue.
#'
#' Use \code{\link{anzc_comp_ids}} as a historical lookup for ANZ Championship
#' and NZ National Netball League competition IDs.
#'
#' Once you know a \code{comp_id}, use \code{\link{downloadFixture}} and
#' \code{\link{downloadMatch}} to retrieve data from the shared Champion Data
#' \code{/data/...} transport.
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
