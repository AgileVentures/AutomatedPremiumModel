test_token <- Sys.getenv('PRODUCTION_SLACK_AUTH_TOKEN')

source("utilities.R")
library(slackr)


earliest_date = as.Date("2017-10-06")
latest_date = as.Date("2017-10-07")


channels <- slackr_channels(test_token)

channel_histories = lapply(channels$id, function(id){
  fetch_history_from_slack_channel_over_period(id, earliest_date, latest_date)
})

# results <- fetch_history_from_slack_channel_over_period("C0285CSUF", earliest_date, latest_date)



print(head(channel_histories))
