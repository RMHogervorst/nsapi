This is a resubmission of the package (then version 0.1.0) with changes based on 
feedback by Prof Brian Ripley. Now on version (0.1.1).

Brian Ripley said:

- Your checks can only work in the Central Europe timezone, not
coincidentally where the CRAN incoming check services are located.

and he suggested I should convert to UTC and add or substract the numeric
offset to make the code more portable

I would like to thank Brian Ripley for this helpful comment. I have forced 
the timezone to "Europe/Amsterdam". I've also forced the tests to use that timezone.

I have not converted to UTC, because of the following reasons:

- the timestamp send from the API is in "Europe/Amsterdam" timezone with an UTC
correction appended as extra information. We know the timezone, the timezone
will not change and I believe that the posixct representation will allow users
to convert to the timezone of their choice. Since the app is used for Dutch 
Train times, I think it makes more sense to use the Dutch time.



# Test environment
* Tested on personal computer ubuntu 16.04 | R 3.5.1
* Tested on windows: r-hub  Windows_NT | R 3.5.1
* Tested on macOS R x86_64-apple-darwin15.6.0 (64-bit)  | 3.5.1
* Tested on linux Ubuntu 14.04.5 LTS (with travis.ci)  | R 3.4.4 & R3.5.0 & R Under development (unstable) (2018-06-20 r74923)



## R CMD check results

0 errors | 0 warnings | 0 notes

There were no ERRORs, WARNINGs or NOTEs


## Downstream dependencies
There are currently no downstream dependencies for this package
