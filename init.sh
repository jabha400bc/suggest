#!/bin/bsh
set -x \
&& mkdir -p ~/repos \
&& cd ~/repos \
&& git clone https://github.com/jabha400bc/suggest.git \
&& cd ~/repos/suggest \
&& . ./setup.sh \
&& install_softwares \
&& set +x