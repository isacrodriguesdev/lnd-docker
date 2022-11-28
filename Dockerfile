# Reinstall
# docker compose down && docker rmi lnd-docker_app && docker compose up -d

# Connection (TLS/Macaroon)
# docker compose exec app base64 -w0 tls.cert && echo -e "\n\n" && docker compose exec app base64 -w0 data/chain/bitcoin/mainnet/admin.macaroon && echo -e "\n"

FROM ubuntu:latest
RUN apt update && apt -y install sudo

RUN adduser --disabled-password --gecos '' ubuntu
RUN adduser ubuntu sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN mkdir /root/.lnd

RUN sudo apt update && sudo apt install -y tor && sudo apt install -y wget && sudo apt install -y git && sudo apt install -y golang-go && sudo apt install -y build-essential && sudo apt install -y vim && apt install -y net-tools && sudo apt clean

RUN cd /home/ubuntu && git clone https://github.com/lightningnetwork/lnd && cd lnd && export && make install
RUN cd /home/ubuntu && git clone https://github.com/LN-Zap/lndconnect.git && cd lndconnect && make

RUN echo > /etc/tor/torrc "SOCKSPort 9050\nLog notice stdout\nCookieAuthentication 1\nCookieAuthFileGroupReadable 1\nControlPort 9051\nCookieAuthentication 1\nHiddenServiceDir /var/lib/tor/lnd\nHiddenServicePort 10009 0.0.0.0:10009"

WORKDIR /root/.lnd

COPY ./password /tmp

ENTRYPOINT sudo chmod -R a+rwx /etc/tor/torrc && service tor start && lnd \
  --rpclisten=0.0.0.0:10009 \
  --listen=0.0.0.0 \
  --neutrino.addpeer=btcd-mainnet.lightning.computer \
  --neutrino.addpeer=mainnet1-btcd.zaphq.io \
  --neutrino.addpeer=mainnet2-btcd.zaphq.io \
  --neutrino.addpeer=mainnet3-btcd.zaphq.io \
  --neutrino.addpeer=mainnet4-btcd.zaphq.io \
  --neutrino.feeurl=https://nodes.lightning.computer/fees/v1/btc-fee-estimates.json \
  --maxpendingchannels=10 \
  --alias=isacrodriguesdev \
  --color=#9999ff \
  --wallet-unlock-allow-create \
  --wallet-unlock-password-file=/tmp/password \
  --maxlogfilesize=10 \
  --bitcoin.active \
  --bitcoin.mainnet \
  --bitcoin.node=neutrino \
  --autopilot.maxchannels=10 \
  --autopilot.allocation=1.0 \
  --tor.active \
  --tor.v3 \
  --tor.streamisolation \
  --tor.dns=nodes.lightning.directory && /bin/bash


