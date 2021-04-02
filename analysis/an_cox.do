
cap log close
log using analysis/output/an_cox, replace t

use analysis/cr_append_process_data, clear

	
*Composite
*vs 2017_19-flu controls
preserve
keep if group==1|group==2
	stcox exposed age1 age2 age3 male i.stp 
	estimates save analysis/output/models/an_cox_COMPOSITEvsflu_MINADJ, replace
	stcox exposed age1 age2 age3 male i.stp i.ethnicity i.imd 
	estimates save analysis/output/models/an_cox_COMPOSITEvsflu_DEMOGADJ, replace
	stcox exposed age1 age2 age3 male i.stp i.ethnicity i.imd i.obese4cat i.smoke_nomiss 
	estimates save analysis/output/models/an_cox_COMPOSITEvsflu_DEMOGLSTYLADJ, replace
	stcox exposed age1 age2 age3 male i.stp i.ethnicity i.imd i.obese4cat i.smoke_nomiss htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression 
	estimates save analysis/output/models/an_cox_COMPOSITEvsflu_FULLADJ, replace
restore

*vs 2019 general pop age/sex/stp matched controls
preserve
	keep if group==1|group==4
	stcox exposed, strata(setid)
	estimates save analysis/output/models/an_cox_COMPOSITEvs2019gp_MINADJ, replace
	stcox exposed i.ethnicity i.imd , strata(setid)
	estimates save analysis/output/models/an_cox_COMPOSITEvs2019gp_DEMOGADJ, replace
	stcox exposed i.ethnicity i.imd i.obese4cat i.smoke_nomiss , strata(setid) 
	estimates save analysis/output/models/an_cox_COMPOSITEvs2019gp_DEMOGLSTYLADJ, replace
	stcox exposed i.ethnicity i.imd i.obese4cat i.smoke_nomiss htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression, strata(setid)
	estimates save analysis/output/models/an_cox_COMPOSITEvs2019gp_FULLADJ, replace
restore

*Death
*vs 2017_19-flu controls
preserve
	include analysis/stsetfordeath1ocare.doi
	keep if group==1|group==2
	stcox exposed age1 age2 age3 male i.region_real 
	estimates save analysis/output/models/an_cox_DEATHvsflu_MINADJ, replace
	stcox exposed age1 age2 age3 male i.region_real i.ethnicity i.imd 
	estimates save analysis/output/models/an_cox_DEATHvsflu_DEMOGADJ, replace
	stcox exposed age1 age2 age3 male i.region_real i.ethnicity i.imd i.obese4cat i.smoke_nomiss 
	estimates save analysis/output/models/an_cox_DEATHvsflu_DEMOGLSTYLADJ, replace
	stcox exposed age1 age2 age3 male i.region_real i.ethnicity i.imd i.obese4cat i.smoke_nomiss htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression 
	estimates save analysis/output/models/an_cox_DEATHvsflu_FULLADJ, replace

restore

*vs 2019 general pop controls
preserve
	include analysis/stsetfordeath1ocare.doi
	keep if group==1|group==4
	stcox exposed, strata(setid)
	estimates save analysis/output/models/an_cox_DEATHvs2019gp_MINADJ, replace
	stcox exposed i.ethnicity i.imd, strata(setid)
	estimates save analysis/output/models/an_cox_DEATHvs2019gp_DEMOGADJ, replace
	stcox exposed i.ethnicity i.imd i.obese4cat i.smoke_nomiss, strata(setid) 
	estimates save analysis/output/models/an_cox_DEATHvs2019gp_DEMOGLSTYLADJ, replace
	stcox exposed i.ethnicity i.imd i.obese4cat i.smoke_nomiss htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression, strata(setid)
	estimates save analysis/output/models/an_cox_DEATHvs2019gp_FULLADJ, replace
restore

log close

