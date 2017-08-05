#!/usr/bin/env bash

set -e

function start_mailer() {
    echo -e "\nSorry, the 'mailer-functionality' has not been implemented yet!\n"    
    ret=0
}

function stop_mailer() {
    echo -e "\nSorry, the 'mailer-functionality' has not been implemented yet!\n"    
    ret=0
}

if [ "$1" == "start" ]; then start_mailer; fi
if [ "$1" == "stop" ]; then stop_mailer; fi
