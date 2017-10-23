options(warn=-1)
library(httptest)
library(devtools)
Sys.setenv(PRODUCTION_SLACK_AUTH_TOKEN="xyz-s")
Sys.setenv(PRODUCTION_SLACK_BOT_TOKEN="abc-d")
devtools::install('automatedpremium')

test_dir("automatedpremium/tests")
options(warn=0)
