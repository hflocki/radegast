FROM ubuntu:18.04
MAINTAINER heiko.flocke@gmail.com
EXPOSE 8080 5901
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Berlin

RUN apt-get update
RUN apt-get install -y xfce4 xfce4-terminal
RUN apt-get install -y novnc
RUN apt-get install -y tightvncserver websockify
RUN apt-get install -y wine1.6
RUN apt-get install -y mono-complete
ENV USER root

COPY start.sh /start.sh
RUN chmod a+x /start.sh

RUN useradd -ms /bin/bash user
RUN mkdir /.novnc
RUN chown user:user /.novnc

COPY config /home/user
RUN chown -R user:user /home/user
RUN mkdir -p /home/user/apps

RUN apt-get -y install gedit vim
USER user

WORKDIR /.novnc
RUN wget -qO- https://github.com/novnc/noVNC/archive/v1.0.0.tar.gz | tar xz --strip 1 -C $PWD
RUN mkdir /.novnc/utils/websockify
RUN wget -qO- https://github.com/novnc/websockify/archive/v0.6.1.tar.gz | tar xz --strip 1 -C /.novnc/utils/websockify
RUN ln -s vnc.html index.html

WORKDIR /home/user

CMD ["sh","/start.sh"]
