FROM rocker/r-ver:3.4.1
WORKDIR /app
ADD . .
RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install -y libssl-dev
RUN apt-get install -y zlib1g-dev
RUN apt-get install -y libcurl4-openssl-dev
RUN Rscript install.R
