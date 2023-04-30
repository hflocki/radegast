FROM ubuntu:18.04
MAINTAINER hflocki78@gmail.com
EXPOSE 8080 5901
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Berlin

RUN apt-get update
RUN apt-get install -y xfce4 xfce4-terminal
RUN apt-get install -y novnc
RUN apt-get install -y tightvncserver websockify
RUN apt-get install -y curl wget gnupg libseccomp2


##############
# Wine setup #
##############

## Enable 32 bit architecture for 64 bit systems
RUN dpkg --add-architecture i386

## Add wine repository
RUN wget -nc https://dl.winehq.org/wine-builds/winehq.key
RUN apt-key add winehq.key
RUN wget -qO- https://dl.winehq.org/wine-builds/Release.key | apt-key add -
RUN apt-get -y install software-properties-common \
    && add-apt-repository 'deb http://dl.winehq.org/wine-builds/ubuntu/ bionic main' \
    && apt-get update


## Install wine and winetricks
#RUN apt-get -y install --install-recommends winehq-devel cabextract 

RUN apt-get -y install --install-recommends wine1.7
RUN apt-get -y install mono-complete

ENV USER root
#RUN printf "axway99\naxway99\n\n" | vncserver :1

COPY start.sh /start.sh
RUN chmod a+x /start.sh

RUN useradd -ms /bin/bash user
RUN mkdir /.novnc
RUN chown user:user /.novnc

WORKDIR /.novnc
RUN wget -qO- https://github.com/novnc/noVNC/archive/v1.4.0.tar.gz | tar xz --strip 1 -C $PWD
RUN mkdir /.novnc/utils/websockify
RUN wget -qO- https://github.com/novnc/websockify/archive/v0.6.1.tar.gz | tar xz --strip 1 -C /.novnc/utils/websockify
RUN ln -s vnc.html index.html

COPY config /home/user
RUN chown -R user:user /home/user
USER user
RUN mkdir /home/user/apps

USER user
WORKDIR /home/user

CMD ["sh","/start.sh"]
