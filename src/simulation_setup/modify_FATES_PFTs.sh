#!/bin/bash

set -o errexit  # Exit the script on any error

module --quiet purge  # Reset the modules to the system default
module load Miniforge3/24.1.2-0
source ${EBROOTMINIFORGE3}/bin/activate
export CONDA_PKGS_DIRS=/cluster/projects/nn9774k/conda/evaler/package-cache
export CONDA_ENV_SRC=/cluster/projects/nn9774k/conda/evaler

conda activate $CONDA_ENV_SRC/ctsm-env

# save a copy of the default parameterfile
cd /cluster/home/evaler/CTSM/src/fates/parameter_files
cp fates_params_default.cdl fates_params_default_unchanged.cdl

# modify SLA of the grass PFTs (arctic_c3_grass,cool_c3_grass,c4_grass)
# for one PFT at a time
cd /cluster/home/evaler/CTSM/src/fates/tools

./modify_fates_paramfile.py --input ../parameter_files/fates_params_default.cdl \
--output ../parameter_files/fates_params_default.cdl \
--variable fates_leaf_slatop \
--PFT 12 \
--value 0.0376

./modify_fates_paramfile.py --input ../parameter_files/fates_params_default.cdl \
--output ../parameter_files/fates_params_default.cdl \
--variable fates_leaf_slatop \
--PFT 13 \
--value 0.0376

./modify_fates_paramfile.py --input ../parameter_files/fates_params_default.cdl \
--output ../parameter_files/fates_params_default.cdl \
--variable fates_leaf_slatop \
--PFT 14 \
--value 0.0376

# Use the IndexSwapper to make a new parameter file with grasses only
GRASSINDICES=12,13,14

./FatesPFTIndexSwapper.py --pft-indices= $GRASSINDICES \
--fin ../parameter_files/fates_params_default.cdl \
--fout ../parameter_files/fates_params_grassonly.cdl
