-- Set the current database to master
use master
go

-- Create the database dockerized
create database dockerdb
go

-- Create a "dockerdb_login" login with a "sybase" password and set his default database
-- This instruction must be executed on master database
create login dockerdb_login with password dockerdb1234 default database dockerdb
go

-- Set the current database to dockerdb
use dockerdb
go

-- Create for the "dockerdb_login" login the "dockerdb" user in the database (applyed on the current database)
sp_adduser dockerdb_login, dockerdb
go

-- Grant all permission on database with grant
grant all
to dockerdb 
go

-- Add the 'select into' option which may be required by certain orm
use master
go

sp_dboption dockerdb, 'select into', true
go