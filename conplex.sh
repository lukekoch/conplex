#!/bin/bash

# CONPLEX - multiplexer for conda environments
# Copyright (C) 2025  Lucas Koch
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

VERSION="1.0"

print_intro() {
  echo "-----------------------------------------"
  echo "   _____                   __         "
  echo -e "  / __\e[32m°\e[0m/\e[31m~\e[0m___  ____  ____  / /__  _  __"
  echo " / /   / __ \/ __ \/ __ \/ / _ \| |/_/"
  echo "/ /___/ /_/ / / / / /_/ / /  __/>  <  "
  echo "\____/\____/_/ /_/ .___/_/\___/_/|_|  "
  echo "                /_/                   "
  echo "  https://github.com/lukekoch/conplex "
  echo ""
  echo "---- Conda Multiplexer version $VERSION ----"
  echo ""

}

list_envs() {
  (echo -e "\e[1mName\e[0m\t\e[1mVersion\e[0m\t\e[1mTags\e[0m\t\e[1mNotes\e[0m"; cut $CONPLEX_ENVS_FILE -f1,2,3,4,7) | column -s $'\t' -t -o "  |  "
}

load_env() {
    local name=$1
    # Assume latest version if no version is specified
    local tag=${2:-latest}
    while IFS=$'\t' read -r rec_name rec_version rec_status stable_commands post_load_message rec_path; do
        if [[ "$rec_name" == "$name" && ("$rec_version" == "$tag" || "$tag" == "latest")  ]]; then
        # clean rec_path
        path=$(echo "$rec_path" | xargs)
        # format command prompt prefix and activate
        CONDA_ENV_PROMPT='(\e[92mconplex\e[0m → \e[94m{name}\e[0m) ' conda activate "$path"
        
        if [ -d "$path" ] && [ -r "$path" ]; then
            echo -e "\e[41mWarning: You have write permission for this environment.\e[0m"
        fi
        echo -e "\e[34mNotes:\e[0m $post_load_message"
        echo -e "Environment is tagged $rec_status"
        return
        fi
    done < "$CONPLEX_ENVS_FILE"
    echo "Environment $name not found for version $tag."
}


function print_help() {
    echo -e "Usage:\tconplex {list|load|unload|setup|check|help} <name> <version>" >&2
    echo 
    echo -e "\tlist: list all conda environments available to conplex"
    echo -e "\tload: load an environment specified by <name> and <version> (optional)"
    echo -e "\tunload: unload the currently loaded environment"
    echo -e "\thelp: Prints this message"
    return 
}


main() {
  case "$1" in
    list)
      list_envs
      ;;
    load)
        load_env "$2" "$3"
      ;;
    unload)
      echo "Deactivating environment."
      conda deactivate
      ;;
    help)
        print_intro
        print_help
        ;;
    *)
        print_intro
        echo "Unknown command: $1. Use conplex help to see available options."
        ;;
  esac
}

main "$@"
