#!/usr/bin/Rscript

# renv::restore()

install.packages(
  c(
    "languageserver",
    "IRkernel",
    "car",
    "FinTS",
    "forecast",
    "nortest",
    "quantmod",
    "rpart",
    "tidyverse",
    "tseries",
    "urca"
  ),
  repos = "http://cran.rstudio.com/"
)

IRkernel::installspec(
  name = "ir",
  displayname = "R (renv)",
  rprofile = "/workspace/.Rprofile"
)

renv::snapshot()
