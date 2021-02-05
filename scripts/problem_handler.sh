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

# Version, mech related lists
PERIOD_LIST=('S17v3' 'S18v2' 'F18v2' 'F18lowEv2')

# problems
PROBLEMS_LIST=('SWIF-USER-NON-ZERO' 'AUGER-TIMEOUT')

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
		# handle problems
		for problem_idx in `seq 0 $NUM_PROBLEMS`; #loop over types of problems
		do
			echo "    Problem type: "  ${PROBLEMS_LIST[problem_idx]}
			if grep -q "cmu.edu" <<< "$LOC_HOSTNAME"; then
				echo swif retry-jobs -workflow ${WORKFLOWNAME} -problems ${PROBLEMS_LIST[problem_idx]}
			elif grep -q "jlab.org" <<< "$LOC_HOSTNAME"; then
				swif retry-jobs -workflow ${WORKFLOWNAME} -problems ${PROBLEMS_LIST[problem_idx]}
			fi
		done
		echo

	done # Done with this reaction mechanism
	echo

done













