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
        --vnc*) # 5900
                password=${x#--vnc:} # --vnc:passwd
                /usr/bin/x11vnc -xkb -noxrecord -noxfixes -noxdamage \
                                -repeat -forever -shared \
                                -auth $(ps wwwwaux | grep auth | grep root | head -n 1 | awk '{ print $15 }') \
                                -passwd ${password} &>> sparerctl.log &
                ;;&
        
        --wifi*)
                y=${x#--wifi:} # --wifi:ssid:passwd
                false
                while [[ $? != 0 ]]; do
                    sleep 0.3
                    /usr/bin/nmcli device wifi rescan >> sparerctl.log
                    sleep 0.3
                    /usr/bin/nmcli device wifi connect ${y%%:*} password ${y#*:} >> sparerctl.log
                done
                ;;
        --ap*)
                y=${x#--ap:} # --ap:ssid:passwd
                /usr/bin/nmcli device wifi hotspot ssid ${y%%:*} password ${y#*:} &>> sparerctl.log
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
