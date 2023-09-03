#!/usr/bin/env zsh

set -eu

# This script is run as ROOT by Carbon Copy Cloner
# Print progress of the job into my homedir
LOG=/Users/martinzacho/.logs/ccc-dd-preflight

enabled=0

if [ $enabled ]; then
  echo "# $(date) | $0: Starting job" >> $LOG

  # Change user so ~ expands correctly in subprocceses
  sudo -u martinzacho -i /Users/martinzacho/bin/backup-userspace.sh >> $LOG 2>&1

  echo "# $(date) | $0: Job finished successfully" >> $LOG
else
  echo "# $(date) | $0: job disabled" >> $LOG
fi
