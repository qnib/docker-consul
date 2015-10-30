#!/bin/bash

# collection of function that help with scripting
function wait_for_srv {
    if [ $(curl -s localhost:8500/v1/catalog/service/${1}${DC}|jq ". | length") -eq 0 ];then
        echo -n "."
        sleep 1
        wait_for_srv ${1}
    else
        echo "OK"
    fi
}

