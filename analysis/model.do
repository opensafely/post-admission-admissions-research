log using logs/model.log
import delimited output/input_covdischarged.csv
log close

do analysis/cr_getmatches
do analysis/cr_stsetmatcheddata

do analysis/an_desctable
do analysis/an_cumulativeincidence
