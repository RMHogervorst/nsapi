notes

# general design

- maybe dutch and english functions (alias or calling english function, translating arguments)
- description of api and how to use it
- all functions should return tibbles
- maybe should work with tidy eval
- maybe shiny example of travel advise?
- maybe cache stations (keep list of valid stations?)
- vignette that shows all functions
-- why do i use it? ( I like to know when next train goes)




# documentatie api van ns

* reisadviezen van station naar station

- fromStation
- toStation
- viaStation
- previousAdvices
- nextAdvices
- dateTime ISO8601 2012-02-21T15:50
- Departure true/ false
- hslAllowed
- yearCArd

returns some sort of xml nested
Turn it into a dataframe with a row per travel advise

Following possible returns: 

    Melding (0..n)  LIST COLUMN
    AantalOverstappen (1) 
    GeplandeReisTijd (1)
    ActueleReisTijd (0..1)
    VertrekVertraging (0..1)
    AankomstVertraging (0..1)
    Optimaal (1)
    GeplandeVertrekTijd (1)
    ActueleVertrekTijd (1)
    GeplandeAankomstTijd (1)
    ActueleAankomstTijd (1)
    Status (0..1): De status van deze ReisMogelijkheid . Mogelijke waarden: VOLGENS-PLAN, GEWIJZIGD, VERTRAAGD, NIEUW, NIET-OPTIMAAL, NIET-MOGELIJK, PLAN-GEWIJZIGD.
    ReisDeel (1..n): Deel van de ReisMogelijkheid die zonder overstap wordt gemaakt.  TIBBLE IN TIBBLE?
    
    reisdeel tibble:
    vervoerder, vervoertype, ritnummer, status, reisdetails, geplandestoringId, ongplande storingid, reisStop (list)



* Prijzen (not implemented, you need a new different autorissation)

* Actuele vertrektijden

- station
Er zullen minimaal 10 vertrektijden worden geretourneerd en minimaal de vertrektijden voor het komende uur

https://webservices.ns.nl/ns-api-avt?station=ut


* Storingen en werkzaamheden

- station
- actual true false
- unplanned (true/false)
http://webservices.ns.nl/ns-api-storingen?station=${Stationsnaam}&actual=${true or false}&unplanned=${true or false}

* De stationslijst met alle stations in Nederland inclusief Geodata
no parameters, only love, i mean response

- code
- type
- namen
- land
UICCode (1): UIC-code van het station, identificerende code volgens de standaard van de Internationale Spoorwegunie, de UIC: Union Internationale des Chemins de fer.
Lat (1): Breedtegraad (latitude) van het station.
Lon (1): Lengtegraad (longitude) van het station.
Synoniemen (1): Synoniemen van het station.

http://webservices.ns.nl/ns-api-stations-v2
