#' NSapi package
#'
#' Access the NS api and download current departure times,
#' disruptions and engineering work, the station list, and
#' travel recommendations from station to station. All results will be
#' returned as a 'data.frame'.
#' NS (Nederlandse Spoorwegen; Dutch Railways) is the largest train travel
#' provider in the Netherlands. for more information about the API itself
#' see <https://www.ns.nl/en/travel-information/ns-api>.
#' To use the API, and this package, you will need to obtain a username
#' and password. More information about authentication and the use of the functions
#' are described in the vignette.
#'
#' Implemented functions:
#'
#' - Get travel advise between two stations \code{\link{get_travel_advise}}.
#' - Get departures from a particular station  \code{\link{get_departures}}.
#' - All the stations \code{\link{get_stationlist}}.
#' - Get all current disruptions \code{\link{get_current_disruptions}}.
#' - Get all scheduled engineering in next two weeks \code{\link{get_scheduled_engineering_work}}.
#' - Get all (un-)scheduled disruptions \code{\link{get_disruptions_station}}.
#' - Find out if you have configured the API keys correct \code{\link{check_ns_api_keys}}.
#' - A small helper function to create datetimestamp \code{\link{datetime}}.
#'
#'
#' Image use:
#' I have combined several images from the Noun project:
#'
#' - hands on circle: 		Data by Gregor Cresnar from the Noun Project:
#' - train: 				railway by BomSymbols from the Noun Project
#' - laptop				Laptop by abdul karim from the Noun Project
#'
#' @docType package
#' @name nsapi
NULL

