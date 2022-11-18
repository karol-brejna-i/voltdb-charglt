#!/bin/sh

. $HOME/.profile

cd
cd voltdb-charglt/ddl

sqlcmd --servers=vdb1 < create_db.sql

java -jar $HOME/bin/addtodeploymentdotxml.jar vdb1,vdb2,vdb3 deployment $HOME/voltdb-charglt/scripts/export_and_import.xml

cd ../jars
java -jar CreateChargingDemoData.jar vdb1,vdb2,vdb3 5000000 30 100000
