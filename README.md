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

## Dokku deployment on Azure
Now, the purpose of this code is to be deployed to a server to enable automatic
running on a schedule (e.g. every Sunday).  [Reference](https://www.digitalocean.com/community/tutorials/how-to-install-r-on-ubuntu-16-04-2)

1. Use the Dokku template https://github.com/azure/azure-quickstart-templates/tree/master/dokku-vm to create a Dokku instance on Azure

2. Connect to the instance vi ssh , e.g. `ssh ubuntu@apm-dokku-trial.eastus2.cloudapp.azure.com`

3. In your ssh session:

    ```sh
    $ List the ssh keys and verify that no public keys exist `dokku ssh-keys:list`

    $ Create a file containing your public key named `dokku.pub`

    $ Add your public key `dokku ssh-keys:add [your-user-name] dokku.pub`

    $ List the keys again and verify that the list is no longer empty `dokku ssh-keys:list`

    $ Remove the file `rm dokku.pub`

    $ Exit from the shell
    ```

    Now you are ready to create the app in dokku.

    ```sh
    $ Create the app
    ```
       ssh dokku@apm-dokku-trial.eastus2.cloudapp.azure.com apps:create apm-production-docker
    ```sh

    $ Set the build arguments
    ```
       ssh dokku@apm-dokku-trial.eastus2.cloudapp.azure.com docker-options:add apm-production-docker build '--build-arg PRODUCTION_SLACK_AUTH_TOKEN=[TOKEN]'

       ssh dokku@apm-dokku-trial.eastus2.cloudapp.azure.com docker-options:add apm-production-docker build '--build-arg WSO_TOKEN=[TOKEN]'

       ssh dokku@apm-dokku-trial.eastus2.cloudapp.azure.com docker-options:add apm-production-docker build '--build-arg PRODUCTION_SLACK_BOT_TOKEN=[TOKEN]'
    ```sh

    $ Add the dokku remote
    ```
       git remote add dokku dokku@apm-dokku-trial.eastus2.cloudapp.azure.com:apm-production-docker
    ```sh

    $ Start the build by pushing to the dokku remote.  This will take some time.
    ```
       git push dokku master
    ```sh

4.  While the build is running, open a new terminal tab and copy the csv files and the shell script to the directory on the remote VM as follows:

    ```sh
    $ scp av_members.csv  ubuntu@apm-dokku-trial.eastus2.cloudapp.azure.com:

    $ scp data.csv  ubuntu@apm-dokku-trial.eastus2.cloudapp.azure.com:

    $ scp email_aliases.csv  ubuntu@apm-dokku-trial.eastus2.cloudapp.azure.com:

    $ scp setup_crontab.sh ubuntu@apm-dokku-trial.eastus2.cloudapp.azure.com:
    ```

5. ssh into the box, move the files you just uploaded, and mount the data volume
    ```
    $ ssh ubuntu@apm-dokku-trial.eastus2.cloudapp.azure.com

    $ sudo mv *.csv /var/lib/dokku/data/storage

    $ dokku storage:mount apm-production-docker  /var/lib/dokku/data/storage:/app/data
    ```sh

6. To run the very basic code so far, return to your ssh session and execute the following command:

   ```sh
   $ dokku --rm run apm-production-docker Rscript basic_functionality_so_far.R
   ```
   You should see a message in the `#data-mining` channel with this week's picks for premium signup.

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
