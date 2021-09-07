FROM ubuntu
EXPOSE 9278/tcp
EXPOSE 9278/udp

COPY . /usr/app/
WORKDIR /usr/app/
