#!/usr/bin/Rscript

renv::restore()

install.packages(
  c(
    "car",
    "doParallel",
    "dplyr",
    "FinTS",
    "foreach",
    "forecast",
    "gam",
    "highfrequency",
    "httr",
    "igraph",
    "IRkernel",
    "jsonlite",
    "kernlab",
    "languageserver",
    "nortest",
    "plm",
    "quantmod",
    "randomForest",
    "Rcpp",
    "remotes",
    "reticulate",
    "rpart",
    "rstan",
    "rvest",
    "selectr",
    "sn",
    "tidytext",
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
