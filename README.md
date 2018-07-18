
<!-- README.md is generated from README.Rmd. Please edit that file -->
nsapi
=====

The Dutch National Railway service (NS; Nederlandse Spoorwegen) has an API where we can query for travel advise, see the current trains on a given station, see if there is any delays or work on the tracks and NS also provides a list with geolocation of all the stations.

The goal of nsapi is to make it easy to gather data from the NS api. The package strives to return data.frames

![an incredibly ugly logo for this package, we need a logo man!](man/figures/nsapilogo.png)

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
#> 1      NA                 0             0:42            0:42
#> 2      NA                 1             0:56            0:56
#>   VertrekVertraging AankomstVertraging Optimaal GeplandeVertrekTijd
#> 1              <NA>               <NA>     TRUE 2018-07-18 15:22:00
#> 2              <NA>               <NA>    FALSE 2018-07-18 15:23:00
#>    ActueleVertrekTijd GeplandeAankomstTijd ActueleAankomstTijd
#> 1 2018-07-18 15:22:00  2018-07-18 16:04:00 2018-07-18 16:04:00
#> 2 2018-07-18 15:23:00  2018-07-18 16:19:00 2018-07-18 16:19:00
#>         Status     ReisDeel
#> 1 VOLGENS-PLAN NS, Inte....
#> 2 VOLGENS-PLAN c("NS", ....
```

Metadata
--------

The package is MIT licensed although the information from NS is probably propriatary.

``` r
codecoverage <- covr::package_coverage(path = ".",type = "tests")
print(codecoverage)
#> nsapi Coverage: 48.91%
#> R/utils.R: 48.28%
#> R/api_calls_authentification.R: 51.28%
```
