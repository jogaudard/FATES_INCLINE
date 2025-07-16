# notes for formatting old COSMO-REA6 data (already modified) to new subset GSWP3 data format

The old COSMO-REA6 data have monthly nc files with all variables included, named e.g. clm1pt_ALP4_2014-12.nc. I need to separate out each variable so that I would get three montly files instead of one, and match the format of the newly subset GSWP3 data. So for each month, I want three output files: clm1pt_ALP4_TPQWL.2014-12.nc (temperature), clm1pt_ALP4_Solr.2014-12.nc (radiation), and clm1pt_ALP4_Prec.2014-12.nc (precipitation).

* COSMO is hourly, GSWP3 daily values - problem?


| GSWP3  | COSMO-REA6 equivalent | notes |
| -------|-----------------------|-------|
| FSDS  | SWDIFDS_RAD | several options in COSMO? -> Solr tag |
| PRECTmms | PRECTmms | several options with same description -> Prec tag |
| PSRF, TBOT, WIND, QBOT, FLDS | PSRF, TBOT, WIND, SHUM, FLDS | all in TPQWL files -> TPQWL tag|
| EDGEN, EDGEE, EDGES, EDGEW, LONGXY, LATIXY | EDGEN, EDGEE, EDGES, EDGEW, LONGXY, LATIXY | check that these match |



```
# go to input data storage
cd /cluster/shared/noresm/inputdata/evaler/inputdata

# make new dir for old format
cd ALP4-COSMO
mv datmdata datmdata_old
mkdir datmdata

# copy domain, surfacedata, user_mods files into cosmo dir
cp skj_pt_gswp3/datmdata/domain.lnd.360x720_gswp3.0v1_ALP4_c250701.nc ALP4-COSMO/datmdata/domain.lnd.360x720_gswp3.0v1_ALP4_c250701.nc
cp skj_pt_gswp3/surfdata_ALP4_hist_2000_16pfts_c250701_modified.nc ALP4-COSMO/surfdata_ALP4_hist_2000_16pfts_c250701_modified.nc
cp -r skj_pt_gswp3/user_mods/ ALP4-COSMO/user_mods

# go to script and execute formatting
cd FATES_INCLINE/src/data_handling/
./cosmorea_formatting.sh

# check whether dimension variables match
diff <(ncdump -v EDGEN ALP4-COSMO/datmdata/clmforc.GSWP3.c2011.0.5x0.5.Solr.ALP4.1995-09.nc) <(ncdump -v EDGEN skj_pt_gswp3/datmdata/clmforc.GSWP3.c2011.0.5x0.5.Solr.ALP4.1995-09.nc)

```





        