#!/bin/sh
##
#
# submit job and take result of job submission, strip spaces and assign to variable job
#
job=$(curl --request POST \
  --user cloud.admin:passingPest@1\
  --url https://psm.europe.oraclecloud.com/paas/api/v1.1/instancemgmt/gse00002055/services/stack/instances \
  --header 'X-ID-TENANT-NAME: gse00002055' \
  --header 'content-type: multipart/form-data' \
  --form name=$ServiceName \
  --form template=Alpha-JCS-DBCS-Template \
  --form 'parameterValues={"commonPwd":"'"$CommonPassword"'", "backupStorageContainer":"'"$BackupStorageContainer"'", "cloudStoragePassword":"passingPest@1"}}'|sed 's/ /_/g')

# find position of JobID in string
num=$(echo $job|grep -b -o "Job_ID"|awk -F":" '{print $1}')

# isolate job id number and assign to jobresult - use this to test status of job below
JOBID=${job:$num+9}

#
#
result="\"status\":\"RUNNING\""
while [ $result = "\"status\":\"RUNNING\"" ]; do
  sleep 60

  # request job status and isolation 'status' lines..keep looping till the status is not RUNNING
  result=$(curl --request GET \
             --user cloud.admin:passingPest@1 \
             --url https://psm.europe.oraclecloud.com/paas/api/v1.1/activitylog/gse00002055/stack/$JOBID |sed -e 's/[{}]/''/g '|awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}'|grep "status"|sed -n 1p)
  echo $result
done
echo $result
