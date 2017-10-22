library(anytime)
library(httr)
library(jsonlite)

fetch_history_from_slack_channel <- function(channel_id, before_this_ts = NULL){
  if(!is.null(before_this_ts)){
    endpoint = paste("https://slack.com/api/channels.history?token=", test_token,"&channel=", channel_id, "&count=999","&latest=", before_this_ts, sep="")
  }else{
    endpoint = paste("https://slack.com/api/channels.history?token=", test_token,"&channel=", channel_id, "&count=999", sep="")
  }
  response = GET(url=endpoint)
  if(status_code(response) == 429){
    #we are rate-limited
    print("we are rate limited")
    print(response$headers)
    Sys.sleep(as.numeric(response$headers$'retry-after') + 1)
    response = GET(url=endpoint)
  }
  results = jsonlite::fromJSON(content(response, "text"))
  
  if(!("ts" %in% colnames(results$messages))){
    results$messages = data.frame(ts=character(0), user=character(0))
  }
  if(!("user" %in% colnames(results$messages))){
    results$messages$user <- NA
  }
  
  results$messages = results$messages[c("user", "ts")]
  return(results)
}

utc_date_from_slack_channel_ts <- function(slack_channel_ts){
  intermediate <- regexpr("^[[:digit:]]+", c(slack_channel_ts), perl=TRUE)
  unix_ts = regmatches(c(slack_channel_ts), intermediate)[1]
  return (utcdate(as.numeric(unix_ts)))
}

extract_earliest_channel_history_slack_ts <- function(df){
  
  utc_time_from_slack_channel_ts <- function(slack_channel_ts){
    intermediate <- regexpr("^[[:digit:]]+", c(slack_channel_ts), perl=TRUE)
    unix_ts = regmatches(c(slack_channel_ts), intermediate)[1]
    return (utctime(as.numeric(unix_ts)))
  }
  
  extract_channel_dependent_ordering_from_slack_channel_ts <- function(slack_channel_ts){
    intermediate <- regexpr("(?<=\\.)([[:digit:]]+)", c(slack_channel_ts), perl=TRUE)
    channel_order <- regmatches(c(slack_channel_ts), intermediate)[1]
    return (as.numeric(channel_order))
  }
  unix_timestamps <- apply(df[c("ts")], 1,function(slack_ts){ utc_time_from_slack_channel_ts(slack_ts)})
  earliest_timestamp_indices <- which(unix_timestamps == min(unix_timestamps))
  if(length(earliest_timestamp_indices) == 1){
    return(df$ts[earliest_timestamp_indices[1]])
  }else{
    min_indice <- earliest_timestamp_indices[which.min(lapply(df$ts[earliest_timestamp_indices], extract_channel_dependent_ordering_from_slack_channel_ts))]
    return(df$ts[min_indice])
  }  
}

compute_last_saturday_utc_date <- function(now_timestamp){
  today = as.Date(now_timestamp)
  prev.days <- seq(today-7,today-1,by='day')
  prev.days[weekdays(prev.days)=='Saturday']
}

fetch_history_from_slack_channel_over_period <- function(channel_id, earliest_date, most_recent_date){
  
  drop_messages_from_before_earliest_date <- function(messages, earliest_date){
    return(subset(messages, !(lapply(ts,utc_date_from_slack_channel_ts) < earliest_date)))
  }
  
  drop_messages_from_after_most_recent_date <- function(messages, most_recent_date){
    return(subset(messages, !(lapply(ts,utc_date_from_slack_channel_ts) > most_recent_date)))
  }
  
  earliest_date_of_data <- earliest_date + 1
  earliest_ts_so_far <- NULL
  history <- NULL
  has_more <- TRUE
  while( (earliest_date_of_data > earliest_date) && has_more){
    result <- fetch_history_from_slack_channel(channel_id, earliest_ts_so_far)
    messages <- result$messages
    has_more <- result$has_more
    history <- rbind(history,messages)
    if(nrow(history) == 0){
      break
    }
    earliest_ts_so_far <- extract_earliest_channel_history_slack_ts(history)
    earliest_date_of_data <- utc_date_from_slack_channel_ts(earliest_ts_so_far)
    
  }
  return(drop_messages_from_after_most_recent_date(drop_messages_from_before_earliest_date(history, earliest_date), most_recent_date))
}

message_project_channel_with_user_names <- function(user_names){
  datamining <- channels[channels$name == "data-mining",]
  datamining_id <- datamining[1,]$id 
  text <- paste("<!here> this week's picks for premium signup are:", paste(user_names, sep="", collapse=" "))
  endpoint = paste("https://slack.com/api/chat.postMessage?token=", api_token , "&channel=", datamining_id,"&username=", "premium-automated-bot","&text=", sep="",URLencode(text))
  response = GET(url=endpoint)
  results = jsonlite::fromJSON(content(response, "text"))
}

message_admin_with_user_emails <- function(user_emails){
  user_id = users[users$name == "tansaku",][1]$id
  text <- paste("this week's picks' emails for premium signup are:", paste(user_emails, sep="", collapse=" "))
  endpoint = paste("https://slack.com/api/chat.postMessage?token=", api_token, "&channel=", user_id,"&username=", "premium-automated-bot","&text=", sep="",URLencode(text))
  response = GET(url=endpoint)
  results = jsonlite::fromJSON(content(response, "text"))
}
  