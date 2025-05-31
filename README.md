# Dellr360_nvidia-smi_fan_control

# 

This programs purpose is to run as a daemon in linux to control the minimum fan-speed of a dell server via idrac ssh with certificate. This method is usually less preferred way to do this, but was the option I went with as it would not impact normal fan function.
You first need to establish ssh connection via key-pair with idrac from the nvidia host machine. test and verify the script works before setting it as a daemon process. If you have questions, feel free to ask, but this should get you 98% of the way there.

USE AT YOUR OWN RISK

## Step 1

Create user named 'automation' in iDRAC with:

Roles : Operator

Login      X

Configure  X

#Create ssh key on host
ssh-keygen -b 2048 -t rsa

#Upload pub SSH key into 'automation' user

#Place .pem (private key) into /etc/ssh/id_rsa.pem on GPU host machine
