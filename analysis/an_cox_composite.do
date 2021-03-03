
cap log close
log using analysis/output/an_cox_composite, replace t

use analysis/cr_stsetmatcheddata, clear

safetab readmission exposed, col

safetab readm_died_reason_b exposed, col

stcox exposed, strata(setid)
stcox exposed i.ethnicity i.imd , strata(setid)
stcox exposed i.ethnicity i.imd i.obese4cat i.smoke_nomiss, strata(setid) 
stcox exposed i.ethnicity i.imd i.obese4cat i.smoke_nomiss htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression, strata(setid)

log close
