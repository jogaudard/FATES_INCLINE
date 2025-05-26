# Python script for modifying a single-site surface data file
# using observed values from the Vestland Climate Grid.

# See old version published in release v1.0 https://github.com/evalieungh/FATES_INCLINE/releases/tag/v1.0
# under FATES_INCLINE/src/data_handling/dataprep_surfacedata.ipynb
# Heavily inspired from NorESM-LSP notebooks and https://github.com/huitang-earth/MossLichen_testbed/blob/main/scripts/SeedClim_surfacedata_modification.ipynb 

# Script by Eva Lieungh, Elin CR Aas, Hui Tang
# Started 2022-11-15

# Observational data from the Vestland Climate Grid  stored on OSF (https://osf.io/npfa9)
# VCG data files:
# - https://osf.io/s9k7c, VCG_clean_gridded_daily_climate_2008-2022.csv
# - VCG_clean_soil_chemistry_2009_2010_2013_2015.csv
# - VCG_clean_soil_structure_2013_2014_2018.csv
# - VCG_clean_soilmoisture_plotlevel_2015-2018.csv
# - INCLINE metadata 

# This script reads observational data, reads an existing surface data file, 
# modifies the surface data, and saves it as a new file.

# import libraries
import xarray as xr  # NetCDF data handling
import netCDF4 
import matplotlib.pyplot as plt  # Plotting
import time  # Keeping track of runtime
import json  # For reading data dictionaries stored in json format
import pandas as pd  # Tabular data analysis
import datetime as dt  # For workaround with long simulations (beyond year 2262)
import statistics as stats # For mean and other calculations
from pathlib import Path  # For easy path handling
import zipfile # for unzipping
import shutil # easiest whole-directory zipping
import glob # for wildcard * searching in file names

# set path observational data
observations_path = Path(f"/cluster/work/users/evaler/noresm/FATES_INCLINE/data/VCG_OSF")

# set path to default surface data
surfacedata_path = Path(f"/cluster/home/evaler/inputdata/skj_pt_gswp3")

# set path for where to store modified surface data
modified_surfacedata_path = str(Path(f"/cluster/home/evaler/inputdata"))

# define LSP site identities and corresponding names 
siteID = ["ALP1","ALP2","ALP3","ALP4","SUB1","SUB2","SUB3","SUB4","BOR1","BOR2","BOR3","BOR4"]
siteID1 = ["Ulvehaugen","Lavisdalen","Gudmedalen","Skjelingahaugen",
           "Alrust","Hogsete","Rambera","Veskre",
           "Fauske","Vikesland","Arhelleren","Ovstedalen"]
siteID2 = ["Ulvehaugen","Lavisdalen","Gudmedalen","Skjellingahaugen",
           "Alrust","Hogsete","Rambera","Veskre",
           "Fauske","Vikesland","Arhelleren","Ovstedalen"]

# read in observational data - soil moisture
print("soil moisture ------------------------------")
soil_moisture = pd.read_csv(observations_path / "VCG_clean_soilmoisture_plotlevel_2015-2018.csv",
                            index_col=None)

# read in observational data - soil chemistry
print("soil chemistry ------------------------------")
soil_chemistry = pd.read_csv(observations_path / "VCG_clean_soil_chemistry_2009_2010_2013_2015.csv",
                             index_col=None)
print("available variables: ", soil_chemistry.variable.unique())
print("site names: ", soil_chemistry.siteID_dest.unique()) # matches siteID1 list

# read in observational data - soil structure
print("soil structure ------------------------------")
soil_structure = pd.read_csv(observations_path / "VCG_clean_soil_structure_2013_2014_2018.csv", 
                             index_col=None)
print("available variables: ", soil_structure.variable.unique())
print("site names: ", soil_structure.siteID.unique()) # matches siteID1

# for some reason, only the alpine sites have data for clay, silt and sand 
print("sites with clay/silt/sand observations: ", soil_structure[soil_structure["variable"] == "sand"].siteID.unique())

# Read INCLINE project metadata for more info on the alpine sites including ALP4 - Skjellingahaugen
print("site metadata, slope ------------------------------")
INCLINE_metadata = pd.read_csv(observations_path / "INCLINE_metadata.csv", sep=";", index_col=None)
INCLINE_metadata.head()

########### MODIFY DATA ##############
# 1. subset the variables from observation data sets
# 2. calculate means of the variables,
# 3. replace the default in the surfacedata file, 
# 4. and save the file in the modified_surfacedata_path

# Subset carbon content, calculate site mean. Needs to be combined with bulk density to convert to kg/m3.

# The code is made as a loop so it can be expanded to inlcude the other sites. Set the index to only calcualte for ALP4 Skjellingahaugen here.

for i in range(3,4):
    print("-------------------------------------")
    print("site: ", siteID[i], siteID2[i])

    #------------- GET OBSERVATION DATA -------------# 

    # Subset variables, calculate means, do unit conversions

    # Organic matter #
    carbon_observed = soil_chemistry[(soil_chemistry["siteID_dest"]==siteID1[i])
                                     & (soil_chemistry["variable"] == "C_content")]
    soil_bulk_density = soil_structure[(soil_structure["siteID"]==siteID1[i]) 
                                       & (soil_structure["variable"] == "bulk_density")]
    carbon_mean = stats.mean(carbon_observed["value"])
    soil_bulk_density_mean = stats.mean(soil_bulk_density["value"])
    print("mean carbon content (%): ", carbon_mean)
    print("bulk density (g/cm^3):   ", soil_bulk_density_mean)
        # observed bulk density: g/cm3, observed carbon content: %, model needs organic: kg/m3. 
        # To get total organic matter (not just C), divide by 0.58   
    org_obs = (soil_bulk_density_mean*1000)*(carbon_mean/100)/0.58 
    org_obs = min(110, org_obs)      # model assumes less than 130 kg/m3 organic matter 
    print("organic matter for model (kg/m3): ", org_obs)

    # percent sand # (only for ALP1-4)
    sand_observed = soil_structure[(soil_structure["siteID"]==siteID1[i]) 
                                       & (soil_structure["variable"] == "sand")]
    sand_obs_mean = stats.mean(sand_observed["value"]) * 100
    print("sand %: ", sand_obs_mean)

    ## silt #
    #silt_observed = soil_structure[(soil_structure["siteID"]==siteID1[i]) 
    #                                   & (soil_structure["variable"] == "silt")]
    #silt_obs_mean = stats.mean(silt_observed["value"]) * 100
    #print("silt %: ", silt_obs_mean)

    # clay #
    clay_observed = soil_structure[(soil_structure["siteID"]==siteID1[i]) 
                                       & (soil_structure["variable"] == "clay")]
    clay_obs_mean = stats.mean(clay_observed["value"]) * 100
    print("clay %: ", clay_obs_mean)

    # Soil depth#
    soil_depth = soil_structure[(soil_structure["siteID"]==siteID1[i]) 
                                       & (soil_structure["variable"] == "soil_depth")]
    soil_depth_mean = stats.mean(soil_depth["value"]) / 100 # convert cm to m
    print("soil depth, m: ", soil_depth_mean)

    # Slope # (NB! from INCLINE data - not identical to SeedClim and FunCaB data)
    slope_observed = INCLINE_metadata[INCLINE_metadata["siteID"]==siteID2[i]]
    slope_obs_mean = stats.mean(slope_observed["slope"])
    print("slope: ",slope_obs_mean)

    # plant and bare ground cover # - set to a fixed number for now! To be calculated from data
    plant_cover_obs = 90 # % cover

    # plant height # 
    plant_height_obs = 15/100
    #MONTHLY_HEIGHT_TOP

    #------------- MODIFY SURFACE DATA VARIABLES -------------#

    # open site-specific default surface data file to be modified
    file_pattern = modified_surfacedata_path + '/surfdata*.nc' # '/' + siteID[i] +
    file_list = glob.glob(file_pattern)

    # check if at least one file was found
    if len(file_list) == 0:
        print(f"No file found matching the pattern {file_pattern}")
    else:
        # if multiple files were found, select the first one
        filename = file_list[0]
        print("surface data file: ", filename)
        dset = netCDF4.Dataset(filename, 'r+')
    
    # modify cover of specific PFTs
    #dset['PCT_NAT_PFT'][0,:,:] = 100-plant_cover_obs # index 0: barren ground
    #dset['PCT_NAT_PFT'][12,:,:] = plant_cover_obs # index 12 = Arctic C3 grass???

    # modify land cover fractions (set whole gridcell to natural vegetation)
    dset['PCT_NATVEG'][:,:] = 100
    dset['PCT_CROP'][:,:] = 0
    dset['PCT_CFT'][0,:,:] = 100 # % crop type on crop land unit - we set PCT_CROP = 0 so this shouldn't matter, but might cause a bug if the crop types don't add to 100.
    dset['PCT_WETLAND'][:,:] = 0
    dset['PCT_LAKE'][:,:] = 0
    dset['PCT_GLACIER'][:,:] = 0
    dset['PCT_URBAN'][:,:,:] = 0

    # Modify soil properties
    dset['ORGANIC'][0:3,:,:] = org_obs      # the layers of soil to modify depending on the availability of the data
    dset['PCT_SAND'][:,:,:] = sand_obs_mean
    dset['PCT_CLAY'][:,:,:] = clay_obs_mean
    dset['zbedrock'][:,:] = soil_depth_mean + 0.40 # the model expects >40 cm of soil. Add this to avoid bugs but keep differences between sites.

    # Modify topography
    dset['SLOPE'][:,:] = slope_obs_mean

    dset.close()
