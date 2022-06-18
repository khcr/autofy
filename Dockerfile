FROM debian:latest

ENV DEBIAN_FRONTEND='noninteractive'

# update
RUN apt-get update && apt upgrade -y

# Icecast 2
RUN apt-get install -y vim icecast2 ices2

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
