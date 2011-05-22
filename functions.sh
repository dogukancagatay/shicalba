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


## create icalendar created field
## creates the content for created field using date time info right now
function createIcalendarCREATED() {
	
	DATEFIELD=$(date +%Y%m%d)
	HOURFIELD=$(date +%H%M%S)	
	ICALDATETIME="$DATEFIELD""T""$HOURFIELD""Z"
	echo $ICALDATETIME
}
#createIcalendarCREATED

## create icalendar datetime $1:day $2:month $3: year $4:hour $5:minute
function createIcalendarDatetime() {
	DATEFIELD="$3$2$1"
	HOURFIELD="$4$5"
	ICALDATETIME="$DATEFIELD""T""$HOURFIELD"
	echo $ICALDATETIME
}

#createIcalendarDatetime 03 04 2011 00 00
#createIcalendarDatetime 03 04 2011 13 22

## create icalendar UID
function createIcalendarUID() {
	#export -f createIcalendarDatetime
	NOW=$(createIcalendarCREATED)
	echo "$NOW""-""$(date | shasum | head -c 7)""-""$(echo $LOGNAME | shasum | head -c 2)""@""$(echo $HOSTNAME | shasum | head -c 3)"
}

#createIcalendarUID

## create icalendar DTSTAMP
function createIcalendarDTSTAMP() {
	DATEFIELD=$(date +%Y%m%d)
	HOURFIELD=$(date -u +%H%M%S)	
	ICALDATETIME="$DATEFIELD""T""$HOURFIELD""Z"
	echo $ICALDATETIME
}

#createIcalendarDTSTAMP

## converts normal date format to Icalendar format
## 12/12/2012 to icalendar format $1 is the date $2 is the time
function normalDateToIcalendar() {
	NDATE=$1
	NTIME=$2
	DAY=${NDATE%/*/*}
	MONTH=${NDATE%/*}
	MONTH=${MONTH#*/}
	YEAR=${NDATE#*/*/}
	HOUR=${NTIME%:*:*}
	MINUTE=${NTIME%:*}
	MINUTE=${MINUTE#*:}
	#SECOND=${NTIME#*:*:}
	
	DATEFIELD="$YEAR$MONTH$DAY"
	HOURFIELD="$HOUR$MINUTE""00"
	ICALDATETIME="$DATEFIELD""T""$HOURFIELD""Z"
	echo $ICALDATETIME
}


## readTheFileFromDialog reads the file that dialog interface has created temporarily and changes it into Icalendar format
## takes no argument
function readTheFileFromDialogAndWriteToIcs() {
	EVENTNAME=$(head -1 /tmp/draft | tail -1)
	LOCATION=$(head -2 /tmp/draft | tail -1)
	TIMEZONE=$(head -3 /tmp/draft | tail -1)
	FROMDATE=$(head -4 /tmp/draft | tail -1)
	FROMTIME=$(head -5 /tmp/draft | tail -1)
	TODATE=$(head -6 /tmp/draft | tail -1)
	TOTIME=$(head -7 /tmp/draft | tail -1)
	NOTE=$(head -8 /tmp/draft | tail -1)
	
	CALUID=$(createIcalendarUID)
	
	echo "BEGIN:VCALENDAR" > /tmp/temp_cal.ics.tmp
	echo "VERSION:2.0" >> /tmp/temp_cal.ics.tmp
	echo "PRODID:-//Shicalba .//shicalba 1.0.0//EN" >> /tmp/temp_cal.ics.tmp
	echo "CALSCALE:GREGORIAN" >> /tmp/temp_cal.ics.tmp
	echo "BEGIN:VEVENT" >> /tmp/temp_cal.ics.tmp
	echo "CREATED:""$(createIcalendarCREATED)" >> /tmp/temp_cal.ics.tmp
	echo "UID:""$CALUID" >> /tmp/temp_cal.ics.tmp
	echo "DTEND;TZID=""$TIMEZONE"":""$(normalDateToIcalendar $FROMDATE $FROMTIME)" >> /tmp/temp_cal.ics.tmp
	echo "TRANSP:OPAQUE" >> /tmp/temp_cal.ics.tmp
	echo "SUMMARY:""$EVENTNAME" >> /tmp/temp_cal.ics.tmp
	echo "DTSTART;TZID=""$TIMEZONE"":""$(normalDateToIcalendar $TODATE $TOTIME)" >> /tmp/temp_cal.ics.tmp
	echo "DTSTAMP:""$(createIcalendarDTSTAMP)" >> /tmp/temp_cal.ics.tmp
	echo "LOCATION:""$LOCATION" >> /tmp/temp_cal.ics.tmp
	echo "SEQUENCE:5" >> /tmp/temp_cal.ics.tmp
	echo "DESCRIPTION:""$NOTE" >> /tmp/temp_cal.ics.tmp
	echo "END:VEVENT" >> /tmp/temp_cal.ics.tmp
	echo "END:VCALENDAR" >> /tmp/temp_cal.ics.tmp
	
	mv /tmp/temp_cal.ics.tmp event-$CALUID.ics
	rm /tmp/temp_cal.ics.tmp
	

## readIcsFile function will read and parse the ics file and will report to a file(to be used in dialog) or as report.
## $1: the ics file
## $2: -r for report output, -f for file output
function readIcsFile() {
	FILE="$1"
	$FCONTENT=$(cat $FILE)
	
	## file exist check
	if [[ ! -f $FILE ]]; then
		echo "No such file $FILE. Exiting..."
		exit 1
	fi 
	## parsing the file
	if [[ ! $(grep "BEGIN:VCALENDAR" "$FILE") ]]; then
		echo "File is not an icalendar file. Exiting..."
		exit 1
	fi
	
	if [[ ! $(echo "$FCONTENT" | grep "VERSION:2.0") ]]; then
		echo "File is not an icalendar file. Exiting..."
		exit 1
	fi
	
	if [[ ! $(echo "$FCONTENT" | grep "BEGIN:VEVENT") ]]; then
		echo "File is not an icalendar file. Exiting..."
		exit 1
	fi
	
	if [[ ! $(echo "$FCONTENT" | grep "CREATED:") ]]; then
		echo "File is not an icalendar file. Exiting..."
		exit 1
	else
		CREATED=$(echo "$FCONTENT" | grep "CREATED:")
		CREATED=${CREATED#CREATED:}
	fi
	
	if [[ ! $(echo "$FCONTENT" | grep "DTEND;TZID=") ]]; then
		echo "File is not an icalendar file. Exiting..."
		exit 1
	else
		ENDDATETIME=$(echo "$FCONTENT" | grep "DTEND;TZID=")
		TIMEZONE=${ENDDATETIME#DTEND;TZID=}
		TIMEZONE=${TIMEZONE%:*}
		ENDDATETIME=${ENDDATETIME#*$TIMEZONE:}
		ENDDATETIME=${ENDDATETIME%Z}
	fi
	
	if [[ ! $(echo "$FCONTENT" | grep "SUMMARY:") ]]; then
		echo "File is not an icalendar file. Exiting..."
		exit 1
	else
		EVENTNAME=$(echo "$FCONTENT" | grep "SUMMARY:")
		EVENTNAME=${EVENTNAME#SUMMARY:}
	fi
	
	if [[ ! $(echo "$FCONTENT" | grep "DTSTART;TZID=") ]]; then
		echo "File is not an icalendar file. Exiting..."
		exit 1
	else
		STARTDATETIME=$(echo "$FCONTENT" | grep "DTEND;TZID=")
		STARTTIMEZONE=${STARTDATETIME#DTEND;TZID=}
		STARTTIMEZONE=${STARTTIMEZONE%:*}
		STARTDATETIME=${STARTDATETIME#*$STARTTIMEZONE:}
		STARTDATETIME=${STARTDATETIME%Z}
	fi
	
	if [[ ! $(echo "$FCONTENT" | grep "DESCRIPTION:") ]]; then
		echo "File is not an icalendar file. Exiting..."
		exit 1
	else
		DESCRIPTION=$(echo "$FCONTENT" | grep "DESCRIPTION:")
		DESCRIPTION=${DESCRIPTION#DESCRIPTION:}
	fi
	
	if [[ ! $(echo "$FCONTENT" | grep "LOCATION:") ]]; then
		echo "File is not an icalendar file. Exiting..."
		exit 1
	else
		LOCATION=$(echo "$FCONTENT" | grep "LOCATION:")
		LOCATION=${LOCATION#LOCATION:}
	fi
	
	#convert ics datetime to normal date time for start time
	NSTARTDATE=${STARTDATETIME%T*}
	NSTARTYEAR=$(echo "$NSTARTDATE" | head -c 4)
	NSTARTMONTH=$(echo "$NSTARTDATE" | head -c 6 | tail -c 2)
	NSTARTDAY=$(echo "$NSTARTDATE" | tail -c 3)
	NSTARTTIME=${STARTDATETIME#*T}
	NSTARTHOUR=$(echo "$NSTARTTIME" | head -c 2)
	NSTARTMINUTE=$(echo "$NSTARTTIME" | head -c 4 | tail -c 2)
	NSTARTSECOND=$(echo "$NSTARTTIME" | tail -c 3)
	
	#for end time
	NENDDATE=${ENDDATETIME%T*}
	NENDYEAR=$(echo "$NENDDATE" | head -c 4)
	NENDMONTH=$(echo "$NENDDATE" | head -c 6 | tail -c 2)
	NENDDAY=$(echo "$NENDDATE" | tail -c 3)
	NENDTIME=${ENDDATETIME#*T}
	NENDHOUR=$(echo "$NENDTIME" | head -c 2)
	NENDMINUTE=$(echo "$NENDTIME" | head -c 4 | tail -c 2)
	NENDSECOND=$(echo "$NENDTIME" | tail -c 3)


	## report mode: will be output to the command line if and input ics file is given
	if [[ "$2" = "-r" ]]; then
		echo "Event Name: $EVENTNAME"
		echo "Event Location: $LOCATION"
		echo "Event Start Date: $NSTARTDAY/$NSTARTMONTH/$NSTARTYEAR"
		echo "Event Start Timezone: $STARTTIMEZONE"
		echo "Event Start Time: $NSTARTHOUR:$NSTARTMINUTE:$NSTARTSECOND"
		echo "Event End Date: $NSTARTDAY/$NSTARTMONTH/$NSTARTYEAR"
		echo "Event End Timezone: $TIMEZONE"
		echo "Event End Time: $NENDHOUR:$NENDMINUTE:$NENDSECOND"
		echo "Event Description: $DESCRIPTION"
	fi
	
	
	## edit mode: will be written to a file /tmp/cal_dialog.tmp and will be shown in dialog to be edited
	if [[ "$2" = "-f" ]]; then
		echo "$EVENTNAME" > /tmp/cal_dialog.tmp
		echo "$LOCATION" >> /tmp/cal_dialog.tmp
		echo "$NSTARTDAY/$NSTARTMONTH/$NSTARTYEAR" >> /tmp/cal_dialog.tmp
		echo "$STARTTIMEZONE" >> /tmp/cal_dialog.tmp
		echo "$NSTARTHOUR:$NSTARTMINUTE:$NSTARTSECOND" >> /tmp/cal_dialog.tmp
		echo "$NSTARTDAY/$NSTARTMONTH/$NSTARTYEAR" >> /tmp/cal_dialog.tmp
		echo "$TIMEZONE" >> /tmp/cal_dialog.tmp
		echo "$NENDHOUR:$NENDMINUTE:$NENDSECOND" >> /tmp/cal_dialog.tmp
		echo "$DESCRIPTION" >> /tmp/cal_dialog.tmp
	fi
}

#readIcsFile event.ics -r
