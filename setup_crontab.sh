#!/bin/bash
cat <<EOF > crontabsetup.txt
05 04 * * 0 dokku dokku --rm run automatedpremium-production Rscript basic_functionality_so_far.R
05 01 * * 0 dokku dokku --rm run automatedpremium-production Rscript updated_active_premium_members.R
EOF
crontab crontabsetup.txt
