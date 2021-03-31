cap log close
log using analysis/output/an_cox_causespecific, replace t

local allgraphs

foreach csoutcome of any circulatory cancer_ex_nmsc respiratory respiratorylrti digestive mentalhealth nervoussystem genitourinary endo_nutr_metabol external musculoskeletal  otherinfections {
	
di _n _dup(50) "*" 
di "`csoutcome'"
	
use analysis/cr_append_process_data, clear
drop if group==3
drop if group==2 & entrydate<d(1/1/2019)

stset CSexit_`csoutcome', fail(CSfail_`csoutcome') origin(entrydate) enter(entrydate) 

*sts graph , by(group) fail name(`csoutcome', replace)

stcox exposed age male i.region_real if group==1|group==2
estimates save analysis/output/models/an_cox_causespecific`csoutcome'_cflu_MATCHFACONLY, replace

stcox exposed age male i.region_real i.ethnicity i.imd i.obese4cat i.smoke_nomiss htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression if group==1|group==2 
estimates save analysis/output/models/an_cox_causespecific`csoutcome'_cflu_FULLADJ, replace

stcox exposed if group==1|group==4, strata(setid)
estimates save analysis/output/models/an_cox_causespecific`csoutcome'_c2019gp_MATCHFACONLY, replace

stcox exposed i.ethnicity i.imd i.obese4cat i.smoke_nomiss htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression if group==1|group==4, strata(setid)
estimates save analysis/output/models/an_cox_causespecific`csoutcome'_c2019gp_FULLADJ, replace

local allgraphs "`allgraphs' `csoutcome'"

}

*graph combine `allgraphs'
*graph export an_cox_causespecific_KMGRAPHS.svg, as(svg) replace

log close
