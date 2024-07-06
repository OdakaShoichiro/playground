renv::restore()

install.packages(
  c(
    "car",
    "doParallel",
    "dplyr",
    "fGarch",
    "FinTS",
    "foreach",
    "forecast",
    "gam",
    "glmnet",
    "highfrequency",
    "httr",
    "igraph",
    "IRkernel",
    "jsonlite",
    "kernlab",
    "KFAS",
    "languageserver",
    "lars",
    "mlbench",
    "nortest",
    "optiSolve",
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
