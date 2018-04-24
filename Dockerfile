FROM rocker/r-ver:3.4.1
WORKDIR /app
ARG PRODUCTION_SLACK_AUTH_TOKEN
RUN if [ -z "$PRODUCTION_SLACK_AUTH_TOKEN" ]; then echo "PRODUCTION_SLACK_AUTH_TOKEN BUILD VARIABLE NOT SET"; exit 1; else : ; fi
ENV PRODUCTION_SLACK_AUTH_TOKEN ${PRODUCTION_SLACK_AUTH_TOKEN}
ARG PRODUCTION_SLACK_BOT_TOKEN
RUN if [ -z "$PRODUCTION_SLACK_BOT_TOKEN" ]; then echo "PRODUCTION_SLACK_BOT_TOKEN BUILD VARIABLE NOT SET"; exit 1; else : ; fi
ENV PRODUCTION_SLACK_BOT_TOKEN ${PRODUCTION_SLACK_BOT_TOKEN}
ARG WSO_TOKEN
RUN if [ -z "$WSO_TOKEN" ]; then echo "WSO_TOKEN BUILD VARIABLE NOT SET"; exit 1; else : ; fi
ENV WSO_TOKEN ${WSO_TOKEN}
ADD . .
RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install -y libssl-dev
RUN apt-get install -y zlib1g-dev
RUN apt-get install -y libcurl4-openssl-dev
RUN Rscript install.R
