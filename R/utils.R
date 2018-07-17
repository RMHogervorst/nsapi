# utils
null_to_na <- function(value){
  ifelse(is.null(value), NA, value)
}

message_part <- function(thing){
  ifelse(thing, " is set", " is NOT set")
}

parse_time <- function(value){
  as.POSIXct(value, format = "%Y-%m-%dT%H:%M:%S%z")
}




parse_reismogelijkheden <- function(reizen){
  l_df <- length(reizen)
  holdingframe <- data.frame(
    Melding =  I(as.list(rep(NA, l_df))), # this is insane
    AantalOverstappen = integer(l_df),
    GeplandeReisTijd = character(l_df),
    ActueleReisTijd = character(l_df),
    VertrekVertraging = character(l_df),
    AankomstVertraging = character(l_df),
    Optimaal = logical(l_df),
    GeplandeVertrekTijd = as.POSIXct(NA),
    ActueleVertrekTijd =as.POSIXct(NA),
    GeplandeAankomstTijd = as.POSIXct(NA),
    ActueleAankomstTijd =as.POSIXct(NA),
    Status = character(l_df),
    ReisDeel = I(as.list(rep(NA, l_df))),
    stringsAsFactors = FALSE
  )
  for (i in seq_along(reizen)) {
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
    holdingframe$ReisDeel[[i]] <-find_reisdelen(reizen[[i]])
  }
  holdingframe
}



find_reisdelen <- function(reisdeel){
  ids_reisdeel <- grep("ReisDeel",names(reisdeel))
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
      rittenframe$Spoor[[index_ritten]] <- null_to_na( reisdeel[[index]][[j]]$Spoor[[1]])
      rittenframe$SpoorWijziging[[index_ritten]] <- null_to_na(attr(reisdeel[[index]][[j]]$Spoor[[1]], "wijziging"))
    }
    reisdelen$Stops[[i]] <- rittenframe
  }
  reisdelen
}






