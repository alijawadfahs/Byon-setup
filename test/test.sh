#!/bin/bash

PID=$(echo $$)

# Set up the script variables
LOGFILE="/tmp/testlog.$PID.log"


# Set up the logging for the script
sudo touch $LOGFILE

