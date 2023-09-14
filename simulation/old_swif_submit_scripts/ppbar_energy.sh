#!/bin/sh 

 
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

# Path
MCWRAPPER_CENTRAL=/w/halld-scshelf2101/haoli/builds/test/gluex_MCwrapper
WORKFLOWWRAPPER_JLAB=/u/home/haoli/workflow/workflow_wrapper #https://github.com/lihaoahil/workflow_wrapper
WORKFLOWWRAPPER_CMU=/home/haoli/test/workflow_wrapper
OUTPUT_JLAB=/w/halld-scshelf2101/home/haoli/simulation/workflow_out    # See here for work/cache/volatile usages: https://scicomp.jlab.org/scicomp/index.html#/work
OUTPUT_CMU=/raid4/haoli/test/workflow_out

# Simulation related
REACTION=ppbar
RUN_LIST=('30274-31057' '40856-42559' '50685-51768' '51384-51457')  # Either single run number: 30730, or run range like 30796-30901 
TRIGGER=2000000
# test
TESTRUN_LIST=('31057' '42559' '50685' '51384')
TESTTRIGGER=5000

# Farm related (do not change unless you know what you are doing)
DISK=5GB           # Max Disk usage
RAM=4GB            # Max RAM usage
TIMELIMIT=4h       # Max walltime (job 'ppbar 10000 evts w/ 1 core' runs roughly 1.5 hours)
NCORES=1
OS=centos79        # Specify CentOS65 machines
BATCH_SYSTEM=swif
PROJECT=gluex 
TRACK=simulation   # See here (https://scicomp.jlab.org/docs/batch_job_tracks)

# Softwares
GENERATOR=mc_gen   # Current event generator (https://github.com/JeffersonLab/halld_sim/tree/master/src/programs/Simulation/MC_GEN)
GEANT_VERSION=4   

# Version, mech related lists
PERIOD_LIST=('S17v3' 'S18v2' 'F18v2' 'F18lowEv2')
MECH_LIST=('M6' 'M5a' 'M5b')
BKG_LIST=('recon-2017_01-ver03.2' 'recon-2018_01-ver02.2' 'recon-2018_08-ver02.2' 'recon-2018_08-ver02.2')
#ENV_LIST=('recon-2017_01-ver03_27.xml' 'recon-2018_01-ver02_20.xml' 'recon-2018_08-ver02_19.xml' 'recon-2018_08-ver02_19.xml')
ENV_LIST=('recon-2017_01-ver03_21.xml' 'recon-2018_01-ver02_13.xml' 'recon-2018_08-ver02_13.xml' 'recon-2018_08-ver02_13.xml')
ANAENV_LIST=('analysis-2017_01-ver36.xml' 'analysis-2018_01-ver02.xml' 'analysis-2018_08-ver02.xml' 'analysis-2018_08-ver05.xml')
RCDBQUERY_LIST=('@is_production and @status_approved' '@is_2018production and @status_approved' '@is_2018production and @status_approved and beam_current > 49' '@is_2018production and @status_approved and beam_current < 49') # Got from https://halldweb.jlab.org/wiki-private/index.php/GlueX_Phase-I_Dataset_Summary
# Energy-dependent settings: 
#   INDEX=  0     1     2     3     4     5     6
EMIN_LIST=('3.8' '4.8' '6.4' '7.6' '8.2' '8.8' '10.0')
EMAX_LIST=('4.8' '5.8' '7.6' '8.2' '8.8' '10.0' '11.4')

PAR1_LIST=('0.24' '0.37' '0.36' '0.39' '0.41' '0.40' '0.41')
PAR2_LIST=('0.24' '0.22' '0.23' '0.23' '0.24' '0.21' '0.22')
PAR3_LIST=('0.03' '0.08' '0.08' '0.09' '0.10' '0.13' '0.13')

PAR4_LIST=('0.49' '0.43' '0.46' '0.44' '0.44' '0.40' '0.42')
PAR5_LIST=('0.02' '0.05' '0.23' '0.21' '0.21' '0.16' '0.12')
PAR6_LIST=('0.15' '0.36' '0.45' '0.47' '0.50' '0.56' '0.57')

PAR7_LIST=('0.88' '0.88' '0.81' '0.79' '0.90' '0.78' '0.79')
PAR8_LIST=('1.70' '1.70' '1.63' '1.60' '1.57' '1.62' '1.58')
PAR9_LIST=('0.65' '0.65' '0.60' '0.57' '0.52' '0.61' '0.60')

CCDBSQLITEPATH=/group/halld/www/halldweb/html/dist/ccdb.sqlite
RCDBSQLITEPATH=/group/halld/www/halldweb/html/dist/rcdb.sqlite
######################################################
#      SETUP & CONFIGURATION    (Don't need edit)    #
######################################################

# take input
MODE=$1
WF_TAG=$2
ENERGY_INDEX=$3 # 0,1 lowE; 2,3,4,5,6 highE

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
echo "Energy range:" ${EMIN_LIST[ENERGY_INDEX]} "-" ${EMAX_LIST[ENERGY_INDEX]}
echo "Parameters:" ${PAR1_LIST[ENERGY_INDEX]}, ${PAR2_LIST[ENERGY_INDEX]}, ${PAR3_LIST[ENERGY_INDEX]}, ${PAR4_LIST[ENERGY_INDEX]}, ${PAR5_LIST[ENERGY_INDEX]}, ${PAR6_LIST[ENERGY_INDEX]}, ${PAR7_LIST[ENERGY_INDEX]}, ${PAR8_LIST[ENERGY_INDEX]}, ${PAR9_LIST[ENERGY_INDEX]}
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
for idx in `seq 0 3`;
do
	if [ "$ENERGY_INDEX" -gt 1 ] && [ "$idx" -eq 3 ]; then
		continue
	fi

	if [ "$ENERGY_INDEX" -lt 2 ] && [ "$idx" -lt 3 ]; then
                continue
        fi

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
	for mech_idx in `seq 0 2`;
	do
		# Build path for the output
		WORKFLOWNAME=`printf "%s_%s_%s%s" "$WF_TAG" "${PERIOD_LIST[idx]}" "$REACTION" "${MECH_LIST[mech_idx]}" `  # WORKFLOW NAME
		DATA_OUTPUT_BASE_DIR=$OUTPUT_PATH/$WORKFLOWNAME
		
		# Check if def exists
		DEF_PATH=`printf "%s/simulation/def_temp/%s_%s.def" "$WORKFLOWWRAPPER_PATH" "$REACTION" "${MECH_LIST[mech_idx]}" `
		if [ ! -f "$DEF_PATH" ]; then
			echo "Cannot find" $DEF_PATH"!"
			exit
		fi
		# cp and edit the final version of definition files
		mkdir -p $DATA_OUTPUT_BASE_DIR/defs
		cd $DATA_OUTPUT_BASE_DIR/defs
		GENERATOR_CONFIG=`printf "%s/defs/%s_%s.def" "$DATA_OUTPUT_BASE_DIR" "$REACTION" "${MECH_LIST[mech_idx]}" `
		cp $DEF_PATH .
		if [ "$mech_idx" -eq 0 ]; then
			loc_PAR1=${PAR1_LIST[ENERGY_INDEX]}
			loc_PAR2=${PAR2_LIST[ENERGY_INDEX]}
			loc_PAR3=${PAR3_LIST[ENERGY_INDEX]}
		elif [ "$mech_idx" -eq 1 ]; then
                        loc_PAR1=${PAR4_LIST[ENERGY_INDEX]}
                        loc_PAR2=${PAR5_LIST[ENERGY_INDEX]}
                        loc_PAR3=${PAR6_LIST[ENERGY_INDEX]}
		else
                        loc_PAR1=${PAR7_LIST[ENERGY_INDEX]}
                        loc_PAR2=${PAR8_LIST[ENERGY_INDEX]}
                        loc_PAR3=${PAR9_LIST[ENERGY_INDEX]}
		fi

		#echo $loc_PAR1 $loc_PAR2 $loc_PAR3
		echo def at: $GENERATOR_CONFIG
		sed -i 's/PAR1/'$loc_PAR1'/' $GENERATOR_CONFIG
		sed -i 's/PAR2/'$loc_PAR2'/' $GENERATOR_CONFIG
		sed -i 's/PAR3/'$loc_PAR3'/' $GENERATOR_CONFIG
	
		# Determine the energy according to run periods
		GEN_MIN_ENERGY=${EMIN_LIST[ENERGY_INDEX]}
		GEN_MAX_ENERGY=${EMAX_LIST[ENERGY_INDEX]}

		# Determine track and trigger for different mode
		if [ "$MODE" != "ifarm" ]; then
			TRACK=debug  # for highest priority
		fi

		# Write configurations into .cfg files
		mkdir -p $DATA_OUTPUT_BASE_DIR/mcwrapper_configs
		cd $DATA_OUTPUT_BASE_DIR/mcwrapper_configs
		rm -f $WORKFLOWNAME.cfg
		
		echo "#This config file was used to submit workflow: " $WORKFLOWNAME                                                    >>$WORKFLOWNAME.cfg
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
		echo "CUSTOM_PLUGINS=file:"$CUSTOM_PLUGINS             							  	        >>$WORKFLOWNAME.cfg
		echo ""                                           									>>$WORKFLOWNAME.cfg
		echo "GENERATOR_CONFIG="$GENERATOR_CONFIG                                                                               >>$WORKFLOWNAME.cfg
		echo "BKG=Random:"${BKG_LIST[idx]}                									>>$WORKFLOWNAME.cfg
		echo "ENVIRONMENT_FILE="$ENVIRONMENT_FILE         									>>$WORKFLOWNAME.cfg
		echo "ANA_ENVIRONMENT_FILE="$ANA_ENVIRONMENT_FILE 									>>$WORKFLOWNAME.cfg
		#echo "CCDBSQLITEPATH="$CCDBSQLITEPATH                                                                                   >>$WORKFLOWNAME.cfg
		#echo "RCDBSQLITEPATH="$RCDBSQLITEPATH                                                                                   >>$WORKFLOWNAME.cfg
		echo "GEN_MIN_ENERGY="$GEN_MIN_ENERGY             									>>$WORKFLOWNAME.cfg
		echo "GEN_MAX_ENERGY="$GEN_MAX_ENERGY             									>>$WORKFLOWNAME.cfg
		echo "RCDB_QUERY="${RCDBQUERY_LIST[idx]}                							        >>$WORKFLOWNAME.cfg
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
echo "PROJECT="$PROJECT                           						
echo "TRACK="$TRACK                               						
echo "GENERATOR="$GENERATOR                       						
echo "GEANT_VERSION="$GEANT_VERSION               						
echo "CUSTOM_PLUGINS=file:"$CUSTOM_PLUGINS             					
echo 
echo
echo " Run periods:"
echo
for idx in `seq 0 3`;
do
	if [ "$ENERGY_INDEX" -gt 1 ] && [ "$idx" -eq 3 ]; then
                continue
        fi

        if [ "$ENERGY_INDEX" -lt 2 ] && [ "$idx" -lt 3 ]; then
                continue
        fi

	echo " --------------------------------------- "
	echo ${PERIOD_LIST[idx]}
	echo "BKG=Random:"${BKG_LIST[idx]}
	echo "ENV="${ENV_LIST[idx]}
	echo "ANA="${ANAENV_LIST[idx]}
	echo "RCDB_QUERY="${RCDBQUERY_LIST[idx]}
	echo " --------------------------------------- "

	RUN_RANGE=${RUN_LIST[idx]}
	TESTRUN=${TESTRUN_LIST[idx]}
	for mech_idx in `seq 0 2`;
	do
		# Build path for the output
		WORKFLOWNAME=`printf "%s_%s_%s%s" "$WF_TAG" "${PERIOD_LIST[idx]}" "$REACTION" "${MECH_LIST[mech_idx]}" `
		cfgPATH=$OUTPUT_PATH/$WORKFLOWNAME/mcwrapper_configs/$WORKFLOWNAME.cfg
		echo "Mech="${MECH_LIST[mech_idx]}", workflow="$WORKFLOWNAME


		# Workflow submission
		if [ "$MODE" == "ifarm" ]; then      # real submission to farm
			echo "FARM MODE: " \$MCWRAPPER_CENTRAL/gluex_MC.py $cfgPATH $RUN_RANGE $TRIGGER cleanrecon=1 batch=2 
			$MCWRAPPER_CENTRAL/gluex_MC.py $cfgPATH $RUN_RANGE $TRIGGER cleanrecon=1 batch=2 |& tee -a $OUTPUT_PATH/$WORKFLOWNAME/mcwrapper_configs/workflow_$WORKFLOWNAME.log
		elif [ "$MODE" == "test" ]; then     # test on farm
			echo "TEST MODE: " \$MCWRAPPER_CENTRAL/gluex_MC.py $cfgPATH $TESTRUN $TESTTRIGGER cleanrecon=1 batch=2
			$MCWRAPPER_CENTRAL/gluex_MC.py $cfgPATH $TESTRUN $TESTTRIGGER cleanrecon=1 batch=2 |& tee -a $OUTPUT_PATH/$WORKFLOWNAME/mcwrapper_configs/workflow_$WORKFLOWNAME.log
		else                                 # debug mode
			echo "In farm mode will run:     " \$MCWRAPPER_CENTRAL/gluex_MC.py $cfgPATH $RUN_RANGE $TRIGGER cleanrecon=1 batch=2 
			echo "In test mode will run:     " \$MCWRAPPER_CENTRAL/gluex_MC.py $cfgPATH $TESTRUN $TESTTRIGGER cleanrecon=1 batch=2
		fi
		echo

	done # Done with this reaction mechanism
	echo

done




































