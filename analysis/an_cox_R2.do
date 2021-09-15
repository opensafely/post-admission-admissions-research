
cap log close
log using analysis/output/an_cox_R2, replace t

*changes for R2
*restrict to the CC bmi/smok population
*implement (outcome-specific) MI for ethnicity

use analysis/cr_append_process_data, clear

*R2
drop if obese4cat_withmiss==.
drop if smoke==.
safetab group

	
***Composite***
*vs 2017_19-flu controls
preserve
keep if group==1|group==2
	stcox exposed age1 age2 age3 male i.stp 
	estimates save analysis/output/models/an_cox_R2_COMPOSITEvsflu_MINADJ, replace
	
	stcox exposed age1 age2 age3 male i.stp htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression 
	estimates save analysis/output/models/an_cox_R2_COMPOSITEvsflu_COMORBS, replace
	
	stcox exposed age1 age2 age3 male i.stp i.obese4cat_withmiss i.smoke htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression 
	estimates save analysis/output/models/an_cox_R2_COMPOSITEvsflu_COMORBS_LSTYLE, replace
restore

*vs 2019 general pop age/sex/stp matched controls
preserve
keep if group==1|group==4
	stcox exposed, strata(setid)
	estimates save analysis/output/models/an_cox_R2_COMPOSITEvs2019gp_MINADJ, replace
	
	stcox exposed htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression, strata(setid) 
	estimates save analysis/output/models/an_cox_R2_COMPOSITEvs2019gp_COMORBS, replace
	
	stcox exposed i.obese4cat_withmiss i.smoke htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression, strata(setid) 
	estimates save analysis/output/models/an_cox_R2_COMPOSITEvs2019gp_COMORBS_LSTYLE, replace
restore	
	
*models with ethnicity incorporating MI
preserve
	drop if _st==0
	sts generate cumh = na
	egen cumhgp = cut(cumh), group(5)
	replace cumhgp = cumhgp + 1
	mi set wide
	mi register imputed ethnicity
	mi impute mlogit ethnicity _d i.cumhgp age1 age2 age3 male i.stp i.imd i.obese4cat_withmiss i.smoke htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression , add(10) rseed(23983)
	mi stset exitdate, fail(readmission) enter(entrydate) origin(entrydate)

	*vs flu controls
	mi estimate, eform post: stcox exposed age1 age2 age3 male i.stp i.ethnicity i.imd i.obese4cat_withmiss i.smoke htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression if (group==1|group==2)
	estimates save analysis/output/models/an_cox_R2_COMPOSITEvsflu_COMORBS_LSTYLE_ETHIMD, replace
	*vs 2019 gen pop controls
	mi estimate, eform post: stcox exposed i.ethnicity i.imd i.obese4cat_withmiss i.smoke htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression if (group==1|group==4), strata(setid) 
	estimates save analysis/output/models/an_cox_R2_COMPOSITEvs2019gp_COMORBS_LSTYLE_ETHIMD, replace
restore



***Death***
*vs 2017_19-flu controls
preserve
	include analysis/stsetfordeath1ocare.doi
	keep if group==1|group==2
	
	stcox exposed age1 age2 age3 male i.stp 
	estimates save analysis/output/models/an_cox_R2_DEATHvsflu_MINADJ, replace
	
	stcox exposed age1 age2 age3 male i.stp htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression 
	estimates save analysis/output/models/an_cox_R2_DEATHvsflu_COMORBS, replace
	
	stcox exposed age1 age2 age3 male i.stp i.obese4cat_withmiss i.smoke htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression 
	estimates save analysis/output/models/an_cox_R2_DEATHvsflu_COMORBS_LSTYLE, replace
	
	gen exposedperiod = exposed
	assert year(entrydate)== 2020 if exposed==1 /*otherwise next line doesn't work*/
	replace exposedperiod = 2 if exposed==1 & monthentry>9
	label define exposedperiodlab 1 "pre-may 2020" 2 "sept 2020 onwards"
	label values exposedperiod exposedperiodlab
	stcox i.exposedperiod age1 age2 age3 male i.stp 
	
	keep if entryd>=d(1/1/2019)

	*denom covid
	safecount if group==1 & _d==1
	local denomcov = r(N)
	*covid deaths in the covid group
	safecount if died_cause_ons=="U071"|died_cause_ons=="U072" & group==1 & _d==1
	if r(N) == . di "% < " 100*5/`denomcov'
	else di "% = " 100*r(N)/`denomcov'
	*pneumonia deaths in covid group
	safecount if substr(died_cause_ons, 1, 1) == "J" &  real(substr(died_cause_ons, 2, 2))>=12 &  real(substr(died_cause_ons, 2, 2))<=18 & group==1 & _d==1
		if r(N) == . di "% < " 100*5/`denomcov'
	else di "% = " 100*r(N)/`denomcov'
	
	*denomflu
	safecount if group==2 & _d==1
	local denomflu = r(N)
	*influenza deaths in inflenza group
	safecount if substr(died_cause_ons, 1, 1) == "J" &  real(substr(died_cause_ons, 2, 2))>=09 &  real(substr(died_cause_ons, 2, 2))<=11 & group==2 & _d==1
	if r(N) == . di "% < " 100*5/`denomflu'
	else di "% = " 100*r(N)/`denomflu'
	*pneumonia deaths in inflenza group
	safecount if substr(died_cause_ons, 1, 1) == "J" &  real(substr(died_cause_ons, 2, 2))>=12 &  real(substr(died_cause_ons, 2, 2))<=18 & group==2 & _d==1
	if r(N) == . di "% < " 100*5/`denomflu'
	else di "% = " 100*r(N)/`denomflu'
	
restore

*vs 2019 general pop controls
preserve
	include analysis/stsetfordeath1ocare.doi
	keep if group==1|group==4
	
	stcox exposed, strata(setid)
	estimates save analysis/output/models/an_cox_R2_DEATHvs2019gp_MINADJ, replace
	
	stcox exposed htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression, strata(setid)
	estimates save analysis/output/models/an_cox_R2_DEATHvs2019gp_COMORBS, replace
	
	stcox exposed i.obese4cat_withmiss i.smoke htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression, strata(setid)
	estimates save analysis/output/models/an_cox_R2_DEATHvs2019gp_COMORBS_LSTYLE, replace
	
restore

*models with ethnicity incorporating MI
preserve
	include analysis/stsetfordeath1ocare.doi
	drop if _st==0
	sts generate cumh = na
	egen cumhgp = cut(cumh), group(5)
	replace cumhgp = cumhgp + 1
	mi set wide
	mi register imputed ethnicity
	mi impute mlogit ethnicity _d i.cumhgp age1 age2 age3 male i.stp i.imd i.obese4cat_withmiss i.smoke htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression , add(10) rseed(95184)
	mi stset deathexit, enter(entrydate) fail(deathindicator) origin(entrydate)


	*vs 2017_19-flu controls
	mi estimate, eform post: stcox exposed age1 age2 age3 male i.stp i.ethnicity i.imd i.obese4cat_withmiss i.smoke htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression if (group==1|group==2)
	estimates save analysis/output/models/an_cox_R2_DEATHvsflu_COMORBS_LSTYLE_ETHIMD, replace

	*vs 2019 general pop controls
	mi estimate, eform post: stcox exposed i.ethnicity i.imd i.obese4cat_withmiss i.smoke htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression if (group==1|group==4), strata(setid) 
	estimates save analysis/output/models/an_cox_R2_DEATHvs2019gp_COMORBS_LSTYLE_ETHIMD, replace
restore


log close

