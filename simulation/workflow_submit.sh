#!/bin/sh 

 
#####################################################
# AUTHOR: Hao Li                                    
# Date:   Sep/14/2023                               
# The scripts helps automate simulation of different
# reactions & mechanisms in jlab ifarm swif2        
#####################################################



##########################
#    CONFIGURATIONS      #
##########################

# Path
WORKFLOWWRAPPER_JLAB=/u/home/haoli/workflow/workflow_wrapper #https://github.com/lihaoahil/workflow_wrapper
WORKFLOWWRAPPER_CMU=/home/haoli/test/workflow_wrapper
OUTPUT_JLAB=/lustre19/expphy/cache/halld/home/haoli/gluex_simulations    # See here for work/cache/volatile usages: https://scicomp.jlab.org/scicomp/index.html#/work
OUTPUT_CMU=/raid4/haoli/test/workflow_out

LOGDIR_JLAB=/u/scifarm/farm_out/haoli/gluex_simulations

# RUNS Simulation related
RUN_LIST=('30274-31057' '40856-42559' '50685-51768' '51384-51457' '71350-73266')  # Either single run number: 30730, or run range like 30796-30901 
TRIGGER=(10000000 10000000 10000000 1000000 10000000)
# test
TESTRUN_LIST=('30730' '40856' '50685' '51384' '71350')
TESTTRIGGER=500

# Farm related (do not change unless you know what you are doing)
DISK=5GB           			# Max Disk usage
RAM=5GB            			# Max RAM usage
TIMELIMIT=300minutes        # Max walltime (job 'ppbar 10000 evts w/ 1 core' runs roughly 1.5 hours)
NCORES=1
OS=general        # Specify CentOS65 machines
BATCH_SYSTEM=swif2
ACCOUNT=halld
PARTITION=production # for debug and test use priority # See here (https://scicomp.jlab.org/docs/batch_job_tracks)
EXPERIMENT=gluex


# Softwares
GENERATOR=mc_gen   # Current event generator (https://github.com/JeffersonLab/halld_sim/tree/master/src/programs/Simulation/MC_GEN)
GEANT_VERSION=4   

# Version, mech related lists
PERIOD_LIST=('S17v3' 'S18v2' 'F18v2' 'F18lowEv2' 'S20v1')
BKG_LIST=('recon-2017_01-ver03.2' 'recon-2018_01-ver02.2' 'recon-2018_08-ver02.2' 'recon-2018_08-ver02.2' 'recon-2019_11-ver01')   # see /w/osgpool-sciwork18/halld/random_triggers/
ENV_LIST=('recon-2017_01-ver03_35.xml' 'recon-2018_01-ver02_28.xml' 'recon-2018_08-ver02_27.xml' 'recon-2018_08-ver02_27.xml' 'recon-2019_11-ver01_9.xml')     # see /group/halld/www/halldweb/html/halld_versions/
ANAENV_LIST=('analysis-2017_01-ver46.xml' 'analysis-2018_01-ver15.xml' 'analysis-2018_08-ver15.xml' 'analysis-2018_08-ver05.xml' 'analysis-2019_11-ver04.xml')   # see https://halldweb.jlab.org/wiki-private/index.php/Fall_2018_Analysis_Launch
RCDBQUERY_LIST=('@is_production and @status_approved' '@is_2018production and @status_approved' '@is_2018production and @status_approved and beam_current > 49' '@is_2018production and @status_approved and beam_current < 49' '@is_dirc_production and @status_approved') 
# Got from https://halldweb.jlab.org/wiki-private/index.php/GlueX_Phase-I_Dataset_Summary
# and      https://halldweb.jlab.org/wiki-private/index.php/GlueX_Phase-II_Dataset_Summary




######################################################
#      SETUP & CONFIGURATION    (Don't need edit)    #
######################################################

# check the MCWrapper path
if [ -n "$MCWRAPPER_CENTRAL" ]; then
    echo "MCWRAPPER_CENTRAL is set to: $MCWRAPPER_CENTRAL"
else
    echo "MCWRAPPER_CENTRAL is not set. Please set it and run the script again."
    exit 1
fi

# Ask the user to confirm
read -p "Is this the correct value? (y/n): " confirm

if [ "$confirm" != "y" ]; then
    echo "Aborting script."
    exit 1
fi

# Reaction Related
REACTION=$1
echo "Reaction:" $REACTION
if [ "$REACTION" == "ppbar" ]; then  # test case
	MECH_LIST=('M6' 'M5a' 'M5b')
elif [ "$REACTION" == "lamlambar" ]; then
	MECH_LIST=('M6' 'M5') 
elif [ "$REACTION" == "plambar" ]; then
	MECH_LIST=('M8' 'M7')   
else
	echo "no reaction is entered, aborting script."
	exit 1
fi

# Mode
MODE=$2
echo     "##############"
if [ "$MODE" == "ifarm" ]; then  # test case
	echo "#  RUN MODE  #" 
elif [ "$MODE" == "test" ]; then
	echo "# TEST MODE  #" 
else
	echo "# DEBUG MODE #"
fi
echo "##############"
echo
TIME=$(date +"%Y_%m_%d_%I_%M_%p")
echo "Current time:" $TIME
echo
# Output Path
LOC_HOSTNAME=`hostname`
echo "HOST: "$LOC_HOSTNAME
if grep -q "cmu.edu" <<< "$LOC_HOSTNAME"; then
	OUTPUT=$OUTPUT_CMU
	WORKFLOWWRAPPER_PATH=$WORKFLOWWRAPPER_CMU
elif grep -q "jlab.org" <<< "$LOC_HOSTNAME"; then
	OUTPUT=$OUTPUT_JLAB
	WORKFLOWWRAPPER_PATH=$WORKFLOWWRAPPER_JLAB
else
	echo " Hostname not matched! Exit now."
	exit
fi
OUTPUT_PATH=`printf "%s/%s_%s_%s" "$OUTPUT" "$REACTION" "$TIME" "$MODE"`
LOG_PATH=`printf "%s/%s_%s_%s" "$LOGDIR_JLAB" "$REACTION" "$TIME" "$MODE"`
echo "OUTPUT_PATH: "$OUTPUT_PATH
echo
echo
echo " --------------------------------------------------------------------------------------- "
echo " Start configuration:"
echo " --------------------------------------------------------------------------------------- "
# JANA configs
CUSTOM_PLUGINS=`printf "%s/simulation/reactions/jana_%s.config" "$WORKFLOWWRAPPER_PATH" "$REACTION" `
# Check if exists
if [ ! -f "$CUSTOM_PLUGINS" ]; then
	echo "Cannot find" $CUSTOM_PLUGINS"!"
	exit
fi

# Loops to set up
for idx in `seq 0 4`;
do
	ENVIRONMENT_FILE=`printf "/group/halld/www/halldweb/html/halld_versions/%s" "${ENV_LIST[idx]}" `
	ANA_ENVIRONMENT_FILE=`printf "/group/halld/www/halldweb/html/halld_versions/%s" "${ANAENV_LIST[idx]}" `
	# Check if key files exist
	if [ ! -f "$ENVIRONMENT_FILE" ]; then
		echo "Cannot find" $ENVIRONMENT_FILE"!"
		if grep -q "jlab.org" <<< "$LOC_HOSTNAME"; then
			exit
		fi
	fi

	if [ ! -f "$ANA_ENVIRONMENT_FILE" ]; then
		echo "Cannot find" $ANA_ENVIRONMENT_FILE"!"
		if grep -q "jlab.org" <<< "$LOC_HOSTNAME"; then
			exit
		fi
	fi

	RUN_RANGE=${RUN_LIST[idx]}
	TESTRUN=${TESTRUN_LIST[idx]}

	# loop over reaction mechanisms
	NUM_MECH=$((${#MECH_LIST[@]}-1))
	for mech_idx in `seq 0 $NUM_MECH`;
	do
		# Build path for the output
		WORKFLOWNAME=`printf "%s_%s%s" "${PERIOD_LIST[idx]}" "$REACTION" "${MECH_LIST[mech_idx]}" `  # WORKFLOW NAME
		DATA_OUTPUT_BASE_DIR=$OUTPUT_PATH/$WORKFLOWNAME
		
		# Check if def exists
		GENERATOR_CONFIG=`printf "%s/simulation/def/%s_%s.def" "$WORKFLOWWRAPPER_PATH" "$REACTION" "${MECH_LIST[mech_idx]}" `
		if [ ! -f "$GENERATOR_CONFIG" ]; then
			echo "Cannot find" $GENERATOR_CONFIG"!"
			exit
		fi



		# Determine the erergy according to run periods
		if [ "$idx" != "3" ]; then
			GEN_MIN_ENERGY=6.0
			GEN_MAX_ENERGY=11.6
		else
			GEN_MIN_ENERGY=3.0
			GEN_MAX_ENERGY=6.0
		fi

		# Determine track and trigger for different mode
		if [ "$MODE" != "ifarm" ]; then
			PARTITION=priority  # for highest priority
		fi

		# Write configurations into .cfg files
		mkdir -p $DATA_OUTPUT_BASE_DIR/mcwrapper_configs
		cd $DATA_OUTPUT_BASE_DIR/mcwrapper_configs
		rm -f $WORKFLOWNAME.cfg
		
		echo "#This config file was used to submit workflow: " $WORKFLOWNAME                >>$WORKFLOWNAME.cfg
		echo ""                                           									>>$WORKFLOWNAME.cfg
		echo "DISK="$DISK                                 									>>$WORKFLOWNAME.cfg
		echo "RAM="$RAM                                   									>>$WORKFLOWNAME.cfg
		echo "TIMELIMIT="$TIMELIMIT                       									>>$WORKFLOWNAME.cfg
		echo "OS="$OS                                     									>>$WORKFLOWNAME.cfg
		echo "NCORES="$NCORES                             									>>$WORKFLOWNAME.cfg
		echo "BATCH_SYSTEM="$BATCH_SYSTEM                 									>>$WORKFLOWNAME.cfg
		echo "ACCOUNT="$ACCOUNT                           									>>$WORKFLOWNAME.cfg
		echo "PARTITION="$PARTITION                               							>>$WORKFLOWNAME.cfg
		echo "EXPERIMENT="$EXPERIMENT                               						>>$WORKFLOWNAME.cfg
		echo ""                                           									>>$WORKFLOWNAME.cfg
		echo "GENERATOR="$GENERATOR                       									>>$WORKFLOWNAME.cfg
		echo "GEANT_VERSION="$GEANT_VERSION               									>>$WORKFLOWNAME.cfg
		echo "CUSTOM_PLUGINS=file:"$CUSTOM_PLUGINS             								>>$WORKFLOWNAME.cfg
		echo ""                                           									>>$WORKFLOWNAME.cfg
		echo "GENERATOR_CONFIG="$GENERATOR_CONFIG                                           >>$WORKFLOWNAME.cfg
		echo "BKG=Random:"${BKG_LIST[idx]}                									>>$WORKFLOWNAME.cfg
		echo "ENVIRONMENT_FILE="$ENVIRONMENT_FILE         									>>$WORKFLOWNAME.cfg
		echo "ANA_ENVIRONMENT_FILE="$ANA_ENVIRONMENT_FILE 									>>$WORKFLOWNAME.cfg
		echo "GEN_MIN_ENERGY="$GEN_MIN_ENERGY             									>>$WORKFLOWNAME.cfg
		echo "GEN_MAX_ENERGY="$GEN_MAX_ENERGY             									>>$WORKFLOWNAME.cfg
		echo "RCDB_QUERY="${RCDBQUERY_LIST[idx]}                							>>$WORKFLOWNAME.cfg
		echo ""                                           									>>$WORKFLOWNAME.cfg
		echo "WORKFLOW_NAME="$WORKFLOWNAME                 									>>$WORKFLOWNAME.cfg
		echo "DATA_OUTPUT_BASE_DIR="$DATA_OUTPUT_BASE_DIR 									>>$WORKFLOWNAME.cfg

		echo "cfg at:" $OUTPUT_PATH/$WORKFLOWNAME/mcwrapper_configs/$WORKFLOWNAME.cfg

		# set up a log file to record workflow submission
		rm -f workflow_$WORKFLOWNAME.log
		echo "#This log file records output running gluex_MC.py."                           >>workflow_$WORKFLOWNAME.log


	done # Done with this reaction mechanism
	echo

done



######################################################
#      WORKFLOW SUBMISSION    (Don't need edit)      #
######################################################

# Set the MCWRAPPER env

echo " --------------------------------------------------------------------------------------- "
echo " Start workflow submission:"
echo " --------------------------------------------------------------------------------------- "
echo 
echo "Set up the farm: "
echo "DISK="$DISK                                 						
echo "RAM="$RAM                                   						
echo "TIMELIMIT="$TIMELIMIT                       						
echo "OS="$OS                                     						
echo "NCORES="$NCORES                             						
echo "BATCH_SYSTEM="$BATCH_SYSTEM                 									
echo "ACCOUNT="$ACCOUNT                           								
echo "PARTITION="$PARTITION                               						
echo "EXPERIMENT="$EXPERIMENT                              						
echo "GENERATOR="$GENERATOR                       						
echo "GEANT_VERSION="$GEANT_VERSION               						
echo "CUSTOM_PLUGINS=file:"$CUSTOM_PLUGINS             					
echo 
cat $CUSTOM_PLUGINS 
echo
echo " Run periods:"
echo
for idx in `seq 0 4`;
do
	echo " --------------------------------------- "
	echo ${PERIOD_LIST[idx]}
	echo "BKG=Random:"${BKG_LIST[idx]}
	echo "ENV="${ENV_LIST[idx]}
	echo "ANA="${ANAENV_LIST[idx]}
	echo "RCDB_QUERY="${RCDBQUERY_LIST[idx]}
	echo " --------------------------------------- "

	RUN_RANGE=${RUN_LIST[idx]}
	TESTRUN=${TESTRUN_LIST[idx]}

	# loop over reaction mechanisms
	NUM_MECH=$((${#MECH_LIST[@]}-1))
	for mech_idx in `seq 0 $NUM_MECH`;
	do
		# Build path for the output
		WORKFLOWNAME=`printf "%s_%s%s" "${PERIOD_LIST[idx]}" "$REACTION" "${MECH_LIST[mech_idx]}" `
		cfgPATH=$OUTPUT_PATH/$WORKFLOWNAME/mcwrapper_configs/$WORKFLOWNAME.cfg
		LOG_OUTPUT_DIR=${LOG_PATH}/${WORKFLOWNAME}
		echo "Log path set to: " $LOG_OUTPUT_DIR
		mkdir -p ${LOG_OUTPUT_DIR}

		echo "Mech="${MECH_LIST[mech_idx]}", workflow="$WORKFLOWNAME


		# Workflow submission
		if [ "$MODE" == "ifarm" ]; then      # real submission to farm
			echo "FARM MODE:  gluex_MC.py $cfgPATH $RUN_RANGE ${TRIGGER[idx]} cleanrecon=1 batch=2 logdir=${LOG_OUTPUT_DIR}"
			${MCWRAPPER_CENTRAL}/gluex_MC.py $cfgPATH $RUN_RANGE ${TRIGGER[idx]} cleanrecon=1 batch=2 logdir=${LOG_OUTPUT_DIR} |& tee -a $OUTPUT_PATH/$WORKFLOWNAME/mcwrapper_configs/workflow_$WORKFLOWNAME.log
		elif [ "$MODE" == "test" ]; then     # test on farm
			echo "TEST MODE:  gluex_MC.py $cfgPATH $TESTRUN $TESTTRIGGER cleanrecon=1 batch=2 logdir=${LOG_OUTPUT_DIR}"
			${MCWRAPPER_CENTRAL}/gluex_MC.py $cfgPATH $TESTRUN $TESTTRIGGER cleanrecon=1 batch=2 logdir=${LOG_OUTPUT_DIR} |& tee -a $OUTPUT_PATH/$WORKFLOWNAME/mcwrapper_configs/workflow_$WORKFLOWNAME.log
		else                                 # debug mode
			echo "In farm mode will run:      gluex_MC.py $cfgPATH $RUN_RANGE ${TRIGGER[idx]} cleanrecon=1 batch=2 logdir=${LOG_OUTPUT_DIR}"
			echo "In test mode will run:      gluex_MC.py $cfgPATH $TESTRUN $TESTTRIGGER cleanrecon=1 batch=2 logdir=${LOG_OUTPUT_DIR}"
		fi
		echo

	done # Done with this reaction mechanism
	echo

done




































