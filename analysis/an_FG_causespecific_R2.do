*csoutcomes passed in as: circulatory cancer_ex_nmsc respiratory respiratorylrti digestive mentalhealth nervoussystem genitourinary endo_nutr_metabol external musculoskeletal  otherinfections 
local csoutcome `1'
local rseed `2'

cap log close
log using analysis/output/an_FG_causespecific_R2`csoutcome', replace t

local allgraphs
	
di _n _dup(50) "*" 
di "`csoutcome'"
	
use analysis/cr_append_process_data, clear
drop if group==3
drop if group==2 & entrydate<d(1/1/2019)
safetab group

*R2
drop if obese4cat_withmiss==.
drop if smoke==.
safetab group
drop if region_real==.
safetab group

replace CSfail_`csoutcome'=2 if CSfail_`csoutcome'==0 & CSexit_`csoutcome'==died_date_ons /*distinguish those that were censored due to competing risk of death*/
stset CSexit_`csoutcome', fail(CSfail_`csoutcome'==1) origin(entrydate) enter(entrydate) 


**Adj match factors only

***VS FLU
stcrreg exposed age male i.region_real if group==1|group==2, compete(CSfail_`csoutcome'==2)
estimates save analysis/output/models/an_FG_causespecific_R2`csoutcome'_cflu_MATCHFACONLY, replace

***VS GENERAL POP
stcrreg exposed age male i.region_real i.ethnicity i.imd i.obese4cat_withmiss i.smoke htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression if group==1|group==2, compete(CSfail_`csoutcome'==2) 
estimates save analysis/output/models/an_FG_causespecific_R2`csoutcome'_cflu_COMORBS_LSTYLE_ETHIMD, replace


**Fully adj with MI for ethnicity

drop if _st==0
sts generate cumh = na
egen cumhgp = cut(cumh), group(5)
replace cumhgp = cumhgp + 1
mi set wide
mi register imputed ethnicity
mi impute mlogit ethnicity _d i.cumhgp i.group age male i.region_real i.imd i.obese4cat_withmiss i.smoke htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression , add(10) rseed(`rseed')
anmi stset CSexit_`csoutcome', fail(CSfail_`csoutcome'==1) origin(entrydate) enter(entrydate) 

***VS FLU
mi estimate, eform post: stcrreg exposed age male i.region_real if group==1|group==4
estimates save analysis/output/models/an_FG_causespecific_R2`csoutcome'_c2019gp_MATCHFACONLY, replace

***VS GENERAL POP
mi estimate, eform post: stcrreg exposed age male i.region_real i.ethnicity i.imd i.obese4cat_withmiss i.smoke htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression if group==1|group==4, compete(CSfail_`csoutcome'==2)
estimates save analysis/output/models/an_FG_causespecific_R2`csoutcome'_c2019gp_COMORBS_LSTYLE_ETHIMD, replace


log close
