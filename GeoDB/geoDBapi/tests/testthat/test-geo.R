library(testthat)
library(countrycode) # Ensure the dataset is loaded for the test environment

# Initialize the GEO object for testing
# Note: Your current code hardcodes max_limit to 10 in the constructor
geo <- GEO$new()

test_that("Initialization and Field Defaults", {
  expect_equal(geo$max_limit, 10)
  expect_match(geo$base_url, "geodb-free-service")
})

test_that("Country Name and Code Retrieval", {
  # We use the 'codelist' from the global environment since the package is loaded
  codes_df <- geo$getCountryNamesAndCodes()
  expect_s3_class(codes_df, "data.frame")
  expect_true(all(c("name", "code2", "code3") %in% colnames(codes_df)))

  # Ensure the check matches the tolower() transformation in your code
  expect_true("canada" %in% codes_df$name)
})

test_that("Closest Matching Country Codes", {
  # Testing exact match (Code uses tolower/toupper internally)
  expect_equal(geo$getClosestMatchingCountryNamesOrCodes("Canada"), "CA")

  # Testing partial match logic from your GEO.R file
  expect_equal(geo$getClosestMatchingCountryNamesOrCodes("United Stat"), "US")
})

test_that("Coordinate to ISO Format Conversion", {
  # Test positive coordinates
  # Your code uses %2B for positive numbers and %2.4f formatting
  iso_val <- geo$convertLongitudeLatitudeToISO(45.5231, -122.6765)
  expect_identical(iso_val, "%2B45.5231-122.6765")

  # Test negative/zero coordinates
  iso_val_neg <- geo$convertLongitudeLatitudeToISO(-10.0, 20.0)
  expect_identical(iso_val_neg, "-10.0000%2B20.0000")
})

test_that("FindCountries functionality", {
  # This requires an internet connection to pass
  skip_if_offline()

  countries <- geo$FindCountries(limit = 1)
  expect_type(countries, "list")
  expect_named(countries, c("count", "data"))
})

test_that("Error Handling for Distance Between Places", {
  # Your code prints an error and returns NULL if params are missing
  # Use expect_output to catch the print() statement if desired
  expect_null(geo$Distance.Between.Places(fromId = NULL, toId = NULL))
})
