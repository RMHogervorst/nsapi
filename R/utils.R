# utils
null_to_na <- function(value) {
  ifelse(is.null(value), NA, value)
}

message_part <- function(thing) {
  ifelse(thing, " is set", " is NOT set")
}

# whatever the API documentation says, they return the time in
# timezone Europe/Amsterdam with a offset from UTC.
# That means we can ignore the offset and parse with timezone Europe/Amsterdam.
parse_time <- function(value) {
  as.POSIXct(value, format = "%Y-%m-%dT%H:%M:%S",tz="Europe/Amsterdam")
}



parse_reismogelijkheden <- function(reizen) {
  # pre allocate dataframe
  l_df <- length(reizen)
  holdingframe <- data.frame(
    Melding = I(as.list(rep(NA, l_df))), # this is insane
    AantalOverstappen = integer(l_df),
    GeplandeReisTijd = character(l_df),
    ActueleReisTijd = character(l_df),
    VertrekVertraging = character(l_df),
    AankomstVertraging = character(l_df),
    Optimaal = logical(l_df),
    GeplandeVertrekTijd = as.POSIXct(NA),
    ActueleVertrekTijd = as.POSIXct(NA),
    GeplandeAankomstTijd = as.POSIXct(NA),
    ActueleAankomstTijd = as.POSIXct(NA),
    Status = character(l_df),
    ReisDeel = I(as.list(rep(NA, l_df))),
    stringsAsFactors = FALSE
  )
  # fill the frame
  for (i in seq_len(l_df)) {
    holdingframe$Melding[[i]] <- null_to_na(reizen[[i]]$Melding[[1]])
    holdingframe$AantalOverstappen[[i]] <- as.integer(reizen[[i]]$AantalOverstappen[[1]])
    holdingframe$GeplandeReisTijd[[i]] <- reizen[[i]]$GeplandeReisTijd[[1]]
    holdingframe$ActueleReisTijd[[i]] <- reizen[[i]]$ActueleReisTijd[[1]]
    holdingframe$VertrekVertraging[[i]] <- null_to_na(reizen[[i]]$VertrekVertraging[[1]])
    holdingframe$AankomstVertraging[[i]] <- null_to_na(reizen[[i]]$AankomstVertraging[[1]])
    holdingframe$Optimaal[[i]] <- ifelse(reizen[[i]]$Optimaal[[1]] == "false", FALSE, TRUE)
    holdingframe$GeplandeVertrekTijd[[i]] <- parse_time(reizen[[i]]$GeplandeVertrekTijd[[1]])
    holdingframe$ActueleVertrekTijd[[i]] <- parse_time(reizen[[i]]$ActueleVertrekTijd[[1]])
    holdingframe$GeplandeAankomstTijd[[i]] <- parse_time(reizen[[i]]$GeplandeAankomstTijd[[1]])
    holdingframe$ActueleAankomstTijd[[i]] <- parse_time(reizen[[i]]$ActueleAankomstTijd[[1]])
    holdingframe$Status[[i]] <- reizen[[i]]$Status[[1]]
    holdingframe$ReisDeel[[i]] <- find_reisdelen(reizen[[i]])
  }
  # return the frame
  holdingframe
}



find_reisdelen <- function(reisdeel) {
  ids_reisdeel <- grep("ReisDeel", names(reisdeel))
  l_reisdelen <- length(ids_reisdeel)
  reisdelen <- data.frame(
    Vervoerder = character(l_reisdelen),
    VervoerType = character(l_reisdelen),
    RitNummer = character(l_reisdelen),
    Status = character(l_reisdelen),
    stringsAsFactors = FALSE
  )

  for (i in seq_along(ids_reisdeel)) { # stupid double loop
    index <- ids_reisdeel[[i]]
    # put the top element in
    reisdelen$Vervoerder[[i]] <- reisdeel[[index]]$Vervoerder[[1]]
    reisdelen$VervoerType[[i]] <- reisdeel[[index]]$VervoerType[[1]]
    reisdelen$RitNummer[[i]] <- reisdeel[[index]]$RitNummer[[1]]
    reisdelen$Status[[i]] <- reisdeel[[index]]$Status[[1]]
    # find the ritten
    ids_ritten <- grep("ReisStop", names(reisdeel[[index]]))
    l_ritten <- length(ids_ritten)
    # preallocate dataframe
    rittenframe <- data.frame(
      Naam = character(l_ritten),
      Tijd = as.POSIXlt(NA),
      Spoor = character(l_ritten),
      SpoorWijziging = character(l_ritten),
      stringsAsFactors = FALSE
    )

    for (index_ritten in seq_along(ids_ritten)) {
      j <- ids_ritten[[index_ritten]]
      rittenframe$Naam[[index_ritten]] <- reisdeel[[index]][[j]]$Naam[[1]]
      rittenframe$Tijd[[index_ritten]] <- parse_time(reisdeel[[index]][[j]]$Tijd[[1]])
      rittenframe$Spoor[[index_ritten]] <- null_to_na(reisdeel[[index]][[j]]$Spoor[[1]])
      rittenframe$SpoorWijziging[[index_ritten]] <- null_to_na(attr(reisdeel[[index]][[j]]$Spoor[[1]], "wijziging"))
    }
    reisdelen$Stops[[i]] <- rittenframe
  }
  reisdelen
}


parse_stations <- function(stationslijst) {
  l_stations <- length(stationslijst)
  stationframe <- data.frame(
    Code = character(l_stations),
    Type = character(l_stations),
    Namen = I(as.list(rep(NA, l_stations))),
    Land = character(l_stations),
    UICCode = character(l_stations),
    Lat = character(l_stations),
    Lon = character(l_stations),
    Synoniemen = I(as.list(rep(NA, l_stations))),
    stringsAsFactors = FALSE
  )
  for (i in seq_len(l_stations)) {
    stationframe$Code[[i]] <- stationslijst[[i]]$Code[[1]]
    stationframe$Type[[i]] <- stationslijst[[i]]$Type[[1]]
    stationframe$Namen[[i]] <- stationslijst[[i]]$Namen
    stationframe$Land[[i]] <- stationslijst[[i]]$Land[[1]]
    stationframe$UICCode[[i]] <- stationslijst[[i]]$UICCode[[1]]
    stationframe$Lat[[i]] <- stationslijst[[i]]$Lat[[1]]
    stationframe$Lon[[i]] <- stationslijst[[i]]$Lon[[1]]
    stationframe$Synoniemen[[i]] <- ifelse(unlist(stationslijst[[i]]$Synoniemen) == "\n\t\t\t\n\t\t", NA, stationslijst[[i]]$Synoniemen)
  }
  stationframe$Lat <- as.numeric(stationframe$Lat)
  stationframe$Lon <- as.numeric(stationframe$Lon)
  stationframe
}



parse_vertrekkende_treinen <- function(treinen) {
  l_treinen <- length(treinen)
  treinen_frame <- data.frame(
    RitNummer = character(l_treinen),
    VertrekTijd = as.POSIXct(NA),
    EindBestemming = character(l_treinen),
    TreinSoort = character(l_treinen),
    RouteTekst = character(l_treinen),
    Vervoerder = character(l_treinen),
    VertrekSpoor = character(l_treinen),
    Spoorwijziging = character(l_treinen),
    stringsAsFactors = FALSE
  )
  for (i in seq_len(l_treinen)) {
    treinen_frame$Ritnummer[[i]] <- treinen[[i]]$Ritnummer[[1]]
    treinen_frame$VertrekTijd[[i]] <- parse_time(treinen[[i]]$VertrekTijd[[1]])
    treinen_frame$EindBestemming[[i]] <- treinen[[i]]$EindBestemming[[1]]
    treinen_frame$TreinSoort[[i]] <- treinen[[i]]$TreinSoort[[1]]
    treinen_frame$RouteTekst[[i]] <- null_to_na(treinen[[i]]$RouteTekst[[1]])
    treinen_frame$VertrekSpoor[[i]] <- treinen[[i]]$VertrekSpoor[[1]]
    treinen_frame$SpoorWijziging[[i]] <- attr(treinen[[i]]$SpoorWijziging, "wijziging")
  }
  treinen_frame
}



deal_with_response <- function(response) {
  response$raise_for_status()
  list_response <- xml2::as_list(xml2::as_xml_document(response$parse("UTF-8")))[[1]]
  list_response
}



parse_disruptions <- function(disruptions) {
  l_gepl <- length(disruptions$Gepland)
  if (l_gepl == 1L) {
    if (any(disruptions$Gepland[[1]] == "\n\t\t\n\t")) l_gepl <- 0L
  }

  l_ongpl <- length(disruptions$Ongepland)
  if (l_ongpl == 1L) {
    if (any(disruptions$Ongepland[[1]] == "\n\t\t\n\t")) l_ongpl <- 0L
  }

  tot <- l_gepl + l_ongpl
  if(tot == 0){
    stop("The API returned empty results\nTry changing actual and unplanned")
  }

  holdingframe <- data.frame(
    id = character(tot),
    Traject = character(tot),
    Periode = character(tot),
    Reden = character(tot),
    Bericht = character(tot),
    Advies = character(tot),
    Datum = as.POSIXct(NA),
    stringsAsFactors = FALSE
  )
  for (i in seq_len(l_gepl)) {
    holdingframe$id[[i]] <- disruptions$Gepland[[i]]$id[[1]]
    holdingframe$Traject[[i]] <- disruptions$Gepland[[i]]$Traject[[1]]
    holdingframe$Periode[[i]] <- null_to_na(disruptions$Gepland[[i]]$Periode[[1]])
    holdingframe$Bericht[[i]] <- null_to_na(disruptions$Gepland[[i]]$Bericht[[1]])
    holdingframe$Advies[[i]] <- null_to_na(disruptions$Gepland[[i]]$Advies[[1]])
    holdingframe$Datum[[i]] <- parse_time(null_to_na(disruptions$Gepland[[i]]$Datum[[1]]))
  }

  for (j in seq_len(l_ongpl)) {
    index <- l_gepl + j
    holdingframe$id[[index]] <- disruptions$Ongepland[[j]]$id[[1]]
    holdingframe$Traject[[index]] <- disruptions$Ongepland[[j]]$Traject[[1]]
    holdingframe$Periode[[index]] <- null_to_na(disruptions$Ongepland[[j]]$Periode[[1]])
    holdingframe$Bericht[[index]] <- null_to_na(disruptions$Ongepland[[j]]$Bericht[[1]])
    holdingframe$Advies[[index]] <- null_to_na(disruptions$Ongepland[[j]]$Advies[[1]])
    holdingframe$Datum[[index]] <- parse_time(null_to_na(disruptions$Ongepland[[j]]$Datum[[1]]))
  }
  holdingframe
}
