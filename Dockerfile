FROM arm32v7/debian:latest

ARG PA_VERSION=16.0

ENV DEBIAN_FRONTEND='noninteractive'

# update
RUN apt-get update && apt upgrade -y

# dependencies for pulse audio
RUN apt-get install -y wget curl libglib2.0-dev gnupg2 meson xz-utils libtdb-dev libsndfile-dev pkg-config gettext gcc g++ patch libtool libsndfile1 libspeexdsp1

# COPY *.patch /home/

# activate the intl library
RUN ln /usr/lib/arm-linux-gnueabihf/preloadable_libintl.so /usr/lib/arm-linux-gnueabihf/intl.so
RUN ln /usr/lib/arm-linux-gnueabihf/preloadable_libintl.so /usr/lib/arm-linux-gnueabihf/libintl.so

# build and install pulse audio
RUN curl -Lo/home/pa.tar.xz https://freedesktop.org/software/pulseaudio/releases/pulseaudio-${PA_VERSION}.tar.xz && \
    tar xvf /home/pa.tar.xz -C /home && \
    cd /home/pulseaudio-${PA_VERSION} && \
    meson \
        --prefix=/usr/local \
        --sysconfdir=/usr/local/etc \
        --localstatedir=/var \
        --optimization=s \
        --buildtype=release \
        -Dman=false \
        -Dtests=false \
        -Dlegacy-database-entry-format=false \
        -Davahi=disabled \
        -Dbluez5=disabled \
        -Ddbus=disabled \
        -Dgsettings=disabled \
        -Dgtk=disabled \
        -Dhal-compat=false \
        -Dsystemd=disabled \
        -Dx11=disabled \
        . output \
    && \
    ninja -C output && \
    ninja -C output install

# dependencies
RUN wget https://packages.erlang-solutions.com/erlang-solutions_2.0_all.deb && dpkg -i erlang-solutions_2.0_all.deb
RUN apt-get update
RUN apt-get install -y build-essential git libssl-dev ruby-dev elixir erlang-dev erlang-xmerl qttools5-dev qttools5-dev-tools libqt5svg5-dev libqt5opengl5-dev supercollider-server sc3-plugins-server alsa-utils jackd2 libjack-jackd2-dev libjack-jackd2-0 libasound2-dev librtmidi-dev pulseaudio-module-jack cmake ninja-build

# install Sonic Pi
RUN wget https://sonic-pi.net/files/releases/v3.3.1/sonic-pi_3.3.1_2_armhf.deb
RUN apt-get install -y ./sonic-pi_3.3.1_2_armhf.deb 
RUN rm sonic-pi_3.3.1_2_armhf.deb

# Icecast 2
RUN apt-get install -y icecast2 ices2

RUN apt-get install -y vim

# setup the user
RUN adduser sonicpi
RUN usermod -aG sudo sonicpi

WORKDIR /home/sonicpi

EXPOSE 8000

RUN mkdir icecast2
RUN cp -r /usr/share/icecast2/web /home/sonicpi/icecast2/
RUN cp -r /usr/share/icecast2/admin /home/sonicpi/icecast2/
RUN chown -R sonicpi:sonicpi /home/sonicpi/icecast2

USER sonicpi

RUN mkdir icecast2/log
RUN touch icecast2/log/access.log
RUN touch icecast2/log/error.log
COPY icecast.xml icecast2/icecast.xml

RUN mkdir ices
RUN mkdir ices/log
RUN touch ices/log/ices.log
COPY ices.xml ices/ices.xml
