#' superNetballR: Download and Tidy Super Netball Statistics
#'
#' Download Champion Data Super Netball match feeds and transform team and
#' player statistics into tidy data frames for analysis.
#'
#' @keywords internal
#' @importFrom magrittr %>%
"_PACKAGE"

## quiets concerns of R CMD check re: the .'s that appear in pipelines
if (getRversion() >= "2.15.1") {
    utils::globalVariables(c(".", "points_new", "homeValue", "homeSquad",
                             "homePoints", "awayValue", "awaySquad",
                             "awayPoints", "points_qtr", "game_results",
                             "squadId.x", "squadId.y"))
}
