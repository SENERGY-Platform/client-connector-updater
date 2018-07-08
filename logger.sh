#!/bin/bash

log() {
    first=1
    while read -r line; do
        if [ "$first" -eq "1" ]; then
            echo "[$(date +"%m.%d.%Y %I:%M:%S %p")] $line" >> gup.log 2>&1
            first=0
        else
            echo "$line" >> gup.log 2>&1
        fi
    done
}