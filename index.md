[![R-CMD-check](https://github.com/KWB-R/kwb.gocr/workflows/R-CMD-check/badge.svg)](https://github.com/KWB-R/kwb.gocr/actions?query=workflow%3AR-CMD-check)
[![pkgdown](https://github.com/KWB-R/kwb.gocr/workflows/pkgdown/badge.svg)](https://github.com/KWB-R/kwb.gocr/actions?query=workflow%3Apkgdown)
[![codecov](https://codecov.io/github/KWB-R/kwb.gocr/branch/main/graphs/badge.svg)](https://codecov.io/github/KWB-R/kwb.gocr)
[![Project Status](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![CRAN_Status_Badge](https://www.r-pkg.org/badges/version/kwb.gocr)]()
[![R-Universe_Status_Badge](https://kwb-r.r-universe.dev/badges/kwb.gocr)](https://kwb-r.r-universe.dev/)

Wrapper functions to [gocr](http://jocr.sourceforge.net/) functionality (Optical 
Character Recognition).

## Installation

For installing the latest release of this R package run the following code below:

```r
# Enable repository from kwb-r
options(repos = c(
  kwbr = 'https://kwb-r.r-universe.dev',
  CRAN = 'https://cloud.r-project.org'))

# Download and install kwb.gocr in R
install.packages('kwb.gocr')

# Browse the kwb.gocr manual pages
help(package = 'kwb.gocr')

```