#!/usr/bin/env bash

set -e

export MYSQL_ROOT_PASSWORD=root
export MYSQL_DATABASE=breakout
export MARIADB_DATA_DIR="data/mariadb_data_dir"
export SPRING_PROFILES_ACTIVE=floriandev
export BACKEND_TMP_DIR="tmp/backend_app"
export BACKEND_VERSION=""

function start_mariadb() {
    if ! mkdir -p $MARIADB_DATA_DIR; then
        echo -e "\nError during creation of mariadb-data-folder!\nRollback start-backend!\n"
        ret=1
    fi

    # Start mariadb container
    source ${files[7]} start mariadb
}

function start_backend() {
    export BACKEND_VERSION=$version
    if [ "$source" == "$REMOTE" ]; then 
        # Start backend-remote container
        source ${files[7]} start backend-remote
    elif [ "$source" == "$LOCAL" ]; then
        mkdir -p $BACKEND_TMP_DIR
        cp -r $version/* $BACKEND_TMP_DIR/
        cwd=$(pwd)
        cd $BACKEND_TMP_DIR
        ./gradlew stage
        cd $cwd

        # Start backend-local container
        source ${files[7]} start backend-local backend
    else
        echo -e "\nError during backend startup.\nSource: $source not valid!"
        ret=1
    fi
}

function stop() {
    # Stop mariadb container
    source ${files[7]} stop mariadb
    cId=''
    cId=$(docker-compose -f ${docker_compose_files[0]} ps -q backend-remote)
    if [ -n "$cId" ]; then
        # Start backend-remote container
        source ${files[7]} stop backend-remote backend
    else
        cId=$(docker-compose -f ${docker_compose_files[0]} ps -q backend-local)
        if [ -n "$cId" ]; then
            # Stop backend-local container
            source ${files[7]} stop backend-local backend
        else
            echo -e "\nError during backend-shutdown!\nNo backend container to stop.\nPlease check current state.\nbreakout-cli.sh -d"
            ret=1
        fi
    fi
    rm -r $BACKEND_TMP_DIR
    ret=0
}

function start() {
    start_mariadb
    if [ $ret -eq 0 ]; then 
        start_backend
    fi
}

if [ "$1" == "start" ]; then start; fi
if [ "$1" == "stop" ]; then stop; fi
