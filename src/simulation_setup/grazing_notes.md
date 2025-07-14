# Notes on grazing capabilities in FATES

Recently introduced early 2025. See <https://github.com/NGEET/fates/pull/1140>.
Looks like it applies to fates-sci.1.80.14_api.37.0.0-ctsm5.3.024 and newer.

Relevant stuff in the FATES parameter file:

| parameter | notes     | longname |
| --------- | --------- | -------- |
|  fates_landuseclass_name =  "primaryland",   "secondaryland",   "rangeland",   "pastureland",  "cropland" ; | Main FATES will by default apply grazing functionality to rangeland (I think) | "Name of the land use classes, for variables associated with dimension fates_landuseclass" |
| fates_landuse_grazing_rate = 0, 0, 0, 0, 0 ;  | Has same dimensions as land use classes - assume the rate applies to that land use class (first index = primaryland). Set this to some small amount | "fraction of leaf biomass consumed by grazers per day" |
| fates_landuse_grazing_palatability = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1 ; | By default grazing only applies to grass PFTs. Change to apply to all. Unitless, 0-1 | "Relative intensity of leaf grazing/browsing per PFT" |
| fates_landuse_grazing_maxheight | in m, by default =1. Change to 1,5? Cows, sheep and elk should be able to reach above 1m I think.  | "maximum height that grazers (browsers, actually) can reach" |
| fates_landuse_grazing_carbon_use_eff, fates_landuse_grazing_nitrogen_use_eff, fates_landuse_grazing_phosphorus_use_eff, | Do not change for now. | |


Modification executed with script: FATES_INCLINE/src/simulation_setup/modify_FATES_grazing_params.sh
