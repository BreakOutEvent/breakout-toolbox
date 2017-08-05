#!/usr/bin/env bash

set -e

function start_services() {
    for (( i=0; i<=number_of_services-1; i++ )); do
        service=${services[$i]}
        source=${service_source[$i]}
        version=${service_version[$i]}

        # Service = backend
        if [ "$service" == "${services[0]}" ]; then
            source ${files[3]} start
            if [ $ret -ne 0 ]; then
                echo -e "\nSomething went wrong during the start of $service\nAll requested service will be stopped!\n"
                stop_services
                ret=1
                break
            fi
        fi

        # Service = frontend
        if [ "$service" == "${services[1]}" ]; then
            source ${files[4]} start
            if [ $ret -ne 0 ]; then
                echo -e "\nSomething went wrong during the start of $service\nAll requested service will be stopped!\n"
                stop_services
                ret=1
                break
            fi
        fi

        # Service = recoder | uploader
        if [ "$service" == "${services[2]}" ] || [ "$service" == "${services[3]}" ]; then
            source ${files[5]} start
            if [ $ret -ne 0 ]; then
                echo -e "\nSomething went wrong during the start of $service\nAll requested service will be stopped!\n"
                stop_services
                ret=1
                break
            fi
        fi

        # Service = mailer
        if [ "$service" == "${services[4]}" ]; then
            source ${files[6]} start
            if [ $ret -ne 0 ]; then
                echo -e "\nSomething went wrong during the start of $service\nAll requested service will be stopped!\n"
                stop_services
                ret=1
                break
            fi
        fi
    done
}

function stop_services() {
    for (( i=0; i<=number_of_services-1; i++ )); do
        service=${services[$i]}
        source=${service_source[$i]}
        version=${service_version[$i]}
        
        # Service = backend
        if [ "$service" == "${services[0]}" ]; then
            source ${files[3]} stop
            if [ $ret -ne 0 ]; then
                echo -e "\nSomething went wrong during the shutdown of $service."
                ret2=1
            fi
        fi

        # Service = frontend
        if [ "$service" == "${services[1]}" ]; then
            source ${files[4]} stop
            if [ $ret -ne 0 ]; then
                echo -e "\nSomething went wrong during the shutdown of $service."
                ret2=1
            fi
        fi

        # Service = recoder | uploader
        if [ "$service" == "${services[2]}" ] || [ "$service" == "${services[3]}" ]; then
            source ${files[5]} stop
            if [ $ret -ne 0 ]; then
                echo -e "\nSomething went wrong during the shutdown of $service."
                ret2=1
            fi
        fi

        # Service = mailer
        if [ "$service" == "${services[4]}" ]; then
            source ${files[6]} stop
            if [ $ret -ne 0 ]; then
                echo -e "\nSomething went wrong during the shutdown of $service."
                ret2=1
            fi
        fi
    done
}

if [ "$1" == "start" ]; then
    start_services
fi

if [ "$1" == "stop" ]; then
    stop_services
fi
