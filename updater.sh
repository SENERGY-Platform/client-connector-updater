#!/bin/bash

#   Copyright 2018 InfAI (CC SES)
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

gup_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
gw_dir="$(dirname "$gup_dir")"
home_dir="$HOME"
pyenvs_dir=.pyenv

source $gup_dir/logger.sh

task_file=gupfile

reboot_flag=0

echo "*********** starting client-connector-updater 0.10.2 ***********" | log

for dir in $(cd $gw_dir && ls -d */); do
    path=$gw_dir/${dir%/}
    if [ -e "$path/$task_file" ]; then
        echo "(${dir%/}) checking for updates ..." | log
        update_result=$(cd "$path" && git remote update 3>&1 1>&2 2>&3 >/dev/null)
        if ! [[ $update_result = *"fatal"* ]] || ! [[ $update_result = *"error"* ]]; then
            status_result=$(cd "$path" && git status)
            if [[ $status_result = *"behind"* ]]; then
                echo "(${dir%/}) downloading and applying updates ..." | log
                pull_result=$(cd "$path" && git pull 3>&1 1>&2 2>&3 >/dev/null)
                if ! [[ $pull_result = *"fatal"* ]] || ! [[ $pull_result = *"error"* ]]; then
                    echo "(${dir%/}) update success" | log
                    reboot_flag=1
                else
                   echo "(${dir%/}) $pull_result" | log
                fi
            fi
        else
            echo "(${dir%/}) $update_result" | log
        fi
        echo "(${dir%/}) checking dependencies ..." | log
        if ! [ -z "$path/$task_file" ]; then
            while IFS="," read -r pkg new_ver; do
                cur_ver=$($home_dir/$pyenvs_dir/${dir%/}/bin/python -m pip show $pkg | grep Version)
                if ! [[ $cur_ver = *"$new_ver"* ]]; then
                    echo "(${dir%/}) '$pkg' -> $new_ver" | log
                    if [[ $pkg = *"client-connector-lib"* ]]; then
                        inst_result=$($home_dir/$pyenvs_dir/${dir%/}/bin/python -m pip install --upgrade git+https://github.com/SENERGY-Platform/client-connector-lib.git@v$new_ver)
                    else
                        inst_result=$($home_dir/$pyenvs_dir/${dir%/}/bin/python -m pip install --upgrade $pkg==$new_ver)
                    fi
                    if [[ $inst_result = *"Success"* ]]; then
                        echo "(${dir%/}) '$pkg' update success" | log
                        reboot_flag=1
                    else
                        echo "(${dir%/}) '$pkg' $inst_result" | log
                    fi
                fi
            done < $path/$task_file
        fi
    fi
done
if [ "$reboot_flag" -eq "1" ]; then
    echo "gateways updated - reboot required" | log
    echo "rebooting in 15s ..." | log
    sleep 15
    sudo reboot
else
    echo "all gateways up to date - exit" | log
    exit 0
fi