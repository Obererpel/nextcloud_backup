#!/bin/sh

CONFIG_FILE_NAME="nextcloud_backup.conf"

OK=0
ERROR_CONFIG_FILE_UNAVAILABLE=1
ERROR_COULD_NOT_SET_MAINTENANCE_MODE=2

ERROR='\033[0;31m'
WARN='\033[1;33m'
INFO='\033[0;32m'
TIME='\033[0;36m'
NC='\033[0m'

function log()
{
  TIMESTAMP="$TIME$(date +%Y-%m-%d\ %H:%M:%S)$NC"
  if [ "$2" == "$ERROR" ]; then
    echo -e "$TIMESTAMP $ERROR$1$NC" 1>&2
  elif [ "$2" == "" ]
  then
    echo -e "$TIMESTAMP $INFO$1$NC"
  else
    echo -e "$TIMESTAMP $2$1$NC"
  fi
}

function log_error()
{
  log $1 $ERROR
}

function load_config_file()
{
  log "Loading config file"
  . ./$CONFIG_FILE_NAME 2> /dev/null

  if [ $? -ne 0 ]; then
    log_error "Could not find config file $CONFIG_FILE_NAME";
    exit ERROR_CONFIG_FILE_UNAVAILABLE;
  fi
  log "Successfully loaded config file"
}

function get_date()
{
  DATE=$(date +"%Y-%m-%d")
  YEAR=$(echo $DATE  | cut --delimiter=- -f1)
  MONTH=$(echo $DATE  | cut --delimiter=- -f2)
}

function prepare_target_directory()
{
  mkdir $TARGET_FOLDER

  TARGET_FOLDER="$TARGET_FOLDER/$YEAR"
  mkdir $TARGET_FOLDER

  TARGET_FOLDER="$TARGET_FOLDER/$MONTH"
  mkdir $TARGET_FOLDER
}

function set_maintenance_mode()
{
  if [ $1 -eq 1 ]; then
    log "Enable maintenance mode"
    php occ maintenance:mode --on
  else
    log "Disable maintenance mode"
    php occ maintenance:mode --off
  fi

  if [ $? -ne 0 ]; then
    log_error "Could not set maintenance mode";
    exit $ERROR_COULD_NOT_SET_MAINTENANCE_MODE
  fi
}

function set_maintenance_mode_via_config()
{
  if [ $1 -eq 1 ]; then
    log "Enable maintenance mode by modifying $NEXTCLOUD_CONFIG_FILE"
    sed --in-place --regexp-extended\
    --expression="s/'maintenance' => (true|false),/'maintenance' => true,/g" $NEXTCLOUD_CONFIG_FILE
  else
    log "Disable maintenance mode by modifying $NEXTCLOUD_CONFIG_FILE"
    sed --in-place --regexp-extended\
    --expression="s/'maintenance' => (true|false),/'maintenance' => false,/g" $NEXTCLOUD_CONFIG_FILE
  fi
}

function backup_web_directory()
{
  log "Backing up web directory"

  snar_file="$TARGET_FOLDER/$TARGET_FILE_WEB.snar"
  archive_file="$TARGET_FOLDER/$DATE-$TARGET_FILE_WEB.tar.gz"
  log "Target: $archive_file"

  tar --create --gzip --file=$archive_file $NEXTCLOUD_WEB_DIRECTORY\
      --exclude=$NEXTCLOUD_DATA_DIRECTORY\
      --listed-incremental="$snar_file"
  create_checksum $archive_file
}

function backup_data_directory()
{
  log "Backing up data directory"

  snar_file="$TARGET_FOLDER/$TARGET_FILE_DATA.snar"
  archive_file="$TARGET_FOLDER/$DATE-$TARGET_FILE_DATA.tar.gz"
  log "Target: $archive_file"

  tar --create --gzip --file=$archive_file $NEXTCLOUD_DATA_DIRECTORY\
      --listed-incremental="$snar_file"
  create_checksum $archive_file
}

function backup_database()
{
  log "Backing up database"

  archive_file="$TARGET_FOLDER/$DATE-$TARGET_FILE_DB.sql.gz"
  log "Target: $archive_file"

  mysqldump $DB_NAME -h $DB_HOST --single-transaction | gzip -c > $archive_file
  create_checksum $archive_file
}

function create_checksum()
{
   log "Creating md5 checksum for $1"
   md5sum $1 >> MD5SUM
}

load_config_file
get_date
prepare_target_directory

cd $NEXTCLOUD_WEB_DIRECTORY

set_maintenance_mode_via_config 1
backup_database
backup_web_directory
backup_data_directory
set_maintenance_mode_via_config 0

exit $OK
