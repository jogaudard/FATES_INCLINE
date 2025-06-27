#!/bin/bash
#SBATCH --job-name=surfdatmod
#SBATCH --output=logs/slurm-%j.out
#SBATCH --account=nn9774k
#SBATCH --time=00:10:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1

set -o errexit

echo "Starting job on $(hostname) at $(date)"

# make a new copy of the surfacedata to be modified
cp /cluster/shared/noresm/inputdata/evaler/inputdata/skj_pt_gswp3/surfdata_ALP4_hist_2000_16pfts_c250625.nc \
   /cluster/work/users/evaler/noresm/FATES_INCLINE/data/surfdata_ALP4_hist_2000_16pfts_c250625_modified.nc

# Load and activate environment
module purge
module load Miniforge3/24.1.2-0
source ${EBROOTMINIFORGE3}/etc/profile.d/conda.sh
conda activate /cluster/projects/nn9774k/conda/evaler/ctsm-env

# Run the Python script to modify surface data
cd /cluster/work/users/evaler/noresm/FATES_INCLINE/src/data_handling
python surfacedata_modification.py

echo "Surface data modification finished"

# Convert the surface data to cdf5 format
cd /cluster/work/users/evaler/noresm/FATES_INCLINE/data
cp surfdata_ALP4_hist_2000_16pfts_c250625_modified.nc surfdata_ALP4_hist_2000_16pfts_c250625_modified_4.nc
nccopy -k 'cdf5' surfdata_ALP4_hist_2000_16pfts_c250625_modified_4.nc surfdata_ALP4_hist_2000_16pfts_c250625_modified.nc

# copy the modified surface data back to the data directory
cp /cluster/work/users/evaler/noresm/FATES_INCLINE/data/surfdata_ALP4_hist_2000_16pfts_c250625_modified.nc \
   /cluster/shared/noresm/inputdata/evaler/inputdata/surfdata_ALP4_hist_2000_16pfts_c250625_modified.nc

echo "Surface data converted and job finished at $(date)"
