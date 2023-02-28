FROM ubuntu:20.04
RUN TZ=Europe/Kiev
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update && apt-get upgrade -y
RUN apt-get install nano curl wget gcc make git net-tools iproute2 automake autoconf libtool build-essential libssl-dev libexpat1-dev bison flex unbound unzip ssh -y
RUN wget https://go.dev/dl/go1.19.4.linux-amd64.tar.gz;rm -rf /usr/local/go && tar -C /usr/local -xzf ./go1.19.4.linux-amd64.tar.gz
RUN cp /usr/local/go/bin/go /usr/bin/
RUN mkdir /root/v2ray
RUN cd /root/v2ray && wget https://github.com/v2fly/v2ray-core/releases/download/v5.3.0/v2ray-linux-64.zip && unzip v2ray-linux-64.zip
RUN cd / && git clone https://github.com/NLnetLabs/unbound.git && cd unbound && ./configure && make && make install
RUN cd / && git clone https://github.com/handshake-org/hnsd.git && cd hnsd && ./autogen.sh && ./configure && make
RUN cp /hnsd/hnsd /usr/bin
COPY ./main.sh ./
CMD sed -i 's/\r//' main.sh && ./main.sh
