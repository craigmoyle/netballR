build_netball_aus_settings_url <- function() {
  "https://mc.championdata.com/netball_aus/settings/application_settings.json"
}

fetch_netball_aus_settings <- function() {
  dat <- httr::RETRY(
    "GET",
    build_netball_aus_settings_url(),
    httr::timeout(30),
    times = 3,
    pause_base = 1,
    terminate_on = c(400, 401, 403, 404),
    quiet = TRUE
  )
  httr::stop_for_status(dat)
  httr::content(dat, as = "parsed", type = "application/json")
}

extract_netball_aus_competitions <- function(payload) {
  competitions <- payload$competitionList$competition
  if (is.null(competitions) || length(competitions) == 0L) {
    stop(
      "netball_aus application settings did not include competitionList$competition.",
      call. = FALSE
    )
  }

  rows <- lapply(competitions, function(comp) {
    dplyr::tibble(
      comp_id = as.integer(comp$id %||% NA_integer_),
      competition_name = as.character(comp$competition_name %||% NA_character_),
      application_source = "netball_aus",
      season = as.integer(comp$season %||% NA_integer_),
      competition_type = as.character(comp$type %||% NA_character_),
      squad_id = as.integer(comp$squad_id %||% NA_integer_),
      application_logo = as.character(comp$application_logo %||% NA_character_)
    )
  })

  dplyr::bind_rows(rows)
}

#' List competitions from the Champion Data netball_aus application
#'
#' \code{listCompetitionsNetballAus()} downloads the public application settings
#' used by the Champion Data \code{netball_aus} iStats app and returns a tidy
#' tibble of currently discoverable competitions.
#'
#' @return A \code{\link[dplyr]{tibble}} with one row per competition and
#'   columns:
#'   \describe{
#'     \item{comp_id}{Champion Data competition identifier. Pass this value to
#'       \code{\link{downloadFixture}} or \code{\link{downloadMatch}}.}
#'     \item{competition_name}{Competition name from the live application
#'       settings.}
#'     \item{application_source}{Always \code{"netball_aus"} for this helper.}
#'     \item{season}{Season year if supplied by the live settings payload,
#'       otherwise \code{NA}.}
#'     \item{competition_type}{Competition type if supplied by the live settings
#'       payload, otherwise \code{NA}.}
#'     \item{squad_id}{Optional squad filter attached to the competition in the
#'       live settings payload.}
#'     \item{application_logo}{Relative logo path from the live settings payload
#'       when available.}
#'   }
#' @details
#' Use this helper for current / active competition discovery. The live
#' catalogue can include Super Netball, Australian Diamonds internationals,
#' and other Australian competitions exposed by Champion Data.
#'
#' The returned \code{comp_id} values use the same Champion Data
#' \code{/data/...} transport as \code{\link{downloadFixture}} and
#' \code{\link{downloadMatch}}. For historical ANZ Championship and NZ
#' National Netball League IDs, use \code{\link{anzc_comp_ids}} instead.
#'
#' @examples
#' \dontrun{
#' comps <- listCompetitionsNetballAus()
#' subset(comps, grepl("Diamonds", competition_name, ignore.case = TRUE))
#' fixture <- downloadFixture(comps$comp_id[[1]])
#' }
#'
#' @export
listCompetitionsNetballAus <- function() {
  extract_netball_aus_competitions(fetch_netball_aus_settings())
}
