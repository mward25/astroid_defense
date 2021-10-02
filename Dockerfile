FROM ubuntu
EXPOSE 9278/tcp
EXPOSE 9278/udp

RUN useradd -Um astroid_server

RUN runuser -l astroid_server -c 'mkdir /home/astroid_server/server_dir/'

# copy data
COPY --chown=astroid_server:astroid_server . /home/astroid_server/server_dir

# install dependencies
RUN apt-get update && apt-get upgrade -y && apt-get install wget unzip -y

# Will be removed later
RUN apt-get install git -y

# get Godot, unzip Godot, and move it to the correct directory
RUN wget https://downloads.tuxfamily.org/godotengine/3.3.4/Godot_v3.3.4-stable_linux_server.64.zip unzip Godot_v*linux*.zip && mv Godot_v*linux*.64 /usr/bin/godot

WORKDIR /home/astroid_server/server_dir
CMD godot .
