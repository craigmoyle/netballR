## Script used to build the anzc_comp_ids package dataset.
## Run from the repository root: source("inst/create_anzc_comp_ids.R")
## Comp IDs were identified by probing mc.championdata.com/data/{id}/fixture.json
## and confirmed by inspecting team names and match dates in the returned fixtures.

anzc_comp_ids <- dplyr::tibble(
  comp_id     = c(
    ## Combined ANZ Championship (Australian + NZ teams), 2008–2016
    8001L,  8002L,   # 2008
    8005L,  8006L,   # 2009
    8012L,  8013L,   # 2010
    8018L,  8019L,   # 2011
    8028L,  8029L,   # 2012
    8035L,  8036L,   # 2013
    9084L,  9085L,   # 2014
    9563L,  9564L,   # 2015
    9818L,  9819L,   # 2016
    ## NZ National Netball League (NZ teams only), 2017–present
    10088L, 10089L,  # 2017
    10404L, 10405L,  # 2018
    10574L, 10575L,  # 2019
    11035L,          # 2020 (COVID-shortened; no separate finals comp recorded)
    11379L, 11380L,  # 2021
    11655L, 11656L,  # 2022
    11875L, 11876L,  # 2023
    12427L, 12428L,  # 2024
    12685L, 12686L   # 2025
  ),
  season      = c(
    2008L, 2008L,
    2009L, 2009L,
    2010L, 2010L,
    2011L, 2011L,
    2012L, 2012L,
    2013L, 2013L,
    2014L, 2014L,
    2015L, 2015L,
    2016L, 2016L,
    2017L, 2017L,
    2018L, 2018L,
    2019L, 2019L,
    2020L,
    2021L, 2021L,
    2022L, 2022L,
    2023L, 2023L,
    2024L, 2024L,
    2025L, 2025L
  ),
  competition = c(
    rep("ANZ Championship", 18L),
    rep("NZ National Netball League", 17L)
  ),
  season_type = c(
    "regular", "finals",
    "regular", "finals",
    "regular", "finals",
    "regular", "finals",
    "regular", "finals",
    "regular", "finals",
    "regular", "finals",
    "regular", "finals",
    "regular", "finals",
    "regular", "finals",
    "regular", "finals",
    "regular", "finals",
    "regular",
    "regular", "finals",
    "regular", "finals",
    "regular", "finals",
    "regular", "finals",
    "regular", "finals"
  )
)

usethis::use_data(anzc_comp_ids, overwrite = TRUE)
