library(httr)

today <- as.Date(Sys.time())

endpoint = "https://www.agileventures.org/api/subscriptions.json"
token <- Sys.getenv('WSO_TOKEN')
auth_value <- paste("Token token=\"", token,"\"",sep="")
resp <- GET(endpoint,add_headers(authorization = auth_value))
premium_users = jsonlite::fromJSON(content(resp, "text"))

slack_token <- Sys.getenv('PRODUCTION_SLACK_AUTH_TOKEN')

library(slackr)

users <- slackr_users(slack_token)

all <- merge(premium_users, users, by="email", all.x = TRUE)
no_matching_email_in_slack <- all[is.na(all$id),]
active_premium_users_whose_email_in_wso_does_not_match_in_slack <- subset(no_matching_email_in_slack, (ended_on > today | is.na(ended_on)) & plan_name != "Associate")
email_aliases <- read.csv("email_aliases.csv", stringsAsFactors=FALSE)
email_aliases_for_those_whose_email_differs <- email_aliases[email_aliases$email==active_premium_users_whose_email_in_wso_does_not_match_in_slack$email,]

premium_users[premium_users$email == email_aliases_for_those_whose_email_differs$email,]$email = email_aliases_for_those_whose_email_differs$alias_email


premium_users_in_slack <- merge(premium_users,users, by="email")
premium_users_in_slack$ended_on <- as.Date(premium_users_in_slack$ended_on)

active_premium_users_in_slack <- subset(premium_users_in_slack, (ended_on > today | is.na(ended_on)) & plan_name != "Associate")
active_premium_users_slack_names <- unique(active_premium_users_in_slack$name)
active_premium_users_slack_names <- c(active_premium_users_slack_names, "tansaku")



slack_names <- data.frame(Slack=active_premium_users_slack_names)
write.csv(slack_names, file="av_members.csv")