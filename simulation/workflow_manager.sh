#!/bin/sh 

 
#####################################################
# AUTHOR: Hao Li                                    #
# Date:   Jan/20/2021                               #
# The scripts helps remove obsolete workflows.     #
#                                                   #
#                                                   #
#####################################################



##########################
#    CONFIGURATIONS      #
##########################
LOC_HOSTNAME=`hostname`
echo "HOST: "$LOC_HOSTNAME

# Version, mech related lists
PERIOD_LIST=('S17v3' 'S18v2' 'F18v2')  #


# reaction
REACTION=$1
WF_name=$2
ACTION=$3

echo "Reaction:" $REACTION
echo "Action:" $ACTION

if [ "$REACTION" == "ppbar" ]; then  # test case
	MECH_LIST=('M6' 'M5a' 'M5b')
elif [ "$REACTION" == "lamlambar" ]; then
	MECH_LIST=('M6' 'M5') 
elif [ "$REACTION" == "plambar" ]; then
	MECH_LIST=('M8' 'M7')   
fi

NUM_PERIOD=$((${#PERIOD_LIST[@]}-1))
for idx in `seq 0 $NUM_PERIOD`;  # loop over run periods
do
	echo " --------------------------------------- "
	echo ${PERIOD_LIST[idx]}
	echo " --------------------------------------- "

	NUM_MECH=$((${#MECH_LIST[@]}-1))
	for mech_idx in `seq 0 $NUM_MECH`;
	do
		# Build path for the output
		WORKFLOWNAME=`printf "%s_%s_%s%s" "$WF_name" "${PERIOD_LIST[idx]}" "$REACTION" "${MECH_LIST[mech_idx]}" `  # WORKFLOW NAME
		echo "Mech="${MECH_LIST[mech_idx]}", workflow="$WORKFLOWNAME
		echo
		if [ "$ACTION" == "delete_all" ]; then # delete action
			swif cancel -delete -discard-tape-files -discard-disk-files -workflow $WORKFLOWNAME
		fi

	done # Done with this reaction mechanism
	echo

done













