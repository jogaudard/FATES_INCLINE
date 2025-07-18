#!/bin/bash
set -o errexit  # Exit the script on any error

module --quiet purge 
module load Miniforge3/24.1.2-0
source ${EBROOTMINIFORGE3}/bin/activate
export CONDA_PKGS_DIRS=/cluster/projects/nn9774k/conda/evaler/package-cache
export CONDA_ENV_SRC=/cluster/projects/nn9774k/conda/evaler

conda activate $CONDA_ENV_SRC/ctsm-env

# go to data storage
cd /cluster/shared/noresm/inputdata/evaler/inputdata

# set in- and output directories
INPUT_DIR="ALP4-COSMO/datmdata_old"
OUTPUT_DIR="ALP4-COSMO/datmdata" 

# use GSWP3 files as templates to get the correct format
template_file_solr="skj_pt_gswp3/datmdata/clmforc.GSWP3.c2011.0.5x0.5.Solr.ALP4.1901-01.nc"
template_file_prec="skj_pt_gswp3/datmdata/clmforc.GSWP3.c2011.0.5x0.5.Prec.ALP4.1901-01.nc"
template_file_tpqwl="skj_pt_gswp3/datmdata/clmforc.GSWP3.c2011.0.5x0.5.TPQWL.ALP4.1901-01.nc"

# Loop over all monthly NetCDF files
for infile in "$INPUT_DIR"/clm1pt_ALP4_*.nc; do
    # Extract date (YYYY-MM) from filename
    filename=$(basename "$infile")
    year_month=$(echo "$filename" | grep -oE '[0-9]{4}-[0-9]{2}')

    echo "Processing month: $year_month"
    
    # define output filenames
    outfile_solr="${OUTPUT_DIR}/clmforc.COSMOREA6.Solr.ALP4.${year_month}.nc"
    outfile_prec="${OUTPUT_DIR}/clmforc.COSMOREA6.Prec.ALP4.${year_month}.nc"
    outfile_tpqwl="${OUTPUT_DIR}/clmforc.COSMOREA6.TPQWL.ALP4.${year_month}.nc"

    # add coordinate info from GSWP3 template
    ncks -v EDGEN,EDGEE,EDGES,EDGEW,LONGXY,LATIXY,lon,lat "$template_file_solr" "$outfile_solr"
    ncks -v EDGEN,EDGEE,EDGES,EDGEW,LONGXY,LATIXY,lon,lat "$template_file_prec" "$outfile_prec"
    ncks -v EDGEN,EDGEE,EDGES,EDGEW,LONGXY,LATIXY,lon,lat "$template_file_tpqwl" "$outfile_tpqwl"

    # transfer the COSMO radiation and time variables
    ncks -A -v SWDIFDS_RAD,time "$infile" "$outfile_solr"
    ncks -A -v PRECTmms,time "$infile" "$outfile_prec"
    ncks -A -v PSRF,TBOT,WIND,SHUM,FLDS,time "$infile" "$outfile_tpqwl"
    
    # Rename variables to match those from GSWP3
    ncrename -v SWDIFDS_RAD,FSDS "$outfile_solr"
    ncrename -v SHUM,QBOT "$outfile_tpqwl"

    # convert time units from hours to days
    for outfile in "$outfile_solr" "$outfile_prec" "$outfile_tpqwl"; do
        # convert time values from hours to days
        ncap2 -O -s 'time=float(time/24.0)' "$outfile" "$outfile"

        # update the time units and starting point
        ref_date="${year_month}-01"
        ncatted -O \
            -a units,time,o,c,"days since ${ref_date}" \
            -a calendar,time,o,c,"noleap" \
            "$outfile"
    done
done
