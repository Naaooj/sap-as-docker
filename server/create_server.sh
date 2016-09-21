#!/bin/bash

# This bash is responsible of the creation of the SAP server using the srcbuildres command

. /opt/sap/SYBASE.sh

# Create the sybase instance
su -l sybase -c ". $SYBASE/SYBASE.sh; $SYBASE/$SYBASE_ASE/bin/srvbuildres -r /tmp/adaptive_server.rs"

# Changing the default character set
charset -Usa -SASE -Psybase binary.srt utf8
isql -Usa -Psybase -SASE -J iso_1 << EOF
sp_configure 'default character set', 190
go
sp_configure 'default sortorder id', 50
go
shutdown
go
EOF

# Start and stop twice the server(http://infocenter.sybase.com/help/index.jsp?topic=/com.sybase.infocenter.dc31654.1570/html/sag1/sag1519.htm)
# and then perform os operations while the instance is stopped
sh /tmp/start_stop_server.sh start
sh /tmp/start_stop_server.sh stop
sh /tmp/start_stop_server.sh start
sh /tmp/start_stop_server.sh stop

# Overwrite the default interfaces file to force 0.0.0.0 instead of 127.0.0.1 otherwise the db server will not be listen outside the container
yes | cp /tmp/interfaces $SYBASE/interfaces

# Change the permission to sybase for the created instance
chown -R sybase:sybase $SYBASE

echo 'The ASE server has been created'

echo 'Starting the ASE instance'

sh /tmp/start_stop_server.sh start

echo 'Waiting for server to start in order to create the default schema, login and user'

isql=( isql -Usa -SASE -Psybase )

for i in {30..0}; do
	if echo 'SELECT 1 go' | "${isql[@]}" &> /dev/null; then
		break;
	fi
	echo 'ASE init process in progress'
	sleep 1
done

echo 'ASE is started, executing bootstrap script'

isql -Usa -SASE -Psybase < /tmp/bootstrap.sql
