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

#' ANZ Championship and NZ National Netball League competition IDs.
#'
#' A dataset mapping Champion Data \code{comp_id} values to the corresponding
#' netball season and competition, covering every season from 2008 to 2023.
#'
#' @format A tibble with 31 rows and 4 variables:
#' \describe{
#'   \item{comp_id}{Integer Champion Data competition identifier. Pass this
#'     value as \code{comp_id} to \code{\link{downloadMatch}} or
#'     \code{\link{downloadFixture}}.}
#'   \item{season}{Integer season year (e.g. \code{2017L}).}
#'   \item{competition}{Competition name: \code{"ANZ Championship"} (the
#'     combined Australia + New Zealand competition, 2008--2016) or
#'     \code{"NZ National Netball League"} (New Zealand only, 2017--present).}
#'   \item{season_type}{Either \code{"regular"} (regular season) or
#'     \code{"finals"} (finals series). The 2020 season was COVID-shortened
#'     and has no separate finals entry.}
#' }
#' @details
#' ANZ Championship seasons (2008--2016) featured both Australian and New
#' Zealand franchises. From 2017 the New Zealand teams continued in the
#' NZ National Netball League while the Australian franchises moved to Super
#' Netball.
#'
#' Both competitions use the \code{goals} statistic for scoring (not the
#' \code{goal_from_zone1} / \code{goal_from_zone2} super-shot statistics used
#' by Super Netball from 2020). Use \code{\link{ladders_pre_2020}} when
#' computing standings for any ANZ Championship or NZ National Netball League
#' season.
#'
#' @source Competition IDs identified by probing the Champion Data feed at
#'   \url{https://mc.championdata.com/anz_championship/} and confirmed by
#'   inspecting team names and match dates in the returned fixture data.
#'
#' @examples
#' anzc_comp_ids
#'
#' # Find the regular-season comp_id for 2019
#' subset(anzc_comp_ids, season == 2019 & season_type == "regular")
"anzc_comp_ids"

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
