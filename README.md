
<!-- README.md is generated from README.Rmd. Please edit that file -->
nsapi
=====

The Dutch National Railway service (NS; Nederlandse Spoorwegen) has an API where we can query for travel advise, see the current trains on a given station, see if there is any delays or work on the tracks and NS also provides a list with geolocation of all the stations.

The goal of nsapi is to make it easy to gather data from the NS api. The package strives to return data.frames

Installation
------------

You can NOT YET install the released version of nsapi from [CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("nsapi")
```

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("RMHogervorst/nsapi")
```

Example
-------

This is a basic example which shows you how you get travelinformation:

``` r
library(nsapi)
```

``` r
treinplanner <- travel_advise(
  fromStation = "Leiden Centraal", 
  toStation = "Utrecht Centraal",
  departure = TRUE,
  yearCard = TRUE,
  previousAdvices = 1, 
  nextAdvices = 1)
treinplanner
#>   Melding AantalOverstappen GeplandeReisTijd ActueleReisTijd
#> 1      NA                 1             1:00            1:00
#> 2      NA                 0             0:42            0:42
#> 3      NA                 1             0:56            0:56
#>   VertrekVertraging AankomstVertraging Optimaal GeplandeVertrekTijd
#> 1              <NA>               <NA>    FALSE 2018-07-17 18:30:00
#> 2              <NA>               <NA>     TRUE 2018-07-17 18:52:00
#> 3              <NA>               <NA>    FALSE 2018-07-17 18:53:00
#>    ActueleVertrekTijd GeplandeAankomstTijd ActueleAankomstTijd
#> 1 2018-07-17 18:30:00  2018-07-17 19:30:00 2018-07-17 19:30:00
#> 2 2018-07-17 18:52:00  2018-07-17 19:34:00 2018-07-17 19:34:00
#> 3 2018-07-17 18:53:00  2018-07-17 19:49:00 2018-07-17 19:49:00
#>         Status     ReisDeel
#> 1    VERTRAAGD c("NS", ....
#> 2 VOLGENS-PLAN NS, Inte....
#> 3 VOLGENS-PLAN c("NS", ....
```

Metadata
--------

The package is MIT licensed although the information from NS is probably propriatary.

``` r
codecoverage <- covr::package_coverage(path = ".",type = "tests")
print(codecoverage)
```
