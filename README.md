
<!-- README.md is generated from README.Rmd. Please edit that file -->
nsapi
=====

[![CRAN\_latest\_release\_date](https://www.r-pkg.org/badges/last-release/nsapi)](https://cran.r-project.org/package=nsapi) [![license](https://img.shields.io/github/license/mashape/apistatus.svg)](https://choosealicense.com/licenses/mit/) [![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active) [![thanks-md](https://img.shields.io/badge/THANKS-md-ff69b4.svg)](THANKS.md) [![lifecycle](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle/#maturing) [![Travis-CI Build Status](https://travis-ci.org/RMHogervorst/nsapi.svg?branch=master)](https://travis-ci.org/RMHogervorst/nsapi)

The Dutch National Railway service (NS; Nederlandse Spoorwegen) has an API where we can query for travel advise, see the current trains on a given station, see if there is any delays or work on the tracks and NS also provides a list with geolocation of all the stations.

The goal of nsapi is to make it easy to gather data from the NS API. The package returns data frames for every response.

![an incredibly ugly logo for this package, we need a hexsticker!](man/figures/nsapilogo.png)

Installation
------------

You can NOT YET install the released version of nsapi from [CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("nsapi")
```

But you can install the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("RMHogervorst/nsapi")
```

Example
-------

This is a basic example which shows you how you get travel information:

``` r
library(nsapi)
```

``` r
treinplanner <- get_travel_advise(
  fromStation = "Leiden Centraal", 
  toStation = "Utrecht Centraal",
  departure = TRUE,
  yearCard = TRUE,
  previousAdvises = 1, 
  nextAdvises = 1)
treinplanner
#>   Melding AantalOverstappen GeplandeReisTijd ActueleReisTijd
#> 1      NA                 0             0:42            0:42
#> 2      NA                 1             0:56            0:56
#> 3      NA                 0             0:42            0:42
#> 4      NA                 1             0:56            0:56
#>   VertrekVertraging AankomstVertraging Optimaal GeplandeVertrekTijd
#> 1              <NA>               <NA>    FALSE 2018-07-31 14:22:00
#> 2              <NA>               <NA>    FALSE 2018-07-31 14:23:00
#> 3              <NA>               <NA>     TRUE 2018-07-31 14:52:00
#> 4              <NA>               <NA>    FALSE 2018-07-31 14:53:00
#>    ActueleVertrekTijd GeplandeAankomstTijd ActueleAankomstTijd
#> 1 2018-07-31 14:22:00  2018-07-31 15:04:00 2018-07-31 15:04:00
#> 2 2018-07-31 14:23:00  2018-07-31 15:19:00 2018-07-31 15:19:00
#> 3 2018-07-31 14:52:00  2018-07-31 15:34:00 2018-07-31 15:34:00
#> 4 2018-07-31 14:53:00  2018-07-31 15:49:00 2018-07-31 15:49:00
#>         Status     ReisDeel
#> 1 VOLGENS-PLAN NS, Inte....
#> 2 VOLGENS-PLAN c("NS", ....
#> 3 VOLGENS-PLAN NS, Inte....
#> 4 VOLGENS-PLAN c("NS", ....
```

FAQ
===

1.  What Can I do with the package?

-   You can access the departures from a station, disruptions (planned and unplanned), get travel advise (between stations) and a list of all stations (in the Netherlands and some outside.). In the [vignette](articles/basic_use_nsapi_package.html) I've described how to use the functions.

1.  I'm getting a curl timeout!

-   Yes... That happens, a lot. The NS website does not return errors but just times you out once in a while. Take a deep breath, retry.

1.  Error Bad request or HTTP 400

-   Your username and password might not be set properly

1.  How do I set a password and username?

-   See Authentication in the vignette

Metadata
--------

The package is MIT licensed although the information from NS is probably proprietary

``` r
codecoverage <- covr::package_coverage(path = ".",type = "tests")
print(codecoverage)
#> nsapi Coverage: 74.53%
#> R/utils.R: 70.00%
#> R/api_calls_authentification.R: 85.48%
```
