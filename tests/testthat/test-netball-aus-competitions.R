test_that("build_netball_aus_settings_url returns the application settings endpoint", {
  expect_equal(
    netballR:::build_netball_aus_settings_url(),
    "https://mc.championdata.com/netball_aus/settings/application_settings.json"
  )
})

test_that("extract_netball_aus_competitions parses application settings into a tidy tibble", {
  result <- netballR:::extract_netball_aus_competitions(make_netball_aus_settings())

  expect_s3_class(result, "tbl_df")
  expect_named(
    result,
    c(
      "comp_id", "competition_name", "application_source", "season",
      "competition_type", "squad_id", "application_logo"
    )
  )
  expect_equal(result$comp_id, c(9315L, 10200L, 12971L))
  expect_equal(result$competition_name[[2]], "2017 Netball Quad Series - January")
  expect_equal(result$application_source, rep("netball_aus", 3))
  expect_equal(result$season, rep(NA_integer_, 3))
  expect_equal(result$competition_type, rep(NA_character_, 3))
  expect_equal(result$squad_id, c(NA_integer_, 811L, NA_integer_))
  expect_equal(
    result$application_logo,
    c(
      "/netball_aus/images/competition/9315.png",
      "/netball_aus/images/competition/9973.png",
      NA_character_
    )
  )
})

test_that("extract_netball_aus_competitions fails loudly when the competition list is absent", {
  expect_error(
    netballR:::extract_netball_aus_competitions(list()),
    "did not include competitionList\\$competition"
  )
})

test_that("listCompetitionsNetballAus returns extracted live competitions", {
  local_mocked_bindings(
    fetch_netball_aus_settings = function() make_netball_aus_settings(),
    .package = "netballR"
  )

  result <- listCompetitionsNetballAus()

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 3L)
  expect_equal(result$comp_id[[1]], 9315L)
  expect_true(all(result$application_source == "netball_aus"))
})
