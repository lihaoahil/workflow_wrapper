#!/bin/sh 

 
#####################################################
# AUTHOR: Hao Li                                    #
# Date:   Jan/20/2021                               #
# The scripts help run gluex_root_analysis jobs.     #
#                                                   #
#                                                   #
#####################################################



##########################
#    CONFIGURATIONS      #
##########################
# SYSTEM
LOC_HOSTNAME=`hostname`
echo "HOST: "$LOC_HOSTNAME
DATE=$(date +%F)
echo $DATE 

# QCD Cluster
QUEUE=green
if [ "$QUEUE" == "green" ]; then
  CPUMEM=1590
  THREADS=40
elif [ "$QUEUE" == "red" ]; then
  CPUMEM=1990
  THREADS=32
fi
let MEM=$THREADS*$CPUMEM


# Path 
INPUT_PATH=/raid4/haoli/MCWrapper/ppbar_2021_01_28_07_30_PM
# Version, mech related lists
PERIOD_LIST=('S17v3' 'S18v2' 'F18v2')  #'F18lowEv2'  





# reaction
REACTION=$1
echo "Reaction:" $REACTION
if [ "$REACTION" == "ppbar" ]; then  # test case
	MECH_LIST=('M6' 'M5a' 'M5b')
	TreeName=antip__B4_Tree
	ConfigPath=/home/haoli/test/Simulation_test/src/dselector/config/ppbar_dselector.config
elif [ "$REACTION" == "lamlambar" ]; then
	MECH_LIST=('M6' 'M5') 
	TreeName=antilamblamb__B4_Tree
	ConfigPath=/home/haoli/test/Simulation_test/src/dselector/config/lamlambar_dselector.config
elif [ "$REACTION" == "plambar" ]; then
	MECH_LIST=('M8' 'M7a' 'M7b')   
	TreeName=antilamblamb__B4_Tree
	ConfigPath=/home/haoli/test/Simulation_test/src/dselector/config/lamlambar_dselector.config
fi
ThrownTreeName=Thrown_Tree


# Loop over to make dselector and run the analysis
NUM_PERIOD=$((${#PERIOD_LIST[@]}-1))
for idx in `seq 0 $NUM_PERIOD`;  # loop over run periods
do
	echo " --------------------------------------- "
	echo ${PERIOD_LIST[idx]}
	echo " --------------------------------------- "

	NUM_MECH=$((${#MECH_LIST[@]}-1))
	for mech_idx in `seq 0 $NUM_MECH`;
	do
		mkdir -p $INPUT_PATH/$WORKFLOWNAME/DSelectors/log
		cd $INPUT_PATH/$WORKFLOWNAME/DSelectors

		# Build path for the output
		WORKFLOWNAME=`printf "%s%s_%s" "$REACTION" "${MECH_LIST[mech_idx]}" "${PERIOD_LIST[idx]}" `  # WORKFLOW NAME
		echo "Mech="${MECH_LIST[mech_idx]}", workflow="$WORKFLOWNAME

		# PATH
		Data=$INPUT_PATH/$WORKFLOWNAME/merged_tree.root
		Thrown=$INPUT_PATH/$WORKFLOWNAME/merged_thrown.root

		# MC data
		echo MakeDSelector $Data $TreeName $WORKFLOWNAME_MC $ConfigPath
		MakeDSelector $Data $TreeName $WORKFLOWNAME_MC $ConfigPath
		if [ -f "$Data" ]; then
			if [ ! -f "${OUTPUTDIR}/${OutPutName}" ]; then
				echo "Input: " $Data
				echo "Output: " ${OUTPUTDIR}/${OutPutName}
				echo 
				#------------- RUNNING SCRIPTS --------------------- 
				sbatch --job-name=${WORKFLOWNAME} --ntasks=${THREADS} --partition=${QUEUE} --mem=${MEM} --time=2:00:00  --output=$INPUT_PATH/$WORKFLOWNAME/DSelectors/log/slurm.out --error=$INPUT_PATH/$WORKFLOWNAME/DSelectors/log/slurm.err --export=INPUTDIR=$INPUTDIR,OUTPUTDIR=$OUTPUTDIR,LOCALDIR=$LOCALDIR,THREADS=$THREADS,QUEUE=$QUEUE,ConfigPath=$ConfigPath,Data=$Data,TreeName=$TreeName,DSelectorName=$DSelectorName,OutPutName=$OutPutName,OutPutTreeName=$OutPutTreeName,FlatTreeName=$FlatTreeName $LOCALDIR/script/runroot.csh 
				echo "----------------"
			fi
		fi



		# Thrown data
		echo MakeDSelector $Thrown $ThrownTreeName $WORKFLOWNAME_Thrown $ConfigPath
		MakeDSelector $Thrown $ThrownTreeName $WORKFLOWNAME_Thrown $ConfigPath
		

	done # Done with this reaction mechanism
	echo

done













