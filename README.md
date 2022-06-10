[![R-CMD-check](https://github.com/KWB-R/kwb.gocr/workflows/R-CMD-check/badge.svg)](https://github.com/KWB-R/kwb.gocr/actions?query=workflow%3AR-CMD-check)
[![pkgdown](https://github.com/KWB-R/kwb.gocr/workflows/pkgdown/badge.svg)](https://github.com/KWB-R/kwb.gocr/actions?query=workflow%3Apkgdown)
[![codecov](https://codecov.io/github/KWB-R/kwb.gocr/branch/main/graphs/badge.svg)](https://codecov.io/github/KWB-R/kwb.gocr)
[![Project Status](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![CRAN_Status_Badge](https://www.r-pkg.org/badges/version/kwb.gocr)]()
[![R-Universe_Status_Badge](https://kwb-r.r-universe.dev/badges/kwb.gocr)](https://kwb-r.r-universe.dev/)

# kwb.gocr

Wrapper functions to [gocr](http://jocr.sourceforge.net/) functionality (Optical 
Character Recognition).

## Installation

For details on how to install KWB-R packages checkout our [installation tutorial](https://kwb-r.github.io/kwb.pkgbuild/articles/install.html).

```r
### Optionally: specify GitHub Personal Access Token (GITHUB_PAT)
### See here why this might be important for you:
### https://kwb-r.github.io/kwb.pkgbuild/articles/install.html#set-your-github_pat

# Sys.setenv(GITHUB_PAT = "mysecret_access_token")

# Install package "remotes" from CRAN
if (! require("remotes")) {
  install.packages("remotes", repos = "https://cloud.r-project.org")
}

# Install KWB package 'kwb.gocr' from GitHub
remotes::install_github("KWB-R/kwb.gocr")
```

## Documentation

Release: [https://kwb-r.github.io/kwb.gocr](https://kwb-r.github.io/kwb.gocr)

Development: [https://kwb-r.github.io/kwb.gocr/dev](https://kwb-r.github.io/kwb.gocr/dev)
