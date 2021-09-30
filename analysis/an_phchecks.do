
*an_phchecks (adj models)


cap log close
log using analysis/output/an_phchecks, replace t

use analysis/cr_append_process_data, clear

*R2
drop if obese4cat_withmiss==.
drop if smoke==.
drop if region_real==.
	
***Composite***
di _n _dup(50) "*" 
di "COMPOSITE"
di _n _dup(50) "*" 
*vs flu controls
stcox exposed age1 age2 age3 male i.stp i.ethnicity i.imd i.obese4cat_withmiss i.smoke htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression if (group==1|group==2)
estat phtest, d
*vs 2019 gen pop controls
stcox exposed i.ethnicity i.imd i.obese4cat_withmiss i.smoke htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression if (group==1|group==4), strata(setid) 
estat phtest, d

***Death***
di _n _dup(50) "*" 
di "ALL CAUSE MORTALITY"
di _n _dup(50) "*" 
*vs 2017_19-flu controls
preserve
include analysis/stsetfordeath1ocare.doi
*vs 2017_19-flu controls
stcox exposed age1 age2 age3 male i.stp i.ethnicity i.imd i.obese4cat_withmiss i.smoke htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression if (group==1|group==2)
estat phtest, d

*vs 2019 general pop controls
stcox exposed i.ethnicity i.imd i.obese4cat_withmiss i.smoke htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression if (group==1|group==4), strata(setid) 
estat phtest, d
restore

********CAUSE SPECIFIC

foreach csoutcome of any circulatory cancer_ex_nmsc respiratory respiratorylrti digestive mentalhealth nervoussystem genitourinary endo_nutr_metabol external musculoskeletal  otherinfections {
	
di _n _dup(50) "*" 
di "`csoutcome'"
di _n _dup(50) "*" 
	
use analysis/cr_append_process_data, clear
drop if group==3
drop if group==2 & entrydate<d(1/1/2019)

stset CSexit_`csoutcome', fail(CSfail_`csoutcome') origin(entrydate) enter(entrydate) 

***VS FLU
stcox exposed age male i.region_real i.ethnicity i.imd i.obese4cat_withmiss i.smoke htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression if group==1|group==2 
estat phtest, d

***VS GENERAL POP
stcox exposed i.ethnicity i.imd i.obese4cat_withmiss i.smoke htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression if group==1|group==4, strata(setid)
estat phtest, d

}

log close

