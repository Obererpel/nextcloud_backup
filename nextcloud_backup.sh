#!/bin/sh

CONFIG_FILE_NAME="nextcloud_backup.conf"

ERROR_CONFIG_FILE_UNAVAILABLE=1

function load_config_file()
{
  echo "Loading config file"
  . ./$CONFIG_FILE_NAME 2> /dev/null

  if [ $? -ne 0 ]; then
    echo "Could not find config file $CONFIG_FILE_NAME";
    exit ERROR_CONFIG_FILE_UNAVAILABLE;
  fi
  echo "Successfully loaded config file"
}

function set_maintenance_mode(){
  if [ $1 -eq 1 ]; then
    echo "Enable maintenance mode"
    php occ maintenance:mode --on
  else
    echo "Disable maintenance mode"
    php occ maintenance:mode --off
  fi
}

load_config_file

cd $nextcloud_directory

set_maintenance_mode 1

set_maintenance_mode 0
