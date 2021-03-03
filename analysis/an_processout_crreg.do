
*an_processout_crreg

*Set up output file
cap file close tablecontent
file open tablecontent using analysis/output/an_processout_crreg.txt, write text replace

foreach outcome of numlist 10 1 2 3 4 5 6 7 8 9 11 12 13 {
    if `outcome'==1 local outcomename "Circulatory"
    if `outcome'==2 local outcomename "Cancers"
	if `outcome'==3 local outcomename "Respiratory"
	if `outcome'==4 local outcomename "Digestive"
	if `outcome'==5 local outcomename "Mental health"
	if `outcome'==6 local outcomename "Nervous system"
	if `outcome'==7 local outcomename "Genitourinary"
	if `outcome'==8 local outcomename "Endocrine, nutritional and metabolic"
	if `outcome'==9 local outcomename "External causes"
	if `outcome'==10 local outcomename "COVID-19"
	if `outcome'==11 local outcomename "Other infections"
	if `outcome'==12 local outcomename "Musculoskeletal"
	if `outcome'==13 local outcomename "Other"
	
	estimates use analysis/output/models/an_crreg_outcome`outcome'_MATCHFACONLY
	lincom exposed, hr
	file write tablecontent ("`outcomename'") _tab %5.2f (r(estimate)) _tab ("(") %5.2f (r(lb)) ("-") %5.2f (r(ub)) (")") _tab
	estimates use analysis/output/models/an_crreg_outcome`outcome'_FULLADJ
	lincom exposed, hr
	file write tablecontent %5.2f (r(estimate)) _tab ("(") %5.2f (r(lb)) ("-") %5.2f (r(ub)) (")") _n
}

file close tablecontent