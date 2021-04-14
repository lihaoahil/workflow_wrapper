#!/bin/sh 

 
#####################################################
# AUTHOR: Hao Li                                    #
# Date:   March/09/2021                             #
# The scripts help run gluex_root_analysis jobs     #
# over mc, gen.                                     #
#                                                   #
#####################################################
# Path 


OUTPUT_PATH=/raid4/haoli/GlueX_Phase_I

# analysis tag
NAME=$1
echo "new path name: $OUTPUT_PATH/$NAME"

# reaction related
REACTION=$2
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


#mode
MODE=$3
#if [ "$MODE" != "qcd" ]; then
#	exit
#fi
##########################
#    CONFIGURATIONS      #
##########################
# SYSTEM
LOC_HOSTNAME=`hostname`
echo "HOST: "$LOC_HOSTNAME
DATE=$(date +%F)
echo $DATE 

# QCD Cluster
QUEUE=$4
if [ "$QUEUE" == "green" ]; then
  CPUMEM=6360
  THREADS=10
elif [ "$QUEUE" == "red" ]; then
  CPUMEM=7960
  THREADS=8
fi
let MEM=$THREADS*$CPUMEM
echo $MEM

# Script path
LOCALDIR=/home/haoli/test/Simulation_test/src/dselector
#scripts
RUN_SCRIPT=/home/haoli/test/workflow_wrapper/root_analysis/run_job.csh
# Version, mech related lists
PERIOD_LIST=('S17v3' 'S18v2' 'F18v2' 'F18lowEv2')  




##########################
#      RUNNING JOBS      #
##########################

# Set env for MakeDSelector
source /home/haoli/build/redhat7/gluex_root_analysis/env_analysis.sh

# Loop over to make dselector and run the analysis
NUM_PERIOD=$((${#PERIOD_LIST[@]}-1))
for idx in `seq 0 $NUM_PERIOD`;  # loop over run periods
do
	echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
	echo ${PERIOD_LIST[idx]}
	echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"

	if [ "$idx" == "3" ]; then
		# reaction related
		if [ "$REACTION" == "ppbar" ]; then  # test case
			ConfigPath=/home/haoli/test/Simulation_test/src/dselector/config/ppbar_dselector_lowE.config
		elif [ "$REACTION" == "lamlambar" ]; then
			ConfigPath=/home/haoli/test/Simulation_test/src/dselector/config/lamlambar_dselector.config
		elif [ "$REACTION" == "plambar" ]; then
			ConfigPath=/home/haoli/test/Simulation_test/src/dselector/config/plambar_dselector.config
		fi		
	else
		# reaction related
		if [ "$REACTION" == "ppbar" ]; then  # test case
			ConfigPath=/home/haoli/test/Simulation_test/src/dselector/config/ppbar_dselector.config
		elif [ "$REACTION" == "lamlambar" ]; then
			ConfigPath=/home/haoli/test/Simulation_test/src/dselector/config/lamlambar_dselector.config
		elif [ "$REACTION" == "plambar" ]; then
			ConfigPath=/home/haoli/test/Simulation_test/src/dselector/config/plambar_dselector.config
		fi
	fi
	# Run over dataset in this run period 


	
	# Build path for the output
	WORKFLOWNAME=`printf "%s_%s" "${PERIOD_LIST[idx]}" "$REACTION"  `  # WORKFLOW NAME
	OUTPUTDIR=`printf "%s/%s" "$OUTPUT_PATH" "$NAME" `
	INPUTDIR=${INPUT_PATH[idx]}
	echo
	echo
	echo "workflow="$WORKFLOWNAME
	echo "INPUTDIR="$INPUTDIR
	echo "##################"
	
	
	# MC data loop
	for data_file in $INPUTDIR/tree_antip__B4_0*.root; 
	do
		loc_data=$data_file
		run_id=`echo $loc_data | cut -d_ -f10 | cut -c 1-6 `   ## magic number used! Attetion!
		JOBNAME=`printf "%s_%s" "$WORKFLOWNAME" "$run_id" `
		OutPutName=hist_${JOBNAME}_data.root 
		OutPutTreeName=tree_${JOBNAME}_data.root
		FlatTreeName=flat_${JOBNAME}_data.root
		DSelectorName=${JOBNAME}_data


		echo $JOBNAME
		mkdir -p $OUTPUTDIR/log
		cd $OUTPUTDIR
		#echo MakeDSelector $loc_data $TreeName $DSelectorName $ConfigPath
		#MakeDSelector $loc_data $TreeName $DSelectorName $ConfigPath
		if [ -f "$loc_data" ]; then
			if [ ! -f "${OUTPUTDIR}/${OutPutName}" ]; then
				echo "Input: " $loc_data
				echo "Output: " ${OUTPUTDIR}/${OutPutName}
				echo 
				#------------- RUNNING SCRIPTS --------------------- 
				if [ "$MODE" == "qcd" ]; then
					sbatch --job-name=${JOBNAME} --ntasks=${THREADS} --partition=${QUEUE} --mem=${MEM} --time=00:30:00  --output=$OUTPUTDIR/log/${JOBNAME}.out --error=$OUTPUTDIR/log/${JOBNAME}.err --export=INPUTDIR=$INPUTDIR,OUTPUTDIR=$OUTPUTDIR,LOCALDIR=$LOCALDIR,THREADS=$THREADS,QUEUE=$QUEUE,ConfigPath=$ConfigPath,Data=$loc_data,TreeName=$TreeName,DSelectorName=$DSelectorName,OutPutName=$OutPutName,OutPutTreeName=$OutPutTreeName,FlatTreeName=$FlatTreeName $RUN_SCRIPT 
				fi
			fi
		fi
		echo "----------------"
		
	done

		


done # done with run periods loop




exit







