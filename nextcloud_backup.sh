#!/bin/sh

CONFIG_FILE_NAME="nextcloud_backup.conf"

ERROR_CONFIG_FILE_UNAVAILABLE=1

function load_config_file()
{
  echo "Loading config file"
  . ./$CONFIG_FILE_NAME 2> /dev/null

echo "FOO"
  if [ $? -ne 0 ]; then
    echo "Could not find config file $CONFIG_FILE_NAME";
    exit ERROR_CONFIG_FILE_UNAVAILABLE;
  fi
  echo "Successfully loaded config file"
}

load_config_file
