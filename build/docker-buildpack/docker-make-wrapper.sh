#!/bin/bash

# This script helps executing LK8000 make commands within a docker container.
# It takes care of creating the build container image and running the desired
# make target within a throw away instance of that image.
#
# In order to speed up builds on non Linux systems the script will create and
# maintain a special data container storing the LK8000 directory. This data
# container is kept in sync through rsync.

set -ue

IMAGE_NAME="docker-buildpack-lk8000"
DATA_CONTAINER_NAME="${IMAGE_NAME}-data"

DOCKER_DIR="$(dirname $0)"
PROJECT_ROOT="$DOCKER_DIR/../.."


sync_project() {
    container_id=$(docker run -d --rm --volumes-from $DATA_CONTAINER_NAME \
        -p 1873:873 $IMAGE_NAME rsync --daemon --no-detach)
    set +e
    [ "$1" = "in" ] && rsync -rlptz --inplace --delete --exclude='.git/' \
            $PROJECT_ROOT/ rsync://$(docker-machine ip):1873/lk8000/
    [ "$1" = "out" ] && rsync -rlptz --inplace --exclude='.git/' \
            rsync://$(docker-machine ip):1873/lk8000/ $PROJECT_ROOT/
    set -e
    docker stop $container_id >/dev/null
}

# Check whether the buildpack is already build
if [ -z "$(docker images -q $IMAGE_NAME)" ]; then
    echo "Building build container image..."
    docker build --pull --rm --tag=$IMAGE_NAME "$DOCKER_DIR"
fi

# Check wheter the data container exists
if [ -z "$(docker ps -aq --filter name=$DATA_CONTAINER_NAME)" ]; then
    echo "Creating data container..."
    docker create -v /lk8000 -v /opt/kobo --name $DATA_CONTAINER_NAME \
        ubuntu:xenial /bin/true
fi

echo "Syncing source directory into data container..."
sync_project in

if docker run -it --rm --volumes-from $DATA_CONTAINER_NAME $IMAGE_NAME \
    test -e /opt/kobo/.kobo-libs-stamp;
then
    echo "Skipping Kobo libs file, stamp file exists"
else
    echo "Building Kobo libs..."
    if docker run -it --rm --volumes-from $DATA_CONTAINER_NAME $IMAGE_NAME \
        bash -c "BUILD_DIR=/tmp/kobo TC=arm-linux-gnueabihf \
            Scripts/kobo-toolchain-install.sh";
    then
        docker run -it --rm --volumes-from $DATA_CONTAINER_NAME $IMAGE_NAME \
            touch /opt/kobo/.kobo-libs-stamp
    else
        echo "ERROR building Kobo libs. Abort."
        exit 1
    fi
fi

echo "Executing make command inside Docker build container..."
if ! docker run -it --rm --volumes-from $DATA_CONTAINER_NAME $IMAGE_NAME \
    make "$@";
then
    echo "ERROR make failed, syncing back anyway"
fi

echo "Syncing results from data container back to source directory..."
sync_project out
