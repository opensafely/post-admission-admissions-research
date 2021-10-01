
*csoutcomes passed in as: circulatory cancer_ex_nmsc respiratory respiratorylrti digestive mentalhealth nervoussystem genitourinary endo_nutr_metabol external musculoskeletal  otherinfections 
local csoutcome `1'
local rseed `2'

cap log close
log using analysis/output/an_SAcausespecific`csoutcome', replace t

local allgraphs
	
di _n _dup(50) "*" 
di "`csoutcome'"
	
use analysis/cr_append_process_data, clear
drop if group==3
drop if group==2 & entrydate<d(1/1/2019)
safetab group

local other_immunosuppression "other_immunosuppression"
if "`csoutcome'"=="mentalhealth"{
recode cancer_haem_cat 1=0 2/4=1
local other_immunosuppression
local simplified simplified
}


*R2
drop if obese4cat_withmiss==.
drop if smoke==.
drop if region_real==.

stset CSexit_`csoutcome', fail(CSfail_`csoutcome') origin(entrydate) enter(entrydate) 

**Fully adj with MI for ethnicity

drop if _st==0
sts generate cumh = na
egen cumhgp = cut(cumh), group(5)
replace cumhgp = cumhgp + 1
mi set wide
mi register imputed ethnicity
mi passive: gen ethnicitysimplified = ethnicity
mi passive: replace ethnicitysimplified = 5 if ethnicitysimplified == 2
mi impute mlogit ethnicity _d i.cumhgp i.group age male i.region_real i.imd i.obese4cat_withmiss i.smoke htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression , add(10) rseed(`rseed')
gen id=_n
mi stset CSexit_`csoutcome', fail(CSfail_`csoutcome') origin(entrydate) enter(entrydate) id(id)
mi stsplit timesinceentry, at(22, 82, 1000)

***VS FLU
*adj non ph
if "`csoutcome'"=="circulatory"{
mi estimate, eform post: stcox exposed age male i.region_real i.ethnicity`simplified' i.imd i.obese4cat_withmiss i.smoke htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease ///
i.stroke 22.timesinceentry#1.stroke 82.timesinceentry#1.stroke ///
dementia other_neuro organ_transplant spleen ra_sle_psoriasis `other_immunosuppression' if group==1|group==2 
estimates save analysis/output/models/an_SAcausespecific`csoutcome'_vsfluADJNONPH, replace
}
if "`csoutcome'"=="cancer_ex_nmsc"{
mi estimate, eform post: stcox exposed ///
	age 22.timesinceentry#c.age 82.timesinceentry#c.age ///
	male i.region_real i.ethnicity`simplified' i.imd ///
	i.obese4cat_withmiss 22.timesinceentry#2.obese4cat_withmiss 22.timesinceentry#3.obese4cat_withmiss 22.timesinceentry#4.obese4cat_withmiss ///
	i.obese4cat_withmiss 82.timesinceentry#2.obese4cat_withmiss 82.timesinceentry#3.obese4cat_withmiss 82.timesinceentry#4.obese4cat_withmiss ///
	i.smoke htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat ///
	i.cancer_exhaem_cat 22.timesinceentry#1.cancer_exhaem_cat 22.timesinceentry#2.cancer_exhaem_cat 22.timesinceentry#3.cancer_exhaem_cat ///
						82.timesinceentry#1.cancer_exhaem_cat 82.timesinceentry#2.cancer_exhaem_cat 82.timesinceentry#3.cancer_exhaem_cat ///
	i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia ///
	i.other_neuro 22.timesinceentry#1.other_neuro 82.timesinceentry#1.other_neuro ///
	organ_transplant spleen ra_sle_psoriasis `other_immunosuppression' if group==1|group==2 
estimates save analysis/output/models/an_SAcausespecific`csoutcome'_vsfluADJNONPH, replace
}

if "`csoutcome'"=="respiratorylrti"{
mi estimate, eform post: stcox exposed age male i.region_real i.ethnicity`simplified' i.imd ///
	i.obese4cat_withmiss 22.timesinceentry#2.obese4cat_withmiss 22.timesinceentry#3.obese4cat_withmiss 22.timesinceentry#4.obese4cat_withmiss ///
	i.obese4cat_withmiss 82.timesinceentry#2.obese4cat_withmiss 82.timesinceentry#3.obese4cat_withmiss 82.timesinceentry#4.obese4cat_withmiss ///
i.smoke htdiag ///
	i.chronic_respiratory_disease 22.timesinceentry#1.chronic_respiratory_disease 82.timesinceentry#1.chronic_respiratory_disease ///
i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis `other_immunosuppression' if group==1|group==2 
estimates save analysis/output/models/an_SAcausespecific`csoutcome'_vsfluADJNONPH, replace
}


*adj care home
mi estimate, eform post: stcox exposed age male i.region_real i.ethnicity`simplified' i.imd i.obese4cat_withmiss i.smoke htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis `other_immunosuppression' carehomebin if group==1|group==2 
estimates save analysis/output/models/an_SAcausespecific`csoutcome'_vsfluADJCAREHOME, replace

*adj critical care
mi estimate, eform post: stcox exposed age male i.region_real i.ethnicity`simplified' i.imd i.obese4cat_withmiss i.smoke htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis anycriticalcare `other_immunosuppression' if group==1|group==2 
estimates save analysis/output/models/an_SAcausespecific`csoutcome'_vsfluADJCRITCARE, replace

*restrict to u071
mi estimate, eform post: stcox exposed age male i.region_real i.ethnicity`simplified' i.imd i.obese4cat_withmiss i.smoke htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis `other_immunosuppression' if ((group==1&admitted1_reason=="U071")|group==2)
estimates save analysis/output/models/an_SAcausespecific`csoutcome'_vsfluU071, replace

***VS GENERAL POP
*adj non ph
if "`csoutcome'"=="cancer_ex_nmsc"{
mi estimate, eform post noisily: stcox exposed i.ethnicity`simplified' i.imd i.obese4cat_withmiss i.smoke htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat ///
	i.cancer_exhaem_cat 22.timesinceentry#1.cancer_exhaem_cat 22.timesinceentry#2.cancer_exhaem_cat 22.timesinceentry#3.cancer_exhaem_cat ///
						82.timesinceentry#1.cancer_exhaem_cat 82.timesinceentry#2.cancer_exhaem_cat 82.timesinceentry#3.cancer_exhaem_cat ///
	i.cancer_haem_cat 22.timesinceentry#1.cancer_haem_cat 22.timesinceentry#2.cancer_haem_cat 22.timesinceentry#3.cancer_haem_cat ///
						82.timesinceentry#1.cancer_haem_cat 82.timesinceentry#2.cancer_haem_cat 82.timesinceentry#3.cancer_haem_cat ///
i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis `other_immunosuppression' if group==1|group==4, strata(setid)
estimates save analysis/output/models/an_SAcausespecific`csoutcome'_vs2019gpADJNONPH, replace
}
if "`csoutcome'"=="respiratory"{
mi estimate, eform post noisily: stcox exposed i.ethnicity`simplified' ///
	i.imd 	22.timesinceentry#2.imd 22.timesinceentry#3.imd 22.timesinceentry#4.imd 22.timesinceentry#5.imd ///
			82.timesinceentry#2.imd 82.timesinceentry#3.imd 82.timesinceentry#4.imd 82.timesinceentry#5.imd ///
	i.obese4cat_withmiss i.smoke htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 ///
	i.chronic_liver_disease 22.timesinceentry#1.chronic_liver_disease 82.timesinceentry#1.chronic_liver_disease ///
	stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis `other_immunosuppression' if group==1|group==4, strata(setid)
estimates save analysis/output/models/an_SAcausespecific`csoutcome'_vs2019gpADJNONPH, replace
}
if "`csoutcome'"=="respiratorylrti"{
mi estimate, eform post noisily: stcox exposed i.ethnicity`simplified' i.imd ///
	i.obese4cat_withmiss 22.timesinceentry#2.obese4cat_withmiss 22.timesinceentry#3.obese4cat_withmiss 22.timesinceentry#4.obese4cat_withmiss ///
	i.obese4cat_withmiss 82.timesinceentry#2.obese4cat_withmiss 82.timesinceentry#3.obese4cat_withmiss 82.timesinceentry#4.obese4cat_withmiss ///
 i.smoke htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis `other_immunosuppression' if group==1|group==4, strata(setid)
estimates save analysis/output/models/an_SAcausespecific`csoutcome'_vs2019gpADJNONPH, replace
}



*adj care home
mi estimate, eform post: stcox exposed i.ethnicity`simplified' i.imd i.obese4cat_withmiss i.smoke htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis `other_immunosuppression' carehomebin if group==1|group==4, strata(setid)
estimates save analysis/output/models/an_SAcausespecific`csoutcome'_vs2019gpADJCAREHOME, replace

*restrict to u071
mi estimate, eform post: stcox exposed i.ethnicity`simplified' i.imd i.obese4cat_withmiss i.smoke htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis `other_immunosuppression' if ((group==1&admitted1_reason=="U071")|group==4), strata(setid)
estimates save analysis/output/models/an_SAcausespecific`csoutcome'_vs2019gpU071, replace


log close
