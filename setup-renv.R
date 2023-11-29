#!/usr/bin/Rscript

renv::restore()

install.packages(
  c(
    "languageserver",
    "igraph",
    "IRkernel",
    "car",
    "FinTS",
    "forecast",
    "httr",
    "jsonlite",
    "nortest",
    "quantmod",
    "rpart",
    "rvest",
    "selectr",
    "tidyverse",
    "tseries",
    "urca",
    "wordcloud2"
  ),
  repos = "http://cran.rstudio.com/"
)

install.packages(
  c(
    "RMeCab"
  ),
  repos = "http://rmecab.jp/R",
  type = "source"
)

IRkernel::installspec(
  name = "ir",
  displayname = "R (renv)",
  rprofile = "/workspace/.Rprofile"
)

renv::snapshot()
