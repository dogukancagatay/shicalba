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

## create icalendar datetime for now
function createIcalendarDatetimeNow() {
	
	DATEFIELD=$(date +%Y%m%d)
	HOURFIELD=$(date +%H%M%S)
	ICALDATETIME="$DATEFIELD""T""$HOURFIELD""Z"
	echo $ICALDATETIME
}

## create icalendar UID
function createIcalendarUID() {
	export -f createIcalendarDatetimeNow
	NOW=$(createIcalendarDatetimeNow)
	echo "$NOW""-""$(date | shasum | head -c 7)""-@""$(echo $LOGNAME | shasum | head -c 5)"
}

createIcalendarUID


