#' Runs the demo shiny app
#'
#' \code{shinySuperNetballR} Runs the demo shiny app to compare Super Netball
#' statistics between teams.
#'
#' @return Runs a shiny app
#'
#' @export
shinySuperNetballR <- function() {
  if (!requireNamespace("shiny", quietly = TRUE)) {
    stop("Package 'shiny' must be installed to run shinySuperNetballR().", call. = FALSE)
  }
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("Package 'ggplot2' must be installed to run shinySuperNetballR().", call. = FALSE)
  }

  my_dir <- system.file(
    "shiny-examples", "superNetballR", package = "superNetballR"
  )
  if (my_dir == "") {
    stop("Can't find the superNetballR shiny directory. Try re-installing `superNetballR`.", call. = FALSE)
  }

  shiny::runApp(my_dir, display.mode = "normal")
}
