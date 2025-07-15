# Simulation setup instructions

This document was created 2025-05-12 and is inspired by several sources, e.g. https://hackmd.io/@pYjjfkwmSfW932OvIjzLHA/H1YNgFXqJl

Created by Eva Lieungh, Yeliz Yilmaz, Lasse T. Keetz and others.

This guide is written to document model installation, simulations setup, and running the model on the Norwegian HPC Betzy. The model repo (CTSM) is stored under my home folder (/cluster/home/evaler/). My own forcing data (subset and modified from defaults), and shared default data (used for subsetting) is available in the project. The FATES_INCLINE repo, case folders, and model outputs are in my Betzy work folder (/cluster/work/users/evaler/).

The goal is to perform:

* two initial out-of-the-box simulations (B - baseline), but with improved surface data changed according to local observations. One will include all the default PFTs (A), while the other will be restricted to grass PFTs only (G). These will use a 2000 compset and cold start, thus representing a recent climate and *not* historical progression. The goal is to see how the model performs out of the box, and run simulations that are long enough to get an equilibrium with the climate and stable soil properties. These serve two purposes: First, results from the last 10(?) years will be reported on as the model's baseline for the site. Second, restart files from these two simulations will be re-used as spinup for the subsequent simulations.
	* GSWP3 forcing, All PFTs - (BA-GSWP3)
	* GSWP3 forcing, Grass PFTs - (BG-GSWP3)
* three improved (I) simulations, using the two baseline simulations as spinup, where the vegetation will reach a new equilibrium and data for the results will be taken from the final 14/16 years. These simulations will also be run with a year-2000 compset, and either of all (A) or grass (G) PFTs. A regional data set, COSMO-REA6, will be used as atmospheric forcing. An additional simulation will have  modified, warmed COSMO-REA6 forcing (COSMO-Warmed) with 1 degree C higher temperature.
	* COSMO forcing, All PFTs - (IA-COSMO)
	* COSMO forcing, Grass PFTs - (IG-COSMO)
	* Warmed COSMO forcing, Grass PFTs, (IG-COSMO-W)

All simulaitons are single-site, at the Skjellingahaugen site of the Vestland Climate Grid. This site is also available in the LSP. Skjellingahaugen has coordinates lon 6.41504, lat 60.9335. Open, alpine vegetation at 1088 m elevation. Mean summer temperature is 7 degrees C, and mean annual precipitation is 3402 mm.

## 1. Initial set up of model and environment

Download the Community Terrestrial Systems Model (incl. CLM), checkout a specific tag and update submodules. Used the most recent tag as of May 2025.

```
cd /cluster/home/evaler
git clone https://github.com/NorESMhub/CTSM.git
cd CTSM
git checkout tags/ctsm5.3.034_noresm_v6 -b ctsm5.3.034_noresm_v6
./bin/git-fleximod update
```

### 1.1 Create and load conda environment

Create a conda environment with the packages CTSM needs to subset global data. The conda env should be placed in the project folder because it will create very many files that would otherwise make the home folder exceed the max allowed file number. Run the shell script `create_conda_env.sh` which will purge (unload) existing modules, install conda with Miniforge, specify that packages should be under /cluster/projects/nn9774k/conda/evaler, and create the ctsm-env conda environment containing a list of packages listed under CTSM/python/conda_env_ctsm_latest.txt.

```
cd /cluster/home/evaler/FATES_INCLINE/src/data_handling
./create_conda_env.sh
```

Then activate the environment in the terminal you are working in.

```
module purge 
module load Miniforge3/24.1.2-0
conda init
conda activate /cluster/projects/nn9774k/conda/evaler/ctsm-env
```

## 2. Set up model input data

Store model input data (atmospheric forcing, durface data, domain) under /cluster/shared/noresm/inputdata/evaler/inputdata/. 

### 2.1 Atmospheric forcing data

Check whether it's possible to re-use the data from the old setup (tag v1.0), at least the atmospheric forcing. 

Prepared single-site forcing available on GitHub, modified from the NorESM-LSP. All these prepared folders include modified surface data (see [the dataprep_surfacedata notebook](https://github.com/evalieungh/FATES_INCLINE/blob/main/src/data_handling/dataprep_surfacedata.ipynb)). Zipped files are available for GSWP3, COSMO, and COSMO-Warmed under [evalieungh/FATES_INCLINE/main/data/](https://github.com/evalieungh/FATES_INCLINE/tree/main/data).

Download the data using direct download links to the zipped files for ALP4 (Skjellingahaugen):

```
# GSWP3
wget https://raw.githubusercontent.com/evalieungh/FATES_INCLINE/main/data/ALP4.zip
# COSMO
wget https://raw.githubusercontent.com/evalieungh/FATES_INCLINE/main/data/ALP4_cosmorea_noleap.zip
# COSMO-Warmed
wget https://raw.githubusercontent.com/evalieungh/FATES_INCLINE/main/data/ALP4_cosmorea_warmed.zip
```

Unzip the folders into Betzy login node folder ALP4-GSWP3 etc with `unzip`

Make sure the surface data is in the correct format. Convert from netcdf-4 to cdf5.

```
cd /cluster/work/users/evaler/noresm/FATES_INCLINE/src/data_handling
chmod +x surfacedata_file_conversion.sh
./surfacedata_file_conversion.sh
```

### 2.2  **ALTERNATIVE** Use new data

See [notes on forcing data preparation](../data_handling/create_singlepoint_gswp3.md).

### 2.3 Modify surface data

First, manually upload the following Vestland Climate Grid data files (from https://osf.io/npfa9) to the data folder (/cluster/work/users/evaler/noresm/FATES_INCLINE/data/VCG_OSF):
- VCG_clean_gridded_daily_climate_2008-2022.csv (https://osf.io/s9k7c)
- VCG_clean_soil_chemistry_2009_2010_2013_2015.csv
- VCG_clean_soil_structure_2013_2014_2018.csv
- VCG_clean_soilmoisture_plotlevel_2015-2018.csv
- INCLINE_metadata.csv

Then run this shell script that executes a python script to read and process data and create a modified version, and replaces the surface data in the input data folders with the new modified version:

```
cd /cluster/work/users/evaler/noresm/FATES_INCLINE/src/data_handling
chmod +x surfacedata_mod_exec.sh
chmod +x surfacedata_modification.py
./surfacedata_mod_exec.sh
```

The finished modified surface data is stored as `/cluster/shared/noresm/inputdata/evaler/inputdata/surfdata_ALP4_hist_2000_16pfts_c250701_modified.nc`
Copy it into each input data folder so it can be used from there following the standard format in user_nl_clm (e.g. fsurdat = '$CLM_USRDAT_DIR/surfdata_ALP4_hist_2000_16pfts_c250701_modified.nc')

```
cd /cluster/shared/noresm/inputdata/evaler/inputdata
cp surfdata_ALP4_hist_2000_16pfts_c250701_modified.nc skj_pt_gswp3/surfdata_ALP4_hist_2000_16pfts_c250701_modified.nc 
```

### 2.4 Modify SLA and grazing, and create grass-only FATES parameter file

Run a script to copy and modify FATES parameter file. It uses FATES' script tools/modify_fates_paramfile.py to change the SLA accroding to local observtions. For fates_leaf_slatop, set the parameter to 0.0376 m²/gC (from 0.03 m²/gC default). Use FATES' IndexSwapper script to make a new FATES parameter file with only grass PFTs. Grass PFTs are arctic_c3_grass,cool_c3_grass,c4_grass (index numbers 12,13,14).

See e.g. <https://fates-users-guide.readthedocs.io/projects/tutorial/en/latest/parameter_file_tools.html>

The script first makes a copy of the default parameter file and renames it `fates_params_default_unchanged.cdl`. 

```
cd /cluster/work/users/evaler/noresm/FATES_INCLINE/src/simulation_setup/
chmod u+x modify_FATES_PFTs.sh
./modify_FATES_PFTs.sh
```

The correct parameterfile must be specified in the namelist (user_nl_clm) of each case if it differs from the (new) default with all PFTs. Also check `CTSM/bld/namelist_files/namelist_defauls_ctsm.xml`. The FATES parameter file is set on line 536 (and the CLM parameter file just above on L58). 

New as of early 2025, FATES can also perform a simple grazing process. See <https://github.com/NGEET/fates/pull/1140>.
It applies to fates-sci.1.80.14_api.37.0.0-ctsm5.3.024 and newer. By default, grazing is only supposed to apply to the 'rangeland' (and pasture?) land use class, but I want to add it to all the land use classes to make sure it applies to my site as well. The grazing rate may be necessary to adjust, but I will set it to a relatively small amount for testing (0.05 relative intensity of leaf grazing/browsing).

See these relevant FATES parameters:

| parameter | notes     | longname |
| --------- | --------- | -------- |
|  fates_landuseclass_name =  "primaryland",   "secondaryland",   "rangeland",   "pastureland",  "cropland" ; | Main FATES will by default apply grazing functionality to rangeland (I think) | "Name of the land use classes, for variables associated with dimension fates_landuseclass" |
| fates_landuse_grazing_rate = 0, 0, 0, 0, 0 ;  | Has same dimensions as land use classes - assume the rate applies to that land use class (first index = primaryland). Set this to some small amount | "fraction of leaf biomass consumed by grazers per day" |
| fates_landuse_grazing_palatability = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1 ; | By default grazing only applies to grass PFTs. Change to apply to all. Unitless, 0-1 | "Relative intensity of leaf grazing/browsing per PFT" |
| fates_landuse_grazing_maxheight | in m, by default =1. Change to 1.5? Cows, sheep and elk should be able to reach above 1m I think.  | "maximum height that grazers (browsers, actually) can reach" |
| fates_landuse_grazing_carbon_use_eff, fates_landuse_grazing_nitrogen_use_eff, fates_landuse_grazing_phosphorus_use_eff, | Do not change for now. | |

Grazing modification is executed with a script: 

```
cd /cluster/work/users/evaler/noresm/FATES_INCLINE/src/simulation_setup
chmod+x modify_FATES_grazing_params.sh
./modify_FATES_grazing_params.sh
```

## 3. Set up cases and run the model

Create cases, which will be placed in /cluster/work/users/evaler/noresm/FATES_INCLINE/cases/casename. Make the 'cases' folder if necessary (`mkdir cases`). There is one create case script per case. Make them executable with `chmod +x <create_case_....sh>`. Next, run ./case.setup to build the namelist. So, for example for the case BA-GSWP3:

```
cd /cluster/work/users/evaler/noresm/FATES_INCLINE/src/simulation_setup
./create_case_BA-GSWP3.sh

cd /cluster/work/users/evaler/noresm/FATES_INCLINE/cases/BA-GSWP3
./case.setup
```

### 3.1 Namelist and xml changes
Then, add these namelist changes to user_nl_clm (inside case directory), changing the parameter file to `fates_params_grassonly.nc` or `fates_params_grazing_grassonly.nc` for the relevant cases:

```
fsurdat = '$CLM_USRDAT_DIR/surfdata_ALP4_hist_2000_16pfts_c250701_modified.nc'

fates_paramfile='/cluster/home/evaler/CTSM/src/fates/parameter_files/fates_params_default.nc'

use_excess_ice = .false.

```
NB! To be able to use the soil depth (zbedrock) modification in the modified surface data, 
`use_bedrock = .true.` also needs to be set in the namelist. But it results in an error related to CN balance checks, so we have to take it out for now. This means that even though I have changed the depth to bedrock in the surface data, this information will not be used in the simulation. See <https://github.com/ESCOMP/CTSM/pull/1902> and <https://github.com/ESCOMP/CTSM/issues/1888>.  <https://bb.cgd.ucar.edu/cesm/threads/use_bedrock-leading-to-cnbalancecheck-error-in-clm-fates.11577/>


For the restart simulations, the restart file also needs to be added:

```
finidat = ‘full_path_to_restart_file.clm2.r.0000.nc’
finidat = '/cluster/work/users/evaler/noresm/BA-GSWP3-bedrockoff/run/BA-GSWP3-bedrockoff.clm2.r.2002-01-01-00000.nc'
```

Then we set additional simulation settings (simulation time etc.). Make a short script per case, for example xmlchange_BA-GSWP3.sh: 

```
cd /cluster/work/users/evaler/noresm/FATES_INCLINE/src/simulation_setup
chmod +x xmlchange_BA-GSWP3.sh
./xmlchange_BA-GSWP3.sh
```

### 3.2 Build the case

Then, build the case so it is ready for running, and run a check to see if there are any issues. If the case has already been built before and you need to change something, run `./case.build --clean` first.

```
cd /cluster/work/users/evaler/noresm/FATES_INCLINE/cases/BA-GSWP3
./case.build
```

Build logs, and output from the simulation, will be placed under /cluster/work/users/evaler/noresm/casename. 
Go there and check the logs just in case to see that there are no errors. 

### 3.3 Submit the case

The final step is to submit a job to run the model.

```
./case.submit
```

When a case is running, output files will be stored temporarily in the run directory (e.g. /cluster/work/users/evaler/noresm/BA-GSWP3/run) befor it is moved to archive.

## 4. Download case folder and model output

The output from a case will be in /cluster/work/users/evaler/archive/<casename>. The output is given as monthly files, so I will combine them first so it's easier to plot and work with a single file. Combine the files, then download all the output to do analysis offline.
Download the case folder first, then download the outputs to that case folder. 

First, concatenate/combine history files for a given case name:

```
cd /cluster/work/users/evaler/noresm/FATES_INCLINE/src/data_handling
chmod u+x ./download_case.sh
./concatenate_case.sh BA-GSWP3
```
NB! If there are multiple history tapes, these should be concatenated separately. Add it to the script ^ or do it manually if necessary. 

NB! Older versions of Panoply cannot open new NetCDF data. My Panoply version can open new model output after conversion to NetCDF4. 

Then open a local wsl terminal and download the case folder and history archive (or right-click and download from VScode setup):

```
rsync --info=progress2 -a evaler@betzy.sigma2.no:/cluster/work/users/evaler/noresm/FATES_INCLINE/cases/BA-GSWP3  /mnt/c/Users/evaler/model_output
mkdir /mnt/c/Users/evaler/model_output/BA-GSWP3/archive
rsync --info=progress2 -a evaler@betzy.sigma2.no:/cluster/work/users/evaler/archive/BA-GSWP3  /mnt/c/Users/evaler/model_output/BA-GSWP3/archive
```


--------------------------

## Useful commands

```
# jobs
squeue --me
scancel <jobID>

# model versions/tags
./bin/git-fleximod status
git describe --tags

# data usage and quota
dusage

# NetCDF conversion
nccopy -k 'cdf5' in.nc out.nc
nccopy -k 'netCDF-4' in.nc out.nc
ncdump in.nc > out.cdl
```
