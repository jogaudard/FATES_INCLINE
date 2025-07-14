#!/bin/bash

set -e

cd /cluster/work/users/evaler/noresm/FATES_INCLINE/cases/BA-GSWP3-bedrock-1850

./xmlchange NTASKS=1  
./xmlchange DATM_MODE=CLMGSWP3v1
./xmlchange STOP_N=5 
./xmlchange STOP_OPTION=nyears
./xmlchange RUN_STARTDATE=1902-01-01,DATM_YR_START=1902,DATM_YR_END=1907
./xmlchange DATM_YR_ALIGN=1902

./xmlchange CLM_USRDAT_NAME=ALP4

./xmlchange CLM_USRDAT_DIR=/cluster/shared/noresm/inputdata/evaler/inputdata/skj_pt_gswp3
./xmlchange PTS_LON=6.41504
./xmlchange PTS_LAT=60.9335

./xmlchange JOB_WALLCLOCK_TIME=03:59:00
./xmlchange CLM_FORCE_COLDSTART=on
