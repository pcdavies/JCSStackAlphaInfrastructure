#!/bin/sh
##
if [ $# -lt 3 ]
then
    echo "Usage: createAlphaDataSource.sh <OPC Identity Domain> <OPC Username> <OPC Password>"
    exit 1
fi
OPC_DOMAIN=$1
OPC_USERNAME=$2
OPC_PASSWORD=$3
#
response=$(curl --request GET \
                --user "${OPC_USERNAME}:${OPC_PASSWORD}" \
                --header "X-ID-TENANT-NAME: ${OPC_DOMAIN}" \
                --url https://jcs.emea.oraclecloud.com/jaas/api/v1.1/instances/${OPC_DOMAIN}/${ServiceName}-JCS | sed 's/ /_/g')
echo "Response = $response"

# find position of EM URL in string
num=$(echo $response|grep -b -o "wls_admin_ur"|awk -F":" '{print $1}')

INPUT=${response:$num+27}
echo "Input = $INPUT"
PUBLIC_IP=${INPUT%%:*}
echo "PublicIP = $PUBLIC_IP"
#
scp -o "StrictHostKeyChecking no" -i ./labkey ./labkey.pub opc@${PUBLIC_IP}:/home/opc/.
scp -o "StrictHostKeyChecking no" -i ./labkey ./setupJCS.sh opc@${PUBLIC_IP}:/home/opc/.
ssh -t -t -o "StrictHostKeyChecking no" -i ./labkey opc@${PUBLIC_IP} "sudo /home/opc/setupJCS.sh"
#
scp -o "StrictHostKeyChecking no" -i ./labkey runAlphaDS.sh oracle@${PUBLIC_IP}:~oracle/.
scp -o "StrictHostKeyChecking no" -i ./labkey create_data_source.py oracle@${PUBLIC_IP}:~oracle/.
scp -o "StrictHostKeyChecking no" -i ./labkey Alpha-ds.properties oracle@${PUBLIC_IP}:~oracle/.
ssh -o "StrictHostKeyChecking no" -i ./labkey oracle@${PUBLIC_IP} "/u01/app/oracle/tools/paas/state/homes/oracle/runAlphaDS.hs"
