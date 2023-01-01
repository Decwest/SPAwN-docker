#!/bin/bash -x

docker build  --tag ${USER}/spawn --build-arg workspace="/home/${USER}" .
