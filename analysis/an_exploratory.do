
use ./analysis/cr_create_analysis_dataset, clear

tab region
tab stp
tab imd

histogram age, width(1)

tab male

tab ethnicity

histogram bmi, width(1)

tab smoke_nomiss

histogram patient_index_date, width(1)

assert patient_index_date == admitted1_date

tab admitted1_reason, sort

gen length_stay1 = discharged1_date-admitted1_date 
histogram length_stay1, width(1)

gen readmitted = admitted2_date<.
tab readmitted

summ admitted1_date, f d
summ discharged1_date, f d

scalar censordate = r(max)
drop if admitted1_date >= censordate-60

gen exit_date = admitted2_date
replace exit_date = died_date_ons if died_date_ons<admitted2_date
replace exit_date = censordate if exit_date>censordate
format %d exit_date
drop if died_date_ons==discharged1_date

gen outcome = 0
replace outcome = 3 if exit_date==died_date_ons
replace outcome = 1 if exit_date==admitted2_date
replace outcome = 2 if outcome==1 & (admitted2_reason=="U071"|admitted2_reason=="U072")

stset exit_date, fail(outcome==1) enter(discharged1_date) origin(discharged1_date)
stcompet cuminc = ci, compet1(2) compet2(3)

twoway line cuminc _t if outcome==1, c(stairstep) sort || line cuminc _t if outcome==2, c(stairstep) sort  || line cuminc _t if outcome==3, c(stairstep) sort legend(label(1 "readmission - covid") label(2 "readmission non-covid") label(3 "death"))

/*
sts graph, by(ethnicity)
sts graph, by(agegroup)
sts graph, by(male)
sts graph, by(imd)
sts graph, by(reduced_kidney_function_cat2)
*/

tab admitted2_reason, sort
gen readmission_icd_chapter = substr(admitted2_reason,1,1)
tab readmission_icd_chapter, sort