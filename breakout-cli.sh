#!/usr/bin/env bash

set -e

SCRIPT=$(basename $BASH_SOURCE)
REMOTE="remote"
LOCAL="local"
ret=0

# lib files 
declare -a files
files[0]="lib/check_docker_config.sh"
files[1]="lib/parameterized_mode.sh"
files[2]="lib/interactive_mode.sh"
files[3]="lib/services/backend.sh"
files[4]="lib/services/frontend.sh"
files[5]="lib/services/recoder_uploader.sh"
files[6]="lib/services/mailer.sh"
files[7]="lib/container_service.sh"

# BreakOut services
declare -a services
services[0]="backend"
services[1]="frontend"
services[2]="recoder"
services[3]="uploader"
services[4]="mailer"

# Corresponding docker-compose files
declare -a docker_compose_files
docker_compose_files[0]="docker-compose-files/docker-compose-breakout.yml"

# Helper functions
function print_usage() {
    echo -e "\n$SCRIPT(1)   BreakOut interactive service shell    $SCRIPT(1)\n
\033[1mNAME
    $SCRIPT \033[0m-- breakout-interactive

\033[1mSYNOPSYS
    \033[1m$SCRIPT \033[0m[-\033[1mh\033[0m | -\033[1md\033[0m]
    \033[1m$SCRIPT \033[0m[-\033[1ms\033[0m <service> [-\033[1ml\033[0m <path> | -\033[1mr\033[0m <version>]]
    \033[1m$SCRIPT \033[0m[-\033[1mk\033[0m <service>]
    
\033[1mDESCRIPTION\033[0m
    This cli implements a couple of nifty little functions which make the day
    of any breakout'er easier. If used interactively the program itself guides
    its user through the process of starting and stoping breakout-services.
    If the user provides option-parameters the program will execute specific
    commands as configured.
    
    -\033[1mh\033[0m    Prints help
    -\033[1md\033[0m    Prints the docker status
    -\033[1ms\033[0m    Starts a service. The -\033[1ms\033[0m option needs a valid service-parameter.
          Valid services are ${services[0]}, ${services[1]}, ${services[2]}, ${services[3]}, ${services[4]}.
    -\033[1ml\033[0m    Specifies that a local version of the configured services should
          be started.
    -\033[1mr\033[0m    Specifies that a remote version of the configured services should
          be started inside a docker container. The -\033[1mr\033[0m option needs a valid
          service-version-parameter.
    -\033[1mk\033[0m    Kills the specified service. In parameterized mode one can either
          start or kill services.

\033[1mEND\n"
}

function wrong_option_order() {
    echo -e "The ordner of the provided option-arguments was wrong.
Your call:
    $0 $@

Wrong argument order around:
    $1\n"
    exit 1
}

function file_check() {
    if ! [ -r "$1" ]; then file_not_found_exception $1; exit 1; fi
}

function file_not_found_exception() {
    echo -e "\nFile: $(basename $1) not found!\nIt should reside in folder $(dirname $1).\n"
}

function docker_status() {
    docker -v
    docker ps -a
    docker info
}

# START SCRIPT
previous_option="x"
declare -a services
declare -i number_of_services=0
declare -a service_source
declare -i number_of_sources=0
declare -a service_version
declare -i number_of_versions=0
while getopts ":hds:l:r:k:" opt; do
    case $opt in
        h)
            print_usage
            exit 0
            ;;
        d)
            docker_status
            exit 0
            ;;
        s)  
            if [ "$previous_option" == "s" ] || [ "$previous_option" == "k" ]; then
                wrong_option_order "-$previous_option -s"
            fi
            services[$number_of_services]="$OPTARG"
            previous_option="s"
            ((number_of_services++))
            ;;
        l)
            if [ "$previous_option" != "s" ]; then
                wrong_option_order "-$previous_option ... -l ..."
            fi
            service_source[$number_of_sources]=$LOCAL
            service_version[$number_of_versions]="$OPTARG"
            previous_option="l"
            ((number_of_sources++))
            ((number_of_versions++))
            ;;
        r)
            if [ "$previous_option" != "s" ]; then
                wrong_option_order "-$previous_option ... -r ..."
            fi
            service_source[$number_of_sources]=$REMOTE
            service_version[$number_of_versions]="$OPTARG"
            previous_option="r"
            ((number_of_sources++))
            ((number_of_versions++))
            ;;
        k)
            if ! [ "$previous_option" == "x" ] || [ "$previous_option" == "k" ] ; then
                wrong_option_order "-$previous_option -k"
            fi
            services[$number_of_services]="$OPTARG"
            previous_option="k"
            ((number_of_services++))
            ;;
        \?)
            echo "Invalid option: -$OPTARG"
            print_usage
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument."
            print_usage
            exit 1
            ;;
    esac
done

# Check if all necessary files are available
for file in "${files[@]}"; do file_check $file; done
for file in "${docker_compose_files[@]}"; do file_check $file; done

# check_docker_config.sh
source ${files[0]}

if [ $number_of_services -ne 0 ]; then
    if [ "$previous_option" == "k" ]; then
        #  Parameterized_mode - stop services
        source ${files[1]} stop
        if [ $ret -ne 0 ]; then
            # TODO Maybe some housekeeping
            exit 1
        else
            echo -e "\nStopped requested services succesfully.\n"
        fi
    elif [ $number_of_services -eq $number_of_sources ] && [ $number_of_services -eq $number_of_versions ]; then
        # Parameterized_mode - start services
        source ${files[1]} start
        if [ $ret -ne 0 ]; then
            # TODO Maybe some housekeeping
            exit 1
        else
            echo -e "\nStarted requested services succesfully.\n"
        fi
    else
        echo -e "\nWrong amout of option-parameters.\nA configured service needs a version, either a local path or docker-image-version.\n\n"
        exit 1
    fi
else
    # Start interactive_mode.sh
    source ${files[2]}interactive_mode
    if [ $ret -ne 0 ]; then
         # TODO Maybe some housekeeping
        exit 1
    else
        echo -e "\nInteractive mode ended.\n"
    fi
fi

exit 0
