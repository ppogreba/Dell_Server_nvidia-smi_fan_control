#!/bin/bash
# This script runs continuously and checks the temp of two nvidia cards every 5 seconds.
# If the temp of the card is above certain threasholds, the idrac command is called to increase
# fan speed. If the temprature drops, the fan speeds also decrease.

# Set number of GPUs
NUMBER_GPUS=2
HOST_IP="192.168.1.120"


## Program Start, do not edit anything below this line
fan_speed=1
while true
do
    temps=()
    for ((i=0; i<$NUMBER_GPUS; i++)); do
        temps+=($(nvidia-smi --id=$i -q --display=TEMPERATURE | grep GPU.Current.Temp | awk '{print $5}'))
    done  
    echo "${temps[@]}"
    all_less_than_50=true
    for temp in ${temps[@]}; do
        if [ $temp -ge 85 ]; then
            update_speed=100
            if [$update_speed -ne $fan_speed]; then
                echo "fan speed MAX"
                fan_speed=$update_speed
                ssh -i /etc/ssh/id_rsa.pem automation@$HOST_IP << EOF
                    racadm set System.ThermalSettings.MinimumFanSpeed $fan_speed
                    exit
EOF
            fi
        elif [ $temp -ge 75 ] && [ $temp -lt 85 ]; then
            update_speed=70           
            if [$update_speed -ne $fan_speed]; then
                echo "fan speed HIGH"
                fan_speed=$update_speed
                ssh -i /etc/ssh/id_rsa.pem automation@$HOST_IP << EOF
                    racadm set System.ThermalSettings.MinimumFanSpeed $fan_speed
                    exit
EOF
            fi
        elif [ $temp -ge 60 ] && [ $temp -lt 75 ]; then
            update_speed=50           
            if [$update_speed -ne $fan_speed]; then
                echo "fan speed Medium"
                fan_speed=$update_speed
                ssh -i /etc/ssh/id_rsa.pem automation@$HOST_IP << EOF
                    racadm set System.ThermalSettings.MinimumFanSpeed $fan_speed
                    exit
EOF
            fi
        elif [ $temp -ge 50 ] && [ $temp -lt 60 ]; then
            update_speed=30            
            if [ $update_speed -ne $fan_speed ]; then
                echo "fan speed low"
                fan_speed=$update_speed
                ssh -i /etc/ssh/id_rsa.pem automation@$HOST_IP << EOF
                    racadm set System.ThermalSettings.MinimumFanSpeed $fan_speed
                    exit
EOF
            fi
        else
            update_speed=0
            if [ $update_speed -ne $fan_speed ]; then
                echo "fan speed normal"
                fan_speed=$update_speed
                ssh -i /etc/ssh/id_rsa.pem automation@$HOST_IP << EOF 
                    racadm set System.ThermalSettings.MinimumFanSpeed $fan_speed
                    exit
EOF
            fi
        fi
    done
done
exit 0
