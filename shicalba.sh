#!/bin/bash

source dialog_functions.sh

## reset the temporary files at each start
rm -rf /tmp/shicalba-temp
mkdir /tmp/shicalba-temp
if [[ ! "$?" = "0" ]]; then
	echo "You don't have the right to do any changes in /tmp directory. Exiting..."
	exit 1
fi


if (( $#==0 )); then # new event will be created
	new_event
else # an event will be edited or will be reported
	if [[ "$1" = "-e" ]]; then # open in edit mode
		edit_event -e "$2"
	elif [[ "$1" = "-r" ]]; then # open in report mode
		edit_event -r "$2"
	else
		echo "Wrong arguments."
		echo "Usage: ./shicalba.sh [-er] [filename]"
	fi
fi
