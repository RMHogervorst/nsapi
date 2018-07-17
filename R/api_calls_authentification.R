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
  opts = list(timeout_ms = 500),
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
#' Station names can be found with the stationfinder call.
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
  response$raise_for_status()
  list_response <- xml2::as_list(xml2::as_xml_document(response$parse("UTF-8") ))[[1]]
  parse_reismogelijkheden(list_response)
}

