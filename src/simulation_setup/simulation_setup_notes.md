# Simulation setup instructions

This document was created 2025-05-12 and is heavily inspired by https://hackmd.io/@pYjjfkwmSfW932OvIjzLHA/H1YNgFXqJl

This guide is written to document model installation, simulations setup, and running the model on the Norwegian HPC Betzy. CTSM and my own forcing data (subset and modified from defaults) are stored on my home folder (/cluster/home/evaler/), shared default data is available in the project (for the data subsetting), and the FATES_INCLINE repo, case folders, and model outputs are in my Betzy work folder (/cluster/work/users/evaler/).

## Simulations

The goal is to perform:

* two initial out-of-the-box simulations (B - baseline), but with improved surface data changed according to local observations. One will include all the default PFTs (A), while the other will be restricted to grass PFTs only (G). These will use a 2000 compset and cold start, thus representing a recent climate and *not* historical progression. The goal is to see how the model performs out of the box, and run simulations that are long enough to get an equilibrium with the climate and stable soil properties. These serve two purposes: First, results from the last 10(?) years will be reported on as the model's baseline for the site. Second, restart files from these two simulations will be re-used as spinup for the subsequent simulations.
	* GSWP3 forcing, All PFTs - (BA-GSWP3)
	* GSWP3 forcing, Grass PFTs - (BG-GSWP3)
* three improved (I) simulations, using the two baseline simulations as spinup, where the vegetation will reach a new equilibrium and data for the results will be taken from the final 14/16 years. These simulations will also be run with a year-2000 compset, and either of all (A) or grass (G) PFTs. A regional data set, COSMO-REA6, will be used as atmospheric forcing. An additional simulation will have  modified, warmed COSMO-REA6 forcing (COSMO-Warmed) with 1 degree C higher temperature.
	* COSMO forcing, All PFTs - (IA-COSMO)
	* COSMO forcing, Grass PFTs - (IG-COSMO)
	* Warmed COSMO forcing, Grass PFTs, (IG-COSMO-W)
	
All simulaitons are single-site, at the Skjellingahaugen site of the Vestland Climate Grid. This site is also available in the LSP. Skjellingahaugen has coordinates lon 6.41504, lat 60.9335. Alpine vegetation at 1088 m elevation. Mean summer temperature is 7 degrees C, and mean annual precipitation is 3402 mm.

## Initial set up of model 

Download the Community Terrestrial Systems Model (incl. CLM)

```
git clone https://github.com/NorESMhub/CTSM.git
cd CTSM
git checkout tags/ctsm5.3.034_noresm_v6 -b ctsm5.3.034_noresm_v6
./bin/git-fleximod update
```

## Set up model input data

Store model input data (atmospheric forcing, durface data, domain) under /cluster/home/evaler/inputdata. 

Check whether it's possible to re-use the data from the old setup, at least the atmospheric forcing. 

Prepared single-site forcing available on GitHub, modified from the [NorESM-LSP](). All these prepared folders include modified surface data (see [the dataprep_surfacedata notebook](https://github.com/evalieungh/FATES_INCLINE/blob/main/src/data_handling/dataprep_surfacedata.ipynb)). Zipped files are available for GSWP3, COSMO, and COSMO-Warmed under [evalieungh/FATES_INCLINE/main/data/](https://github.com/evalieungh/FATES_INCLINE/tree/main/data).

Download the data using direct download links to the zipped files for ALP4 (Skjellingahaugen):

```
cd ~/fates_incline/inputdata
# GSWP3
wget https://raw.githubusercontent.com/evalieungh/FATES_INCLINE/main/data/ALP4.zip
# COSMO
wget https://raw.githubusercontent.com/evalieungh/FATES_INCLINE/main/data/ALP4_cosmorea_noleap.zip
# COSMO-Warmed
wget https://raw.githubusercontent.com/evalieungh/FATES_INCLINE/main/data/ALP4_cosmorea_warmed.zip
```

Unzip the folders into Betzy login node folder fates_incline/ALP4-GSWP3 etc with `unzip`

### **ALTERNATIVE** Use new data

See [notes on forcing data preparation](../data_handling/create_singlepoint_gswp3.md)

### Modify surface data and replace old (LSP) version

First, manually upload the following Vestland Climate Grid data files (from https://osf.io/npfa9) to the data folder (/cluster/work/users/evaler/noresm/FATES_INCLINE/data/VCG_OSF):
- https://osf.io/s9k7c, VCG_clean_gridded_daily_climate_2008-2022.csv
- VCG_clean_soil_chemistry_2009_2010_2013_2015.csv
- VCG_clean_soil_structure_2013_2014_2018.csv
- VCG_clean_soilmoisture_plotlevel_2015-2018.csv

Then run this shell script that executes a python script to read and process data and create a modified version, and replaces the surface data in the input data folders with the new modified version:
```
cd /cluster/work/users/evaler/noresm/FATES_INCLINE/src/data_handling
chmod +x surfacedata_mod_exec.sh
chmod +x surfacedata_modification.py
./surfacedata_mod_exec.sh
```

### Changes to manually specify input data location

Replace the contents of this file with the code below: CTSM/tools/site_and_regional/default_data_2000.cfg.

```
[main]
clmforcingindir = /cluster/home/evaler/inputdata

[datm_gswp3]
# dir not changed! see if this works... 
domain = /cluster/home/evaler/fates_incline/inputdata/ALP4-GSWP3/domain.lnd.fv0.9x1.25_gx1v7_ALP4_c221027.nc

[surfdat]
dir = /cluster/home/evaler/fates_incline/inputdata/ALP4-GSWP3
surfdat_16pft = surfdata_ALP4_hist_2000_16pfts_c250521.nc

[domain]
file = /cluster/home/evaler/fates_incline/inputdata/ALP4-GSWP3/domain.lnd.fv0.9x1.25_gx1v7_ALP4_c221027.nc
```

(old surface data file name: surfdata_0.9x1.25_hist_16pfts_Irrig_CMIP6_simyr2000_ALP4_c221027.nc)

Also check `CTSM/bld/namelist_files/namelist_defauls_ctsm.xml`. 
The FATES parameter file is set on line 536 (and the CLM parameter file just above on L58). For now I assume that this file is not necessary to change but can be overwritten with namelist changes for specific cases.

## setting up cases and running the model

Create cases, which will be placed in ~/fates_incline/casename. There is one create case script per case to make sure it's reproducible. Make them executable with `chmod +x <create_case_....sh>`. Next, run ./case.setup to build the namelist.

```
cd /cluster/home/evaler/FATES_INCLINE/src/simulation_setup/
./create_case_DA-GSWP3_test.sh

cd /cluster/home/evaler/fates_incline/<casename>
./case.setup
```

Then, add these namelist changes to user_nl_clm (inside case directory):

```
fsurdat = '$CLM_USRDAT_DIR/surfdata_ALP4_hist_2000_16pfts_c250521.nc'

use_bedrock = .true.

hist_fincl2 = 'FATES_GPP'
hist_nhtfrq = 0,-24
hist_mfilt = 12,30
```

# Also, replace the default user_nl_datm_streams with the one from the (modified) LSP data
# 
# ```
# cd /cluster/home/evaler/fates_incline/SKJ1PT_DA-GSWP3_test
# mv user_nl_datm_streams user_nl_datm_streams_default
# cp /cluster/home/evaler/fates_incline/inputdata/ALP4-GSWP3/user_mods/user_nl_datm_streams user_nl_datm_streams
# ```

Then we set some simulation settings. Make a short script, fates_incline/SKJ1PT_DA-GSWP3_PTS/xmlchange_DA-GSWP3.sh, with all the xml changes needed. 

```
chmod +x xmlchange_DA-GSWP3.sh
cd /cluster/home/evaler/fates_incline/SKJ1PT_DA-GSWP3_test
./cluster/home/evaler/FATES_INCLINE/src/simulation_setup/xmlchange_DA-GSWP3.sh
```

### Modify SLA and create grass-only FATES parameter file

Run a script to copy and modify FATES parameter file. It uses FATES' script tools/modify_fates_paramfile.py to change the SLA accroding to local observtions. fates_leaf_slatop set the parameter to 0.0376 m²/gC (from 0.03 m²/gC default)
Use FATES' IndexSwapper script to make a new FATES parameter file with only grass PFTs. Grass PFTs are arctic_c3_grass,cool_c3_grass,c4_grass (index numbers 12,13,14).

```
cd /cluster/work/users/evaler/noresm/FATES_INCLINE/src/simulation_setup/
chmod u+x modify_FATES_PFTs.sh
./modify_FATES_PFTs.sh
```

When/how do I set the fates parameter file for each case? 

### Build the case

Then, build the case so it is ready for running, and run a check to see if there are any issues. If the case has already been built before and you need to change something, run `./case.build --clean` first.

```
./case.build
./check_case
```
Build logs, and output from the simulation, will be placed under /cluster/work/users/evaler/noresm/casename. 
Go there and check the logs just in case to see that there are no errors. 

### Submit the case

The final step is to submit a job to run the model.

```
./case.submit
```

### Download case folder and model output

The output from a case will be in /cluster/work/users/evaler/archive/<casename>. The output is given as monthly files, so I will combine them first so it's easier to plot and work with a single file. Combine the files, then download all the output to do analysis offline.
Download the case folder first, then download the outputs to that case folder. 

First, concatenate/combine history files for a given case name:

```
chmod u+x ./download_case.sh
./concatenate_case.sh SKJ1PT_DA-GSWP3
```

Then open a local wsl terminal and download the case folder and history archive:

```
rsync --info=progress2 -a evaler@betzy.sigma2.no:/cluster/work/users/evaler/noresm/FATES_INCLINE/cases/SKJ1PT_DA-GSWP3  /mnt/c/Users/evaler/model_output
mkdir /mnt/c/Users/evaler/model_output/SKJ1PT_DA-GSWP3/archive
rsync --info=progress2 -a evaler@betzy.sigma2.no:/cluster/work/users/evaler/archive/SKJ1PT_DA-GSWP3  /mnt/c/Users/evaler/model_output/SKJ1PT_DA-GSWP3/archive
```


--------------------------

## Useful commands

```
# jobs
squeue --me
scancel <jobID>

# model versions/tags
./bin/git-fleximod status

# data usage and quota
dusage
```
