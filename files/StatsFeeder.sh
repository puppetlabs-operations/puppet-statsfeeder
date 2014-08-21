#!/bin/bash
usage()
{
cat << EOF
usage: $0 options

This script will run the StatsFeeder batch configuration for retrieving performance metrics
from the specified vCenter server

OPTIONS:
   -?      Show this message
   -h      The vCenter IP address or hostname
   -u      vCenter user name
   -p      vCenter password
   -c      Path to statsfeeder configuration file
EOF
}

STATSFEEDER_DIR=`dirname $0`
LIB_DIR=${STATSFEEDER_DIR}/lib

VCENTER=
USER=
PASSWD=
CONFIG=
while getopts â€œ?h:b:u:p:c:â€� OPTION
do
     case $OPTION in
         h)
             VCENTER=$OPTARG
             ;;
         u)
             USER=$OPTARG
             ;;
         p)
             PASSWD=$OPTARG
             ;;
         c)
             CONFIG=$OPTARG
             ;;
         ?)
             usage
             exit 1
             ;;
     esac
done

if [[ -z $USER ]] || [[ -z $PASSWD ]] || [[ -z $CONFIG ]] || [[ -z $VCENTER ]]
then
     usage
     exit 1
fi

CLASSPATH=$(JARS=("$LIB_DIR"/*.jar); IFS=:; echo "${JARS[*]}")

java -cp $CLASSPATH:. com.vmware.ee.statsfeeder.Main ${VCENTER} ${USER} ${PASSWD} ${CONFIG}
