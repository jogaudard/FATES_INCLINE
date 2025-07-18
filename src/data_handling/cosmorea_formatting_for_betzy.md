# notes for formatting old COSMO-REA6 data (already modified) to new subset GSWP3 data format

The old COSMO-REA6 data have monthly nc files with all variables included, named e.g. clm1pt_ALP4_2014-12.nc. I need to separate out each variable so that I would get three montly files instead of one, and match the format of the newly subset GSWP3 data. So for each month, I want three output files with tags Solr, Prec, TPQWL

* COSMO is hourly, GSWP3 3-hourly values - problem?


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
diff <(ncdump -v EDGEN ALP4-COSMO/datmdata/clmforc.GSWP3.c2011.0.5x0.5.Solr.1995-09.nc) <(ncdump -v EDGEN skj_pt_gswp3/datmdata/clmforc.GSWP3.c2011.0.5x0.5.Solr.ALP4.1995-09.nc)

```

## In addition, to enable switching between GSWP3 and COSMO forcing for different cases:

Following the old notes, add COSMOREA as a datm_mode option by adding it in these files:

### CTSM/components/cdeps/datm/cime_config/namelist_definition_datm.xml

L31       <value datm_mode="COSMOREA">
L32         COSMOREA.Solar,COSMOREA.Precip,COSMOREA.TPQW
L33       </value>

L99      <valid_values>CLMNCEP,CORE2_NYF,CORE2_IAF,CORE_IAF_JRA,CORE_RYF6162_JRA,CORE_RYF8485_JRA,CORE_RYF9091_JRA,CORE_RYF0304_JRA,ERA5,SIMPLE,CPLHIST,1PT,COSMOREA</valid_values>

L149      </value>
L150      <value datm_mode="COSMOREA">
L151        CLMNCEP


### CTSM/components/cdeps/datm/cime_config/stream_definition_datm.xml

Backup of lines from Hui's version:
<meshfile>$DIN_LOC_ROOT_CLMFORC/cosmo_rea_6km/COSMOREA6_nomask_mesh.nc</meshfile>
<file first_year="1995" last_year="2018">$DIN_LOC_ROOT_CLMFORC/cosmo_rea_6km/clm_atmforcing/clmforc.COSMOREA6.Solr.%ym.nc</file>

From L500, after the chunk for GSWP3:

```

  <!-- ===================================  -->
  <!-- datm_mode COSMO-REA 6km              -->
  <!-- ===================================  -->

  <stream_entry name="COSMOREA.Solar">
    <stream_meshfile>
      <meshfile>$DIN_LOC_ROOT_CLMFORC/atm_forcing.datm7.GSWP3.0.5d.v1.c170516/clmforc.GSWP3.c2011.0.5x0.5.TPQWL.SCRIP.210520_ESMFmesh.nc</meshfile>
    </stream_meshfile>
    <stream_datafiles>
      <file first_year="1995" last_year="2018">$DIN_LOC_ROOT_CLMFORC/atm_forcing.datm7.GSWP3.0.5d.v1.c170516/Solar/clmforc.GSWP3.c2011.0.5x0.5.Solr.%ym.nc</file>
    </stream_datafiles>
    <stream_datavars>
      <var>SWDIFDS_RAD Faxa_swdndf</var>
      <var>SWDIRS_RAD Faxa_swdndr</var>
    </stream_datavars>
    <stream_lev_dimname>null</stream_lev_dimname>
    <stream_mapalgo>
      <mapalgo>bilinear</mapalgo>
    </stream_mapalgo>
    <stream_vectors>null</stream_vectors>
    <stream_year_align>$DATM_YR_ALIGN</stream_year_align>
    <stream_year_first>$DATM_YR_START</stream_year_first>
    <stream_year_last>$DATM_YR_END</stream_year_last>
    <stream_offset>0</stream_offset>
    <stream_tintalgo>
      <tintalgo>coszen</tintalgo>
    </stream_tintalgo>
    <stream_taxmode>
      <taxmode>cycle</taxmode>
    </stream_taxmode>
    <stream_dtlimit>
      <dtlimit>1.5</dtlimit>
    </stream_dtlimit>
    <stream_readmode>single</stream_readmode>
  </stream_entry>

  <stream_entry name="COSMOREA.Precip">
    <stream_meshfile>
      <meshfile>$DIN_LOC_ROOT_CLMFORC/atm_forcing.datm7.GSWP3.0.5d.v1.c170516/clmforc.GSWP3.c2011.0.5x0.5.TPQWL.SCRIP.210520_ESMFmesh.nc</meshfile>
    </stream_meshfile>
    <stream_datafiles>
      <file first_year="1995" last_year="2018">$DIN_LOC_ROOT_CLMFORC/atm_forcing.datm7.GSWP3.0.5d.v1.c170516/Precip/clmforc.GSWP3.c2011.0.5x0.5.Prec.%ym.nc</file>
    </stream_datafiles>
    <stream_datavars>
      <var>RAIN_CON Faxa_rainc</var>
      <var>RAIN_GSP Faxa_rainl</var>
      <var>SNOW_CON Faxa_snowc</var>
      <var>SNOW_GSP Faxa_snowl</var>
      <var>PRECIPmms Faxa_precn</var>
    </stream_datavars>
    <stream_lev_dimname>null</stream_lev_dimname>
    <stream_mapalgo>
      <mapalgo>bilinear</mapalgo>
    </stream_mapalgo>
    <stream_vectors>null</stream_vectors>
    <stream_year_align>$DATM_YR_ALIGN</stream_year_align>
    <stream_year_first>$DATM_YR_START</stream_year_first>
    <stream_year_last>$DATM_YR_END</stream_year_last>
    <stream_offset>1800</stream_offset>
    <stream_tintalgo>
      <tintalgo>nearest</tintalgo>
    </stream_tintalgo>
    <stream_taxmode>
      <taxmode>cycle</taxmode>
    </stream_taxmode>
    <stream_dtlimit>
      <dtlimit>1.5</dtlimit>
    </stream_dtlimit>
    <stream_readmode>single</stream_readmode>
  </stream_entry>

  <stream_entry name="COSMOREA.TPQW">
    <stream_meshfile>
      <meshfile>$DIN_LOC_ROOT_CLMFORC/atm_forcing.datm7.GSWP3.0.5d.v1.c170516/clmforc.GSWP3.c2011.0.5x0.5.TPQWL.SCRIP.210520_ESMFmesh.nc</meshfile>
    </stream_meshfile>
    <stream_datafiles>
      <file first_year="1995" last_year="2018">$DIN_LOC_ROOT_CLMFORC/atm_forcing.datm7.GSWP3.0.5d.v1.c170516/TPHWL/clmforc.GSWP3.c2011.0.5x0.5.TPQWL.%ym.nc</file>
    </stream_datafiles>
    <stream_datavars>
      <var>T     Sa_tbot</var>
      <var>WIND     Sa_wind</var>
      <var>Q     Sa_shum</var>
      <var>PS     Sa_pbot</var>
      <var>FLDS     Faxa_lwdn</var>
    </stream_datavars>
    <stream_lev_dimname>null</stream_lev_dimname>
    <stream_mapalgo>
      <mapalgo>bilinear</mapalgo>
    </stream_mapalgo>
    <stream_vectors>null</stream_vectors>
    <stream_year_align>$DATM_YR_ALIGN</stream_year_align>
    <stream_year_first>$DATM_YR_START</stream_year_first>
    <stream_year_last>$DATM_YR_END</stream_year_last>
    <stream_offset>0</stream_offset>
    <stream_tintalgo>
      <tintalgo>linear</tintalgo>
    </stream_tintalgo>
    <stream_taxmode>
      <taxmode>cycle</taxmode>
    </stream_taxmode>
    <stream_dtlimit>
      <dtlimit>1.5</dtlimit>
    </stream_dtlimit>
    <stream_readmode>single</stream_readmode>
  </stream_entry>

```

### CTSM/components/cdeps/datm/cime_config/config_component.xml

(Line numbers *after* editing)

L13     <desc atm="DATM[%QIA][%WISOQIA][%CRUJRA2024][%CRUv7][%GSWP3v1][%MOSARTTEST][%NLDAS2][%CPLHIST][%1PT][%NYF][%IAF][%JRA][%JRA-1p4-2018][%JRA-1p5-2023][%JRA-RYF6162][%JRA-RYF8485][%JRA-RYF9091][%JRA-RYF0304][%SIMPLE][%COSMOREA]"> Data driven ATM </desc>

L33     <desc option="COSMOREA">COSMO reanalysis 6 km</desc>

L47     <valid_values>CORE2_NYF,CORE2_IAF,CLM_QIAN,CLM_QIAN_WISO,1PT,CLMCRUJRA2024,CLMCRUNCEPv7,CLMGSWP3v1,CLMNLDAS2,CPLHIST,CORE_IAF_JRA,CORE_IAF_JRA_1p4_2018,CORE_IAF_JRA_1p5_2023,CORE_RYF6162_JRA,CORE_RYF8485_JRA,CORE_RYF9091_JRA,CORE_RYF0304_JRA,ERA5,SIMPLE,COSMOREA</valid_values>

L75       <value compset="%COSMOREA">COSMOREA</value>


## Edit user_nl_datm_streams

Made a new copy of the input user_nl_datm_streams: /cluster/shared/noresm/inputdata/evaler/inputdata/ALP4-COSMO/user_mods/user_nl_datm_streams

Tags changed from CLMGSWP3v1 to COSMOREA, file names checked, and years changed to match those available from COSMO-REA6.


