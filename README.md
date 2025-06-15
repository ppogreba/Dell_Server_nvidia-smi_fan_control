# Dell R730_nvidia-smi_fan_control

tested on R630 and R730. should work on may others as well with the same racadm syntax

# 

This programs purpose is to run as a daemon in linux to control the minimum fan-speed of a dell server via idrac ssh with certificate. This method is usually less preferred way to do this, but was the option I went with as it would not impact normal fan function. You first need to establish ssh connection via key-pair with idrac from the nvidia host machine. test and verify the script works before setting it as a daemon process. If you have questions, feel free to ask, but this should get you 98% of the way there.

There is an alternative ipmi method in case that is more preferred for higher end cards. Please use this method with caution, as it aims to lower the default speed instead of just increase the default speed of the fans.

USE AT YOUR OWN RISK

# Step 1

## Create user named 'automation' in iDRAC with:

Roles : Operator

Login      X

Configure  X


## Create ssh key on host

ssh-keygen -b 2048 -t rsa

Upload pub SSH key into 'automation' user

Place .pem (private key) into /etc/ssh/id_rsa.pem on GPU host machine

# Step 2

## Update Global variables on top of fan_control.sh

NUMBER_GPUS=2 ## number of GPUs
HOST_IP="192.168.1.120" ## ip or resolvable name of host

## Place fan_control.sh into /etc/init.d/ 

remember to sudo chmod +x fan_control.sh

# Step 3

## TEST run /etc/init.d/fan_control.sh

# Step 4 

## Create Daemon

follow instructions in fan_control.services
