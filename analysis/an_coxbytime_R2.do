
cap log close
log using analysis/output/an_coxbytime_R2, replace t

*changes for R2
*restrict to the CC bmi/smok population
*implement (outcome-specific) MI for ethnicity

use analysis/cr_append_process_data, clear

*R2
drop if obese4cat_withmiss==.
drop if smoke==.
safetab group
drop if region_real==.
safetab group

gen id=_n
streset, id(n)
	
***Composite***
*vs 2017_19-flu controls
preserve
keep if group==1|group==2
	stsplit timesinceentry, at(23, 73, 1000)
	stcox i.exposed##i.timesinceentry age1 age2 age3 male i.stp 
	estimates save analysis/output/models/an_coxbytime_R2_COMPOSITEvsflu_MINADJ, replace
restore

*vs 2019 general pop age/sex/stp matched controls
preserve
keep if group==1|group==4
	stsplit timesinceentry, at(23, 73, 1000)
	stcox i.exposed##i.timesinceentry, strata(setid)
	estimates save analysis/output/models/an_coxbytime_R2_COMPOSITEvs2019gp_MINADJ, replace
restore	
	


***Death***
*vs 2017_19-flu controls
preserve
	include analysis/stsetfordeath1ocare.doi
	streset, id(n)
	keep if group==1|group==2
	
	stsplit timesinceentry, at(23, 73, 1000)
	stcox i.exposed##i.timesinceentry age1 age2 age3 male i.stp 
	estimates save analysis/output/models/an_coxbytime_R2_DEATHvsflu_MINADJ, replace
restore

*vs 2019 general pop controls
preserve
	include analysis/stsetfordeath1ocare.doi
	streset, id(n)
	keep if group==1|group==4
	
	stsplit timesinceentry, at(23, 73, 1000)
	stcox i.exposed##i.timesinceentry, strata(setid)
	estimates save analysis/output/models/an_coxbytime_R2_DEATHvs2019gp_MINADJ, replace
restore

log close

