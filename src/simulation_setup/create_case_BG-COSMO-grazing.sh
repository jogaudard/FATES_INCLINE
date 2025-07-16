#!/bin/bash

# Baseline simulation with COSMO forcing, Grass PFTs only, grazing enabled - (BG-COSMO-grazing)

CASE_ROOT=/cluster/work/users/evaler/noresm/FATES_INCLINE/cases
CASE_NAME=BG-COSMO-grazing
PROJECT=nn9774k
COMPSET=I2000Clm50Fates
UMODS_ROOT=/cluster/shared/noresm/inputdata/evaler/inputdata/ALP4-COSMO

cd /cluster/home/evaler/CTSM/cime/scripts/

./create_newcase --case $CASE_ROOT/$CASE_NAME --compset $COMPSET \
--driver nuopc --res CLM_USRDAT --machine betzy --run-unsupported \
--user-mods-dirs $UMODS_ROOT/user_mods --project $PROJECT
