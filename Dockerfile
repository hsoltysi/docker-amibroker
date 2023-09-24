# Run amiBroker in a container.
#
# Copyright (c) 2023 moritius <smorituri@gmail.com>
#
# SPDX-License-Identifier:     ISC
#
# docker run \
#	--net host \
#	-v /tmp/.X11-unix:/tmp/.X11-unix \
#	-e DISPLAY \
#	-v $AMIBROKER_HOST_PATH:/amiBroker \
#	--name amiBroker \
#	smorituri/amiBroker

# Base docker image.
FROM ubuntu:focal

ADD https://dl.winehq.org/wine-builds/winehq.key /winehq.key

# Disable interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install Wine
RUN apt-get update && \
	apt-get install -y gnupg apt-utils && \
	echo "deb http://dl.winehq.org/wine-builds/ubuntu/ focal main" >> /etc/apt/sources.list && \
	apt-key add /winehq.key && \
	mv /winehq.key /usr/share/keyrings/winehq-archive.key && \
	dpkg --add-architecture i386 && \
	apt-get update && \
	apt-get install -y -q --install-recommends winehq-devel winetricks zenity && \
	rm -rf /var/lib/apt/lists/* /winehq.key

# Add root password for future winetricks via sudo
RUN echo 'root:Docker!' | chpasswd

# Add wine user.
# NOTE: You might need to change the UID/GID so the
# wine user has write access to your amiBroker
# directory at $AMIBROKER_HOST_PATH.
RUN groupadd -g 1000 wine \
	&& useradd -g wine -u 1000 wine \
	&& mkdir -p /home/wine/.wine && chown -R wine:wine /home/wine

# Run MetaTrader as non privileged user.
USER wine

# amiBroker needs WINEARCH=win32.
# Not strictly necessary, but this
# way it works...
ENV WINEARCH win32

# adding winetricks required to install and run amiBroker
# RUN winetricks -q corefonts mfc42 riched20 wsh57 mdac28
#RUN winetricks -q mfc42
#RUN winetricks -q mdac28
#RUN winetricks -q vcrun2005
# RUN winetricks -q msvcrt=native wscript.exe=native

# Autorun amiBroker Terminal.
ENTRYPOINT [ "wine" ]
#CMD [ "/MetaTrader/terminal.exe", "/portable" ]
CMD [ "/AmiBroker/Broker.exe", "/portable" ]
