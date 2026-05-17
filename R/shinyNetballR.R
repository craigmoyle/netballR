#' Runs the demo shiny app
#'
#' \code{shinyNetballR} runs the demo shiny app to compare team statistics.
#'
#' @return Runs a shiny app
#'
#' @export
shinyNetballR <- function() {
  if (!requireNamespace("shiny", quietly = TRUE)) {
    stop("Package 'shiny' must be installed to run shinyNetballR().", call. = FALSE)
  }
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("Package 'ggplot2' must be installed to run shinyNetballR().", call. = FALSE)
  }

  my_dir <- system.file(
    "shiny-examples", "netballR", package = "netballR"
  )
  if (my_dir == "") {
    stop("Can't find the netballR shiny directory. Try re-installing `netballR`.", call. = FALSE)
  }

  shiny::runApp(my_dir, display.mode = "normal")
}
