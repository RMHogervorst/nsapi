context("basic functionality")

test_that("user and password are set", {
  expect_false(is.na(Sys.getenv("NSAPIACCOUNT", unset = NA)))
  expect_false(is.na(Sys.getenv("NSAPIPW", unset = NA)))
})

test_that("passwordchecker is telling us something",{
  expect_message(ns_api_check_keys(),regexp = "username is set")
})

test_that("utility functions are working",{
  expect_identical(null_to_na(NULL), NA)
  expect_match(message_part(TRUE), regexp = "is set")
  expect_match(message_part(FALSE), regexp = "is NOT set")
  #parse_time
  #parse_reismogelijkheden
  #find_reisdelen
  # datetime
})

test_that("api call object is created",{

})

context("travel_advise")

test_that("arguments of travel_advise are tested correctly", {
  expect_error(travel_advise(fromStation = "Amsterdam Centraal", toStation = "Rotterdam Centraal",departure = NA,yearCard = TRUE), regexp = "departure and yearCard can only be TRUE or FALSE")
  expect_error(travel_advise(fromStation = "Amsterdam Centraal", toStation = "Rotterdam Centraal",departure = TRUE,yearCard = 1), regexp = "departure and yearCard can only be TRUE or FALSE")
  expect_error(travel_advise(fromStation = "Amsterdam Centraal", toStation = "Rotterdam Centraal",departure = TRUE,yearCard = TRUE,previousAdvices = "alpha"),regexp = "need to be numeric")
  expect_error(travel_advise(fromStation = "Amsterdam Centraal", toStation = "Rotterdam Centraal",departure = TRUE,yearCard = TRUE,previousAdvices = c(1,2,3)),regexp = "need to be numeric")
  expect_error(travel_advise( toStation = "Rotterdam Centraal",departure = TRUE,yearCard = TRUE,previousAdvices =3))
  expect_error(travel_advise( toStation = "Rotterdam Centraal",departure = TRUE,yearCard = TRUE,previousAdvices =3))
})

test_that("travel_advise returns proper values",{
  advise_today <- travel_advise(fromStation = "Amsterdam Centraal", toStation = "Rotterdam Centraal",departure = TRUE,yearCard = TRUE,previousAdvices = 1, nextAdvices = 1)
  expect_true(is.data.frame(advise_today))
})


# all parsing files.
