source("../utilities.R")
source("../test_token.R")


context("testing utilities")

test_that("utc_date_from_slack_channel_ts deals with period", {
  expect_equal(utc_date_from_slack_channel_ts("1499100740.171331"),utcdate(1499100740))
})

test_that("extract_earliest_channel_history_slack_ts", {
  ts = c("1499100740.171331","1499100740.171329", "1509100740.171331")
  df = data.frame(ts)
  df$ts <- as.character(df$ts)
  expect_equal(extract_earliest_channel_history_slack_ts(df),"1499100740.171329")
  ts = c("1499100740.171331","1499100740.171329", "1499100738.171325" )
  df = data.frame(ts)
  df$ts <- as.character(df$ts)
  expect_equal(extract_earliest_channel_history_slack_ts(df),"1499100738.171325")
})

test_that("compute_last_saturday_utc_date", {
  current_time <- anytime("2017-10-07 20:00:00 EDT")
  last_saturday <- as.Date("2017-10-07")
  expect_equal(compute_last_saturday_utc_date(current_time), last_saturday)
  current_time <- anytime("2017-10-07 12:29:37 EDT")
  last_saturday <- as.Date("2017-09-30")
  expect_equal(compute_last_saturday_utc_date(current_time), last_saturday)
})

without_internet({
  test_that("fetch_history_from_slack_channel calls right endpoint", {
    expect_GET(fetch_history_from_slack_channel("C0285CSUF"), paste("https://slack.com/api/channels.history?token=", test_token, "&channel=C0285CSUF&count=999", sep=""))
  })
  
  test_that("fetch_history_from_slack_channel calls right endpoint when there is a ts", {
    expect_GET(fetch_history_from_slack_channel("C0285CSUF", "123.12"), paste("https://slack.com/api/channels.history?token=", test_token, "&channel=C0285CSUF&count=999&latest=123.12", sep=""))
  })
})

with_mock_API({
  test_that("We can get history", {
    result <- fetch_history_from_slack_channel("C0285CSUF")
    expect_true(result$has_more)
    expect_equal(result$messages$user, c("U32", "U23", "U23", "U26"))
    expect_equal(result$messages$ts, c("1507611600.01","1507316797.000367",  "1507309519.000232", "1507309398.000374"))
  })
  
  test_that("we can get full history amid certain dates", {
    last_saturday <- as.Date("2017-10-07")
    three_sundays_ago <- as.Date("2017-10-07") - 20
    full_history <- fetch_history_from_slack_channel_over_period("C0285CSUF", three_sundays_ago, last_saturday)
    expect_equal(full_history$user, c("U23", "U23", "U26", "U24"))
  })
  
  test_that("we can respect has_more value", {
    last_saturday <- as.Date("2017-10-07")
    three_sundays_ago <- as.Date("2017-10-07") - 20
    full_history <- fetch_history_from_slack_channel_over_period("C300", three_sundays_ago, last_saturday)
    expect_equal(full_history$user, c("U24"))
  })
  
  test_that("message_project_channel_with_user_names calls right endpoint", {
    users <- data.frame(user=c("yada", "yolo"))$user
    #expect_GET(message_project_channel_with_user_names(users), "")
    message_project_channel_with_user_names(users)
  })
})

