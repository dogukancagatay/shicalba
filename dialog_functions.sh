#!/bin/bash

source functions.sh

function new_event() {
	declare -i cnt=1

	while [[ cnt -lt 10 ]]
	do
	
		if [[ $cnt = "1" ]]
		then
			dialog --inputbox "Enter event name:" 8 40 2>/tmp/temp
			cntl="`echo $?`"
		
			eventName=`cat /tmp/temp`
	
			if [[ $cntl = "1" ]]
			then
				exit
			fi
		fi
	
		if [[ $cnt = "2" ]]
		then
			dialog --inputbox "Enter location:" 8 40 2>/tmp/temp
			cntl="`echo $?`"
	
			location=`cat /tmp/temp`
	
			if [[ $cntl = "1" ]]
			then
				let cnt=cnt-2
			fi
		fi
	
		if [[ $cnt = "3" ]]
		then
			zones=`modifiedZones`
			dialog --radiolist "Select your continent" 100 100 20 $zones 2>/tmp/temp
			cntl="`echo $?`"
	
			continent=`cat /tmp/temp`
			userZone=$continent
	
			if [[ $cntl = "1" ]]
			then
				let cnt=cnt-2
			fi
		fi	
	
		if [[ $cnt = "4" ]]
		then
			allRegion=`modifyZones`
			dialog --radiolist "Select your region" 100 100 20 $allRegion 2>/tmp/temp
			cntl="`echo $?`"
								
			region=`cat /tmp/temp`
	
			if [[ $cntl = "1" ]]
			then
				let cnt=cnt-2
			fi		
		fi	
	
		if [[ $cnt = "5" ]]
		then
			year=`date "+%Y"`
			month=`date "+%m"`
			day=`date "+%d"`
									
			dialog --stdout --title "Calendar" --calendar "Select start date of event:" 0 0 $day $month $year >/tmp/temp
			cntl="`echo $?`"
						
			startDate=`cat /tmp/temp`
			
			if [[ $cntl = "1" ]]
			then
				let cnt=cnt-2
			fi
		fi	
	
		if [[ $cnt = "6" ]]
		then
			sed -n "${cnt}p" cal_dialog.tmp >/tmp/temp
	
			day=`nawk -F'[/]' '{print $1}' /tmp/temp`
			month=`nawk -F'[/]' '{print $2}' /tmp/temp`
			year=`nawk -F'[/]' '{print $3}' /tmp/temp`		
	
			dialog --stdout --title "Calendar" --calendar "Select end date of event:" 0 0 $day $month $year > /tmp/temp
			cntl="`echo $?`"
			
			endDate=`cat /tmp/temp`
			
			if [[ $cntl = "1" ]]
			then
				let cnt=cnt-2
			fi
		fi	
	
		if [[ $cnt = "7" ]]
		then
			dialog --stdout --title "Event time" --timebox "Event Starting time:" 0 0 >/tmp/temp
			cntl="`echo $?`"
		
			startTime=`cat /tmp/temp`
			
			if [[ $cntl = "1" ]]
			then
				let cnt=cnt-2
			fi
		fi	
	
		if [[ $cnt = "8" ]]
		then
			dialog --stdout --title "Event time" --timebox "Event Ending time:" 0 0 >/tmp/temp
			cntl="`echo $?`"
			endTime=`cat /tmp/temp`
	
			if [[ $cntl = "1" ]]
			then
				let cnt=cnt-2
			fi
		fi
	
		if [[ $cnt = "9" ]]
		then
			dialog --inputbox "Enter notes:" 8 40 2>/tmp/temp
			cntl="`echo $?`"
			notes=`cat /tmp/temp`
	
			if [[ $cntl = "1" ]]
			then
				let cnt=cnt-2
			fi
		fi
	
		
		let cnt=cnt+1
	done

	rm -rf /tmp/shicalba-temp
	mkdir /tmp/shicalba-temp
	if [[ ! "$?" = "0" ]]; then
		echo "You don't have the right to do any changes in /tmp directory. Exiting..."
		exit 1
	fi

	echo "$eventName">/tmp/shicalba-temp/draft
	echo "$location">>/tmp/shicalba-temp/draft
	echo "$userZone">>/tmp/shicalba-temp/draft
	echo "$region">>/tmp/shicalba-temp/draft
	echo "$startDate">>/tmp/shicalba-temp/draft
	echo "$startTime">>/tmp/shicalba-temp/draft
	echo "$endDate">>/tmp/shicalba-temp/draft
	echo "$endTime">>/tmp/shicalba-temp/draft
	echo "$notes">>/tmp/shicalba-temp/draft
}

function edit_event() {
	

	
	if [[ "$1" = "-e" ]]; then

	readIcsFile -f "$2"
	
	declare -i cnt=1
	
	while [[ cnt -lt 10 ]]
	do
	
		if [[ $cnt = "1" ]]
		then
			eventName=`sed -n "${cnt}p" cal_dialog.tmp`
			dialog --inputbox "Enter event name:" 8 40 $eventName 2>/tmp/temp
			cntl=`echo $?`
	
			eventName=`cat /tmp/temp`
	
			if [[ $cntl = "1" ]]
			then
				exit
			fi
		fi
	
		if [[ $cnt = "2" ]]
		then
			location=`sed -n "${cnt}p" cal_dialog.tmp`
			dialog --inputbox "Enter location:" 8 40 $location 2>/tmp/temp
			cntl=`echo $?`
	
			location=`cat /tmp/temp`
	
			if [[ $cntl = "1" ]]
			then
				let cnt=cnt-2
			fi
		fi
	
		if [[ $cnt = "3" ]]
		then
			sed -n "${cnt}p" cal_dialog.tmp >/tmp/temp2
	
			day=`nawk -F'[/]' '{print $1}' /tmp/temp2`
			month=`nawk -F'[/]' '{print $2}' /tmp/temp2`
			year=`nawk -F'[/]' '{print $3}' /tmp/temp2`		
			
			dialog --stdout --title "Calendar" --calendar "Select start date of event:" 0 0 $day $month $year > /tmp/temp
			cntl=`echo $?`
	
			startDate=`cat /tmp/temp`
	
			if [[ $cntl = "1" ]]
			then
				let cnt=cnt-2
			fi
		fi	
	
		if [[ $cnt = "4" ]]
		then
			sed -n "${cnt}p" cal_dialog.tmp >/tmp/temp2
	
			continent=`nawk -F'[/]' '{print $1}' /tmp/temp2`
			region=`nawk -F'[/]' '{print $2}' /tmp/temp2`
			
			zones=`modifiedZonesWithContinent $continent`
			dialog --radiolist "Select your continent" 100 100 20 $zones 2>/tmp/temp
			cntl=`echo $?`
	
			continent=`cat /tmp/temp`
	
			if [[ $cntl = "1" ]]
			then
				let cnt=cnt-2
			else
				exactLocation=$continent/$region
				allRegion=`modifyZonesWithRegion $exactLocation`
				dialog --radiolist "Select your region" 100 100 20 $allRegion 2>/tmp/temp
				cntl=`echo $?`
	
				region=`cat /tmp/temp`
				
				if [[ $cntl = "1" ]]
				then
					let cnt=cnt-2
				fi
			fi
				
		fi	
	
		if [[ $cnt = "5" ]]
		then
			sed -n "${cnt}p" cal_dialog.tmp >/tmp/temp
	
			hour=`nawk -F'[:]' '{print $1}' /tmp/temp`
			minute=`nawk -F'[:]' '{print $2}' /tmp/temp`
			second=`nawk -F'[:]' '{print $3}' /tmp/temp`
	
			dialog --stdout --title "Event time" --timebox "Event Starting time:" 0 0 $hour $minute $second >/tmp/temp
			cntl="`echo $?`"
		
			startTime=`cat /tmp/temp`
			
			if [[ $cntl = "1" ]]
			then
				let cnt=cnt-2
			fi
		fi	
	
		if [[ $cnt = "6" ]]
		then
			sed -n "${cnt}p" cal_dialog.tmp >/tmp/temp
	
			day=`nawk -F'[/]' '{print $1}' /tmp/temp`
			month=`nawk -F'[/]' '{print $2}' /tmp/temp`
			year=`nawk -F'[/]' '{print $3}' /tmp/temp`		
	
			dialog --stdout --title "Calendar" --calendar "Select end date of event:" 0 0 $day $month $year > /tmp/temp
			cntl="`echo $?`"
			
			endDate=`cat /tmp/temp`
			
			if [[ $cntl = "1" ]]
			then
				let cnt=cnt-2
			fi
		fi	
	
		if [[ $cnt = "8" ]]
		then
			sed -n "${cnt}p" cal_dialog.tmp >/tmp/temp
	
			hour=`nawk -F'[:]' '{print $1}' /tmp/temp`
			minute=`nawk -F'[:]' '{print $2}' /tmp/temp`
			second=`nawk -F'[:]' '{print $3}' /tmp/temp`
	
			dialog --stdout --title "Event time" --timebox "Event ending time:" 0 0 $hour $minute $second >/tmp/temp
			cntl="`echo $?`"
		
			endTime=`cat /tmp/temp`
			
			if [[ $cntl = "1" ]]
			then
				let cnt=cnt-3
			fi
		fi	
	
		if [[ $cnt = "9" ]]
		then
			notes=`sed -n "${cnt}p" cal_dialog.tmp`
	
			dialog --inputbox "Enter notes:" 8 40 "$notes" 2>/tmp/temp
			cntl="`echo $?`"
	
			notes=`cat /tmp/temp`
	
			if [[ $cntl = "1" ]]
			then
				let cnt=cnt-2
			fi
		fi
	
		
		let cnt=cnt+1
	done
		
	echo "$eventName">/tmp/shicalba-temp/draft
	echo "$location">>/tmp/shicalba-temp/draft
	echo "$continent">>/tmp/shicalba-temp/draft
	echo "$region">>/tmp/shicalba-temp/draft
	echo "$startDate">>/tmp/shicalba-temp/draft
	echo "$startTime">>/tmp/shicalba-temp/draft
	echo "$endDate">>/tmp/shicalba-temp/draft
	echo "$endTime">>/tmp/shicalba-temp/draft
	echo "$notes">>/tmp/shicalba-temp/draft
	
	readTheFileFromDialogAndWriteToIcs
	clear
	
	elif [[ "$1" = "-r" ]]; then
		readIcsFile -r "$2"
	else
		echo "whong choice"
	fi

}

