#!/bin/bash

# activate conda environment
module purge
module load Miniforge3/24.1.2-0
source ${EBROOTMINIFORGE3}/bin/activate
export CONDA_PKGS_DIRS=/cluster/projects/nn9774k/conda/evaler/package-cache
export CONDA_ENV_SRC=/cluster/projects/nn9774k/conda/evaler

conda activate /cluster/projects/nn9774k/conda/evaler/ctsm-env

# go to input data folder
cd /cluster/home/evaler/inputdata

# make a copy of surface data file to be converted
cp surfdata_ALP4_hist_2000_16pfts_c250521.nc surfdata_ALP4_hist_2000_16pfts_c250521_4.nc

# convert from netcdf 4 to 5
nccopy -k 'cdf5' surfdata_ALP4_hist_2000_16pfts_c250521_4.nc surfdata_ALP4_hist_2000_16pfts_c250521.nc
