#!/bin/bash
START=$SECONDS

REPOSITORY=$1
TARGETFILE=$2

echo "-> Backup"
echo "source = $REPOSITORY"
echo "target = $TARGETFILE"

if [[ $TARGETFILE == *.tar.gz ]]
then
	echo "gzip compression ENABLED"
else
	if [[ $TARGETFILE == *.tar ]]
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

echo '-> clone repository (--bare)'
git clone --bare $REPOSITORY $TEMPDIR


if [[ $TARGETFILE == *.tar.gz ]]
then
	echo '-> create backup (gzip compression)'
	tar cf - $TEMPDIR -P | pv -s $(du -sb $TEMPDIR | awk '{print $1}') | gzip > ${TARGETFILE}

	echo '-> filesize after compression:'
	du -h $TARGETFILE
else
	echo '-> create backup (no compression)'
	tar cf - $TEMPDIR -P | pv -s $(du -sb $TEMPDIR | awk '{print $1}') > $TARGETFILE
fi

echo '-> cleanup'
rm -rf $TEMPDIR


echo ''
DURATION=$(( SECONDS - START ))
if (( $DURATION > 3600 )) ; then
    let "hours=DURATION/3600"
    let "minutes=(DURATION%3600)/60"
    let "seconds=(DURATION%3600)%60"
    echo "completed in $hours hour(s), $minutes minute(s) and $seconds second(s)" 
elif (( $DURATION > 60 )) ; then
    let "minutes=(DURATION%3600)/60"
    let "seconds=(DURATION%3600)%60"
    echo "completed in $minutes minute(s) and $seconds second(s)"
else
    echo "completed in $DURATION seconds"
fi
