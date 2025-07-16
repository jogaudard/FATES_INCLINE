#!/bin/bash
set -o errexit  # Exit the script on any error

module --quiet purge  # Reset the modules to the system default
module load Miniforge3/24.1.2-0
source ${EBROOTMINIFORGE3}/bin/activate
export CONDA_PKGS_DIRS=/cluster/projects/nn9774k/conda/evaler/package-cache
export CONDA_ENV_SRC=/cluster/projects/nn9774k/conda/evaler

conda activate $CONDA_ENV_SRC/ctsm-env

# go to input data storage
cd /cluster/shared/noresm/inputdata/evaler/inputdata

# Directory containing input NetCDF files
INPUT_DIR="ALP4-COSMO/datmdata_old"
OUTPUT_DIR="ALP4-COSMO/datmdata" 
#mkdir -p "$OUTPUT_DIR"

# use GSWP3 files as templates to get the correct format
template_file_solr="skj_pt_gswp3/datmdata/clmforc.GSWP3.c2011.0.5x0.5.Solr.ALP4.1901-01.nc"
template_file_prec="skj_pt_gswp3/datmdata/clmforc.GSWP3.c2011.0.5x0.5.Prec.ALP4.1901-01.nc"
template_file_tpqwl="skj_pt_gswp3/datmdata/clmforc.GSWP3.c2011.0.5x0.5.TPQWL.ALP4.1901-01.nc"

# Loop over all monthly NetCDF files
for infile in "$INPUT_DIR"/clm1pt_ALP4_*.nc; do
    # Extract date (YYYY-MM) from filename
    filename=$(basename "$infile")
    date_part=$(echo "$filename" | grep -oE '[0-9]{4}-[0-9]{2}')

    echo "Processing month: $date_part"
    
    # Define temporary and output filenames
        # solar radiation
    tmpfile_solr="${OUTPUT_DIR}/tmp_Solr_${date_part}.nc"
    outfile_solr="${OUTPUT_DIR}/clmforc.GSWP3.c2011.0.5x0.5.Solr.ALP4.${date_part}.nc"
        # precipitation
    tmpfile_prec=${OUTPUT_DIR}/tmp_Prec_${date_part}.nc
    outfile_prec="${OUTPUT_DIR}/clmforc.GSWP3.c2011.0.5x0.5.Prec.ALP4.${date_part}.nc"
        # temperature, pressure etc
    tmpfile_tpqwl=${OUTPUT_DIR}/tmp_tpqwl_${date_part}.nc
    outfile_tpqwl="${OUTPUT_DIR}/clmforc.GSWP3.c2011.0.5x0.5.TPQWL.ALP4.${date_part}.nc"

    # Extract the radiation and time variables
    ncks -v SWDIFDS_RAD,time "$infile" "$tmpfile_solr"
    ncks -v PRECTmms,time "$infile" "$tmpfile_prec"
    ncks -v PSRF,TBOT,WIND,SHUM,FLDS,time "$infile" "$tmpfile_tpqwl"
    
    # Rename variables to match those from GSWP3
    ncrename -v SWDIFDS_RAD,FSDS "$tmpfile_solr"
    ncrename -v SHUM,QBOT "$tmpfile_tpqwl"

    # copy template as new file structure
    cp "$template_file_solr" "$outfile_solr"
    cp "$template_file_prec" "$outfile_prec"
    cp "$template_file_tpqwl" "$outfile_tpqwl"

    # make a copy of the time variable as a backup for format comparison
    ncrename -v time,time_gswp3 "$outfile_solr"
    ncrename -v time,time_gswp3 "$outfile_prec"
    ncrename -v time,time_gswp3 "$outfile_tpqwl"

    # Convert time: double → float, hours → days, and match attributes
    ref_date="${date_part}-01"
    #ncap2 -O -s "time=float(time)/24.0; time@units=\"days since ${ref_date}\"; time@calendar=\"noleap\"" "$tmpfile_solr" "$tmpfile_solr"
    
    # Scale time (hours → days) while preserving type (double)
    for tmpfile in "$tmpfile_solr" "$tmpfile_prec" "$tmpfile_tpqwl"; do
      ncap2 -O -s "time=time/24.0" "$tmpfile" "$tmpfile"
      ncatted -O \
        -a units,time,o,c,"days since ${ref_date}" \
        -a calendar,time,o,c,"noleap" \
        "$tmpfile"
      ncks -O --fix_rec_dmn time "$tmpfile" "$tmpfile"
    done

    # overwrite variables and time
    ncks -A -v FSDS,time "$tmpfile_solr" "$outfile_solr"
    ncks -A -v PRECTmms,time "$tmpfile_prec" "$outfile_prec"
    ncks -A -v PSRF,TBOT,WIND,QBOT,FLDS,time "$tmpfile_tpqwl" "$outfile_tpqwl"

    # clean up temporary files
    rm -f "$tmpfile_solr" "$tmpfile_prec" "$tmpfile_tpqwl"

done
