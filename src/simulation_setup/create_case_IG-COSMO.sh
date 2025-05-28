#!/bin/bash

CASE_ROOT=/cluster/work/users/evaler/noresm/FATES_INCLINE/cases
CASE_NAME=SKJ1PT_IG-COSMO
PROJECT=nn9774k
COMPSET=I2000Clm50Fates
UMODS_ROOT=/cluster/home/evaler/inputdata/ALP4-COSMO

export PARAM_FILES=/paramfiles

cd /cluster/home/evaler/CTSM/cime/scripts/

./create_newcase --case $CASE_ROOT/$CASE_NAME --compset $COMPSET \
--driver nuopc --res CLM_USRDAT --machine betzy --run-unsupported \
--user-mods-dirs $UMODS_ROOT/user_mods --project $PROJECT
