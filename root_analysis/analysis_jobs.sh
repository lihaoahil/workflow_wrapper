#!/bin/sh 

 
#####################################################
# AUTHOR: Hao Li                                    #
# Date:   Jan/20/2021                               #
# The scripts helps handle the problematic jobs.     #
#                                                   #
#                                                   #
#####################################################



##########################
#    CONFIGURATIONS      #
##########################
LOC_HOSTNAME=`hostname`
echo "HOST: "$LOC_HOSTNAME

# Path 
INPUT_PATH=/raid4/haoli/MCWrapper/ppbar_2021_01_28_07_30_PM

# Version, mech related lists
PERIOD_LIST=('S17v3' 'S18v2' 'F18v2')  #'F18lowEv2'  


# reaction
REACTION=$1
echo "Reaction:" $REACTION
if [ "$REACTION" == "ppbar" ]; then  # test case
	MECH_LIST=('M6' 'M5a' 'M5b')
elif [ "$REACTION" == "lamlambar" ]; then
	MECH_LIST=('M6' 'M5') 
elif [ "$REACTION" == "plambar" ]; then
	MECH_LIST=('M8' 'M7a' 'M7b')   
fi


for idx in `seq 0 3`;  # loop over run periods
do
	echo " --------------------------------------- "
	echo ${PERIOD_LIST[idx]}
	echo " --------------------------------------- "

	NUM_MECH=$((${#MECH_LIST[@]}-1))
	for mech_idx in `seq 0 $NUM_MECH`;
	do
		# Build path for the output
		WORKFLOWNAME=`printf "%s%s_%s" "$REACTION" "${MECH_LIST[mech_idx]}" "${PERIOD_LIST[idx]}" `  # WORKFLOW NAME
		echo "Mech="${MECH_LIST[mech_idx]}", workflow="$WORKFLOWNAME

		NUM_PROBLEMS=$((${#PROBLEMS_LIST[@]}-1))
		
		# hadd
		echo hadd $INPUT_PATH/$WORKFLOWNAME/merged_tree.root $INPUT_PATH/$WORKFLOWNAME/root/trees/tree_*.root
		hadd $INPUT_PATH/$WORKFLOWNAME/merged_tree.root $INPUT_PATH/$WORKFLOWNAME/root/trees/tree_*.root
		echo
		
		echo hadd $INPUT_PATH/$WORKFLOWNAME/merged_thrown.root $INPUT_PATH/$WORKFLOWNAME/root/thrown/tree_thrown_*.root
		hadd $INPUT_PATH/$WORKFLOWNAME/merged_thrown.root $INPUT_PATH/$WORKFLOWNAME/root/thrown/tree_thrown_*.root
		echo

	done # Done with this reaction mechanism
	echo

done













