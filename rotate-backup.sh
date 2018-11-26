#!/bin/bash
FILE="/source/"
HEALTHCHECKSURL=""
RETENTION=10
FILEAGE=1

#### Display command usage ########
usage()
{
cat << EOF
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
-a Specify expected age of file in days (eg. if backup is done weekly, specify 7 days. Default is $FILEAGE)

EXAMPLES:
$ rotate-backup.sh /path/to/file

$ rotate-backup.sh -a 7 /path/to/file

$ rotate-backup.sh -h https://hc-ping.com/your-uuid-here /path/to/file

$ rotate-backup.sh -r 30 https://hc-ping.com/your-uuid-here /path/to/file

EOF
}

#### Getopts #####
while getopts ":r::h::a:" opt; do
case $opt in
r) RETENTION=${OPTARG};;
h) HEALTHCHECKSURL=${OPTARG};;
a) FILEAGE=${OPTARG};;
\?) echo "$OPTARG is an unknown option" >&2
usage
exit 1
;;
:) echo "Option $OPTARG requires an argument" >&2
usage
exit 1
;;
esac
done
 
shift $((OPTIND-1))
if [ -z "$1" ]; then
	usage
else

#### Set Variables ####
FILE=$1
CREATIONDATE=$(date -r "$FILE" +%F)
FILECHECK=$(find "$FILE" -mtime -"$FILEAGE" -print)

#### If creation date is today, rotate file and ping healhchecks.io ####
if [ -n "$FILECHECK" ]; then
	echo "Expected file age set to: $FILEAGE"
	echo "$FILE exists and was modified on $CREATIONDATE"
	#Rename file
	cp "$FILE" "$FILE-$CREATIONDATE"
	echo "$FILE copied to $FILE-$CREATIONDATE"
	    #Ping health checks if option is specified
	    if [ -n "$HEALTHCHECKSURL" ]; then
	        echo "Pinging: $HEALTHCHECKSURL"
	        curl -s -o /dev/null --retry 3 "$HEALTHCHECKSURL"
	        echo "healthchecks.io pinged via $HEALTHCHECKSURL"
	    fi
	#Remove backups older than retention
	echo "File retention set to $RETENTION"
	echo "Deleting any files matching $FILE* that are older than $RETENTION days"
	find "$FILE"* -mtime +"$RETENTION" -exec rm {} \;
elif [ ! -f "$FILE" ]; then
	echo "File $FILE does not exist... Did not ping healthchecks.io. :("
else
	echo "Expected file age set to: $FILEAGE"
	echo "File $FILE found, but was not modified $FILEAGE days ago or less... Did not rename file or ping healthchecks.io. :("
fi
fi
