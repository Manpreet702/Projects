library(testthat)

test_that("End-to-End: Find Cities near a specific Address", {
  skip_with_no_internet <- function() {
    if (!curl::has_internet()) skip("No internet connection")
  }
  skip_with_no_internet()

  geo <- GEO$new()

  # Integration: tests address -> coordinates -> API request -> Dataframe
  # Note: 'Kelowna, BC' works well for your local context
  results <- geo$FindPlaces(locationAddress = "Kelowna, BC", radius = 50, limit = 5)

  # Assertions
  expect_s3_class(results$data, "data.frame")
  expect_gt(results$count, 0)
  # Check if the returned data contains characters (standard for API response)
  expect_type(results$data$name, "character")
})

test_that("Integration: Region lookup within a Country", {
  skip_if_offline()

  geo <- GEO$new()

  # Integration: tests the flow from Country Name to Region List
  regions <- geo$FindRegions.ByCountry(country = "Canada", limit = 5)

  expect_type(regions, "list")
  expect_named(regions, c("count", "data"))
  expect_s3_class(regions$data, "data.frame")
})
