# nextcloud_backup
Script for backing up my nextcloud instance.

`nextcloud_backup` uses the [incremental dump functionality of GNU TAR](https://www.gnu.org/software/tar/manual/html_node/Incremental-Dumps.html) to create an incremental backup of an nextcloud instance.
The nextcloud web directory, the data directory and the database dump are considered separatly and result in a sepratate file each.

## Prerequisites
The script has to be configured using the `nextcloud_backup.conf` first.
Use `nextcloud_backup.conf.sample` as a sample.
Please be advised that the script assumes no default values for unset variables.
This might result in unpredictable behaviour.

This backup script uses standard unix/bash tools like `date`, `tar`, `cut` and `gzip`.
Additionally it needs `php` to be executable and `mysqldump`.
Please make sure, these are available.
The script does not check, if the commands are available.

As `mysqldump` is utilized to create a backup of the database and we do not want to pass the credentials via cli, `~/.my.cnf` must exist.
It should look similar to the following listing:
```
[mysqldump]
user=<user>
password=<password>
```
## Usage
Just run the script on the machine where nextcloud is installed.
At the moment parameters are neither expected nor needed.
```
sh nextcloud_backup.sh
```
## Return Codes
| Return Code | Description                     |
| ------------|---------------------------------|
| 0           | Ok                              |
| 1           | The config file is not available|
