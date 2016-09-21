#!/bin/sh

SERVER_NAME='ASE'

start() {
	START_MSG=$"Starting server ${SERVER_NAME}:"
	su -l sybase -c ". $SYBASE/SYBASE.sh; startserver -f $SYBASE/$SYBASE_ASE/install/RUN_${SERVER_NAME} > /dev/null"
	RET=$?
	
	if [ $RET -eq 0 ] 
	then
		echo "$START_MSG succeeded."
	else
		echo "$START_MSG failed."
		exit 1;
	fi
}

stop() {
	STOP_MSG=$"Stoping server ${SERVER_NAME}:"
	su -l sybase -c ". $SYBASE/SYBASE.sh; isql -Usa -S${SERVER_NAME} -Psybase < $SYBASE/$SYBASE_ASE/upgrade/shutdown.sql > /dev/null"
	RET=$?

	if [ $RET -eq 0 ] 
	then
		echo "$STOP_MSG succeeded."
	else
		echo "$STOP_MSG failed."
		exit 1;
	fi
}

case "$1" in
start)
	start
	;;
stop)
	stop
	;;
*)
	echo $"Usage: $0 {start|stop}"
	exit 1
esac

exit 0