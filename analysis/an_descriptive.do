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

foreach outcome of numlist -1 0/14 {

foreach group of numlist 1 2 4 {

if `outcome'==-1 local condition 
else local condition " & readm_reason_b == `outcome'"
cou if group==`group' `condition'
file write tablecontent (r(N))
if `outcome'==-1 local denominator = r(N)
if `outcome'>=0 file write tablecontent (" (") %3.1f (100*r(N)/`denominator') (")")
if `group'<4 file write tablecontent _tab
else file write tablecontent _n
}

if `outcome'==-1|`outcome'==13 file write tablecontent _n
if `outcome'==0 file write tablecontent _n _n

}

file close tablecontent

log close
