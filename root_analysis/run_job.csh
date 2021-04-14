#!/bin/tcsh -f


set WORKINGDIR=/scratch/PBS_$SLURM_JOBID
set SCP=/usr/bin/scp
#------------- Check Parameters --------------
echo "The job is running with         " $THREADS" threads on "$QUEUE" queue"
echo "Working directory is in         " $WORKINGDIR
echo "Input data is                   " $Data
echo "Tree name is                    " $TreeName
echo "local directory is in           " $LOCALDIR
echo "MakeDSelector configuration is  " $ConfigPath

echo "Output directory is in          " $OUTPUTDIR
echo "Output files are                " $OutPutName ", " $OutPutTreeName ", " $FlatTreeName 


#------------- Prepare DSelector Analysis --------------
#set up the environment
source /home/haoli/env/test.csh
#source /home/haoli/env/set_version.csh

#Cast ROOT commands
set PROOF=-1
echo "PROOF is on"
set ROOTScript=`printf 'run.C("%s", %d, %d, "%s", "%s", "%s", "%s", "%s")' "$TreeName" "$PROOF" "$THREADS" "input.root" "$OutPutName" "$OutPutTreeName" "$FlatTreeName" "$DSelectorName"`
#Move DSelector to $WORKINGDIR
cd $WORKINGDIR
scp ${OUTPUTDIR}/DSelector_${DSelectorName}.C ./
scp ${OUTPUTDIR}/DSelector_${DSelectorName}.h ./
scp ${LOCALDIR}/script/run.C ./
scp -l 10000 $Data ./input.root  #limit the data scp speed not over 10 MB/s
scp -l 10000 /home/gluex2/gluexdb/ccdb_2020_11_13.sqlite ./

ls -lah
echo
##------------- Set new CCDB CONNECTION to accelerate --------------
setenv CCDB_CONNECTION sqlite:////$WORKINGDIR/ccdb_2020_11_13.sqlite
echo ccdb is at $CCDB_CONNECTION
#------------- Prepare DSelector Analysis --------------
echo calling: $ROOTScript
echo 
root -l -b -q "$ROOTScript"  
ls -lah
#------------- MOVE PRODUCTS BACK TO OUTPUT DIRECTORY --------------

cp $WORKINGDIR/${OutPutName} ${OUTPUTDIR}/.
#cp $WORKINGDIR/${OutPutTreeName} ${OUTPUTDIR}/trees/.
#cp $WORKINGDIR/${FlatTreeName} ${OUTPUTDIR}/trees.
echo "hist files are transfered back."


exit 0










