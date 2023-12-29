#!/usr/bin/Rscript

renv::restore()

install.packages(
  c(
    "car",
    "doParallel",
    "FinTS",
    "foreach",
    "forecast",
    "httr",
    "igraph",
    "IRkernel",
    "jsonlite",
    "kernlab",
    "languageserver",
    "nortest",
    "quantmod",
    "randomForest",
    "Rcpp",
    "reticulate",
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
