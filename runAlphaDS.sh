#!/bin/sh
#
. /u01/app/oracle/middleware/wlserver/server/bin/setWLSEnv.sh

java weblogic.WLST /u01/app/oracle/tools/paas/state/homes/oracle/create_data_source.py -p /u01/app/oracle/tools/paas/state/homes/oracle/Alpha-ds.properties
