
cap log close
log using analysis/output/an_cox_composite, replace t

use analysis/cr_stsetmatcheddata_ALLCONTROLS, clear

safetab readmission exposed_allcontrols, col

safetab readm_died_reason_b exposed_allcontrols, col

*vs 2020 controls
stcox exposed if analysis2020==1, strata(setid)
stcox exposed i.ethnicity i.imd if analysis2020==1, strata(setid)
stcox exposed i.ethnicity i.imd i.obese4cat i.smoke_nomiss if analysis2020==1, strata(setid) 
stcox exposed i.ethnicity i.imd i.obese4cat i.smoke_nomiss htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression if analysis2020==1, strata(setid)

*vs 2019 controls
stcox exposed if analysis2019==1, strata(setid)
stcox exposed i.ethnicity i.imd if analysis2019==1, strata(setid)
stcox exposed i.ethnicity i.imd i.obese4cat i.smoke_nomiss if analysis2019==1, strata(setid) 
stcox exposed i.ethnicity i.imd i.obese4cat i.smoke_nomiss htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression if analysis2019==1, strata(setid)

*vs 2019-pneumonia controls
stcox exposed age1 age2 age3 male i.stp if analysispneum==1
stcox exposed age1 age2 age3 male i.stp i.ethnicity i.imd if analysispneum==1
stcox exposed age1 age2 age3 male i.stp  i.ethnicity i.imd i.obese4cat i.smoke_nomiss if analysispneum==1
stcox exposed age1 age2 age3 male i.stp i.ethnicity i.imd i.obese4cat i.smoke_nomiss htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression if analysispneum==1


*vs 2017_19-flu controls
stcox exposed age1 age2 age3 male i.stp i.monthentry if analysisflu==1
stcox exposed age1 age2 age3 male i.stp i.monthentry i.ethnicity i.imd if analysisflu==1
stcox exposed age1 age2 age3 male i.stp i.monthentry  i.ethnicity i.imd i.obese4cat i.smoke_nomiss if analysisflu==1
stcox exposed age1 age2 age3 male i.stp i.monthentry i.ethnicity i.imd i.obese4cat i.smoke_nomiss htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression if analysisflu==1

*Circulatory readmissions only:
preserve 
keep if analysispn==1
streset, fail(readm_died_reason_b==1)
stcox exposed age1 age2 age3 male i.stp
restore

log close

