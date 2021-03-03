
*an_processout_crreg

*Set up output file
cap file close tablecontent
file open tablecontent using analysis/output/an_processout_crreg.txt, write text replace

tempfile estimates
postutil clear
postfile estimates str40 outcome str7 adjust hr lci uci using `estimates'

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
	file write tablecontent ("`outcomename'") _tab %4.2f (r(estimate)) (" (") %4.2f (r(lb)) ("-") %4.2f (r(ub)) (")") _tab
	post estimates ("`outcomename'") ("minadj") (r(estimate)) (r(lb)) (r(ub))
	estimates use analysis/output/models/an_crreg_outcome`outcome'_FULLADJ
	lincom exposed, hr
	file write tablecontent %5.2f (r(estimate))  (" (") %4.2f (r(lb)) ("-") %4.2f (r(ub)) (")") _n
	post estimates ("`outcomename'") ("fulladj") (r(estimate)) (r(lb)) (r(ub))
}

file close tablecontent
postclose estimates 

use `estimates', clear

gen N=_n
expand 2 if adjust=="fulladj", gen(expanded)
sort N expanded
for var hr lci uci: replace X = . if expanded==1
qui cou
gen graphn = _N-_n+1
gen names = 0.01

twoway scatter graphn hr if adjust=="minadj", m(circle_hollow) mc(black) || rcap uci lci graphn if adjust=="minadj", hor lc(black) ///
	|| scatter graphn hr if adjust=="fulladj", m(circle) mc(black) || rcap uci lci graphn if adjust=="fulladj", hor lc(black) ///
	|| scatter graphn names if adjust=="minadj", m(i) mlab(outcome) mlabsize(vsmall) ///
	||, xtitle(sHR and 95% CI) xscale(log) xlab(1 2 5 10 20 40) xline(1, lp(dash)) ysize(8) legend(order(1 3) label(1 "Adj match factors") label(3 "Fully adjusted")) ///
	ytitle("") ylab(none)  xline(2, lp(dot))

graph export analysis/output/an_processout_crreg_sHRplot.svg, as(svg) replace
