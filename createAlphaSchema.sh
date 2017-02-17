#!/bin/sh
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
response=$(curl --request GET \
                --user "${OPC_USERNAME}:${OPC_PASSWORD}" \
                --header "X-ID-TENANT-NAME: ${OPC_DOMAIN}" \
                --url https://dbcs.emea.oraclecloud.com/jaas/db/api/v1.1/instances/${OPC_DOMAIN}/${ServiceName}-DBCS | sed 's/ /_/g')

# find position of EM URL in string
num=$(echo $response|grep -b -o "em_url"|awk -F":" '{print $1}')

INPUT=${response:$num+20}
PUBLIC_IP=${INPUT%%:*}
#
ssh -o "StrictHostKeyChecking no" -i ./labkey oracle@${PUBLIC_IP} sqlplus system/Alpha2014_@PDB1 < createAlphaUser.sql
#
ssh -o "StrictHostKeyChecking no" -i ./labkey oracle@${PUBLIC_IP} sqlplus alpha/oracle@PDB1 < createProducts.sql
