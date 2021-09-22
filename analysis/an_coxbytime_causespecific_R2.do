*csoutcomes passed in as: circulatory cancer_ex_nmsc respiratory respiratorylrti digestive mentalhealth nervoussystem genitourinary endo_nutr_metabol external musculoskeletal  otherinfections 
local csoutcome `1'

cap log close
log using analysis/output/an_coxbytime_causespecific_R2`csoutcome', replace t

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

stset CSexit_`csoutcome', fail(CSfail_`csoutcome') origin(entrydate) enter(entrydate) 

gen id=_n
streset, id(id)
stsplit timesinceentry, at(22, 82, 1000)

**Adj match factors only

***VS FLU
stcox i.exposed##i.timesinceentry age male i.region_real if group==1|group==2 
estimates save analysis/output/models/an_coxbytime_causespecific_R2`csoutcome'_cflu_MATCHFACONLY, replace

***VS GENERAL POP
stcox i.exposed##i.timesinceentry if group==1|group==4, strata(setid)
estimates save analysis/output/models/an_coxbytime_causespecific_R2`csoutcome'_c2019gp_MATCHFACONLY, replace


log close
