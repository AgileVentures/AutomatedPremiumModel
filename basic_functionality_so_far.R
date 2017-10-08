test_token <- "insert token here"

source("utilities.R")

earliest_date = as.Date("2017-06-01")
latest_date = as.Date("2017-10-07")

results <- fetch_history_from_slack_channel_over_period("C0285CSUF", earliest_date, latest_date)