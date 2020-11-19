echo >> spareRctl.log
printf '#%.0s' {1..88} >> spareRctl.log
echo -e "\n$(date)\n" >> spareRctl.log

filename=
for x in $(cat /proc/cmdline); do
    case "$x" in
        --spareRctl*)
            filename="${x#--spareRctl:}" # --spareRctl:filename
            ;;
    esac
done

if [ -r "${filename}" ]; then
    while read -r line; do
        case "${line}" in
            --ssh) # 22
                    /usr/bin/sshd &>> spareRctl.log &
                    ;;&
            --novnc) # 6080
                    /usr/bin/novnc &>> spareRctl.log &
                    ;&
            --vnc) # 5900
                    read -r password
                    /usr/bin/x11vnc -xkb -noxrecord -noxfixes -noxdamage \
                                    -repeat -forever -shared \
                                    -auth "$(ps wwwwaux | grep auth | grep root | head -n 1 | awk '{ print $15 }')" \
                                    -passwd "${password}" &>> spareRctl.log &
                    ;;&
            
            --wifi)
                    read -r ssid
                    read -r passwd
                    false
                    while [[ $? != 0 ]]; do
                        sleep 0.3
                        /usr/bin/nmcli device wifi rescan >> spareRctl.log
                        sleep 0.3
                        /usr/bin/nmcli device wifi connect "${ssid}" password "${passwd}" >> spareRctl.log
                    done
                    ;;
            --ap)
                    read -r ssid
                    read -r passwd
                    /usr/bin/nmcli device wifi hotspot ssid "${ssid}" password "${passwd}" &>> spareRctl.log
                    ;;
        esac
    done < "${filename}"
fi

LOOP=0
if [ -r "${filename}" ]; then
    while read -r line; do
        case "${line}" in
            --ssh) ;&
            --novnc) ;&
            --vnc)
                LOOP=1
                break
                ;;
        esac
    done < "${filename}"
fi
if [[ $LOOP == 1 ]]; then
     while true; do sleep 10; done
fi
