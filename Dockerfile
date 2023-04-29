FROM ubuntu:22.04
MAINTAINER hflocki78@gmail.com
EXPOSE 8080 5901
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Berlin

RUN apt-get update
RUN apt-get install -y libseccomp2
RUN apt-get install -y xfce4 xfce4-terminal
RUN apt-get install -y novnc
RUN apt-get install -y tightvncserver websockify
RUN dpkg --add-architecture i386
RUN mkdir -pm755 /etc/apt/keyrings
RUN wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
RUN wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/winehq-jammy.sources
RUN apt-get install --install-recommends winehq-stable
RUN apt-get install -y mono-complete
ENV USER root
#RUN printf "axway99\naxway99\n\n" | vncserver :1

COPY start.sh /start.sh
RUN chmod a+x /start.sh

RUN useradd -ms /bin/bash user
RUN mkdir /.novnc
RUN chown user:user /.novnc

COPY config /home/user
RUN chown -R user:user /home/user
USER user
RUN mkdir /home/user/apps

USER user
WORKDIR /home/user

CMD ["sh","/start.sh"]
