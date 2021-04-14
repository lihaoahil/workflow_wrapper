#!/bin/sh 

 
#####################################################
# AUTHOR: Hao Li                                    #
# Date:   March/11/2021                             #
# The scripts grab run number list.                 #
#                                                   #
#####################################################



##########################
#    CONFIGURATIONS      #
##########################

# Version, mech related lists
#PERIOD_LIST=('S17v3' 'S18v2' 'F18v2' 'F18lowEv2')  
PERIOD_LIST=( 'F18lowEv2')  

# reaction related
REACTION=$1
echo "Reaction:" $REACTION
if [ "$REACTION" == "ppbar" ]; then  # test case
	TreeName=antip__B4_Tree
	INPUT_PATH=('/raid4/haoli/RunPeriod-2017-01/analysis/ver36/merged/tree_antip__B4/pre_selected_CL5/trees' 
				'/raid4/haoli/RunPeriod-2018-01/analysis/ver02/tree_antip__B4/pre_selected_CL5/trees' 
				'/raid4/haoli/RunPeriod-2018-08/analysis/ver02/tree_antip__B4/pre_selected_CL5/trees' 
				'/raid4/haoli/RunPeriod-2018-08/analysis/ver05/merged/tree_antip__B4/pre_selected_CL5/trees')
elif [ "$REACTION" == "lamlambar" ]; then
 	TreeName=antilamblamb__B4_Tree
	INPUT_PATH=/raid4/haoli/MCWrapper/lamlambar_2021_02_03_12_47_AM   #plambar_2021_02_09_01_00_PM_ifarm
elif [ "$REACTION" == "plambar" ]; then
	TreeName=antilamblamb__B4_Tree
	INPUT_PATH=/raid4/haoli/MCWrapper/plambar_2021_02_09_01_00_PM_ifarm
fi
ThrownTreeName=Thrown_Tree




##########################
#     RUNNING SCRIPTS    #
##########################

# Loop over to make dselector and run the analysis
NUM_PERIOD=$((${#PERIOD_LIST[@]}-1))
for idx in `seq 0 $NUM_PERIOD`;  # loop over run periods
do
	echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
	echo ${PERIOD_LIST[idx]}
	echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"

	INPUTDIR=${INPUT_PATH[idx]}
	# MC data loop
	for data_file in $INPUTDIR/tree_antip__B4_0*.root; 
	do
		loc_data=$data_file
		run_id=`echo $loc_data | cut -d_ -f10 | cut -c 1-6 `   ## magic number used! Attetion!
		POLARIZATION_DIRECTION=`rcnd $run_id polarization_direction`
		POLARIZATION_ANGLE=`rcnd $run_id polarization_angle`
		#echo -n "\""$run_id"\", "
		echo $run_id $POLARIZATION_DIRECTION $POLARIZATION_ANGLE

	done
	echo

done # done with run periods loop
echo



exit







