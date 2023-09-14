#!/bin/tcsh -f


set WORKINGDIR=/scratch/slurm_$SLURM_JOBID
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
source /home/haoli/env/test11.csh
#source /home/haoli/env/set_version.csh

#Cast ROOT commands
set PROOF=0
echo "PROOF is on"
set ROOTScript=`printf 'run.C("%s", %d, %d, "%s", "%s", "%s", "%s", "%s")' "$TreeName" "$PROOF" "$THREADS" "input.root" "$OutPutName" "$OutPutTreeName" "$FlatTreeName" "$DSelectorName"`
#Move DSelector to $WORKINGDIR
cd $WORKINGDIR
scp ${OUTPUTDIR}/dselectors/DSelector_${DSelectorName}.C ./
scp ${OUTPUTDIR}/dselectors/DSelector_${DSelectorName}.h ./
scp ${LOCALDIR}/script/run.C ./
scp -l 10000 $Data ./input.root  #limit the data scp speed not over 10 MB/s
scp -l 10000 /home/gluex2/gluexdb/ccdb_2023_03_01.sqlite ./ccdb.sqlite
touch $WORKINGDIR/data_output.csv

ls -lah
echo
##------------- Set new CCDB CONNECTION to accelerate --------------
setenv CCDB_CONNECTION sqlite:////$WORKINGDIR/ccdb.sqlite
echo ccdb is at $CCDB_CONNECTION
#------------- Prepare DSelector Analysis --------------
echo calling: $ROOTScript
echo 
root -l -b -q "$ROOTScript"  
ls -lah
#------------- MOVE PRODUCTS BACK TO OUTPUT DIRECTORY --------------


if ($PROOF == 0) then
	echo "copy back" $DSelectorName.root
	#set OutPutName=$DSelectorName.root
	cp $WORKINGDIR/$DSelectorName.root ${OUTPUTDIR}/$OutPutName
	#cp $WORKINGDIR/data_output.csv ${OUTPUTDIR}/data_output.csv
else
	cp $WORKINGDIR/${OutPutName} ${OUTPUTDIR}/.     
endif

#cp $WORKINGDIR/${OutPutTreeName} ${OUTPUTDIR}/trees/.
#cp $WORKINGDIR/${FlatTreeName} ${OUTPUTDIR}/trees.
echo "hist files are transfered back."


exit 0










