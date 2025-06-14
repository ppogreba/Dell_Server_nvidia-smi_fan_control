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
    MAX=false
    HIGH=false
    MID=false
    LOW=False
    NORM=false
    temps=()
    for ((i=0; i<$NUMBER_GPUS; i++)); do
        temps+=($(nvidia-smi --id=$i -q --display=TEMPERATURE | grep GPU.Current.Temp | awk '{print $5}'))
    done  
    echo -e "\n${temps[0]}   ${temps[1]}"
    all_less_than_50=true
    for temp in ${temps[@]}; do
        if [ $temp -ge 85 ]; then
            MAX=true
            echo -n "MAX! "
        elif [ $temp -ge 75 ] && [ $temp -lt 85 ]; then
            HIGH=true
            echo -n "HIGH "         
        elif [ $temp -ge 60 ] && [ $temp -lt 75 ]; then
            MID=true
            echo -n "Mid  "         
        elif [ $temp -ge 50 ] && [ $temp -lt 60 ]; then
            LOW=true
            echo -n "Low  "
        elif [ $temp -ge 0 ] && [ $temp -lt 50 ]; then
            NORM=true
            echo -n "Norm "      
        fi
    done
    if $MAX; then
        update_speed=100
    elif $HIGH; then
        update_speed=70
    elif $MID; then
        update_speed=50
    elif $LOW; then
        update_speed=30
    elif $NORM; then
        update_speed=0
    fi
    if [ $update_speed -ne $fan_speed ]; then
        longhold=false
        if [ $update_speed -gt $fan_speed ]; then
            longhold=true
        fi
        echo -e "\nUpdate Fan Speed to $update_speed"
        fan_speed=$update_speed
        ssh -i /etc/ssh/id_rsa.pem automation@$HOST_IP << EOF 
        racadm set System.ThermalSettings.MinimumFanSpeed $fan_speed
        exit
EOF
        if $longhold; then
            echo "Success!! - waiting 30"
            sleep 30
        fi
    else
        sleep 2
    fi
done
exit 0
