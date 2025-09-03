#!/bin/bash
#
# Shell script to start coda_ts
#
#  If no arguments, use coda_conf_functions to get ROC information
#
#  Otherwise:
#
#   startROC.sh ROCNAME ROCOPTIONS
#
#   Where ROCNAME is the name of the ROC component to start
#   and ROCOPTIONS (optional) are any other arguments to copy to the coda_ts
#   commandline
#

ARGS=$@

DEFAULT="-i -v"
PROG=$(basename $0)
TYPE=ROC
CODA_ROC=coda_roc

case "$PROG" in
    "startFPGA.sh" )
	TYPE=FPGA
	;;

    "startTS.sh" )
	TYPE=TS
	CODA_ROC=coda_ts
	;;

    * )
	TYPE=ROC
	;;
esac

SHOSTNAME=$(hostname -s)

if [ ${#@} -gt 0 ]; then
    # Get the ROC component name
    ROCNAME=$1

    # Get this ROC's commandline option
    shift 1
    ROCOPTION=$@
else
    . coda_conf_functions

    # Get the ROC component name
    codaconf_get_component_name $SHOSTNAME $TYPE
    ROCNAME=$CODA_COMPONENT_NAME

    # Get this ROC's commandline option
    codaconf_get_name_option $SHOSTNAME $ROCNAME
    ROCOPTION=$CODA_COMPONENT_OPTION
fi

ROC_ACTIVE=$(pgrep ${CODA_ROC})
if [ -n "$ROC_ACTIVE" ]; then
    echo "WARNING: ${CODA_ROC} already running"
    echo "         killing them"
    killall -v ${CODA_ROC}
fi


echo "************************************************************"
echo "Starting ROC on" $SHOSTNAME
echo "   SESSION     =" $SESSION
echo "   EXPID       =" $EXPID
echo "   ROC name    =" $ROCNAME
echo "   TYPE        =" $TYPE
echo "   ROC option  =" $ROCOPTION
echo "   Commandline =" $ARGS
echo "************************************************************"
${CODA_ROC} $DEFAULT -type $TYPE -name $ROCNAME $ROCOPTION
