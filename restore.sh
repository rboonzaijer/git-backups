#!/bin/bash
START=$SECONDS

RESTORE_FROM_FILE=$1
EMPTY_REPOSITORY=$2

echo "-> Restore"
echo "source = $RESTORE_FROM_FILE"
echo "target = $EMPTY_REPOSITORY"

if [[ $RESTORE_FROM_FILE == *.tar.gz ]]
then
	echo "gzip compression ENABLED"
else
	if [[ $RESTORE_FROM_FILE == *.tar ]]
	then
		echo "gzip compression DISABLED"
	else
		echo "non-supported file extension (only .tar / .tar.gz are supported)"
		echo "(exit)"
		exit
	fi
fi
echo ''


# make sure the command 'pv' is available
if ! command -v pv &> /dev/null
then
    echo "'pv' could not be found, this is used to show the progress, install with 'sudo apt install pv -y'"
    exit
fi

# NOTE: Do not change this!
TEMPDIR=./repo

echo '-> ensure clean temp directory'
rm -rf $TEMPDIR && mkdir $TEMPDIR

# untar the file
if [[ $RESTORE_FROM_FILE == *.tar.gz ]]
then
	echo '-> unpack backup (gzip compression)'
	pv "$RESTORE_FROM_FILE" | tar -C . -xz
else
	echo '-> unpack backup (non-gzip compression)'
	pv "$RESTORE_FROM_FILE" | tar -C . -x
fi

echo '-> set remote-url'
git -C ./repo remote set-url origin $EMPTY_REPOSITORY

echo '-> push to repository'
git -C ./repo push -u origin --all

echo '-> cleanup'
rm -rf ./repo


# show how much time this took...
DURATION=$(( SECONDS - START ))
if (( $DURATION > 3600 )) ; then
    let "hours=DURATION/3600"
    let "minutes=(DURATION%3600)/60"
    let "seconds=(DURATION%3600)%60"
    echo "Completed in $hours hour(s), $minutes minute(s) and $seconds second(s)" 
elif (( $DURATION > 60 )) ; then
    let "minutes=(DURATION%3600)/60"
    let "seconds=(DURATION%3600)%60"
    echo "Completed in $minutes minute(s) and $seconds second(s)"
else
    echo "Completed in $DURATION seconds"
fi
