# Automated Premium Model

This is an in-progress prototype for automating the running of the current ML
prediction for premium signup

## Installation

You will need to install the packages `httr`, `httptest`, `anytime` and `jsonlite`

```r
$ install.packages("httr")

$ install.packages("httptest")

$ install.packages("jsonlite")

$ install.packages("anytime")
```

## Running Tests

```sh
$ RScript run_tests.R
```

You should get something like this output:

```sh
Loading required package: testthat Loading required package: methods testing
utilities: ............

DONE ===========================================================================
```

You can run the code in `basic_functionality_so_far.R` in something like Rstudio
and examine the results in the variable `results` to see what can be gleaned so
far from the history of the `#general` channel. However, you will need to insert a
valid token into `test_token`, i.e. modify this line:

```r
test_token <-Sys.getenv('PRODUCTION_SLACK_AUTH_TOKEN')
```

where you replace `Sys.getenv` with a real valid token that will work on our slack
`#general` channel, OR you arrange for a valid token to exist in the
environment variable `PRODUCTION_SLACK_AUTH_TOKEN` via some mechanism such as
`.bashrc`.

## Completed

 - [x] Code that can fetch a channel's history between dates
 - [x] Make code to Fetch a list of all relevant channels to mine for history
 - [x] Make code to Fetch all relevant channels' history and build a running dataframe of such
history
 - [x] Make code to calculate the relevant features from the dataframe
of history, ie, a user's aggregate "posts" during week 1, week 2, and week 3,
and build a dataframe of it
 - [x] Make code to fetch a list of all users
 - [x] Make code to cross link the list of all users data, ie emai land username, with
the dataframe of relevant features from history (week1, week2, week3)
 - [x] Run feature dataframe through ML model, ie adaboost, etc and get results

## To Do

- [ ] Make code automatically calculate time period to select from (ie, figure out
    which saturday to begin from and go backwards 3 weeks based on current date)

- [ ] Make code to send message to @tansaku on slack about week's results (ie,
    using slackr), and some results to \#data-mining (ie, with no emails)

- [ ] Test the code that fetches a channel's history for robustness to errors like
    rate limiting, internet weather, etc (right now a spike is in place that
    seems to do parts of this)

## Azure Installation
Now, the purpose of this code is to be deployed to a server to enable automatic
running on a schedule (e.g. every Sunday).  [Reference](https://www.digitalocean.com/community/tutorials/how-to-install-r-on-ubuntu-16-04-2)

1. Create an ubuntu VM box in azure based off ubuntu 16.04 lts 
2. Open an ssh session for a user who has 'root' access in your VM:

    ```sh
    $ ssh michael@automatedpremium-production
    ```

3. In your ssh session:

    ```sh
    $ sudo add-apt-repository 'deb [arch=amd64,i386] https://cran.rstudio.com/bin/linux/ubuntu xenial/'

    $ sudo apt-get update

    $ sudo apt-get install r-base

    $ Rscript --version
    ```

    You should see output similar to this:

    ```sh
      R scripting front-end version 3.4.2 (2017-09-28)
    ```

    Now you are ready to install the app.

    ```sh
    $ sudo apt-get install git

    $ git clone https://github.com/AgileVentures/AutomatedPremiumModel

    $ sudo chown michael:michael /usr/local/lib/R/site-library   # so that you have rights to install

    $ cd AutomatedPremiumModel

    $ sudo apt-get install libcurl4-openssl-dev

    $ sudo apt-get install libssl-dev

    $ Rscript install.R

    $ Rscript run_tests.R 
    ```
    
    You might see a failure or so, but as of now that is okay, as long as the apparatus seemed to fail while still loading libraries.

4.  Open a new terminal tab and copy the csv files to the directory on the remote VM as follows:

    ```sh
    $ scp av_members.csv michael@automatedpremium-production:/home/michael/AutomatedPremiumModel

    $ scp data.csv michael@automatedpremium-production:/home/michael/AutomatedPremiumModel
    ```

5. To run the very basic code so far, return to your ssh session and execute the following command:

   ```sh
   $ PRODUCTION_SLACK_AUTH_TOKEN='put your api token' Rscript basic_functionality_so_far.R
   ```
   
   You'll probably see messages about timeouts and waiting but when the model finishes it should be something like this:

    [1] "the top 10 free members that might signup are: "
    [1] "roschaefer" "joaopereira" "sdas4" 
    [4] "domenicoangilletta" "ahalle" "hasnutech"
    [7] "pcaston" "msheinb1" "nirmalkumarb94"

## Adding Another User to the VM

To grant VM access to another user:

1. `ssh michael@automatedpremium-production`

2. `sudo adduser sam` to add a sam as a user and fill out form with password. Dispatch password to sam forthwith, using any means at your disposal, however crypographically insecure.

3. Edit the config file as follows: `sudo vi /etc/ssh/sshd_config`
    At the end of the file add

   ```
      PermitRootLogin yes
      AllowUsers michael sam
   ```

     Note that we added both michael and sam here.

4. Create .ssh directory for sam user: `mkdir /home/sam/.ssh`
5. Edit the authorized keys file `sudo vi /home/sam/.ssh/authorized_keys` and add sam's public key (making sure ssh is at the start)
6. Give sam back ownership of his folder and file

   ```sh
     $ sudo chown sam:sam /home/sam/.ssh/authorized_keys

     $ sudo chown sam:sam /home/sam/.ssh
   ```

7. Add sam to the sudoer group: `sudo usermod -aG sudo sam`
8. Run the service to make ssh changes be taken up: `sudo service ssh reload` 


    Now sam should be able to ssh in with a proper configuration on his side.
