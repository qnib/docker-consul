#!/bin/bash

# collection of function that help with scripting
function wait_for_srv {
    nmap 127.0.0.1 -p 8500|grep open >/dev/null
    if [ $? -ne 0 ];then
        echo -n "1"
        sleep 1
        wait_for_srv ${1}
    fi
    curl -s localhost:8500/v1/catalog/services|jq . 1>/dev/null 2>/dev/null
    if [ $? -ne 0 ];then
        echo -n "2"
        sleep 1
        wait_for_srv ${1}
    fi
    if [ $(curl -s localhost:8500/v1/catalog/service/${1}${DC}|jq ". | length") -eq 0 ];then
        echo -n "3"
        sleep 1
        wait_for_srv ${1}
    else
        echo "OK"
    fi
}

