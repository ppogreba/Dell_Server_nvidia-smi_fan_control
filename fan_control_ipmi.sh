#!/bin/bash
# This script runs continuously and checks the temp of two nvidia cards every 5 seconds.
# If the temp of the card is above certain threasholds, the idrac command is called to increase
# fan speed. If the temprature drops, the fan speeds also decrease.

# Storing sensitive vars in fan_control_vars.conf -- Example doc provided
source fan_control_vars.conf
# Set number of GPUs
NUMBER_GPUS=2
HOST_IP="192.168.1.120"


## Program Start, do not edit anything below this line
ENABLE="raw 0x30 0x30 0x01 0x00"
DISABLE="raw 0x30 0x30 0x01 0x01"
base_hex="raw 0x30 0x30 0x02 0xff"
ENABLE_FAN_CTL="ipmitool -I lanplus -H $HOST_IP -U $USERNAME -y $KEY -P $PASSWORD $ENABLE"
DISABLE_FAN_CTL="ipmitool -I lanplus -H $HOST_IP -U $USERNAME -y $KEY -P $PASSWORD $DISABLE"
CHANGE_FAN="ipmitool -I lanplus -H $HOST_IP -U $USERNAME -y $KEY -P $PASSWORD $base_hex"
fan_00="0x00"
fan_10="0xA"
fan_15="0xF"
fan_20="0x14"
fan_30="0x1E"
fan_40="0x28"
fan_50="0x32"
fan_60="0x3C"
fan_70="0x46"
fan_80="0x50"
fan_90="0x5A"
fan_100="0x64"

fan_speed=100

echo $ENABLE_FAN_CTL

while true
do
    MAX=false
    HIGH=false
    MID=false
    LOW=false
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
        update_hex=$fan_100
    elif $HIGH; then
        update_hex=$fan_70
    elif $MID; then
        update_hex=$fan_50
    elif $LOW; then
        update_hex=$fan_40
    elif $NORM; then
        update_hex=$fan_20
    fi
    update_speed=$(printf "%d" "$update_hex")

    if [ $update_speed -ne $fan_speed ]; then
        longhold=false
        if [ $update_speed -gt $fan_speed ]; then
            longhold=true
        fi
        echo -e "\nUpdate Fan Speed to $update_speed"
        fan_speed=$update_speed
        $CHANGE_FAN $update_hex
        if $longhold; then
            echo "Success!! - waiting 30"
            sleep 30
        fi
    else
        sleep 2
    fi
done
exit 0

