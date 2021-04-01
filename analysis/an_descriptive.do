cap log close
log using analysis/output/an_descriptive, replace t
use analysis/cr_append_process_data, clear

preserve
keep if group==1|group==4
bysort setid: gen groupsize = _N
tab groupsize if group==1
restore


histogram entrydate if (group==1|group==2|group==4), by(group, cols(1)) 
graph export analysis/output/an_descriptive_EVENTSBYTIME.svg, as(svg) replace

gen monthyrentry = year(entrydate) * 100 + month(entrydate)

safetab monthyrent group  if group==2 & entrydate<d(1/11/2019)

safetab readmission group, col

safetab readm_reason_b group, col

cap file close tablecontent
file open tablecontent using ./analysis/output/an_descriptive_OUTCOMES.txt, write text replace

gen byte cons=1

foreach outcome of any DENOM composite death{
if "`outcome'"=="death" include analysis/setfordeath.doi

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



foreach csoutcome of any DENOM otherinfections cancer_ex_nmsc endo_nutr_metabol mentalhealth nervoussystem circulatory respiratorylrti respiratory digestive musculoskeletal genitourinary external {

foreach group of numlist 1 2 4 {


if "`csoutcome'"=="DENOM" local condition 
else{
	stset CSexit_`csoutcome', fail(CSfail_`csoutcome') origin(entrydate) enter(entrydate) 
	local condition " & _d == 1"
	if `group'==1 file write tablecontent ("`csoutcome'") _tab 
}

cou if group==`group' `condition'
if "`csoutcome'"!="DENOM" file write tablecontent (r(N))
if "`csoutcome'"=="DENOM" local denominator`group' = r(N)
if "`csoutcome'"!="DENOM" file write tablecontent (" (") %3.1f (100*r(N)/`denominator`group'') (")")
if `group'<4 file write tablecontent _tab
else file write tablecontent _n
}

if "`csoutcome'"=="DENOM" file write tablecontent _n 

}

file close tablecontent

log close
