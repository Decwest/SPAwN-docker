#!/bin/bash

cd `dirname $0`

# xhost +
xhost +local:user

docker run -it \
    --privileged \
    --runtime=nvidia \
    -e NVIDIA_VISIBLE_DEVICES=all \
    -e NVIDIA_DRIVER_CAPABILITIES=all \
    --env=DISPLAY=$DISPLAY \
    --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
    -v "/home/${USER}/.Xauthority:/home/${USER}/.Xauthority" \
    --env="QT_X11_NO_MITSHM=1" \
    --rm \
    -v "/$(pwd)/entrypoint.sh:/entrypoint.sh" \
    -v "/$(pwd)/spawn:/home/${USER}/spawn" \
    -v "/$(pwd)/data:/data" \
    -v /etc/group:/etc/group:ro \
    -v /etc/passwd:/etc/passwd:ro \
    -v /etc/localtime:/etc/localtime:ro \
    -v /media:/media \
    -v /dev:/dev \
    --net host \
    ${USER}/spawn
