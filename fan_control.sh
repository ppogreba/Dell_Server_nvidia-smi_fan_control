#!/bin/bash
# This script runs continuously and checks the temp of two nvidia cards every 5 seconds.
# If the temp of the card is above certain threasholds, the idrac command is called to increase
# fan speed. If the temprature drops, the fan speeds also decrease.
user={enter your user} ##
fan_speed=0

while true
do
    temp1=$(nvidia-smi --id=0 -q --display=TEMPERATURE | grep GPU.Current.Temp | awk '{print $5}')
    temp2=$(nvidia-smi --id=1 -q --display=TEMPERATURE | grep GPU.Current.Temp | awk '{print $5}')
    if [ $temp1 -lt 50 ] && [ $temp2 -lt 50 ]; then
        update_speed=0
        echo "fan speed normal"
        if [ $update_speed -ne $fan_speed ]; then
            fan_speed=$update_speed
            ssh -i /home/"$user"/.ssh/id_rsa.pem automation@192.168.1.120 << EOF 
                racadm set System.ThermalSettings.MinimumFanSpeed 0
                exit
EOF
        fi
    elif [ $temp1 -ge 50 ] && [ $temp1 -lt 60 ] || [ $temp2 -ge 50 ] && [ $temp2 -lt 60 ]; then
        update_speed=30
        echo "fan speed low"
        if [ $update_speed -ne $fan_speed ]; then
            fan_speed=$update_speed
            ssh -i /home/"$user"/.ssh/id_rsa.pem automation@192.168.1.120 << EOF
                racadm set System.ThermalSettings.MinimumFanSpeed 30
                exit
EOF
        fi
    elif [ $temp1 -ge 60 ] && [ $temp1 -lt 75 ] || [ $temp2 -ge 60 ] && [ $temp2 -lt 75 ]; then
        update_speed=50
        echo "fan speed Medium"
                if [ $update_speed -ne $fan_speed ]; then
            fan_speed=$update_speed
            ssh -i /home/"$user"/.ssh/id_rsa.pem automation@192.168.1.120 << EOF
                racadm set System.ThermalSettings.MinimumFanSpeed 50
                exit
EOF
        fi
    elif [ $temp1 -ge 75 ] && [ $temp1 -lt 85 ] || [ $temp2 -ge 75 ] && [ $temp1 -lt 85 ]; then
        update_speed=70
        echo "fan speed HIGH"
        if [ $update_speed -ne $fan_speed ]; then
            fan_speed=$update_speed
            ssh -i /home/"$user"/.ssh/id_rsa.pem automation@192.168.1.120 << EOF
                racadm set System.ThermalSettings.MinimumFanSpeed 70
                exit
EOF
        fi
    elif [ $temp1 -ge 85 ] || [ $temp2 -ge 85 ]; then
        update_speed=100
        echo "fan speed HIGH"
        if [ $update_speed -ne $fan_speed ]; then
            fan_speed=$update_speed
            ssh -i /home/"$user"/.ssh/id_rsa.pem automation@192.168.1.120 << EOF
                racadm set System.ThermalSettings.MinimumFanSpeed 100
                exit
EOF
        fi
    else
        echo "overload!" ##should never get here
    fi
sleep 2
done

exit 0
