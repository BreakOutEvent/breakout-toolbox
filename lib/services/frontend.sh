#!/usr/bin/env bash

set -e

function start_frontend() {
    echo -e "\nSorry, the 'frontend-functionality' has not been implemented yet!\n"    
    ret=0
}

function stop_frontend() {
    echo -e "\nSorry, the 'frontend-functionality' has not been implemented yet!\n"    
    ret=0
}

if [ "$1" == "start" ]; then start_frontend; fi
if [ "$1" == "stop" ]; then stop_frontend; fi
