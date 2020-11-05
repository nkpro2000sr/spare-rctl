echo >> sparerctl.log
printf '#%.0s' {1..88} >> sparerctl.log
echo -e "\n$(date)\n" >> sparerctl.log

for x in $(cat /proc/cmdline); do
    case $x in
        --ssh) # 22
                /usr/bin/sshd &>> sparerctl.log &
                ;;&
        --novnc) # 6080
                /usr/bin/novnc &>> sparerctl.log &
                ;&
        --vnc) # 5900
                /usr/bin/x11vnc -xkb -noxrecord -noxfixes -noxdamage \
                                -repeat -forever -shared \
                                -auth $(ps wwwwaux | grep auth | grep root | head -n 1 | awk '{ print $15 }') \
                                -passwd spareRctl.sh &>> sparerctl.log &
                ;;&
        
        --wifi)
                false
                while [[ $? != 0 ]]; do
                    sleep 0.3
                    /usr/bin/nmcli device wifi rescan >> sparerctl.log
                    sleep 0.3
                    /usr/bin/nmcli device wifi connect spareRctl password spareRctl.sh >> sparerctl.log
                done
                ;;
        --ap)
                /usr/bin/nmcli device wifi hotspot ssid spareRctl password spareRctl.sh &>> sparerctl.log
                ;;
    esac
done

LOOP=0
for x in $(cat /proc/cmdline); do
    case $x in
        --ssh) ;&
        --novnc) ;&
        --vnc)
               LOOP=1 ;;
    esac
done
if [[ $LOOP == 1 ]]; then
     while true; do sleep 10; done
fi

## /usr/lib/systemd/system/sparerctl.service
# [Unit]
# Description=spare remote control to access at the time of problem
# Wants=network-online.target
# After=network.target network-online.target
# Wants=sshdgenkeys.service
# After=sshdgenkeys.service
# Requires=graphical.target
# #After=graphical.target
# 
# [Service]
# User=root
# WorkingDirectory=/root
# ExecStart=/usr/bin/bash /opt/spareRctl.sh
# KillMode=mixed
# 
# [Install]
# WantedBy=multi-user.target
