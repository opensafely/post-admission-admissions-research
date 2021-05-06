
cap log close
log using analysis/output/an_posthoc_mentalhealth, replace t
	
use analysis/cr_append_process_data, clear
drop if group==3|group==4
drop if group==2 & entrydate<d(1/1/2019)


stset CSexit_mentalhealth, fail(CSfail_mentalhealth) origin(entrydate) enter(entrydate) 
gen fup = _t-_t0 
summ fup if group==1
scalar fupcovid = r(mean)*r(N)

summ fup if group==2
scalar fupflu = r(mean)*r(N)

cou if CSfail_mentalhealth==1 & _d==1
cou if CSfail_mentalhealth==1 & CSfaildiedonly_mentalhealth ==1 & _d==1

gen mentalhealthicd3 = substr(admitted_mentalhealth_reason, 1, 3) if CSfail_mentalhealth==1 & CSfaildiedonly_mentalhealth!=1 & _d==1
replace mentalhealthicd3 = substr(died_cause_ons, 1, 3) if CSfail_mentalhealth==1 & CSfaildiedonly_mentalhealth==1 & _d==1
gen icdnumeric = real(substr(mentalhealthicd3,2,2))

gen mentalhealthgrouped = "Dementia (F00-F03, G30)" if icdnumer>=0 & icdnumer<=3
replace mentalhealthgrouped = "Delirium (F05)" if icdnumeric==5
replace mentalhealthgrouped = "Schizophrenia/schizotypal/delusional disorders (F20-29)" if icdnumeric>=20 & icdnumeric<=29
replace mentalhealthgrouped = "Mood disorders (F30-39)" if icdnumeric>=30 & icdnumeric<=39
replace mentalhealthgrouped = "Neurotic/stress-related/somatoform disorders (F40-48)" if icdnumeric>=40 & icdnumeric<=49

encode mentalhealthgrouped, gen(mentalhealthgrouped_n)

/*gen fail_exdem = CSfail_mentalhealth
replace fail_exdem = 0 if substr(mentalhealthgrouped,1,3)!="Dem"


stcox exposed age male i.region_real if group==1|group==2
stcox exposed age male i.region_real i.ethnicity i.imd i.obese4cat i.smoke_nomiss htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression if group==1|group==2 
*/
/*
gen fail2 = CSfail_mentalhealth
replace fail2 = 0 if substr(mentalhealthgrouped,1,3)!="Dem"
streset, fail(fail2)

stmh group, c(1,2) by(agegroup male)
stcox ib2.group age male dementia
stcox ib2.group age male if dementia==0
*/
foreach run of any dem demwdem demexdem demnocare demcare del sch moo neu all{
preserve
local failtype = substr("`run'",1,3)
if "`run'"=="demwdem" keep if dementia==1
if "`run'"=="demexdem" drop if dementia==1
if "`run'"=="demnocare" drop if carehomebin==1
if "`run'"=="demcare" keep if carehomebin==1
if "`run'"=="all" replace mentalhealthgrouped = "All except dementia (F05-F99)" if icdnumeric>=5 & icdnumeric<.
tempfile temp`run'
gen fail`failtype' = CSfail_mentalhealth
replace fail`failtype' = 0 if substr(lower(mentalhealthgrouped),1,3)!="`failtype'"
streset, fail(fail`failtype') scale(365.25)
cou if _d==1 &CSfaildiedonly_mentalhealth==1
di "N FAILURES THAT WERE DEATHS RATHER THAN HOSPITALISATIONS = " r(N)
strate group, per(1000) output(`temp`run'')
tab _d group

stcox ib2.group age male i.region_real
lincom 1.group, hr
local hr = r(estimate)
local lci = r(lb)
local uci = r(ub)

if "`run'"=="dem"{
stcox ib2.group##i.dementia age male i.region_real
test 1.group#1.dementia
local pint_dem = string(r(p), "%4.2f")
lincom 1.group, hr
local hrciexdem = string(r(estimate), "%4.2f") + " (" + string(r(lb), "%4.2f") + "-" + string(r(ub), "%4.2f") + ")"
lincom 1.group + 1.group#1.dementia, hr
local hrciwdem = string(r(estimate), "%4.2f") + " (" + string(r(lb), "%4.2f") + "-" + string(r(ub), "%4.2f") + ")"
stcox ib2.group##i.carehomebin age male i.region_real
test 1.group#1.carehomebin
local pint_care = string(r(p), "%4.2f")
lincom 1.group, hr
local hrcinocare = string(r(estimate), "%4.2f") + " (" + string(r(lb), "%4.2f") + "-" + string(r(ub), "%4.2f") + ")"
lincom 1.group + 1.group#1.carehomebin, hr
local hrcicare = string(r(estimate), "%4.2f") + " (" + string(r(lb), "%4.2f") + "-" + string(r(ub), "%4.2f") + ")"
}

restore
preserve
use `temp`run'', clear
gen str10 failtype = "`run'"
gen hr = `hr' if _n==1
gen lci = `lci' if _n==1
gen uci = `uci' if _n==1
save, replace
restore
}
clear
foreach run of any dem demwdem demexdem demcare demnocare del sch moo neu all{
append using `temp`run''
}

gen mentalhealthgrouped = "Dementia (F00-F03)" if failtype=="dem"
replace mentalhealthgrouped = "(among those with baseline dementia)" if failtype=="demwdem"
replace mentalhealthgrouped = "(among those with NO baseline dementia)" if failtype=="demexdem"
replace mentalhealthgrouped = "(among those living in care homes)" if failtype=="demcare"
replace mentalhealthgrouped = "(among those NOT living in care homes)" if failtype=="demnocare"
replace mentalhealthgrouped = "Delirium (F05)" if failtype=="del"
replace mentalhealthgrouped = "Schizophrenia/schizotypal/delusional disorders (F20-29)" if failtype=="sch"
replace mentalhealthgrouped = "Mood disorders (F30-39)" if failtype=="moo"
replace mentalhealthgrouped = "Neurotic/stress-related/somatoform disorders (F40-48)" if failtype=="neu"
replace mentalhealthgrouped = "All except dementia (F05-F99)" if failtype=="all"

gen order = 1 if failtype!=failtype[_n-1]
replace order = sum(order)
gen rateci = string(_Rate, "%4.2f") + " (" + string(_Lower, "%4.2f") + "-" + string(_Upper, "%4.2f") + ")"
gen _dstr = string(_D) if _D>5
replace _dstr = "<=5" if _D<=5
gen events_ratecov = "[" + _dstr + "] " + rateci
gen hrci = string(hr, "%4.2f") + " (" + string(lci, "%4.2f") + "-" + string(uci, "%4.2f") + ")"
replace hrci = hrci[_n-1] if group==2

replace hrci = "`hrcicare'" if failtype=="demcare"
replace hrci = "`hrcinocare'" if failtype=="demnocare"
replace hrci = "`hrciwdem'" if failtype=="demwdem"
replace hrci = "`hrciexdem'" if failtype=="demexdem"

keep group mentalhealthgrouped events_ratecov hrci order
reshape wide events_ratecov , i(order) j(group)

drop order
order mentalhealthgrouped

outsheet using analysis/output/an_posthoc_mentalhealth.txt, replace c 

log close