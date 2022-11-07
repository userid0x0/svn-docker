#!/bin/bash

check_ret() {
    if [ $1 -ne 0 ]; then
        echo ""
        echo "!!! FAIL: $2"
        echo "********************************************************************************"
        echo ""
        exit $1
    else
        echo ""
        echo "*** SUCCESS: $2"
        echo "********************************************************************************"
        echo ""
    fi
}

docker rmi sea5kg/svn-server

docker build -t sea5kg/svn-server:latest .
check_ret $?


# for test run
# docker run --rm --name svn-server -p 80:80 -v `pwd`/data:/data sea5kg/svn-server
