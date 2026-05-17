validate_identifier <- function(value, name) {
    if (length(value) != 1 || is.na(value)) {
        stop(name, " must be a single value.", call. = FALSE)
    }

    value <- as.character(value)
    if (!grepl("^[0-9]+$", value)) {
        stop(name, " must contain digits only.", call. = FALSE)
    }

    value
}

validate_positive_whole_number <- function(value, name) {
    value <- validate_identifier(value, name)
    value <- as.integer(value)

    if (value < 1) {
        stop(name, " must be greater than or equal to 1.", call. = FALSE)
    }

    value
}

build_match_url <- function(comp_id, round_id, game_id) {
    comp_id <- validate_identifier(comp_id, "comp_id")
    round_id <- validate_positive_whole_number(round_id, "round_id")
    game_id <- validate_positive_whole_number(game_id, "game_id")

    sprintf(
        "https://mc.championdata.com/data/%s/%s%02d%02d.json",
        comp_id,
        comp_id,
        round_id,
        game_id
    )
}

build_fixture_url <- function(comp_id) {
    comp_id <- validate_identifier(comp_id, "comp_id")
    sprintf("https://mc.championdata.com/data/%s/fixture.json", comp_id)
}

extract_match_stats <- function(payload) {
    dat_list <- payload$matchStats
    if (is.null(dat_list)) {
        stop("Champion Data response did not include matchStats.", call. = FALSE)
    }

    dat_list
}

extract_fixture <- function(payload) {
    fixture <- payload$fixture
    if (is.null(fixture)) {
        stop("Champion Data response did not include fixture.", call. = FALSE)
    }

    matches <- fixture$match
    if (is.null(matches) || length(matches) == 0L) {
        return(dplyr::tibble(
            round          = integer(),
            game           = integer(),
            matchId        = integer(),
            matchStatus    = character(),
            utcStartTime   = character(),
            homeSquadId    = integer(),
            homeSquadName  = character(),
            homeSquadScore = integer(),
            awaySquadId    = integer(),
            awaySquadName  = character(),
            awaySquadScore = integer()
        ))
    }

    rows <- lapply(matches, function(m) {
        dplyr::tibble(
            round          = as.integer(m$roundNumber),
            game           = as.integer(m$matchNumber),
            matchId        = as.integer(m$matchId),
            matchStatus    = as.character(m$matchStatus %||% NA_character_),
            utcStartTime   = as.character(m$utcStartTime %||% NA_character_),
            homeSquadId    = as.integer(m$homeSquadId),
            homeSquadName  = as.character(m$homeSquadName %||% NA_character_),
            homeSquadScore = as.integer(m$homeSquadScore %||% NA_integer_),
            awaySquadId    = as.integer(m$awaySquadId),
            awaySquadName  = as.character(m$awaySquadName %||% NA_character_),
            awaySquadScore = as.integer(m$awaySquadScore %||% NA_integer_)
        )
    })

    dplyr::bind_rows(rows)
}

#' @noRd
`%||%` <- function(x, y) if (is.null(x)) y else x

#' Download data from a single match
#'
#' \code{downloadMatch} downloads match and player data for a single match.
#'
#' @param comp_id A string identifying which season the game is
#'     in. \code{comp_id} is different depending on regular season or finals.
#'     See \code{\link{anzc_comp_ids}} for known ANZ Championship competition
#'     IDs, or \code{\link{listCompetitionsNetballAus}} for the broader live
#'     catalogue exposed by the Champion Data \code{netball_aus} application.
#' @param round_id An integer identifying which round the game is in. Finals
#'     reset round number to 1.
#' @param game_id An integer indentifying which game in the round to
#'     download. There are four games per round in the regular season, two games
#'     in the semi finals, one game for the prelim, and one grand final.
#' @return A list containing game and player data for the match.
#' @details
#' \code{downloadMatch()} validates the supplied identifiers, retries transient
#' HTTP failures, and raises an explicit error if the Champion Data response no
#' longer includes a \code{matchStats} object.
#'
#' ANZ Championship matches use the same data format as Super Netball and can
#' be downloaded with the same function by supplying the appropriate
#' \code{comp_id}. Because ANZ Championship matches do not use the super-shot
#' scoring zone, use \code{\link{ladders_pre_2020}} (and
#' \code{\link{matchPoints_pre_2020}}) when calculating standings for ANZ
#' Championship data. Use \code{\link{downloadFixture}} to discover the rounds
#' and game numbers available for a given competition.
#'
#' @examples
#' \dontrun{
#' downloadMatch("10083", 1, 1)
#'
#' ## ANZ Championship
#' downloadMatch("10088", 1, 1)
#' }
#'
#' @export
downloadMatch <- function(comp_id, round_id, game_id) {
    pg <- build_match_url(comp_id, round_id, game_id)
    dat <- httr::RETRY(
        "GET",
        pg,
        httr::timeout(30),
        times = 3,
        pause_base = 1,
        terminate_on = c(400, 401, 403, 404),
        quiet = TRUE
    )
    httr::stop_for_status(dat)
    extract_match_stats(httr::content(
        dat,
        as = "parsed",
        type = "application/json"
    ))
}

#' Download the fixture for a competition
#'
#' \code{downloadFixture} fetches the full match schedule and results for a
#' competition, returning one row per match.
#'
#' @param comp_id A string identifying the competition. See
#'     \code{\link{anzc_comp_ids}} for known ANZ Championship competition IDs
#'     or \code{\link{listCompetitionsNetballAus}} for the broader live
#'     catalogue exposed by the Champion Data \code{netball_aus} application.
#' @return A \code{\link[dplyr]{tibble}} with one row per match and columns:
#'   \describe{
#'     \item{round}{Round number.}
#'     \item{game}{Match number within the round.}
#'     \item{matchId}{Champion Data match identifier. Pass the round and game
#'       numbers to \code{\link{downloadMatch}} to retrieve full statistics.}
#'     \item{matchStatus}{Status string, e.g. \code{"complete"} or
#'       \code{"scheduled"}.}
#'     \item{utcStartTime}{Match start time in UTC (character).}
#'     \item{homeSquadId}{Numeric squad identifier for the home team.}
#'     \item{homeSquadName}{Full name of the home team.}
#'     \item{homeSquadScore}{Final score for the home team, or \code{NA} if the
#'       match has not been played.}
#'     \item{awaySquadId}{Numeric squad identifier for the away team.}
#'     \item{awaySquadName}{Full name of the away team.}
#'     \item{awaySquadScore}{Final score for the away team, or \code{NA} if the
#'       match has not been played.}
#'   }
#' @details
#' \code{downloadFixture()} is the recommended starting point when working with
#' a new competition: it shows which rounds and game numbers are available so
#' you can pass them to \code{\link{downloadMatch}}. Use
#' \code{\link{listCompetitionsNetballAus}} when you need to discover live
#' competition IDs from the broader \code{netball_aus} catalogue first.
#'
#' The function validates \code{comp_id}, retries transient HTTP failures, and
#' raises an explicit error if the Champion Data response does not include a
#' \code{fixture} object.
#'
#' @examples
#' \dontrun{
#' ## ANZ Championship 2017 (New Zealand, regular season)
#' downloadFixture("10088")
#'
#' ## Super Netball 2017
#' downloadFixture("10083")
#' }
#'
#' @export
downloadFixture <- function(comp_id) {
    pg <- build_fixture_url(comp_id)
    dat <- httr::RETRY(
        "GET",
        pg,
        httr::timeout(30),
        times = 3,
        pause_base = 1,
        terminate_on = c(400, 401, 403, 404),
        quiet = TRUE
    )
    httr::stop_for_status(dat)
    extract_fixture(httr::content(
        dat,
        as = "parsed",
        type = "application/json"
    ))
}
