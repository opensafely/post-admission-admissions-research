

cap postutil clear
tempfile estimates
postfile estimates str6 ctrl str9 outcome str10 adjustment str12 deathhandling shr lci uci using `estimates', replace
foreach ctrl of any flu 2019gp{

foreach deathhandling of any csdeath alldeathcens {
foreach outcome of numlist 1/9 11/12{

estimates use analysis/output/models/an_cox_causespecific`outcome'_c`ctrl'_MATCHFACONLY_`deathhandling'
lincom exposed, eform
post estimates ("`ctrl'") ("`outcome'") ("matchfac") ("`deathhandling'") (r(estimate)) (r(lb)) (r(ub))

estimates use analysis/output/models/an_cox_causespecific`outcome'_c`ctrl'_FULLADJ_`deathhandling'
lincom exposed, eform
post estimates ("`ctrl'") ("`outcome'") ("full") ("`deathhandling'") (r(estimate)) (r(lb)) (r(ub))

}
}
}

postclose estimates

use `estimates', clear

foreach deathhandling of any csdeath alldeathcens{

*COX GRAPHS OF NON-COMPETING OUTCOMES
preserve
	keep if deathhandling=="`deathhandling'"

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
	text(75 35 "HR and 95% CI", size(vsmall) placement(e)) name(`deathhandling', replace)
*	graph export analysis/output/an_processout_coxcausespecific_FOREST_FINEGRAY.svg, as(svg) replace
restore

}