#' Season 2017 match data.
#'
#' A dataset containing match statistics for all home and away and finals series
#' matches from the 2017 super netball season, by period.
#'
#' @format A data frame with 15360 rows and 9 variables:
#' \describe{
#'   \item{squadId}{Unique squad number}
#'   \item{squadName}{Full squad name}
#'   \item{squadNickname}{Squad nickname}
#'   \item{squadCode}{Short code for squad}
#'   \item{stat}{Statistic measured during the match}
#'   \item{value}{Character representation of the statistic value}
#'   \item{period}{Which period the statistic is measured in}
#'   \item{round}{Round number of the match}
#'   \item{game}{Game number of the match}
#' }
"season_2017"

#' Season 2017 player data.
#'
#' A dataset containing player statistics for all home and away and finals
#' series matches from the 2017 super netball season, by period.
#'
#' @format A data frame with 153728 rows and 11 variables:
#' \describe{
#'   \item{playerId}{Unique player number}
#'   \item{period}{Which period the statistic is measured in}
#'   \item{squadId}{Unique squad number}
#'   \item{shortDisplayName}{surname, firstname}
#'   \item{firstname}{Player firstname}
#'   \item{surname}{Player surname}
#'   \item{squadName}{Full squad name}
#'   \item{stat}{Statistic measured during the match}
#'   \item{value}{Character representation of the statistic value}
#'   \item{round}{Round number of the match}
#'   \item{game}{Game number of the match}
#' }
"players_2017"

#' Match and player statistics from round 5, game 3, season 2017.
#'
#' A list containing detailed match and player statistics, as obtained using the
#' \code{downloadMatch} function.
#'
#' @format A list.
"round5_game3"

#' Team colours.
#'
#' A dataset containing hex-coded team colours for the current Super Netball
#' competition teams, plus the historical Magpies entry used by the bundled
#' 2017 data.
#'
#' @format A data frame with 9 rows and 3 variables:
#' \describe{
#'   \item{squadName}{Full squad name}
#'   \item{squadId}{Unique squad number}
#'   \item{squadColour}{Hex-coded team colour}
#' }
"team_colours"
