FROM ubuntu
EXPOSE 9278/tcp
EXPOSE 9278/udp

# copy data
COPY . /usr/app/

# install dependencies
RUN apt-get update && apt-get upgrade -y && apt-get install wget unzip -y

# Will be removed later
RUN apt-get install git -y

# get Godot, unzip Godot, and move it to the correct directory
RUN wget https://downloads.tuxfamily.org/godotengine/3.3.3/Godot_v3.3.3-stable_linux_server.64.zip && unzip Godot_v*linux*.zip && mv Godot_v*linux*.64 /usr/app

WORKDIR /usr/app/
CMD ./Godot_v*linux*.64 .