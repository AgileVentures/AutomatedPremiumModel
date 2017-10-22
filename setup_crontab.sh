#!/bin/bash
SHELLFILE=${HOME}/AutomatedPremiumModel/run_model.sh
cat <<EOF > crontabsetup.txt
05 04 * * 0 ${SHELLFILE}
EOF
crontab crontabsetup.txt

