#!/bin/bash

# This is the entrypoint of the container, every script
# in the /docker-entrypoint.d will be executed

DIR=/docker-entrypoint.d

if [[ -d "$DIR" ]]
then
	echo "Executing script in folder $DIR"
	for SCRIPT in $DIR/*
	do
		if [ -f $SCRIPT -a -x $SCRIPT ]
		then
			$SCRIPT
		else
			echo "The script $SCRIPT is not executable"
		fi
	done
fi

# Execute the command passed through CMD of the Dockerfile or command when creating a container
exec "$@"

