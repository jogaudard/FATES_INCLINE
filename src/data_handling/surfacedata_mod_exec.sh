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
cp /cluster/home/evaler/inputdata/skj_pt_gswp3/surfdata_ALP4_hist_2000_16pfts_c250521.nc \
              /cluster/home/evaler/inputdata/surfdata_ALP4_hist_2000_16pfts_c250521.nc

# Load and activate environment
module purge
module load Miniforge3/24.1.2-0
source ${EBROOTMINIFORGE3}/etc/profile.d/conda.sh
conda activate /cluster/projects/nn9774k/conda/evaler/ctsm-env

# Run the Python script
cd /cluster/work/users/evaler/noresm/FATES_INCLINE/src/data_handling
python surfacedata_modification.py

# copy the modified surface data into the forcing data folders
cp /cluster/home/evaler/inputdata/surfdata_ALP4_hist_2000_16pfts_c250521.nc \
   /cluster/home/evaler/inputdata/skj_pt_gswp3/surfdata_ALP4_hist_2000_16pfts_c250521.nc
cp /cluster/home/evaler/inputdata/surfdata_ALP4_hist_2000_16pfts_c250521.nc \
   /cluster/home/evaler/inputdata/ALP4-COSMO/surfdata_ALP4_hist_2000_16pfts_c250521.nc
cp /cluster/home/evaler/inputdata/surfdata_ALP4_hist_2000_16pfts_c250521.nc \
   /cluster/home/evaler/inputdata/ALP4-COSMO-warmed/surfdata_ALP4_hist_2000_16pfts_c250521.nc

echo "Job finished at $(date)"