test_token <- Sys.getenv('PRODUCTION_SLACK_AUTH_TOKEN')
api_token <- Sys.getenv('PRODUCTION_SLACK_BOT_TOKEN')

library(anytime)
library(httr)
library(jsonlite)
library(automatedpremium)
library(slackr)

latest_date = compute_last_saturday_utc_date(Sys.time())
earliest_date = latest_date - 20

channels <- slackr_channels(test_token)
channels <- subset(channels,!is_archived) #archived channels seem to be problematic?
channels <- subset(channels, name != "z-harrow-gb-40")

channel_histories = lapply(channels$id, function(id){
  fetch_history_from_slack_channel_over_period(id, earliest_date, latest_date, test_token)
})

total_history <- Reduce(rbind, channel_histories) #combine all posts into one giant frame
total_history <- subset(total_history, !is.na(user)) #scrub out apps and such

total_history$utcdate <- utcdate(unlist(lapply(total_history$ts, function(ts){ utc_date_from_slack_channel_ts(ts)})))

# results <- fetch_history_from_slack_channel_over_period("C0285CSUF", earliest_date, latest_date)

first_week_end <- latest_date
first_week_start <- latest_date - 6

second_week_end <- latest_date -  7
second_week_start <- latest_date - 13

third_week_end <- latest_date - 14
third_week_start <- latest_date - 20

total_history$week1 <- unlist(lapply(total_history$utcdate, function(date){
  (first_week_start <= date) && (first_week_end >= date)
}))

total_history$week2 <- unlist(lapply(total_history$utcdate, function(date){
  (second_week_start <= date) && (second_week_end >= date)
}))

total_history$week3 <- unlist(lapply(total_history$utcdate, function(date){
  (third_week_start <= date) && (third_week_end >= date)
}))

df1 <- aggregate(week1 ~ user, total_history, sum)
df2 <- aggregate(week2 ~ user, total_history, sum)
df3 <- aggregate(week3 ~ user, total_history, sum)

posts <- cbind(df3, cbind(df1,df2))[c("user", "week1", "week2", "week3")]

names(posts)[names(posts) == 'user'] <- 'id'

users <- slackr_users(test_token)

final <- merge(users, posts)

names(final)[names(final) == 'name'] <- 'user'

to_be_predicted <- final[c("week1", "week2", "week3", "user", "email")]


#here is code from elsewhere-- the model


data = read.csv("data/data.csv")
nonzerodata = subset(data, week1 > 0 | week2 > 0 | week3 > 0)
library(caTools)
library(DMwR)
set.seed(2000)
spl = sample.split(nonzerodata$premium,SplitRatio = .75)
train = nonzerodata[spl,]
test = nonzerodata[!spl,]

train$premium <- factor(ifelse(train$premium == 1,"rare","common"))
test$premium <- factor(ifelse(test$premium == 1, "rare", "common"))

train <- SMOTE(premium ~ ., train, perc.over = 300,perc.under=500)
table(train$premium)

train$premium <- ifelse(train$premium == "rare", 1,0)
test$premium <- ifelse(test$premium == "rare", 1,0)


library(ROCR)
library(gbm)

ab = gbm(premium ~ week1 + week2 + week3, distribution="adaboost", data=train)

probTest = predict(ab,test, n.trees=100,type="response")
predTest <- prediction(probTest, test$premium)
perfTest <- performance(predTest, "auc")
perfTest@y.values[[1]] # 0.7092623

premiums <- read.csv("data/av_members.csv")

to_be_predicted <- subset(to_be_predicted, !(user %in% premiums$Slack))

print("the top 10 free members that might signup are: ")

to_be_predicted$probs <- predict(ab, type="response", n.trees=100,newdata=to_be_predicted)
to_be_predicted <- to_be_predicted[order(-to_be_predicted$probs),]

predicted <- to_be_predicted[0:10,]
print(predicted$user)
print(predicted$email)

#relay the results to the slack channel

message_project_channel_with_user_names(predicted$user, channels, api_token)

message_admin_with_user_emails(predicted$email, users, api_token)
