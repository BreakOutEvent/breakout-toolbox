#!/usr/bin/env bash

set -e

function print_docker_compose_install_instructions {
    echo -e "The bash script you have called and the whole breakout-techstack rely heavily on docker-compose.
Hence, you need to install docker-compose in a version >=1.14.0.
Check for instruction here: https://docs.docker.com/compose/install/\n"
}

function check_docker_compose {
    if which docker-compose 1>/dev/null; then
        if docker_compose_version="$(docker-compose version --short)"; then
            version=(${docker_compose_version//./ })
            if [ ${version[0]} -lt 1 ] || [ ${version[1]} -lt 14 ]; then
                echo -e "\nWrong docker-compose version: $docker_compose_version. \nPlease install at least version 1.14.0.\n"
                print_docker_compose_install_instructions
                exit 1
            fi
        else
            echo -e "\nThe call 'docker-compose version --short' exited with a non-zero value.\n"
            exit 1
        fi
    else
        echo -e "\nDocker-compose is not installed.\nPlease install at least version 1.14.0\n"
        print_docker_compose_install_instructions
        exit 1
    fi
}

function print_docker_install_instructions {
    echo -e "The bash script you have called and the whole breakout-techstack rely heavily on docker.
Hence, you need to install docker in a version >=1.13.
Check for instruction here: https://docs.docker.com/engine/installation/\n"
}

function check_docker {
    if which docker 1>/dev/null; then
        if docker_api_version=$(docker version --format '{{.Client.Version}}'); then
            version=(${docker_api_version//./ })
            if [ ${version[0]} -lt 17 ]; then
                if [ ${version[0]} -lt 1 ] || [ ${version[1]} -lt 13 ]; then
                    echo -e "\nWrong docker version: $docker_api_version. \nPlease install at least version 1.13.\n"
                    print_docker_install_instructions
                    exit 1
                fi
            fi
        else
            echo -e "\nThe call 'docker version --format '{{.Client.Version}}' exited with a non-zero value.\n"
            exit 1
        fi
    else
        echo -e "\nDocker is not installed.\nPlease install at least version 1.13.\n"
        print_docker_install_instructions
        exit 1
    fi
}

check_docker
check_docker_compose
