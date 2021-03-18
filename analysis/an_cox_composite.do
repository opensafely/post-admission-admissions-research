
cap log close
log using analysis/output/an_cox_composite, replace t

use analysis/cr_append_process_data, clear

	
*Composite
*vs 2017_19-flu controls
preserve
keep if group==1|group==2
stcox exposed age1 age2 age3 male i.stp i.monthentry 
stcox exposed age1 age2 age3 male i.stp i.monthentry i.ethnicity i.imd 
stcox exposed age1 age2 age3 male i.stp i.monthentry  i.ethnicity i.imd i.obese4cat i.smoke_nomiss 
stcox exposed age1 age2 age3 male i.stp i.monthentry i.ethnicity i.imd i.obese4cat i.smoke_nomiss htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression 
restore

*vs 2019 general pop age/sex/stp matched controls
preserve
	keep if group==1|group==4
	stcox exposed, strata(setid)
	stcox exposed i.ethnicity i.imd , strata(setid)
	stcox exposed i.ethnicity i.imd i.obese4cat i.smoke_nomiss , strata(setid) 
	stcox exposed i.ethnicity i.imd i.obese4cat i.smoke_nomiss htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression, strata(setid)
restore

*Death
*vs 2017_19-flu controls
preserve
	include analysis/setfordeath.doi
	keep if group==1|group==2
	stcox exposed age1 age2 age3 male i.region_real i.monthentry 
	stcox exposed age1 age2 age3 male i.region_real  i.monthentry i.ethnicity i.imd 
	stcox exposed age1 age2 age3 male i.region_real  i.monthentry  i.ethnicity i.imd i.obese4cat i.smoke_nomiss 
	stcox exposed age1 age2 age3 male i.region_real  i.monthentry i.ethnicity i.imd i.obese4cat i.smoke_nomiss htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression 
restore

*vs 2019 general pop controls
preserve
	include analysis/setfordeath.doi
	keep if group==1|group==4
	stcox exposed age1 age2 age3 male i.stp i.monthentry 
	stcox exposed age1 age2 age3 male i.stp i.monthentry i.ethnicity i.imd 
	stcox exposed age1 age2 age3 male i.stp i.monthentry  i.ethnicity i.imd i.obese4cat i.smoke_nomiss 
	stcox exposed age1 age2 age3 male i.stp i.monthentry i.ethnicity i.imd i.obese4cat i.smoke_nomiss htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression 
restore

log close

