#!/bin/bash

# This bash script is designed to prepare and install docker and Kubernetes for Ubuntu 18.04
# The stpes were taken from https://phoenixnap.com/kb/install-kubernetes-on-ubuntu with modifications done once necessary.
# Author: Ali Jawad FAHS, Activeeon


# Set up the script variables
STARTTIME=$(date +%s)
PID=$(echo $$)
DATE=$(date)
LOGFILE="/var/log/kube-install.$PID.log"


# Set up the logging for the script
sudo touch $LOGFILE
sudo chown $USER:$USER $LOGFILE


# All the output of this shell script is redirected to the LOGFILE
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>$LOGFILE 2>&1

# A function to print a message to the stdout as well as as the LOGFILE
log_print(){
  level=$1
  Message=$2
  echo "$level [$(date)]: $Message"
  echo "$level [$(date)]: $Message" >&3
  }


# Start the Configuration
log_print INFO "Configuration started!"
log_print INFO "Logs are saved at: $LOGFILE"


# Update the package list
log_print INFO "Updating the package list."
sudo apt-get update

# Install curl
log_print INFO "Installing curl"
sudo apt-get install -y curl || { log_print ERROR "curl installation failed!"; exit 1; }

# Install Docker
log_print INFO "Installing Docker"
sudo apt-get install -y docker.io
sudo systemctl enable docker
sudo systemctl status docker
sudo systemctl start docker

sudo docker -v || { log_print ERROR "Docker installation failed!"; exit 1; }


# Install Kubernetes
log_print INFO "Installing Kubernetes"

sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main" || { log_print ERROR "Kubernetes repo can't be added!"; exit 1; }

sudo apt-get install -y kubeadm  || { log_print ERROR "kubeadm installation failed!"; exit 1; }
sudo apt-get install -y kubectl  || { log_print ERROR "kubectl installation failed!"; exit 1; }
sudo apt-get install -y kubelet  || { log_print ERROR "kubelet installation failed!"; exit 1; }


# Hoding upgrades for Kubernetes software (versions to updated manually)
sudo apt-mark hold kubeadm kubelet kubectl

# Checking for the installiation versions
log_print INFO "Checking Kubernetes versions"

kubeadm version     || { log_print ERROR "Docker installation failed!"; exit 1; }
kubectl version     || { log_print ERROR "Docker installation failed!"; exit 1; }
kubelet --version   || { log_print ERROR "Docker installation failed!"; exit 1; }


# Turn off the swap momery
if [ `grep Swap /proc/meminfo | grep SwapTotal: | cut -d" " -f14` == "0" ];
	then
		log_print INFO "The swap memory is Off"
	else
		sudo swapoff –a || { log_print ERROR "swap memory can't be turned off "; exit 1; }
	fi


# Declare configuration done successfully
ENDTIME=$(date +%s)
ELAPSED=$(( ENDTIME - STARTTIME ))
log_print INFO "Configuration done successfully in $ELAPSED seconds "

