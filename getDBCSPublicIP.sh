#!/bin/bash
##
if [ $# -lt 3 ]
then
    echo "Usage: getDBCSPublicIP <OPC Identity Domain> <OPC Username> <OPC Password>"
    exit 1
fi
OPC_DOMAIN=$1
OPC_USERNAME=$2
OPC_PASSWORD=$3
#
curl --request GET \
     --user ${OPC_USERNAME}:$OPC_PASSWORD \
     --header 'X-ID-TENANT-NAME: ${OPC_DOMAIN}' \
     --url https://dbcs.emea.oraclecloud.com/jaas/db/api/v1.1/instances/${OPC_DOMAIN}/${ServiceName}-DBCS 
