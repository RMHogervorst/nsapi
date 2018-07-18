# basic functionality
# key management and authentification

#' Are the username and password set?
#'
#' A function to see if your username and password are set for nsapi.
#' Note that I have no clue if the password or username are correct,
#' that is up to you.
#' @export
ns_api_check_keys <- function(){
  pw <- !is.na(Sys.getenv("NSAPIPW", unset = NA))
  username <- !is.na(Sys.getenv("NSAPIACCOUNT",unset = NA))
  message(paste0("Your username",message_part(pw),
                 ",\nyour password", message_part(username),
                 ifelse(all(pw,username), "", "\nSee the vignette `Basic use of the nsapi package` section: 'Authentification'\n for more information on how to set these variables")))
}




# call api


nsapi_client <- crul::HttpClient$new(
  url = "webservices.ns.nl",
  auth = crul::auth(user = Sys.getenv("NSAPIACCOUNT",unset = NA),
              pwd = Sys.getenv("NSAPIPW", unset = NA),
              auth = "basic"),
  opts = list(timeout_ms = 800),
  headers = list(`User-Agent` = "ns_api_r_package")
)

#' Translate date and time into datetime stamp to use in api call
#'
#' @param date date in iso format (year-month-day): 2018-12-29 for example
#' @param time time in standard format (HH:MM): 20:21
#' @export
datetime <- function(date , time ){
  if(!is.character(date)) stop(paste(date, " is not a character value, \ndate needs to be YYYY-MM-DD format"))
  if(!is.character(time)) stop(paste(time, " is not a character value, \ntime needs to be in HH:MM format"))
  paste0(date,"T",time)
}

#' Get travel advise from one station to another station
#'
#' This is equivalent to the [NS reisplanner](https://www.ns.nl/reisplanner#/), you give
#' in a from and to station time, departure or arrival, and optionally if you have
#' a NS year card (has effect on some travels). You can also specify how many trips
#' before and after the chosen time you want to call.
#'
#' Some things to consider: station names need to be in Dutch and the NS webservice also
#' accepts shortened versions: "Utrecht Centraal" and "ut" is apparently the same.
#' Station names can be found with the `stationlist()` call.
#'
#' Although the documentation <https://www.ns.nl/en/travel-information/ns-api/documentation-travel-recommendations.html> is in
#' english, the returns are all in Dutch. And I keep the results in English.
#'
#' @param fromStation the station to start from, for instance "Rotterdam Centraal"
#' @param toStation the station to end, for instance "Utrecht Centraal"
#' @param dateTime defaults to current time, but you can use a different one: f.i. 2012-02-21T15:50, You can also use the `datetime()` function
#' @param departure is the datetime the start or end time? do you want to depart on that date or arrive, defaults to departure
#' @param yearCard if you have a NS year card (jaarabonnement) some trips will be different
#' @param hslAllowed use of the highspeed train
#' @param previousAdvices how many advices do you want before the time
#' @param nextAdvices how many advises do you want after
#' @export
travel_advise <- function(fromStation, toStation, dateTime = NULL,
                          departure= TRUE, yearCard = FALSE,
                          hslAllowed = FALSE,
                          previousAdvices = 4, nextAdvices = 4){
  if(any(base::missing(fromStation), base::missing(toStation), is.null(fromStation), is.null(toStation))) stop("You need to supply both fromStation and toStation")
  if(!all(is.logical(departure), is.logical(yearCard), !is.na(departure), !is.na(yearCard))) stop("departure and yearCard can only be TRUE or FALSE")
  if(!all(is.numeric(previousAdvices),is.numeric(nextAdvices), length(previousAdvices)==1, length(nextAdvices)==1)) stop("previousAdvises and nextAdvises need to be numeric and a single number, f.i. 8.")
  response <- nsapi_client$get(path = "/ns-api-treinplanner",
                                    query = list(
                                      fromStation=fromStation,
                                      toStation =toStation,
                                      departure = departure,
                                      dateTime = dateTime,
                                      yearCard= yearCard,
                                      hslAllowed = hslAllowed,
                                      previousAdvices=previousAdvices,
                                      nextAdvices=nextAdvices
                                    ))

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
#'
#' @export
stationlist <- function(){
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
#' @param station station names need to be in Dutch and the NS webservic also accepts short versions:f.i. Groningen or GN
#' @export
departures <- function(station){
  response <- nsapi_client$get(path = "/ns-api-avt", query = list(station=station))
  list_response <- deal_with_response(response)
  parse_vertrekkende_treinen(list_response)
}





#' Get disruptions and engineering work
#'
#'
#' - current disruptions  (=unscheduled disruptions + current engineering work)
#' - scheduled engineering work(=scheduled engineering work)
#' - current disruptions for a specific station (=unscheduled disruptions + current engineering work)
#' @param station  station names need to be in Dutch and the NS webservic also accepts short versions:f.i. Groningen or GN
#' @param actual TRUE or FALSE indicator of the current disruptions must be returned This includes both unscheduled disruptions at the moment of the request, as well as engineering work scheduled to take place within two hours of the request.
#' @param unplanned TRUE or FALSE indicator of the scheduled engineering work for the next two weeks must be returned.
#' @export
disruptions_and_maintenance <- function(station = NULL, actual = TRUE, unplanned= TRUE ){
  # reverse unplanned because the NS has made this weird.
  unplanned <- !unplanned
  response <- nsapi_client$get(path = "/ns-api-storingen",
                               query = list(
                                 station=station,
                                 actual = actual,
                                 unplanned = unplanned
                                 ) )
  list_response <- deal_with_response(response)
  parse_disruptions(list_response)
}


