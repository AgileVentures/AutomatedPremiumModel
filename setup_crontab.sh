#!/bin/bash
SHELLFILE=${HOME}/AutomatedPremiumModel/run_model.sh
UPDATESHELLFILE=${HOME}/AutomatedPremiumModel/run_update_of_active_premiums.sh
cat <<EOF > crontabsetup.txt
05 04 * * 0 ${SHELLFILE}
05 01 * * 0 ${UPDATESHELLFILE}
EOF
crontab crontabsetup.txt
