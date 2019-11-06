#!/bin/bash

#   Copyright 2019 InfAI (CC SES)
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

arg=$1

gup_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source $gup_dir/logger.sh

duration=$(( ( RANDOM % 120 )  + 10 ))
no_reboot=0

if ! [ -z "$arg" ]; then
    if [[ $arg = "now" ]]; then
        duration=0
        no_reboot=1
    else
        echo "unknown argument '$arg'"
        exit 1
    fi
fi

sleep $duration

wget -q -o /dev/null --tries=3 --timeout=20 --spider https://github.com/SENERGY-Platform  > /dev/null
if [[ $? -eq 0 ]]; then
    update_result=$(cd $gup_dir && git remote update 3>&1 1>&2 2>&3 >/dev/null)
    if ! [[ $update_result = *"fatal"* ]] || ! [[ $update_result = *"error"* ]]; then
        status_result=$(cd $gup_dir && git status)
        if [[ $status_result = *"behind"* ]]; then
            echo "------------------------------------------------------" | log
            echo "(gateway-updater) downloading and applying updates ..." | log
            pull_result=$(cd $gup_dir && git pull 3>&1 1>&2 2>&3 >/dev/null)
            if ! [[ $pull_result = *"fatal"* ]] || ! [[ $pull_result = *"error"* ]]; then
                echo "(gateway-updater) update success" | log
            else
               echo "(gateway-updater) $pull_result - exit" | log
               exit 1
            fi
        fi
    else
        echo "(gateway-updater) $update_result - exit" | log
        exit 1
    fi
else
    echo "no internet access - exit" | log
    exit 1
fi
sleep 5
if [[ $no_reboot = 1 ]]; then
    bash $gup_dir/updater.sh nrbt &
else
    bash $gup_dir/updater.sh &
fi
exit 0
