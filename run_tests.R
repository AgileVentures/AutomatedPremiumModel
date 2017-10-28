options(warn=-1)
library(httptest)
library(devtools)
devtools::install('automatedpremium')

test_dir("automatedpremium/tests")
options(warn=0)
