#!/bin/sh
##
if [ $# -lt 3 ]
then
    echo "Usage: createAlphaInrastructure.sh <OPC Identity Domain> <OPC Username> <OPC Password>"
    exit 1
fi
OPC_DOMAIN=$1
OPC_USERNAME=$2
OPC_PASSWORD=$3
#
job=$(curl --request POST \
     --user "${OPC_USERNAME}:${OPC_PASSWORD}" \
     --url https://psm.europe.oraclecloud.com/paas/api/v1.1/instancemgmt/${OPC_DOMAIN}/services/stack/instances \
     --header "X-ID-TENANT-NAME: ${OPC_DOMAIN}" \
     --header "content-type: multipart/form-data" \
     --form name=$ServiceName \
     --form template=Alpha-JCS-DBCS-Template \
     --form 'parameterValues={"commonPwd":"'"$CommonPassword"'", "backupStorageContainer":"'"$BackupStorageContainer"'", "cloudStoragePassword":"${OPC_PASSWORD}"}}')

#
#
result="\"status\":\"RUNNING\""
sleep 1200
while [ $result = "\"status\":\"RUNNING\"" ]; do
  sleep 120

  # request job status and isolation 'status' lines..keep looping till the status is not RUNNING
  result=$(curl --request GET \
                --user "${OPC_USERNAME}:${OPC_PASSWORD}" \
                --header "X-ID-TENANT-NAME: ${OPC_DOMAIN}" \
                --url https://psm.europe.oraclecloud.com/paas/api/v1.1/activitylog/${OPC_DOMAIN}/stack/$ServiceName \
     | sed -e 's/[{}]/''/g '|awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}'|grep "status"|sed -n 1p)
  echo $result
done
