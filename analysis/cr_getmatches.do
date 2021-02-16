
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
use ./analysis/cr_create_pool_basicdata_02, clear
gen byte inpool2=1
rename age age_p2
*!drop from pool if in hospital on 1st of month [need to extract these columns using on_or_before in study def]


forvalues i = 3/11 {
	
	if `i'<10 local ifull "0`i'"
	else local ifull "`i'"
	
	merge 1:1 patient_id using ./analysis/cr_create_pool_basicdata_`ifull' 

	rename age age_p`i'
	
	*!drop from pool if in hospital on 1st of month [need to extract these columns using on_or_before in study def]
	
	gen byte inpool`i'=1 if (_merge==2|_merge==3)
	drop _m
	sort patient_id

}

*remove from pool once hospitalised for covid
merge 1:1 patient_id using ./analysis/cr_create_analysis_dataset, keepusing(admitted1_date admitted1_reason)

gen monthfirstineligible = month(admitted1_date) + 1 if (admitted1_reason=="U071"|admitted1_reason=="U072") & day(admitted1_date)>1
replace monthfirstineligible = month(admitted1_date)  if (admitted1_reason=="U071"|admitted1_reason=="U072") & day(admitted1_date)==1
replace monthfirstineligible = 1 if monthfirst==13

forvalues i = 2/11 {
	replace inpool`i'=0 if monthfirstineligible<=`i' 
}

drop _merge monthfirstineligible
drop admitted1_date admitted1_reason

/*
forvalues i = 1/32 {
	frame put if (stp_p2==`i'|stp_p3==`i'|stp_p4==`i'|stp_p5==`i'|stp_p6==`i'|stp_p7==`i'|stp_p8==`i'|stp_p9==`i'|stp_p10==`i'|stp_p11==`i') & male==0, into(stp`i'_male0)
	frame put if (stp_p2==`i'|stp_p3==`i'|stp_p4==`i'|stp_p5==`i'|stp_p6==`i'|stp_p7==`i'|stp_p8==`i'|stp_p9==`i'|stp_p10==`i'|stp_p11==`i') & male==1, into(stp`i'_male1)
}
*/
forvalues i = 1/32 {
	frame put if stp==`i' & male==0, into(stp`i'_male0)
	frame put if stp==`i' & male==1, into(stp`i'_male1)
}

frame change tomatch
frame drop pool 

for num 1/5: gen long matchedto_X=.

qui cou
local totaltomatch = r(N)

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
keep patient_id matchedto*


reshape long matchedto_, i(patient_id)

rename patient_id setid
rename matchedto patient_id

expand 2 if setid!=setid[_n-1], gen(expanded)
replace patient_id=setid if expanded==1
drop expanded

replace patient_id = -_n if patient_id==-999

merge m:1 patient_id using "./analysis/cr_create_analysis_dataset.dta", keep(match master)

gen discharged1_month = month(discharged1_date) if patient_id==setid
sort setid discharged1_month
by setid: replace discharged1_month=discharged1_month[1]


sort setid patient_id
safecount if setid!=setid[_n+1] & patient_id<0
noi di r(N) " patients could not be matched at all"

drop if patient_id<0

stset stime_onsdeath, fail(onsdeath=1) 				///
	id(patient_id) enter(enter_date) origin(enter_date)

gsort setid -hiv patient_id

save cr_matchedcohort_STSET_onsdeath_fail1, replace 

