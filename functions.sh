#!/bin/bash

##find all Timezones in the computer
function findAllTimeZones() {
	
	for i in $(ls /usr/share/zoneinfo) 
	do
		if [[ -d /usr/share/zoneinfo/$i ]]; then
			for j in $(ls /usr/share/zoneinfo/$i)
			do
				echo "$i/$j"
			done
		fi
	done
}

#findAllTimeZones

## find Timezone hour set (args; $1 : timezone ex:America/Los_Angeles)
function findTimeZoneHourSet() {
	export TZ=America/Los_Angeles
	#export TZ=$1
	declare -i TZHOUR=$(date +%H) 
	declare -i UTCHOUR=$(date -u +%H)
	let RESULT=$TZHOUR-$UTCHOUR
	echo $RESULT
	
}

#findTimeZoneHourSet

## create icalendar datetime $1:day $2:month $3: year $4:hour $5:minute
## if no argument exists output will be the current datetime
## if only 1 argument exists it creates date for DTSTAMP
## if 3 arguments exist hour and minute values are 0
function createIcalendarDatetime() {
	if (( $#==0 )); then
		DATEFIELD=$(date +%Y%m%d)
		HOURFIELD=$(date +%H%M%S)
	elif (( $#==1 )); then
		DATEFIELD=$(date +%Y%m%d)
		HOURFIELD="000000"
	elif (( $#==3 )); then
		DATEFIELD="$3$2$1"
		HOURFIELD="000000"
	else
		DATEFIELD="$3$2$1"
		HOURFIELD="$4$5""00"
	fi
	
	ICALDATETIME="$DATEFIELD""T""$HOURFIELD""Z"
	echo $ICALDATETIME
}

#createIcalendarDatetime
#createIcalendarDatetime 03 04 2011
#createIcalendarDatetime 03 04 2011 13 22

## create icalendar UID
function createIcalendarUID() {
	#export -f createIcalendarDatetime
	NOW=$(createIcalendarDatetime)
	echo "$NOW""-""$(date | shasum | head -c 7)""-""$(echo $LOGNAME | shasum | head -c 2)""@""$(echo $HOSTNAME | shasum | head -c 3)"
}

createIcalendarUID

## create icalendar DTSTAMP
function createIcalendarDTSTAMP() {
	DATETIME=$(createIcalendarDatetime DTSTAMP)
	echo $DATETIME
}

createIcalendarDTSTAMP
