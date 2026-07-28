printf "hostname: %s\n", $HOSTNAME
printf "ld preload: %s\n", $LD_PRELOAD
printf "using thunder: %s\n", $USING_THUNDER
printf "\n/etc paths:\n"
ls /etc
printf "\n/etc/thunder paths:\n"
ls /etc/thunder
printf "\n/dev paths:\n"
ls /dev
printf "\nconfig.json content:\n"
cat /etc/thunder/config.json
printf "\n"
nvidia-smi
