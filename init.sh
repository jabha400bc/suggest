#!/bin/bash
function init(){
    set -x \
    && sudo su ubuntu \
    && mkdir -p ~/repos \
    && cd ~/repos \
    && git clone https://github.com/jabha400bc/suggest.git \
    && cd ~/repos/suggest \
    && . ./setup.sh \
    && install_softwares \
    && get_suggestions \
    && sudo shutdown -h now \
    && set +x
}
init > /tmp/init_log.txt 2>&1

