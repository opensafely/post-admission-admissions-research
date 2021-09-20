

cap postutil clear
tempfile estimates
postfile estimates str6 ctrl str9 outcome str30 adjustment shr lci uci using `estimates', replace
foreach ctrl of any 2019gp flu {

foreach coxoutcome of any COMPOSITE DEATH {
estimates use analysis/output/models/an_cox_R2_`coxoutcome'vs`ctrl'_MINADJ
lincom exposed, eform
post estimates ("`ctrl'") ("`coxoutcome'") ("min") (r(estimate)) (r(lb)) (r(ub))
estimates use analysis/output/models/an_cox_R2_`coxoutcome'vs`ctrl'_COMORBS
lincom exposed, eform
post estimates ("`ctrl'") ("`coxoutcome'") ("comorbs") (r(estimate)) (r(lb)) (r(ub))
estimates use analysis/output/models/an_cox_R2_`coxoutcome'vs`ctrl'_COMORBS_LSTYLE
lincom exposed, eform
post estimates ("`ctrl'") ("`coxoutcome'") ("comorbs_lstyle") (r(estimate)) (r(lb)) (r(ub))
estimates use analysis/output/models/an_cox_R2_`coxoutcome'vs`ctrl'_COMORBS_LSTYLE_ETHIMD
lincom exposed, eform
post estimates ("`ctrl'") ("`coxoutcome'") ("comorbs_lstyle_ethimd") (r(estimate)) (r(lb)) (r(ub))
}
/*
foreach outcome of numlist 1/9 11/13{

estimates use analysis/output/models/an_crreg_outcome`outcome'_c`ctrl'_MATCHFACONLY
lincom exposed, eform
post estimates ("`ctrl'") ("`outcome'") ("matchfac") (r(estimate)) (r(lb)) (r(ub))

estimates use analysis/output/models/an_crreg_outcome`outcome'_c`ctrl'_FULLADJ
lincom exposed, eform
post estimates ("`ctrl'") ("`outcome'") ("full") (r(estimate)) (r(lb)) (r(ub))

}
*/
}

postclose estimates

use `estimates', clear

*COX GRAPHS OF NON-COMPETING OUTCOMES
preserve
	gen origorder=_n
	gsort outcome ctrl orig
	drop origorder
	gen counter=1
	replace counter = 2 if adjustment=="min"
	replace counter = 3 if adjustment=="min" & & ctrl=="flu" 
	replace counter = 4 if adjustment=="min" & outcome=="DEATH" & ctrl=="2019gp"
	gen cumcounter = sum(counter)
	summ cumcounter
	gen graphorder = r(max)+1-cumcounter
	gen hrandci = string(shr , "%5.2f") + " (" + string(lci , "%5.2f") + "-" + string(uci , "%5.2f") + ")"
	gen hrcipos = 30
	gen modelpos = 0.02

	gen adjlong = "Adj for age, sex, geography" if adjustment=="min" & ctrl=="flu"
	replace adjlong = "Adj for matching factors " if adjustment=="min" & ctrl=="2019gp"
	replace adjlong = " + comorbidities" if adjustment=="comorbs"
	replace adjlong = " + obesity/smoking*" if adjustment=="comorbs_lstyle"
	replace adjlong = " + IMD/ethnicity*" if adjustment=="comorbs_lstyle_ethimd"

	scatter graphorder shr, msize(small) mcol(black) || rcap lci uci graphorder, hor lw(thin) lc(black) ///
	|| scatter graphorder hrcipos, m(i) mlab(hrandci) mlabsize(vsmall) mlabcol(black) ///
	|| scatter graphorder modelpos, m(i) mlab(adjlong) mlabsize(vsmall) mlabcol(gs7)  ///
	||, xscale(log range(0.015 320)) xline(1, lp(dash)) xlab(0.5 1 2 5 10 20) xtitle(HR and 95% CI) ysize(8) ylab(, nogrid) ytitle("") yscale(off range(23)) legend(off) ///
	text(25 0.015 "a) Composite outcome of hospitalisation or death", size(vsmall) placement(e)) text(18 0.017 "vs flu controls", size(vsmall) placement(e)) text(24 0.017 "vs 2019 general population controls", size(vsmall) placement(e)) ///
	text(12 0.015 "b) All-cause mortality", size(vsmall) placement(e)) text(5 0.017 "vs flu controls", size(vsmall) placement(e)) text(11 0.017 "vs 2019 general population controls", size(vsmall) placement(e)) ///
	text(24 35 "HR and 95% CI", size(vsmall) placement(e)) 
	graph export analysis/output/an_processout_regressionmodels_FOREST_R2_COX.svg, as(svg) replace
restore
/*
preserve
	drop if outcome=="COMPOSITE"|outcome=="DEATH"

	gen outcomereal = real(outcome)
	*gsort outcomereal -ctrl -adjustment
	gen counter=1
	replace counter = 2 if adjustment=="matchfac"
	replace counter = 4 if adjustment=="matchfac" & ctrl=="2019gp" & outcomereal==1

	gen cumcounter = sum(counter)
	summ cumcounter
	gen graphorder = r(max)+1-cumcounter

	gen hrandci = string(shr , "%5.2f") + " (" + string(lci , "%5.2f") + "-" + string(uci , "%5.2f") + ")"
	gen hrcipos = 30
	gen modelpos = 0.02

	gen adjlong = "Adj for matching factors only" if adjustment=="matchfac"
	replace adjlong = "Fully adjusted" if adjustment=="full"

	gen outcometext = "Circulatory" if outcomereal==1 & adjustment=="matchfac"
	replace outcometext = "Cancers" if outcomereal==2 & adjustment=="matchfac"
	replace outcometext = "Respiratory" if outcomereal==3 & adjustment=="matchfac"
	replace outcometext = "Digestive" if outcomereal==4 & adjustment=="matchfac"
	replace outcometext = "Mental health" if outcomereal==5 & adjustment=="matchfac"
	replace outcometext = "Nervous system" if outcomereal==6 & adjustment=="matchfac"
	replace outcometext = "Genitourinary" if outcomereal==7 & adjustment=="matchfac"
	replace outcometext = "Endocrine, nutritional and metabolic" if outcomereal==8 & adjustment=="matchfac"
	replace outcometext = "External causes" if outcomereal==9 & adjustment=="matchfac" 
	replace outcometext = "Infections" if outcomereal==11 & adjustment=="matchfac" 
	replace outcometext = "Musculoskeletal" if outcomereal==12 & adjustment=="matchfac" 
	replace outcometext = "Other" if outcomereal==13 & adjustment=="matchfac" 

	scatter graphorder shr if adjustment=="matchfac", m(Oh) msize(small) mcol(black) || rcap lci uci graphorder if adjustment=="matchfac", hor lw(thin) lc(black) ///
	|| scatter graphorder shr if adjustment=="full", m(O) msize(small) mcol(black) || rcap lci uci graphorder if adjustment=="full", hor lw(thin) lc(black) ///
	|| scatter graphorder hrcipos, m(i) mlab(hrandci) mlabsize(vsmall) mlabcol(black) ///
	|| scatter graphorder modelpos, m(i) mlab(outcometext) mlabsize(vsmall) mlabcol(gs7)  ///
	||, xscale(log range(0.015 320)) xline(1, lp(dash)) xlab(0.5 1 2 5 10 20) ysize(10) ytitle("") yscale(off range(23)) legend(cols(1) order(1 3) label(1 "Adjusted for matching factors") label(3 "Fully adjusted")) xtitle(Subdistribution HR and 95% CI) ///
	text(75 0.015 "vs flu controls", size(small) placement(e)) ///
	text(37 0.015 "vs 2019 general population controls", size(small) placement(e)) ///
	text(75 35 "HR and 95% CI", size(vsmall) placement(e))
	graph export analysis/output/an_processout_regressionmodels_FOREST_FINEGRAY.svg, as(svg) replace
restore
*/
