
cap log close
log using analysis/output/an_sensanalyses, replace t

use analysis/cr_append_process_data, clear

*R2
drop if obese4cat_withmiss==.
drop if smoke==.
safetab group
drop if region_real==.
safetab group

gen id=_n
streset, id(id)
	
***Composite***
preserve
	drop if _st==0
	sts generate cumh = na
	egen cumhgp = cut(cumh), group(5)
	replace cumhgp = cumhgp + 1
	mi set wide
	mi register imputed ethnicity
	mi impute mlogit ethnicity _d i.cumhgp i.group age1 age2 age3 male i.region_real i.imd i.obese4cat_withmiss i.smoke htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression , add(10) rseed(234958)
	mi stset exitdate, fail(readmission) enter(entrydate) origin(entrydate) id(id)
	mi stsplit timesinceentry, at(22, 82, 1000)
	
	*vs flu controls
	*adj non ph
	mi estimate, eform post: stcox exposed age1 age2 age3 male i.stp i.ethnicity i.imd i.timesinceentry##i.obese4cat_withmiss i.smoke htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.timesinceentry##i.cancer_exhaem_cat i.timesinceentry##i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia i.timesinceentry##i.other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression if (group==1|group==2)
	estimates save analysis/output/models/an_sensanalyses_compositevsfluADJNONPH, replace
	
	*adj carehome
	mi estimate, eform post: stcox exposed age1 age2 age3 male i.stp i.ethnicity i.imd i.obese4cat_withmiss i.smoke htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression carehomebin if (group==1|group==2)
	estimates save analysis/output/models/an_sensanalyses_compositevsfluADJCAREHOME, replace
	
	*adj critical care
	mi estimate, eform post: stcox exposed age1 age2 age3 male i.stp i.ethnicity i.imd i.obese4cat_withmiss i.smoke htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression anycriticalcare if (group==1|group==2)
	estimates save analysis/output/models/an_sensanalyses_compositevsfluADJCRITCARE, replace
	
	*restrict to u071 
	mi estimate, eform post: stcox exposed age1 age2 age3 male i.stp i.ethnicity i.imd i.obese4cat_withmiss i.smoke htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression if ((group==1&admitted1_reason=="U071")|group==2)
	estimates save analysis/output/models/an_sensanalyses_compositevsfluU071, replace
	
	
	*vs 2019 gen pop controls
	*adj non ph
	mi estimate, eform post: stcox exposed i.ethnicity i.imd i.obese4cat_withmiss i.smoke htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.timesinceentry##i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression if (group==1|group==4), strata(setid) 
	estimates save analysis/output/models/an_sensanalyses_compositevs2019gpADJNONPH, replace
	
	*adj carehome
	mi estimate, eform post: stcox exposed i.ethnicity i.imd i.obese4cat_withmiss i.smoke htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression carehomebin if (group==1|group==4), strata(setid) 
	estimates save analysis/output/models/an_sensanalyses_compositevs2019gpADJCAREHOME, replace
	
	*restrict to u071 
	mi estimate, eform post: stcox exposed i.ethnicity i.imd i.obese4cat_withmiss i.smoke htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression if ((group==1&admitted1_reason=="U071")|group==4), strata(setid) 
	estimates save analysis/output/models/an_sensanalyses_compositevs2019gpU071, replace

restore


***Death***
preserve
	include analysis/stsetfordeath1ocare.doi
	drop if _st==0
	sts generate cumh = na
	egen cumhgp = cut(cumh), group(5)
	replace cumhgp = cumhgp + 1
	mi set wide
	mi register imputed ethnicity
	mi impute mlogit ethnicity _d i.cumhgp i.group age1 age2 age3 male i.region_real i.imd i.obese4cat_withmiss i.smoke htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression , add(10) rseed(59390)
	mi stset deathexit, enter(entrydate) fail(deathindicator) origin(entrydate) id(id)
	mi stsplit timesinceentry, at(22, 82, 1000)

*vs 2017_19-flu controls
	*adj non ph
	mi estimate, eform post: stcox exposed age1 age2 age3 male i.stp i.ethnicity i.imd i.timesinceentry##i.obese4cat_withmiss i.smoke htdiag i.timesinceentry##i.chronic_respiratory_disease i.asthmacat i.timesinceentry##i.chronic_cardiac_disease i.diabcat i.timesinceentry##i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke i.timesinceentry##i.dementia i.timesinceentry##i.other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression if (group==1|group==2)
	estimates save analysis/output/models/an_sensanalyses_deathvsfluADJNONPH
	*adj carehome
	mi estimate, eform post: stcox exposed age1 age2 age3 male i.stp i.ethnicity i.imd i.obese4cat_withmiss i.smoke htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression carehomebin if (group==1|group==2)
	estimates save analysis/output/models/an_sensanalyses_deathvsfluADJCAREHOME, replace
	
	*adj critical care
	mi estimate, eform post: stcox exposed age1 age2 age3 male i.stp i.ethnicity i.imd i.obese4cat_withmiss i.smoke htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression anycriticalcare if (group==1|group==2)
	estimates save analysis/output/models/an_sensanalyses_deathvsfluADJCRITCARE, replace
	
	*restrict tou071
	mi estimate, eform post: stcox exposed age1 age2 age3 male i.stp i.ethnicity i.imd i.obese4cat_withmiss i.smoke htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression if ((group==1&admitted1_reason=="U071")|group==2)
	estimates save analysis/output/models/an_sensanalyses_deathvsfluU071, replace
	
*vs 2019 general pop controls
	*adj non ph NA

	*adj carehome
	mi estimate, eform post: stcox exposed i.ethnicity i.imd i.obese4cat_withmiss i.smoke htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression carehomebin if (group==1|group==4), strata(setid) 
	estimates save analysis/output/models/an_sensanalyses_deathvs2019gpADJCAREHOME, replace
	
	*adj critical care
	mi estimate, eform post: stcox exposed i.ethnicity i.imd i.obese4cat_withmiss i.smoke htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression anycriticalcare if (group==1|group==4), strata(setid) 
	estimates save analysis/output/models/an_sensanalyses_deathvs2019gpADJCRITCARE, replace
	
	*restrict tou071
	mi estimate, eform post: stcox exposed i.ethnicity i.imd i.obese4cat_withmiss i.smoke htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression if ((group==1&admitted1_reason=="U071")|group==4), strata(setid) 
	estimates save analysis/output/models/an_sensanalyses_deathvs2019gpU071, replace
	
	restore


log close

