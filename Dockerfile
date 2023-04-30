FROM ubuntu:22.04
MAINTAINER hflocki78@gmail.com
EXPOSE 8080 5901
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Berlin

RUN apt-get update
RUN apt-get install -y xfce4 xfce4-terminal
RUN apt-get install -y novnc
RUN apt-get install -y tightvncserver websockify
RUN apt-get install -y curl wget libseccomp2
ENV WINE_VERSION=8.1~jammy-1
RUN curl -O https://dl.winehq.org/wine-builds/winehq.key && \
    apt-key add winehq.key && \
    rm winehq.key && \
    echo deb https://dl.winehq.org/wine-builds/ubuntu/ jammy main > /etc/apt/sources.list.d/winehq.list && \
    apt-get update && \
    apt-get install -y --install-recommends \
     wine-stable-i386=${WINE_VERSION} wine-stable:i386=${WINE_VERSION} winehq-stable:i386=${WINE_VERSION} && \
    apt-get clean
# https://wiki.winehq.org/Gecko
RUN mkdir -p /usr/share/wine/gecko/ && cd /usr/share/wine/gecko/ && \
   curl -O http://dl.winehq.org/wine/wine-gecko/2.47.4/wine-gecko-2.47.4-x86.msi
# https://wiki.winehq.org/Mono
RUN mkdir -p /usr/share/wine/mono && cd /usr/share/wine/mono && \
   curl -O https://dl.winehq.org/wine/wine-mono/7.4.0/wine-mono-7.4.0-x86.msi
RUN curl https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks > /usr/local/bin/winetricks && \
    chmod +x /usr/local/bin/winetricks
ENV USER_PATH /opt/wineuser
RUN useradd -b /opt -m -d ${USER_PATH} wineuser
RUN mkdir /wine /Data && chown wineuser.wineuser /wine /Data
RUN mkdir -p /opt/wineuser/.cache/winetricks/

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
