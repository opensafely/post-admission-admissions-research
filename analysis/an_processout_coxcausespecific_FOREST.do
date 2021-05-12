

cap postutil clear
tempfile estimates
postfile estimates str6 ctrl str20 outcome str30 adjustment str12 deathhandling shr lci uci using `estimates', replace

foreach ctrl of any flu 2019gp{
foreach outcome of any otherinfections cancer_ex_nmsc endo_nutr_metabol mentalhealth nervoussystem circulatory respiratorylrti respiratory digestive musculoskeletal genitourinary external {

estimates use analysis/output/models/an_cox_causespecific`outcome'_c`ctrl'_MATCHFACONLY
lincom exposed, eform
post estimates ("`ctrl'") ("`outcome'") ("matchfac") ("`deathhandling'") (r(estimate)) (r(lb)) (r(ub))

estimates use analysis/output/models/an_cox_causespecific`outcome'_c`ctrl'_COMORBS
lincom exposed, eform
post estimates ("`ctrl'") ("`outcome'") ("comorbs") ("`deathhandling'") (r(estimate)) (r(lb)) (r(ub))

estimates use analysis/output/models/an_cox_causespecific`outcome'_c`ctrl'_COMORBS_LSTYLE
lincom exposed, eform
post estimates ("`ctrl'") ("`outcome'") ("comorbs_lstyle") ("`deathhandling'") (r(estimate)) (r(lb)) (r(ub))

estimates use analysis/output/models/an_cox_causespecific`outcome'_c`ctrl'_COMORBS_LSTYLE_ETHIMD
lincom exposed, eform
post estimates ("`ctrl'") ("`outcome'") ("comorbs_lstyle_ethimd") ("`deathhandling'") (r(estimate)) (r(lb)) (r(ub))


}
}

postclose estimates

use `estimates', clear

keep if adj=="matchfac"|adj=="comorbs_lstyle_ethimd"

*COX GRAPHS OF NON-COMPETING OUTCOMES
gen counter=1
replace counter = 2 if adjustment=="matchfac"
replace counter = 4 if adjustment=="matchfac" & ctrl=="2019gp" & outcome=="otherinfections"

*replace counter = 4 if ctrl=="2019gp" & outcome=="otherinfections"

gen cumcounter = sum(counter)
summ cumcounter
gen graphorder = r(max)+1-cumcounter

gen hrandci = string(shr , "%5.2f") + " (" + string(lci , "%5.2f") + "-" + string(uci , "%5.2f") + ")"
gen hrcipos = 30
gen modelpos = 0.005

gen adjlong = "Adj for age, sex, geography" if adjustment=="matchfac" 
replace adjlong = "Fully adjusted" if adjustment=="full"
l
gen outcometext = "Other infections (A)" if outcome=="otherinfections" & adjustment=="matchfac" 
replace outcometext = "Cancers (C ex C44)" if outcome=="cancer_ex_nmsc" & adjustment=="matchfac"
replace outcometext = "Endocrine, nutritional and metabolic (E)" if outcome=="endo_nutr_metabol" & adjustment=="matchfac"
replace outcometext = "Mental health and cognitive (F/G30/X60-84)" if outcome=="mentalhealth" & adjustment=="matchfac"
replace outcometext = "Nervous system (G, ex G30)" if outcome=="nervoussystem" & adjustment=="matchfac"
replace outcometext = "Circulatory (I)" if outcome=="circulatory" & adjustment=="matchfac"
replace outcometext = "COVID/Flu/LRTI (J09-22, U071-072)" if outcome=="respiratorylrti" & adjustment=="matchfac" 
replace outcometext = "Other respiratory (J23-99)" if outcome=="respiratory" & adjustment=="matchfac"
replace outcometext = "Digestive (K)" if outcome=="digestive" & adjustment=="matchfac"
replace outcometext = "Musculoskeletal (M)" if outcome=="musculoskeletal" & adjustment=="matchfac" 
replace outcometext = "Genitourinary (N)" if outcome=="genitourinary" & adjustment=="matchfac"
replace outcometext = "External causes (S-Y except U/X60-84)" if outcome=="external" & adjustment=="matchfac" 


scatter graphorder shr if adjustment=="matchfac", m(Oh) msize(small) mcol(black) || rcap lci uci graphorder if adjustment=="matchfac", hor lw(thin) lc(black) ///
	|| scatter graphorder shr if adjustment=="comorbs_lstyle_ethimd", m(O) msize(small) mcol(black) || rcap lci uci graphorder if adjustment=="comorbs_lstyle_ethimd", hor lw(thin) lc(black) ///
	|| scatter graphorder hrcipos, m(i) mlab(hrandci) mlabsize(vsmall) mlabcol(black) ///
	|| scatter graphorder modelpos, m(i) mlab(outcometext) mlabsize(vsmall) mlabcol(gs7)  ///
	||, xscale(log range(0.004 320)) xline(1, lp(dash)) xlab(0.5 1 2 5 10 20) ysize(10) ytitle("") yscale(off range(75)) ylab(0 75, nogrid) ytick(none) legend(cols(1) order(1 3) label(1 "Adjusted for age, sex, geography") label(3 "Fully adjusted")) xtitle(HR and 95% CI) ///
	text(75 0.004 "vs flu controls", size(small) placement(e)) ///
	text(37 0.004 "vs 2019 general population controls", size(small) placement(e)) ///
	text(75 35 "HR and 95% CI", size(vsmall) placement(e)) 
	graph export analysis/output/an_processout_coxcausespecific_FOREST.svg, as(svg) replace


