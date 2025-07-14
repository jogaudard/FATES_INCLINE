#!/bin/bash

# Baseline simulation with GSWP3 forcing, All PFTs - (BA-GSWP3)

CASE_ROOT=/cluster/work/users/evaler/noresm/FATES_INCLINE/cases
CASE_NAME=BA-GSWP3-bedrock-1850
PROJECT=nn9774k
COMPSET=1850_DATM%GSWP3v1_CLM50%FATES_SICE_SOCN_MOSART_SGLC_SWAV
UMODS_ROOT=/cluster/shared/noresm/inputdata/evaler/inputdata/skj_pt_gswp3

cd /cluster/home/evaler/CTSM/cime/scripts/

./create_newcase --case $CASE_ROOT/$CASE_NAME --compset $COMPSET \
--driver nuopc --res CLM_USRDAT --machine betzy --run-unsupported \
--user-mods-dirs $UMODS_ROOT/user_mods --project $PROJECT
