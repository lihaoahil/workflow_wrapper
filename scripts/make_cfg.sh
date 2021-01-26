#!/bin/sh 
echo
TIME=$(date +"%Y_%m_%d_%I_%M_%p")
echo "Time:" $TIME
echo
 
#####################################################
# AUTHOR: Hao Li                                    #
# Date:   Jan/20/2021                               #
# The scripts helps automate simulation of the      #
# three reaction mechanisms in ppbar channel and    #
# five reaction mechanisms in lamlambar channel     #
# for all run periods                               #
#####################################################



##########################
#    CONFIGURATIONS      #
##########################

# WRAPPER path
WORKFLOWWRAPPER_PATH=/home/haoli/test/workflow_wrapper
MCWRAPPER_CENTRAL=/w/halld-scifs17exp/haoli/builds/test/gluex_MCwrapper

# Simulation related
REACTION=ppbar
RUN_LIST=('30274-31057' '40856-42559' '50685-51768' '51384-51457')  # Either single run number: 30730, or run range like 30796-30901 
TRIGGER=1000000
# test
TESTRUN_LIST=('30730' '40856' '50685' '51384')
TESTTRIGGER=500

# Farm related (do not change unless you know what you are doing)
DISK=5GB           # Max Disk usage
RAM=4GB            # Max RAM usage
TIMELIMIT=4h       # Max walltime (job 'ppbar 10000 evts w/ 1 core' runs roughly 1.5 hours)
NCORES=1
OS=centos77        # Specify CentOS65 machines
BATCH_SYSTEM=swif
PROJECT=gluex 
TRACK=simulation   # See here (https://scicomp.jlab.org/docs/batch_job_tracks)

# Softwares
GENERATOR=mc_gen   # Current event generator (https://github.com/JeffersonLab/halld_sim/tree/master/src/programs/Simulation/MC_GEN)
GEANT_VERSION=4   

# Path
#OUTPUT_PATH=/w/halld-scifs17exp/haoli/workflow_output  # See here for work (cache, volatile) usages: https://scicomp.jlab.org/scicomp/index.html#/work
OUTPUT_PATH=`printf "/raid4/haoli/test/workflow_out/%s_%s" "$REACTION" "$TIME" `

# Version, mech related lists
PERIOD_LIST=('S17v3' 'S18v2' 'F18v2' 'F18lowEv2')
MECH_LIST=('M6' 'M5a' 'M5b')
BKG_LIST=('recon-2017_01-ver03' 'recon-2018_01-ver02' 'recon-2018_08-ver02' 'recon-2018_08-ver02')
ENV_LIST=('recon-2017_01-ver03_22.xml' 'recon-2018_01-ver02_14.xml' 'recon-2018_08-ver02_13.xml' 'recon-2018_08-ver02_13.xml')
ANAENV_LIST=('analysis-2017_01-ver36.xml' 'analysis-2018_01-ver02.xml' 'analysis-2018_08-ver02.xml' 'analysis-2018_08-ver05.xml')
RCDBQUERY_LIST=('@is_production and @status_approved' '@is_2018production and @status_approved' '@is_2018production and @status_approved and beam_current > 49' '@is_2018production and @status_approved and beam_current < 49') # Got from https://halldweb.jlab.org/wiki-private/index.php/GlueX_Phase-I_Dataset_Summary



######################################################
#      SETUP & CONFIGURATION    (Don't need edit)    #
######################################################
echo
# take input
MODE=$1
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

# JANA configs
CUSTOM_PLUGINS=`printf "%s/scripts/reactions/jana_%s.config" "$WORKFLOWWRAPPER_PATH" "$REACTION" `
# Check if exists
if [ ! -f "$CUSTOM_PLUGINS" ]; then
	echo "Cannot find" $CUSTOM_PLUGINS"!"
	#exit
fi

# Loops to set up
for idx in `seq 0 3`;
do
	ENVIRONMENT_FILE=`printf "/group/halld/www/halldweb/html/halld_versions/%s" "${ENV_LIST[idx]}" `
	ANA_ENVIRONMENT_FILE=`printf "/group/halld/www/halldweb/html/halld_versions/%s" "${ANAENV_LIST[idx]}" `
	# Check if key files exist
	if [ ! -f "$ENVIRONMENT_FILE" ]; then
		echo "Cannot find" $ENVIRONMENT_FILE"!"
		#exit
	fi

	if [ ! -f "$ANA_ENVIRONMENT_FILE" ]; then
		echo "Cannot find" $ANA_ENVIRONMENT_FILE"!"
		#exit
	fi

	RUN_RANGE=${RUN_LIST[idx]}
	TESTRUN=${TESTRUN_LIST[idx]}
	for mech_idx in `seq 0 2`;
	do
		# Build path for the output
		WORKFLOWNAME=`printf "%s%s_%s" "$REACTION" "${MECH_LIST[mech_idx]}" "${PERIOD_LIST[idx]}" `  # WORKFLOW NAME
		DATA_OUTPUT_BASE_DIR=$OUTPUT_PATH/$WORKFLOWNAME
		
		# Check if def exists
		GENERATOR_CONFIG=`printf "%s/scripts/def/%s_%s.def" "$WORKFLOWWRAPPER_PATH" "$REACTION" "${MECH_LIST[mech_idx]}" `
		if [ ! -f "$GENERATOR_CONFIG" ]; then
			echo "Cannot find" $GENERATOR_CONFIG"!"
			#exit
		fi



		# Determine the erergy according to run periods
		if [ "${PERIOD_LIST[idx]}" != "fall18lowEv2" ]; then
			GEN_MIN_ENERGY=6.0
			GEN_MAX_ENERGY=11.6
		else
			GEN_MIN_ENERGY=3.8
			GEN_MAX_ENERGY=5.8
		fi

		# Determine track and trigger for different mode
		if [ "$MODE" != "ifarm" ]; then
			TRACK=debug  # for highest priority
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
		echo "PROJECT="$PROJECT                           									>>$WORKFLOWNAME.cfg
		echo "TRACK="$TRACK                               									>>$WORKFLOWNAME.cfg
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
		echo "WORKFLOWNAME="$WORKFLOWNAME                 									>>$WORKFLOWNAME.cfg
		echo "DATA_OUTPUT_BASE_DIR="$DATA_OUTPUT_BASE_DIR 									>>$WORKFLOWNAME.cfg


	done # Done with this reaction mechanism
	echo

done



######################################################
#      WORKFLOW SUBMISSION    (Don't need edit)      #
######################################################

# Set the MCWRAPPER env
setenv MCWRAPPER_CENTRAL $MCWRAPPER_CENTRAL
echo $MCWRAPPER_CENTRAL
echo 

echo " Start workflow submission:"
echo
for idx in `seq 0 3`;
do
	echo " --------------------------------------------------------------------------------------- "
	echo "Run Period="${PERIOD_LIST[idx]}", ENV="${ENV_LIST[idx]}", ANA="${ANAENV_LIST[idx]}
	echo " --------------------------------------------------------------------------------------- "

	RUN_RANGE=${RUN_LIST[idx]}
	TESTRUN=${TESTRUN_LIST[idx]}
	for mech_idx in `seq 0 2`;
	do
		# Build path for the output
		WORKFLOWNAME=`printf "%s%s_%s" "$REACTION" "${MECH_LIST[mech_idx]}" "${PERIOD_LIST[idx]}" `  # WORKFLOW NAME
		echo "Mech="${MECH_LIST[mech_idx]}", workflow="$WORKFLOWNAME 


		# Workflow submission
		if [ "$MODE" == "ifarm" ]; then      # real submission to farm
			echo "FARM MODE: " gluex_MC.py $WORKFLOWNAME.cfg $RUN_RANGE $TRIGGER batch=2
			gluex_MC.py $WORKFLOWNAME.cfg $RUN_RANGE $TRIGGER batch=2
		elif [ "$MODE" == "test" ]; then     # test on farm
			echo "TEST MODE: " gluex_MC.py $WORKFLOWNAME.cfg $TESTRUN $TESTTRIGGER batch=0
			gluex_MC.py $WORKFLOWNAME.cfg $RUN $TRIGGER batch=0
		else                                 # debug mode
			echo "In farm mode will run:     " gluex_MC.py $WORKFLOWNAME.cfg $RUN_RANGE $TRIGGER batch=2
			echo "In test mode will run:     " gluex_MC.py $WORKFLOWNAME.cfg $TESTRUN $TESTTRIGGER batch=0
			echo "cfg at:                    " $OUTPUT_PATH/$WORKFLOWNAME/mcwrapper_configs/$WORKFLOWNAME.cfg
		fi
		echo

	done # Done with this reaction mechanism
	echo

done




































