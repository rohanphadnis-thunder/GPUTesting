curl -fsSL https://get.thundercompute.com/install.sh | sudo THUNDER_INSTALL_MODE=client THUNDER_ENROLLMENT_TOKEN='tr_dd7a7fb96cad5cefb5b8f26c0416e265fec52f104d15fbbeb013b68f20cbe808' THUNDER_CENTRAL_URL='https://giga-staging.thundercompute.com:2096' sh
printf "ld preload: %s\n", $LD_PRELOAD
printf "using thunder: %s\n", $USING_THUNDER
ls /etc
ls /etc/thunder
find / -type f -name "libthunder.so"
sudo find / -type f -name "libthunder.so"
nvidia-smi
