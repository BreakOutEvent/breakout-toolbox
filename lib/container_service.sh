#!/usr/bin/env bash

set -e

function check_container_status() {
    stats=$(docker inspect --format='{{json .State.Status}}' $containerId)
    health=$(docker inspect --format='{{json .State.Health.Status}}' $containerId)
}

function healthcheck_loop() {
    i=0
    while [ ${i} -lt 120 ]; do
        check_container_status $containerId
        if [ "$status" == "\"running\"" ] && [ "$health" == "\"healthy\"" ]; then break; fi
        sleep 1
        ((i+=1))
    done
}

function start_container() {
    if ! docker-compose -f ${docker_compose_files[0]} up -d $requested_app; then
        error_during_startup_exception $requested_app $env
        ret=1
    fi
    
    containerId=$(docker-compose -f ${docker_compose_files[0]} ps -q $requested_app)
    healthcheck_loop $containerId
    check_container_status $containerId
    if [ "$stats" != "\"running\"" ] || [ "$health" != "\"healthy\"" ]; then
        echo -e "\nError during $requested_app-startup!\nRollback start-$breakout_environment!\n"
        ret=1
    fi
    ret=0
}

function stop_container() {
    ret=0
    if docker-compose -f ${docker_compose_files[0]} stop $requested_app; then
        if ! docker-compose -f ${docker_compose_files[0]} rm --force $requested_app; then
            echo -e "\nError during removal of container: $requested_app!\nPlease check current state.\nbreakout-cli.sh -d"
            ret=1
        fi
    else
        echo -e "\nError during shutdown of $requested_app!\nPlease check current state.\nbreakout-cli.sh -d"
        ret=1
    fi
}

request=$1
requested_app=$2
breakout_environment=$3

if [ "$request" == "start" ]; then
    start_container $requested_app
fi

if [ "$request" == "stop" ]; then
    stop_container $requested_app
fi
