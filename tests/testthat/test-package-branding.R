test_that("netballR exports the renamed shiny launcher", {
  exports <- getNamespaceExports("netballR")

  expect_true("shinyNetballR" %in% exports)
  expect_false("shinySuperNetballR" %in% exports)
})
