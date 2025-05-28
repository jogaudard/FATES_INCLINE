#!/bin/bash

set -o errexit  # Exit the script on any error

# load environment
module --quiet purge  # Reset the modules to the system default
module load Miniforge3/24.1.2-0
#source ${EBROOTMINIFORGE3}/bin/activate
source ${EBROOTMINIFORGE3}/etc/profile.d/conda.sh
conda activate /cluster/projects/nn9774k/conda/evaler/ctsm-env

# Get the case name from the first command-line argument
CASENAME="$1"

# concatenate history files
ncrcat /cluster/work/users/evaler/archive/$CASENAME/lnd/hist/*.nc \
       /cluster/work/users/evaler/noresm/FATES_INCLINE/cases/$CASENAME/${CASENAME}.concatenated.nc

