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
PERIOD_LIST=('S17v31' 'S18v21' 'F18v21' 'F18lowEv2')  #  


# reaction
REACTION=ppbar
echo "Reaction:" $REACTION
if [ "$REACTION" == "ppbar" ]; then  # test case
	MECH_LIST=('M6' 'M5a' 'M5b')
	TAG=antip__B4
elif [ "$REACTION" == "lamlambar" ]; then
	MECH_LIST=('M6' 'M5') 
	TAG=antilamblamb__B4
elif [ "$REACTION" == "plambar" ]; then
	MECH_LIST=('M8' 'M7') 
	TAG=antilamblamb__B4  
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
		WORKFLOWNAME=`printf "%s_%s%s" "${PERIOD_LIST[idx]}" "$REACTION" "${MECH_LIST[mech_idx]}"  `  # WORKFLOW NAME
		echo "Mech="${MECH_LIST[mech_idx]}", workflow="$WORKFLOWNAME

		NUM_PROBLEMS=$((${#PROBLEMS_LIST[@]}-1))
		
		# hadd
		rm $INPUT_PATH/$WORKFLOWNAME/merged_tree.root
		echo hadd $INPUT_PATH/$WORKFLOWNAME/merged_tree.root $INPUT_PATH/$WORKFLOWNAME/root/trees/tree_${TAG}_mc_gen_*.root
		hadd $INPUT_PATH/$WORKFLOWNAME/merged_tree.root $INPUT_PATH/$WORKFLOWNAME/root/trees/tree_${TAG}_mc_gen_*.root
		echo
		
		rm $INPUT_PATH/$WORKFLOWNAME/merged_thrown.root
		echo hadd $INPUT_PATH/$WORKFLOWNAME/merged_thrown.root $INPUT_PATH/$WORKFLOWNAME/root/thrown/tree_thrown_*.root
		hadd $INPUT_PATH/$WORKFLOWNAME/merged_thrown.root $INPUT_PATH/$WORKFLOWNAME/root/thrown/tree_thrown_*.root
		echo

	done # Done with this reaction mechanism
	echo

done




