#!/bin/bash

flac=/usr/bin/flac
flaclist=/tmp/flaclist
temp_file=/tmp/temp_file

if [ ! -f "$flaclist" ];
then
	echo "creating FLAC list"
        find "." -type f -iname "*.flac" > $temp_file
        sort $temp_file > $flaclist
        rm $temp_file
fi

echo "Files to process:  " $(wc -l $flaclist), press CTRL-C at any time to interrupt

while [ -s $flaclist ] ; do
    file=$(head -1 $flaclist)
    if ! $flac -t --silent --warnings-as-errors "$file" ; then
        echo $file corrupt  >> /tmp/corrupted_flac
        echo Corrupt: $file
    fi
    # remove current file from list
    sed -i.prev '1d' $flaclist
done
rm $flaclist.prev
rm $flaclist
