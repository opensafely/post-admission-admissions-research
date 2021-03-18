
local outcome `1'
local comparison `2'

cap log close
log using analysis/output/an_crreg_outcome`outcome', replace t

use analysis/cr_append_process_data, clear
if `comparison'=="flu"{
	keep if group==1|group==2
	local regionvar "region_real"
	local seasonvar i.monthentry
}
if `comparison'=="2019gp" {
	keep if group==1|group==4
	local regionvar "stp"
	local seasonvar
}

streset, fail(readm_died_reason_b=`outcome')

local competingoutcomes = subinstr("1 2 3 4 5 6 7 8 9 10 11 12 13 14", "`outcome'", "", 1)
di "Outcome `outcome'"
di "Competing: `competingoutcomes'"

stcrreg exposed age male i.`regionvar' `seasonvar', compete(readm_died_reason_b = `competingoutcomes') 
estimates save analysis/output/models/an_crreg_outcome`outcome'_c`comparison'_MATCHFACONLY, replace

stcrreg exposed age male i.`regionvar' `seasonvar' i.ethnicity i.imd i.obese4cat i.smoke_nomiss htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression, compete(readm_died_reason_b = `competingoutcomes')
estimates save analysis/output/models/an_crreg_outcome`outcome'_c`comparison'_FULLADJ, replace

log close