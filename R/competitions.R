## Named mapping from user-facing source identifiers to Champion Data application paths.
## Use this to add new sources without changing the public API.
.application_source_map <- c(
  netball_aus     = "netball_aus",
  netball_nz      = "netball_nz",
  england_netball = "england_netball",
  nwc2015         = "nwc2015",
  nwc2019         = "VitalityNetballWorldCup2019",
  nwc2023         = "nwc2023"
)

resolve_application_source <- function(source) {
  if (source %in% names(.application_source_map)) {
    return(.application_source_map[[source]])
  }
  stop(
    "'", source, "' is not a recognised application source. ",
    "Supported sources: ", paste(names(.application_source_map), collapse = ", "), ".",
    call. = FALSE
  )
}

build_application_settings_url <- function(application_path) {
  sprintf(
    "https://mc.championdata.com/%s/settings/application_settings.json",
    application_path
  )
}

fetch_application_settings <- function(application_path) {
  dat <- httr::RETRY(
    "GET",
    build_application_settings_url(application_path),
    httr::timeout(30),
    times = 3,
    pause_base = 1,
    terminate_on = c(400, 401, 403, 404),
    quiet = TRUE
  )
  httr::stop_for_status(dat)
  httr::content(dat, as = "parsed", type = "application/json")
}

extract_competitions <- function(payload, source) {
  competitions <- payload$competitionList$competition
  if (is.null(competitions) || length(competitions) == 0L) {
    stop(
      "'", source, "' application settings did not include competitionList$competition.",
      call. = FALSE
    )
  }

  ## Normalise: a single competition may parse as a named list rather than a
  ## list-of-lists. Wrap it so lapply always iterates over competition entries.
  if (!is.list(competitions[[1]])) {
    competitions <- list(competitions)
  }

  rows <- lapply(competitions, function(comp) {
    id <- as.integer(comp$id %||% NA_integer_)
    if (is.na(id)) {
      return(NULL)
    }
    dplyr::tibble(
      comp_id          = id,
      competition_name = as.character(comp$competition_name %||% NA_character_),
      application_source = source,
      season           = as.integer(comp$season %||% NA_integer_),
      competition_type = as.character(comp$type %||% NA_character_),
      squad_id         = as.integer(comp$squad_id %||% NA_integer_),
      application_logo = as.character(comp$application_logo %||% NA_character_)
    )
  })

  dplyr::bind_rows(rows[!vapply(rows, is.null, logical(1L))])
}

#' List competitions from a Champion Data application catalogue
#'
#' \code{listCompetitions()} downloads the public application settings for a
#' named Champion Data iStats catalogue and returns a tidy tibble of
#' discoverable competitions.
#'
#' @param source A string naming the application catalogue. Supported values:
#'   \describe{
#'     \item{\code{"netball_aus"}}{Current Australian competitions including
#'       Super Netball and Australian Diamonds internationals.}
#'     \item{\code{"netball_nz"}}{New Zealand competitions including the NZ
#'       National Netball League (ANE) and Silver Ferns internationals.}
#'     \item{\code{"england_netball"}}{England Netball competitions.}
#'     \item{\code{"nwc2015"}}{Netball World Cup 2015.}
#'     \item{\code{"nwc2019"}}{Vitality Netball World Cup 2019.}
#'     \item{\code{"nwc2023"}}{Netball World Cup 2023.}
#'   }
#' @return A \code{\link[dplyr]{tibble}} with one row per competition and
#'   columns:
#'   \describe{
#'     \item{comp_id}{Champion Data competition identifier.}
#'     \item{competition_name}{Competition name, or \code{NA} for World Cup
#'       catalogues which do not include names in their application settings.}
#'     \item{application_source}{The \code{source} value supplied, identifying
#'       which catalogue the row came from.}
#'     \item{season}{Season year when available.}
#'     \item{competition_type}{Competition type when available.}
#'     \item{squad_id}{Optional squad filter.}
#'     \item{application_logo}{Relative logo path when available.}
#'   }
#' @details
#' The same \code{comp_id} can appear in more than one catalogue
#' (e.g. international competitions may be listed by both \code{netball_aus}
#' and \code{netball_nz}). Use \code{\link{listAllCompetitions}} to query
#' multiple catalogues at once and deduplicate by \code{comp_id}.
#'
#' All returned \code{comp_id} values are compatible with
#' \code{\link{downloadFixture}} and \code{\link{downloadMatch}}.
#' @examples
#' \dontrun{
#' listCompetitions("netball_nz")
#' listCompetitions("england_netball")
#' listCompetitions("nwc2023")
#' }
#' @seealso \code{\link{listAllCompetitions}}, \code{\link{listCompetitionsNetballAus}},
#'   \code{\link{listCompetitionsNetballNZ}}, \code{\link{listCompetitionsEnglandNetball}},
#'   \code{\link{listCompetitionsWorldCup}}
#' @export
listCompetitions <- function(source) {
  path <- resolve_application_source(source)
  extract_competitions(fetch_application_settings(path), source)
}

#' List competitions from the Champion Data netball_aus application
#'
#' \code{listCompetitionsNetballAus()} downloads the public application settings
#' used by the Champion Data \code{netball_aus} iStats app and returns a tidy
#' tibble of currently discoverable competitions.
#'
#' @return A \code{\link[dplyr]{tibble}} with one row per competition. See
#'   \code{\link{listCompetitions}} for column descriptions.
#' @details
#' The live catalogue includes Super Netball, Australian Diamonds
#' internationals, and other Australian competitions.
#'
#' For historical ANZ Championship and NZ National Netball League IDs, use
#' \code{\link{anzc_comp_ids}} instead.
#' @examples
#' \dontrun{
#' comps <- listCompetitionsNetballAus()
#' subset(comps, grepl("Diamonds", competition_name, ignore.case = TRUE))
#' fixture <- downloadFixture(comps$comp_id[[1]])
#' }
#' @seealso \code{\link{listCompetitions}}, \code{\link{listAllCompetitions}}
#' @export
listCompetitionsNetballAus <- function() {
  listCompetitions("netball_aus")
}

#' List competitions from the Champion Data netball_nz application
#'
#' \code{listCompetitionsNetballNZ()} returns competitions from the New Zealand
#' catalogue, including the NZ National Netball League (ANE), Silver Ferns
#' internationals, and domestic NZ competitions.
#'
#' @return A \code{\link[dplyr]{tibble}} with one row per competition. See
#'   \code{\link{listCompetitions}} for column descriptions.
#' @details
#' The same competition may appear in both \code{netball_nz} and
#' \code{netball_aus} catalogues (e.g. Constellation Cup). Use
#' \code{\link{listAllCompetitions}} to deduplicate across sources.
#' @examples
#' \dontrun{
#' listCompetitionsNetballNZ()
#' }
#' @seealso \code{\link{listCompetitions}}, \code{\link{listAllCompetitions}}
#' @export
listCompetitionsNetballNZ <- function() {
  listCompetitions("netball_nz")
}

#' List competitions from the Champion Data england_netball application
#'
#' \code{listCompetitionsEnglandNetball()} returns competitions from the England
#' Netball catalogue, including Vitality Roses internationals and domestic
#' England competitions.
#'
#' @return A \code{\link[dplyr]{tibble}} with one row per competition. See
#'   \code{\link{listCompetitions}} for column descriptions.
#' @examples
#' \dontrun{
#' listCompetitionsEnglandNetball()
#' }
#' @seealso \code{\link{listCompetitions}}, \code{\link{listAllCompetitions}}
#' @export
listCompetitionsEnglandNetball <- function() {
  listCompetitions("england_netball")
}

#' List competitions from a Netball World Cup application catalogue
#'
#' \code{listCompetitionsWorldCup()} returns competitions from the specified
#' Netball World Cup Champion Data catalogue.
#'
#' @param year Integer. The World Cup year. Must be one of \code{2015},
#'   \code{2019}, or \code{2023}.
#' @return A \code{\link[dplyr]{tibble}} with one row per competition. See
#'   \code{\link{listCompetitions}} for column descriptions.
#' @details
#' World Cup catalogues do not include \code{competition_name} in their
#' application settings, so that column will be \code{NA}. The
#' \code{application_source} column (\code{"nwc2015"}, \code{"nwc2019"}, or
#' \code{"nwc2023"}) identifies the catalogue.
#' @examples
#' \dontrun{
#' listCompetitionsWorldCup(2023)
#' listCompetitionsWorldCup(2019)
#' }
#' @seealso \code{\link{listCompetitions}}, \code{\link{listAllCompetitions}}
#' @export
listCompetitionsWorldCup <- function(year) {
  valid_years <- c(2015L, 2019L, 2023L)
  year <- validate_positive_whole_number(year, "year")
  if (!year %in% valid_years) {
    stop(
      "'year' must be one of: ", paste(valid_years, collapse = ", "), ".",
      call. = FALSE
    )
  }
  source <- c("2015" = "nwc2015", "2019" = "nwc2019", "2023" = "nwc2023")[[as.character(year)]]
  listCompetitions(source)
}

#' List competitions from all known Champion Data application catalogues
#'
#' \code{listAllCompetitions()} queries multiple Champion Data application
#' catalogues and returns a combined tidy tibble.
#'
#' @param sources Character vector of source identifiers to query. Defaults to
#'   all known sources. See \code{\link{listCompetitions}} for supported values.
#' @param deduplicate Logical. If \code{TRUE} (default), rows with duplicate
#'   \code{comp_id} values are removed, keeping the first occurrence based on
#'   the order of \code{sources}. Set to \code{FALSE} to retain all rows and
#'   inspect cross-catalogue coverage via \code{application_source}.
#' @param on_error One of \code{"warn"} (default), \code{"error"}, or
#'   \code{"ignore"}. Controls behaviour when fetching a single source fails.
#'   \code{"warn"} issues a warning and continues; \code{"error"} stops
#'   immediately; \code{"ignore"} silently skips the failed source. An error is
#'   always raised if every source fails.
#' @return A \code{\link[dplyr]{tibble}} with one row per competition (after
#'   optional deduplication). Includes all columns from
#'   \code{\link{listCompetitions}}.
#' @details
#' International competitions may appear in more than one catalogue. When
#' \code{deduplicate = TRUE}, the first occurrence wins, so source ordering
#' in \code{sources} determines which \code{application_source} label is
#' retained for shared \code{comp_id} values.
#'
#' Set \code{deduplicate = FALSE} to inspect which catalogues list a given
#' competition:
#' \preformatted{
#' all <- listAllCompetitions(deduplicate = FALSE)
#' all[all$comp_id == 9315, c("comp_id", "competition_name", "application_source")]
#' }
#' @examples
#' \dontrun{
#' ## Deduplicated (default)
#' listAllCompetitions()
#'
#' ## Full cross-catalogue view
#' listAllCompetitions(deduplicate = FALSE)
#'
#' ## Subset of sources
#' listAllCompetitions(sources = c("netball_aus", "netball_nz"))
#' }
#' @seealso \code{\link{listCompetitions}}
#' @export
listAllCompetitions <- function(
  sources   = names(.application_source_map),
  deduplicate = TRUE,
  on_error  = c("warn", "error", "ignore")
) {
  on_error <- match.arg(on_error)

  results <- lapply(sources, function(src) {
    tryCatch(
      listCompetitions(src),
      error = function(e) {
        msg <- paste0(
          "Failed to fetch competitions from '", src, "': ", conditionMessage(e)
        )
        if (on_error == "error") stop(msg, call. = FALSE)
        if (on_error == "warn")  warning(msg, call. = FALSE)
        NULL
      }
    )
  })

  non_null <- results[!vapply(results, is.null, logical(1L))]
  if (length(non_null) == 0L) {
    stop("Failed to fetch competitions from all sources.", call. = FALSE)
  }

  out <- dplyr::bind_rows(non_null)

  if (deduplicate) {
    out <- dplyr::distinct(out, comp_id, .keep_all = TRUE)
  }

  out
}
