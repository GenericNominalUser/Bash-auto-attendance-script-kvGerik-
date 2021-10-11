#!/bin/bash
# Constants
ENDPOINT="https://kvgenovate.com/konline/keylaporan.php";
USER_NAME="YOUR NAME HERE";
USER_KAD_PENGENALAN="YOUR IC HERE";
LOGFILE="${HOME}/attendence.log";
CURRENT_BASE_DATE=`date '+%D %T'`;

# Class Code
declare -A CLASSES_CODE;
CLASSES_CODE=([KPD3024]="KPD30242SVMKPD" [KPD3033]="KPD30332SVMKPD" [KPD3014]="KPD30142SVMKPD" [BM]="A0130032SVMKPD" [PI]="A0630012SVMKPD" [MT]="A0330012SVMKPD" [BI]="A0230012SVMKPD" [SEJ]="A0530012SVMKPD" [CA]="CA32SVMKPD");
function logIntoClass { #logIntoClass $class_code
	local currentClassCode=$1;
	checkLogFile;
	sendPostQuery;
	logPostQuery;
}
function checkLogFile { #createLogFile
	if [ ! -e $LOGFILE ];then
		touch $LOGFILE;
	fi
}
function sendPostQuery { #sendPostQuery $class_code
	local userCredential="nama=${USER_NAME}&kp=${USER_KAD_PENGENALAN}&kod=${currentClassCode}";
#	echo ${userCredential};
	curl -s --fail-early --proto https -X POST -d "${userCredential}" "${ENDPOINT}">/dev/null 2>&1;
}
function logPostQuery { #logPostQuery
	if [ $? -eq 0 ]; then
		echo "Logged in succcessfully into class $currentClassCode |$CURRENT_BASE_DATE">>$LOGFILE;
	else
		echo "Logged in failed while logging into class $currentClassCode |$CURRENT_BASE_DATE">>$LOGFILE;
	fi
}

# Determine current day
currentDayOfWeek=`date -d "$CURRENT_BASE_DATE" +%w`;
currentHour=`date -d "$CURRENT_BASE_DATE" +%H`;
logIntoClass ${CLASSES_CODE[KPD3014]};

case $currentDayOfWeek in
	1) #Monday
 		case $currentHour in
 			8) #8:00am
 				logIntoClass ${CLASSES_CODE[KPD3024]};
			;;
			12) #12:00am
				logIntoClass ${CLASSES_CODE[KPD3033]};
			;;
			*)
				exit
			;;
		esac
	;;
	2) #Tuesday
		case $currentHour in
			8) #8:00am
				logIntoClass ${CLASSES_CODE[KPD3014]};
			;;
			11) #11:00am
				logIntoClass ${CLASSES_CODE[BM]};
			;;
			15) #3:00pm
				logIntoClass ${CLASSES_CODE[PI]};
			;;
			16) #4:00pm
				logIntoClass ${CLASSES_CODE[MT]};
			;;
			*)
				exit
			;;
		esac
	;;
	3) #Wednesday
		case $currentHour in
			8) #8:00am
				logIntoClass ${CLASSES_CODE[BI]};
			;;
			9) #9:00am
				logIntoClass ${CLASSES_CODE[SEJ]};
			;;
			10) #10:00am
				logIntoClass ${CLASSES_CODE[KPD3033]};
			;;
			12) #12:00am
				logIntoClass ${CLASSES_CODE[CA]};
			;;
			14) #2:00pm
				logIntoClass ${CLASSES_CODE[KPD3024]};
			;;
			*)
				exit
			;;
		esac
	;;
	4) #Thursday
		case $currentHour in
			9) #9:00am
				logIntoClass ${CLASSES_CODE[BM]};
			;;
			11) #11:00am
				logIntoClass ${CLASSES_CODE[KPD3014]};
			;;
			16) #4:00pm
				logIntoClass ${CLASSES_CODE[MT]};
			;;
			*)
				exit
			;;
		esac
	;;
	5) $Friday
		case $currentHour in
			9) #9:00am
				logIntoClass ${CLASSES_CODE[CA]};
			;;
			*)
				exit
			;;
		esac
	;;
	*) #Saturday&Sunday
		exit
	;;
esac
