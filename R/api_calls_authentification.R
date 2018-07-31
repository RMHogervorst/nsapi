# basic functionality
# key management and authentication

#' Are the username and password set?
#'
#' A function to see if your username and password are set for nsapi.
#' Note that I have no clue if the password or username are correct,
#' that is up to you.
#'
#' For more details see the help vignette:
#' \code{vignette("basic_use_nsapi_package", package = "nsapi")}
#' and get your keys here:
#' \url{https://www.ns.nl/ews-aanvraagformulier/?0}
#'
#' @export
check_ns_api_keys <- function() {
  pw <- !is.na(Sys.getenv("NSAPIPW", unset = NA))
  username <- !is.na(Sys.getenv("NSAPIACCOUNT", unset = NA))
  message(paste0(
    "Your username", message_part(pw),
    ",\nyour password", message_part(username),
    ifelse(all(pw, username), "",
           "\nSee the vignette `Basic use of the nsapi package` section: 'Authentication'\n for more information on how to set these variables")
  ))
}



# call api


nsapi_client <- function(){
  crul::HttpClient$new(
  url = "webservices.ns.nl",
  auth = crul::auth(
    user = Sys.getenv("NSAPIACCOUNT", unset = NA),
    pwd = Sys.getenv("NSAPIPW", unset = NA),
    auth = "basic"
  ),
  opts = list(timeout_ms = 3000),
  headers = list(`User-Agent` = "ns_api_r_package")
)
}

#' Translate date and time into datetime stamp to use in api call
#'
#' The datetime stamp format might be a bit difficult to use. This
#' helper function allows you to supply the date and time and a datetime
#' character string comes out.
#'
#'
#' @param date date in iso format (year-month-day): 2018-12-29 for example
#' @param time time in standard format (HH:MM): 20:21
#' @export
#' @examples
#' \dontrun{
#' get_travel_advise(
#'     fromStation = "Amsterdam Centraal",
#'     toStation = "Utrecht Centraal",
#'     dateTime = datetime("2018-08-21","15:21"),
#'     departure = TRUE
#'     )
#' }
datetime <- function(date, time) {
  if (!is.character(date)) stop(paste(date, " is not a character value, \ndate needs to be YYYY-MM-DD format"))
  if (!is.character(time)) stop(paste(time, " is not a character value, \ntime needs to be in HH:MM format"))
  paste0(date, "T", time)
}

#' Get travel advise from one station to another station
#'
#' This is equivalent to the [NS reisplanner](https://www.ns.nl/reisplanner#/),
#' you give in a from and to station, the timestamp, if you want the time
#' to be your departure or arrival time, and optionally if you have a NS year
#' card (has effect on some travels).
#'
#' You can also specify how many trips before and after the chosen time you
#' want to collect (defaults to 4, maximum is 5 before, and 5 after).
#'
#' Some things to consider: station names need to be in Dutch but the NS
#' webservice also accepts shortened versions: "Utrecht Centraal" and
#' "ut" is apparently the same.
#' Station names can be found with the `get_stationlist()` call.
#'
#' Although the documentation
#' <https://www.ns.nl/en/travel-information/ns-api/documentation-travel-recommendations.html>
#' is in English, the returned values are all in Dutch. And I keep the results
#' in Dutch.
#'
#'
#' @param fromStation the station to start from, for instance "Rotterdam Centraal"
#' @param toStation the station to end, for instance "Utrecht Centraal"
#' @param dateTime defaults to current time, but you can use a different one: f.i. 2012-02-21T15:50, You can also use the `datetime()` function
#' @param departure is the datetime the start or end time? do you want to depart on that date or arrive, defaults to departure
#' @param yearCard if you have a NS year card (jaarabonnement) some trips will be different
#' @param hslAllowed use of the high speed train
#' @param previousAdvises how many advices do you want before the time
#' @param nextAdvises how many advises do you want after
#' @export
#' @examples
#' \dontrun{
#' get_travel_advise("Amsterdam Centraal",
#' "Utrecht Centraal",dateTime = "2018-08-01T15:21",departure = TRUE)
#' }
get_travel_advise <- function(fromStation, toStation, dateTime = NULL,
                          departure = TRUE, yearCard = FALSE,
                          hslAllowed = FALSE,
                          previousAdvises = 4, nextAdvises = 4) {
  if (any(base::missing(fromStation), base::missing(toStation), is.null(fromStation), is.null(toStation))) stop("You need to supply both fromStation and toStation")
  if (!all(is.logical(departure), is.logical(yearCard), !is.na(departure), !is.na(yearCard))) stop("departure and yearCard can only be TRUE or FALSE")
  if (!all(is.numeric(previousAdvises), is.numeric(nextAdvises), length(previousAdvises) == 1, length(nextAdvises) == 1)) stop("previousAdvises and nextAdvises need to be numeric and a single number, f.i. 8.")

  nsapi_client <- nsapi_client()
  response <- nsapi_client$get(
    path = "/ns-api-treinplanner",
    query = list(
      fromStation = fromStation,
      toStation = toStation,
      departure = departure,
      dateTime = dateTime,
      yearCard = yearCard,
      hslAllowed = hslAllowed,
      previousAdvices = previousAdvises,
      nextAdvices = nextAdvises
    )
  )

  list_response <- deal_with_response(response)
  parse_reismogelijkheden(list_response)
}

#' Get a complete list of all the stations
#'
#' This function should not be called too often.
#' The stations will probably not change a lot so it might
#' be better to save it as a dataframe in your local environment for further use.
#'
#' The dataframe consists of all the Dutch stations, many German and Belgian stations and
#' bigger stations in other countries in Europe.
#' \url{https://www.ns.nl/en/travel-information/ns-api/documentation-station-list.html}
#' @export
get_stationlist <- function() {
  nsapi_client <- nsapi_client()
  response <- nsapi_client$get(path = "/ns-api-stations-v2")
  list_response <- deal_with_response(response)
  parse_stations(list_response)
}

#' Get up to date departures from a station
#'
#' Shows up to date departure times for a station. Displays all departing
#' trains for the next hour.
#' At least 10 departure times will be sent back and at least all the
#' departure times for the next hour.
#' \url{https://www.ns.nl/en/travel-information/ns-api/documentation-up-to-date-departure-times.html}.
#' @param station station names need to be in Dutch and the NS webservice also accepts short versions:f.i. Groningen or GN
#' @return a dataframe
#' @export
#' @examples
#' \dontrun{
#' get_departures("UT")
#' }
get_departures <- function(station) {
  nsapi_client <- nsapi_client()
  response <- nsapi_client$get(path = "/ns-api-avt", query = list(station = station))
  list_response <- deal_with_response(response)
  parse_vertrekkende_treinen(list_response)
}







disruptions_and_maintenance <- function(station = NULL, actual = NULL, unplanned = NULL) {
  nsapi_client <- nsapi_client()
  response <- nsapi_client$get(
    path = "/ns-api-storingen",
    query = list(
      station = station,
      actual = actual,
      unplanned = unplanned
    )
  )
  list_response <- deal_with_response(response)
  parse_disruptions(list_response)
}


#' Get disruptions and engineering work
#'
#' These 3 functions call out to find out about disruptions and engineering on
#' the tracks for the current time, for the next 2 weeks or a specific station.
#'
#' @details
#' - current disruptions  (=unscheduled disruptions + current engineering work)
#'
#' These are all the disruptions of the railroad at this moment. So both
#' unscheduled work and work
#' and work that was scheduled and currently underway.
#' Use `get_current_disruptions()`
#'
#' - scheduled engineering work(=scheduled engineering work)
#'
#' Get all the scheduled engineering work for the next 2 weeks
#' with `get_scheduled_engineering_work()`. This will exclude
#' work that was unplanned.
#'
#' - current disruptions for a specific station (=unscheduled disruptions + current engineering work)
#'
#' Use `get_disruptions_station()` and give a station name as argument.
#'
#' \url{https://www.ns.nl/en/travel-information/ns-api/documentation-disruptions-and-maintenance-work.html}
#' @param station  optional, station names need to be in Dutch and the NS webservice also accepts short versions:f.i. Groningen or GN
#' @return a dataframe
#' @export
get_disruptions_station <- function(station){
  disruptions_and_maintenance(station= station)
}

#' @describeIn get_disruptions_station current disruptions
#' @export
get_current_disruptions <- function(){
  disruptions_and_maintenance(station = NULL, actual = TRUE,unplanned = NULL)
}

#' @describeIn get_disruptions_station scheduled disruptions
#' @export
get_scheduled_engineering_work <- function(){
  disruptions_and_maintenance(station = NULL,actual = FALSE, unplanned = TRUE)
}
