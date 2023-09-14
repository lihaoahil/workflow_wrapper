#!/bin/sh 

 
#####################################################
# AUTHOR: Hao Li                                    #
# Date:   Jan/20/2021                               #
# The scripts help run gluex_root_analysis jobs     #
# over data, mc, gen.                               #
#                                                   #
#####################################################
# Path 




# analysis tag
NAME=$1
echo "new path name: INPUT_PATH/$NAME/DSelectors_WORKFLOWNAME"

# reaction related
REACTION=$2
echo "Reaction:" $REACTION
if [ "$REACTION" == "ppbar" ]; then  # test case
	MECH_LIST=('M6' 'M5a' 'M5b')
	TreeName=antip__B4_Tree
	INPUT_PATH=/raid4/haoli/MCWrapper/ppbar_2021_01_28_07_30_PM
elif [ "$REACTION" == "lamlambar" ]; then
	MECH_LIST=('M6' 'M5') 
	TreeName=antilamblamb__B4_Tree
	INPUT_PATH=/raid4/haoli/MCWrapper/lamlambar_2021_02_03_12_47_AM   #plambar_2021_02_09_01_00_PM_ifarm
elif [ "$REACTION" == "plambar" ]; then
	MECH_LIST=('M8' 'M7')   
	TreeName=antilamblamb__B4_Tree
	INPUT_PATH=/raid4/haoli/MCWrapper/plambar_2021_02_09_01_00_PM_ifarm
fi
ThrownTreeName=Thrown_Tree


#mode
MODE=$3
if [ "$MODE" != "qcd" ]; then
	exit
fi
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
PERIOD_LIST=('S17v3' 'S18v2' 'F18v2')  
#PERIOD_LIST=('F18lowEv2')  




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
			ConfigPath=/home/haoli/test/Simulation_test/src/dselector/config/ppbar_jpsiMassCut.config
		elif [ "$REACTION" == "lamlambar" ]; then
			ConfigPath=/home/haoli/test/Simulation_test/src/dselector/config/lamlambar_dselector.config
		elif [ "$REACTION" == "plambar" ]; then
			ConfigPath=/home/haoli/test/Simulation_test/src/dselector/config/plambar_dselector.config
		fi
	fi
	# Run over dataset in this run period 


	#Run over mechanics
	NUM_MECH=$((${#MECH_LIST[@]}-1))
	for mech_idx in `seq 0 $NUM_MECH`;
	do

		# Build path for the output
		WORKFLOWNAME=`printf "%s_%s%s" "${PERIOD_LIST[idx]}" "$REACTION" "${MECH_LIST[mech_idx]}"  `  # WORKFLOW NAME
		echo
		echo
		echo "Mech="${MECH_LIST[mech_idx]}", workflow="$WORKFLOWNAME
		echo "##################"
		OUTPUTDIR=`printf "%s/%s" "$INPUT_PATH" "$NAME" `
		
		
		# MC data
		mc_data=$INPUT_PATH/$WORKFLOWNAME/merged_tree.root
		JOBNAME=`printf "%s_mc" "$WORKFLOWNAME" `
		OutPutName=hist_${WORKFLOWNAME}_mc.root 
		OutPutTreeName=tree_${WORKFLOWNAME}_mc.root
		FlatTreeName=flat_${WORKFLOWNAME}_mc.root
		DSelectorName=${WORKFLOWNAME}_MC


		echo $JOBNAME
		mkdir -p $OUTPUTDIR/log
		cd $OUTPUTDIR
		echo MakeDSelector $mc_data $TreeName $DSelectorName $ConfigPath
		MakeDSelector $mc_data $TreeName $DSelectorName $ConfigPath
		if [ -f "$mc_data" ]; then
			if [ ! -f "${OUTPUTDIR}/${OutPutName}" ]; then
				echo "Input: " $mc_data
				echo "Output: " ${OUTPUTDIR}/${OutPutName}
				echo 
				#------------- RUNNING SCRIPTS --------------------- 
				sbatch --job-name=${JOBNAME} --ntasks=${THREADS} --partition=${QUEUE} --mem=${MEM} --time=1:00:00  --output=$OUTPUTDIR/log/${JOBNAME}.out --error=$OUTPUTDIR/log/${JOBNAME}.err --export=INPUTDIR=$INPUTDIR,OUTPUTDIR=$OUTPUTDIR,LOCALDIR=$LOCALDIR,THREADS=$THREADS,QUEUE=$QUEUE,ConfigPath=$ConfigPath,Data=$mc_data,TreeName=$TreeName,DSelectorName=$DSelectorName,OutPutName=$OutPutName,OutPutTreeName=$OutPutTreeName,FlatTreeName=$FlatTreeName $RUN_SCRIPT 
				echo "----------------"
			fi
		fi



		# Thrown data
		gen_data=$INPUT_PATH/$WORKFLOWNAME/merged_thrown.root
		JOBNAME=`printf "%s_thrown" "$WORKFLOWNAME" `
		OutPutName=hist_${WORKFLOWNAME}_thrown.root 
		OutPutTreeName=tree_${WORKFLOWNAME}_thrown.root
		FlatTreeName=flat_${WORKFLOWNAME}_thrown.root
		DSelectorName=${WORKFLOWNAME}_GEN

		echo $JOBNAME
		cd $OUTPUTDIR
		echo MakeDSelector $gen_data $ThrownTreeName $DSelectorName $ConfigPath
		MakeDSelector $gen_data $ThrownTreeName $DSelectorName $ConfigPath
		if [ -f "$gen_data" ]; then
			if [ ! -f "${OUTPUTDIR}/${OutPutName}" ]; then
				echo "Input: " $gen_data
				echo "Output: " ${OUTPUTDIR}/${OutPutName}
				echo 
				#------------- RUNNING SCRIPTS --------------------- 
				sbatch --job-name=${JOBNAME} --ntasks=${THREADS} --partition=${QUEUE} --mem=${MEM} --time=1:00:00  --output=$OUTPUTDIR/log/${JOBNAME}.out --error=$OUTPUTDIR/log/${JOBNAME}.err --export=INPUTDIR=$INPUTDIR,OUTPUTDIR=$OUTPUTDIR,LOCALDIR=$LOCALDIR,THREADS=$THREADS,QUEUE=$QUEUE,ConfigPath=$ConfigPath,Data=$gen_data,TreeName=$ThrownTreeName,DSelectorName=$DSelectorName,OutPutName=$OutPutName,OutPutTreeName=$OutPutTreeName,FlatTreeName=$FlatTreeName $RUN_SCRIPT  
				echo "----------------"
			fi
		fi
		

	done # Done with this reaction mechanism
	echo

done # done with run periods loop




exit








