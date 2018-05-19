#!/bin/bash

set -ue

IMAGE_NAME="lk8000-build-kobo"

# Check whether the buildpack is already build
if [ -z "$(docker images -q $IMAGE_NAME)" ]; then
    echo "Building build container image..."
    cd Scripts
    docker build --pull --rm --tag=$IMAGE_NAME -f docker/Dockerfile-build-kobo .
    cd ..
fi

docker run -it --rm -v $PWD:/lk8000:delegated $IMAGE_NAME \
    make TARGET=KOBO TCPATH=arm-linux-gnueabihf- SYSROOT=/usr/arm-linux-gnueabihf clean
docker run -it --rm -v $PWD:/lk8000:delegated $IMAGE_NAME \
    make TARGET=KOBO TCPATH=arm-linux-gnueabihf- SYSROOT=/usr/arm-linux-gnueabihf
