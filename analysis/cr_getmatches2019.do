
cap log close
log using ./analysis/output/cr_getmatches2019, replace t

set seed 45092

frames reset
use ./analysis/cr_create_analysis_dataset, clear

count

keep if admitted1_reason=="U071"|admitted1_reason=="U072"

summ discharged1_date, f d
scalar censordate = r(max) - 60


*tie together admissions that are within the same day of a previous discharge
gen coviddischargedate = discharged1_date
replace coviddischargedate = discharged2_date if discharged1_date==admitted2_date
replace coviddischargedate = discharged3_date if discharged1_date==admitted2_date & discharged2_date==admitted3_date
replace coviddischargedate = discharged4_date if discharged1_date==admitted2_date & discharged2_date==admitted3_date & discharged3_date==admitted4_date

*drop set if later than 60d before latest sus data
drop if coviddischargedate >= censordate

cou

*drop if died date on/before discharge date
cou if died_date_ons==coviddischargedate
cou if died_date_ons<coviddischargedate
drop if died_date_ons<=coviddischargedate
cou
keep patient_id stp age male coviddischargedate

sort coviddischargedate

gen discharged1_month = month(coviddischargedate)

*frame put if discharged1_month==2, into(tomatch)

frame rename default tomatch

frame create pool 
frame change pool

**********PREPARE POOL
use patient_id stp age male admitted_date discharged_date lastprior* died_date_ons using ./analysis/cr_create_2019pool_data_02, clear
gen byte inpool2=1
rename age age_p2
*drop from pool if in hospital on 1st of month 
drop if lastprioradmission_adm_date<d(1/2/2019) & lastprioradmission_dis_date >= d(1/2/2019) 
drop lastprior*
*drop from pool if died on/before 1st of month 
drop if died_date_ons<=d(1/2/2019) 

forvalues i = 3/11 {
	
	if `i'<10 local ifull "0`i'"
	else local ifull "`i'"
	
	merge 1:1 patient_id using ./analysis/cr_create_2019pool_data_`ifull' , keepusing(patient_id stp age male admitted_date discharged_date lastprior* died_date_ons)
	rename age age_p`i'

	gen byte inpool`i'=1 if (_merge==2|_merge==3)
	drop _m
	
	*drop from pool if in hospital on 1st of month 
	replace inpool`i' = 0 if lastprioradmission_adm_date<d(1/`i'/2019) & lastprioradmission_dis_date >= d(1/`i'/2019) 
	drop lastprior*
	
	*drop from pool if died on/before 1st of month 
	replace inpool`i' = 0 if died_date_ons<=d(1/`i'/2019) 
	drop died_date_ons

	sort patient_id

}

*remove from pool once hospitalised for covid
merge 1:1 patient_id using ./analysis/cr_create_analysis_dataset, keepusing(admitted1_date admitted1_reason)

gen monthfirstineligible = month(admitted1_date)  if (admitted1_reason=="U071"|admitted1_reason=="U072") 
replace monthfirstineligible = 1 if monthfirst==13

forvalues i = 2/11 {
	replace inpool`i'=0 if monthfirstineligible<=`i' 
}

drop _merge monthfirstineligible
drop admitted1_date admitted1_reason

*Make a frame for each stp/sex combo
forvalues i = 1/32 {
	frame put if stp==`i' & male==0, into(stp`i'_male0)
	frame put if stp==`i' & male==1, into(stp`i'_male1)
}

frame change tomatch
frame drop pool 

for num 1/5: gen long matchedto_X=.

qui cou
local totaltomatch = r(N)
noi di "Total patients to match = `totaltomatch'" _n

forvalues matchnum = 1/5{
noi di "Getting match number `matchnum's"

	forvalues i = 1/`totaltomatch' {
		if mod(`i',100)==0 noi di "." _cont
		if mod(`i',1000)==0 noi di "`i'" _cont

		scalar idtomatch = patient_id[`i']
		scalar TMage = age[`i']
		local TMstp = stp[`i']
		local TMmale = male[`i']
		local TMmonth = discharged1_month[`i']
			
		cap frame drop eligiblematches
		frame change stp`TMstp'_male`TMmale'
		
		frame put if abs(age_p`TMmonth'-TMage)<=3 & inpool`TMmonth'==1, into(eligiblematches)
		frame eligiblematches: qui cou
		if r(N)>=1{
			frame eligiblematches: gen u=uniform()
			frame eligiblematches: gen agediff=abs(age_p`TMmonth'-TMage)
			frame eligiblematches: sort agediff u
			frame eligiblematches: scalar selectedmatch = patient_id[1]
		}
		else scalar selectedmatch = -999

		frame tomatch: qui replace matchedto_`matchnum' = selectedmatch in `i'
		qui drop if patient_id==selectedmatch
		
		frame change tomatch
	}
}

frame change tomatch
keep patient_id matchedto* discharged1_month

reshape long matchedto_, i(patient_id)

rename patient_id setid
rename matchedto patient_id

expand 2 if setid!=setid[_n-1], gen(expanded)
replace patient_id=setid if expanded==1
drop expanded

replace patient_id = -_n if patient_id==-999

sort setid patient_id
safecount if setid!=setid[_n+1] & patient_id<0
noi di r(N) " patients could not be matched at all"
drop if patient_id<0

gen exposed = patient_id==setid

*Get correct variables from month-specific pool
preserve 
	keep if exposed==1
	merge m:1 patient_id using "./analysis/cr_create_analysis_dataset.dta", keep(match master)
	
	*tie together admissions that are within the same day of a previous discharge (as above pre-matching - this time also produce readmission date)
	gen coviddischargedate = discharged1_date
	replace coviddischargedate = discharged2_date if discharged1_date==admitted2_date
	replace coviddischargedate = discharged3_date if discharged1_date==admitted2_date & discharged2_date==admitted3_date
	replace coviddischargedate = discharged4_date if discharged1_date==admitted2_date & discharged2_date==admitted3_date & discharged3_date==admitted4_date

	gen readmission_date = admitted2_date 
	gen readmission_reason = admitted2_reason
	replace readmission_date = admitted3_date if discharged1_date==admitted2_date
	replace readmission_reason = admitted3_reason if discharged1_date==admitted2_date
	replace readmission_date = admitted4_date if discharged1_date==admitted2_date & discharged2_date==admitted3_date
	replace readmission_reason = admitted4_reason if discharged1_date==admitted2_date & discharged2_date==admitted3_date
	replace readmission_date = admitted5_date if discharged1_date==admitted2_date & discharged2_date==admitted3_date & discharged3_date==admitted4_date
	replace readmission_reason = admitted5_reason if discharged1_date==admitted2_date & discharged2_date==admitted3_date & discharged3_date==admitted4_date
		
	tempfile alldata 
	save `alldata', replace
restore 

forvalues i=2/11{
  	if `i'<10 local ifull "0`i'"
	else local ifull "`i'"
    preserve
	keep if discharged1_month==`i' & exposed==0
	merge m:1 patient_id using "./analysis/cr_create_2019pool_data_`ifull'.dta", keep(match master)
	append using `alldata'
	save `alldata', replace
	restore
}

use `alldata', clear
gsort setid -exposed patient_id
save ./analysis/cr_getmatches2019, replace 

log close