cap log close
log using analysis/output/an_descriptive, replace t
use analysis/cr_append_process_data, clear

preserve
keep if group==1|group==4
bysort setid: gen groupsize = _N
tab groupsize if group==1
restore

*How many in both cov and flu groups
preserve
keep if group==1|group==2
sort patient_id
by patient_id: gen inboth = _N==2
tab inboth group, col
restore


preserve
*Round entry dates into monthly bins for histogram
*Add small cell suppression - <=5 replaced with 5

gen yearentry = year(discharged1_date) if group==1|group==2
replace yearentry = 2019 if group==4
gen yearmonth = yearentry+10000*month(discharged1_date) if group==1|group==2
replace yearmonth = yearentry+10000*monthentry if group==4
table yearmonth group, c(freq) replace
gen year = mod(yearmonth, 10000)
gen month = (yearmonth - year)/10000

replace table1=5 if table1<=5

gen datehist = mdy(month,15,year)

/*gen datehist = mdy(month(discharged1_date),15,2020) if group==1
replace datehist = mdy(monthentry,15,2019) if group==4
replace datehist = mdy(month(discharged1_date),15,year(discharged1_date)) if group==2
*/

format %d datehist 

histogram datehist if (group==1|group==2|group==4) [fw=table1], by(group, cols(1)) bin(48) xtitle(Entry date)
graph export analysis/output/an_descriptive_EVENTSBYTIME.svg, as(svg) replace

restore 

gen monthyrentry = year(entrydate) * 100 + month(entrydate)

safetab monthyrent group  if group==2 & entrydate<d(1/11/2019)

safetab readmission group, col

safetab readm_reason_b group, col

cap file close tablecontent
file open tablecontent using ./analysis/output/an_descriptive_OUTCOMES.txt, write text replace

gen byte cons=1

foreach outcome of any DENOM composite death{
if "`outcome'"=="death" include analysis/stsetfordeath1ocare.doi

foreach group of numlist 1 2 4 {
	
if `group'==1 file write tablecontent ("`outcome'") _tab 

if "`outcome'"=="DENOM" local condition 
else local condition " & _d==1"

cou if group==`group' `condition'
file write tablecontent (r(N))
if "`outcome'"=="DENOM" local denominator`group' = r(N)
if "`outcome'"=="DENOM" & `group'==2{
	cou if group==2 & entrydate>=d(1/1/2019)
	file write tablecontent (" (") (r(N)) (" in 2019*)")
}
if "`outcome'"!="DENOM" file write tablecontent (" (") %3.1f (100*r(N)/`denominator`group'') (")")
if `group'<4 file write tablecontent _tab
else file write tablecontent _n

}

if "`outcome'"=="DENOM" file write tablecontent _n 
}

drop if group==2 & entrydate<d(1/1/2019)

include analysis/stsetfordeath1ocare.doi
preserve 
qui table died_reason group if _d==1, replace
table died_reason group  [fw=table1]
restore

/*cov group causes of death
THESE TABLES PRODUCE SMALL Ns - commenting out for routine runs
tab died_reason if _d==1 & gr==1 & died_date_1o>=d(1/1/2019), sort f m
tab died_cause_ons if gr==1 & _d==1 & died_r==7

*flu causes of death
tab died_reason if _d==1 & gr==2 & died_date_1o>=d(1/1/2019), sort f m
tab died_cause_ons if gr==2 & _d==1 & died_r==8 /*copds*/
*/

foreach csoutcome of any DENOM otherinfections cancer_ex_nmsc endo_nutr_metabol mentalhealth nervoussystem circulatory respiratorylrti respiratory digestive musculoskeletal genitourinary external {

foreach group of numlist 1 2 4 {


if "`csoutcome'"=="DENOM" local condition 
else{
	stset CSexit_`csoutcome', fail(CSfail_`csoutcome') origin(entrydate) enter(entrydate) 
	
	local condition " & _d == 1"
	local conditiondied " & _d == 1 & CSfaildiedonly_`csoutcome' == 1"

	if `group'==1 file write tablecontent ("`csoutcome'") _tab 
}

if "`csoutcome'"!="DENOM" {
cou if group==`group' `conditiondied'
local ndied=r(N)
}
cou if group==`group' `condition'
if "`csoutcome'"!="DENOM" file write tablecontent (r(N)) (" [") (`ndied') ("]")
if "`csoutcome'"=="DENOM" local denominator`group' = r(N)
if "`csoutcome'"!="DENOM" file write tablecontent (" (") %3.1f (100*r(N)/`denominator`group'') (")")
if `group'<4 file write tablecontent _tab
else file write tablecontent _n
}

if "`csoutcome'"=="DENOM" file write tablecontent _n 

}

file close tablecontent

**Additional descriptive on the resp/lrti outcome
stset CSexit_respiratorylrti, fail(CSfail_respiratorylrti) origin(entrydate) enter(entrydate)
*Deaths
safecount if _d==1 & CSfaildiedonly_respiratorylrti==1 & group==1
local denomdied = r(N)
safecount if _d==1 & CSfaildiedonly_respiratorylrti==1 & group==1 & (died_cause_ons=="U071"|died_cause_ons=="U072")
di "% covid = " 100*r(N)/`denomdied'
*Hospitalisations
safecount if _d==1 & CSfaildiedonly_respiratorylrti!=1 & group==1
local denomhosp = r(N)
safecount if _d==1 & CSfaildiedonly_respiratorylrti!=1 & group==1 & (admitted_respiratorylrti_reason=="U071"|admitted_respiratorylrti_reason=="U072")
di "% covid = " 100*r(N)/`denomhosp'
safecount if _d==1 & CSfaildiedonly_respiratorylrti!=1 & group==1 & (substr(admitted_respiratorylrti_reason,1,3)=="J18")
di "% pneumonia = " 100*r(N)/`denomhosp'






log close
