
cap log close
log using ./analysis/output/cr_getmatches, replace t

set seed 340590

frames reset
use ./analysis/cr_create_analysis_dataset, clear

count

keep if admitted1_reason=="U071"|admitted1_reason=="U072"
drop if discharged1_date>=d(1/12/2020)

keep patient_id stp age male discharged1_date

sort discharged1_date

gen discharged1_month = month(discharged1_date)

*frame put if discharged1_month==2, into(tomatch)

frame rename default tomatch

frame create pool 
frame change pool

**********PREPARE POOL
use patient_id stp age male admitted_date discharged_date lastprior* using ./analysis/cr_create_pool_data_02, clear
gen byte inpool2=1
rename age age_p2
*drop from pool if in hospital on 1st of month 
drop if lastprioradmission_adm_date<d(1/2/2021) & lastprioradmission_dis_date >= d(1/2/2021) 
drop lastprior*

forvalues i = 3/11 {
	
	if `i'<10 local ifull "0`i'"
	else local ifull "`i'"
	
	merge 1:1 patient_id using ./analysis/cr_create_pool_data_`ifull' , keepusing(patient_id stp age male admitted_date discharged_date lastprior*)
	rename age age_p`i'

	*drop from pool if in hospital on 1st of month 
	drop if lastprioradmission_adm_date<d(1/`i'/2021) & lastprioradmission_dis_date >= d(1/`i'/2021) 
	drop lastprior*
	
	gen byte inpool`i'=1 if (_merge==2|_merge==3)
	drop _m
	sort patient_id

}

*remove from pool once hospitalised for covid
merge 1:1 patient_id using ./analysis/cr_create_analysis_dataset, keepusing(admitted1_date admitted1_reason)

replace monthfirstineligible = month(admitted1_date)  if (admitted1_reason=="U071"|admitted1_reason=="U072") 
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
		
		frame put if abs(age_p`TMmonth'-TMage)<=3, into(eligiblematches)
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
	tempfile alldata 
	save `alldata', replace
restore 

forvalues i=2/11{
  	if `i'<10 local ifull "0`i'"
	else local ifull "`i'"
    preserve
	keep if discharged1_month==`i' & exposed==0
	merge m:1 patient_id using "./analysis/cr_create_pool_data_`ifull'.dta", keep(match master)
	append using `alldata'
	restore
}

use `alldata', clear
gsort setid -exposed patient_id
save ./analysis/cr_getmatches, replace 

log close