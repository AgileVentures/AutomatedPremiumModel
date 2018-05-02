#!/bin/bash
cat <<EOF > crontabsetup.txt
05 04 * * 0 dokku --rm run apm-production-docker Rscript basic_functionality_so_far.R
05 01 * * 0 dokku --rm run apm-production-docker Rscript updated_active_premium_members.R
EOF
sudo crontab -u dokku crontabsetup.txt
