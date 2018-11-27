# rotate-backup

USAGE:

$ rotate-backup.sh /full/path/to/backupfile

This script checks if the specified backup file exists,
and if it was modified within the specified amount of days (default=1),
it renames the file, appending the date modified to the end,
then removes any files matching the specified path that are older than X 
amount of days (default=10).

Must provide full path to file.

OPTIONS:
-r Specify Rentention period in days (default is $RETENTION)

-h Specify healthchecks.io URL to ping

-m Specify expected days file has been modified within (eg. if backup is done weekly, specify 7 days. Default is $FILEAGE)

EXAMPLES:

$ rotate-backup.sh /path/to/file


$ rotate-backup.sh -m 7 /path/to/file


$ rotate-backup.sh -h https://hc-ping.com/your-uuid-here /path/to/file


$ rotate-backup.sh -r 30 https://hc-ping.com/your-uuid-here /path/to/file
