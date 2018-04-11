#!/bin/bash
cd AutomatedPremiumModel/
source ~/AutomatedPremiumModel/setup_environs.sh
Rscript ~/AutomatedPremiumModel/update_active_premium_members.R > output.logs
