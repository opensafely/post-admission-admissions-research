
*an_processout_SAresults

postutil clear
tempfile results
postfile results str12 analysis str20 outcome str10 comparator adjhr lci uci using `results'

foreach outcome of any composite death otherinfections cancer_ex_nmsc endo_nutr_metabol mentalhealth nervoussystem circulatory respiratorylrti respiratory digestive musculoskeletal genitourinary external {
    
	foreach SA of any original FGmodel ADJNONPH ADJCAREHOME ADJCRITCARE U071 {
	
	foreach comparator of any flu 2019gp {
	
	*load the estimates
		
	*ORIGINAL 
	local outcomeupper = upper("`outcome'")
	if "`SA'"=="original"{
		if ("`outcome'"=="death"|"`outcome'"=="composite") cap estimates use analysis/output/models/an_cox_R2_`outcomeupper'vs`comparator'_COMORBS_LSTYLE_ETHIMD
		else cap estimates use analysis/output/models/an_cox_causespecific_R2`outcome'_c`comparator'_COMORBS_LSTYLE_ETHIMD
	}
	
	*FG MODEL (only applies to c-s outcomes)
	else if "`SA'"=="FGmodel"{
		cap estimates use analysis/output/models/an_FG_causespecific_R2`outcome'_c`comparator'_COMORBS_LSTYLE_ETHIMD
	}
	
	*adjNONPH
	else if "`SA'"=="ADJNONPH"{
		if ("`outcome'"=="death"|"`outcome'"=="composite") cap estimates use analysis/output/models/an_sensanalyses_`outcome'vs`comparator'ADJNONPH 
		else cap estimates use analysis/output/models/an_SAcausespecific`outcome'_vs`comparator'ADJNONPH 
	}
	
	*adjCAREHOME
	*adjCRITCARE
	*u071
	else {
	    if ("`outcome'"=="death"|"`outcome'"=="composite") cap estimates use analysis/output/models/an_sensanalyses_`outcome'vs`comparator'`SA'
		else cap estimates use analysis/output/models/an_SAcausespecific`outcome'_vs`comparator'`SA'
		}
		
	*post the hr lci uci
	if _rc==0 & !("`comparator'"=="2019gp" & "`SA'"=="ADJCRITCARE") {
	    lincom exposed, eform
	    post results ("`SA'") ("`outcome'") ("`comparator'") (r(estimate)) (r(lb)) (r(ub))	
		}
			
	} /*comparator*/
	} /*SA*/
	
} /*outcome*/

postclose results

use `results', clear
cap log close
log using analysis/output/an_processout_SAresults, replace t
list 
outsheet using analysis/output/an_processout_SAresults.txt, replace c
*save analysis/output/an_processout_SAresults, replace 
log close

rename outcome outcomestr
gen outcome = 1 if outcomestr!=outcomestr[_n-1]
replace outcome = sum(outcome)

label define outcomelab ///
	1 "Composite hosp/death" ///
	2 "All-cause mortality" ///
	3 "Other infections (A)" ///
	4 "Cancers (C ex C44)" ///
	5 "Endocr, nutr, metabol (E)" ///
	6 "Mental health/cognitive (F/G30/X60-84)" ///
	7 "Nervous system (G ex G30)" ///
	8 "Circulatory (I)" ///
	9 "Covid/flu/LRTI (J09-22, U071-2)" ///
	10 "Other respiratory (J23-99)" ///
	11 "Digestive (K)" ///
	12 "Musculoskeletal (M)" ///
	13 "Genitourinary (N)" ///
	14 "External (S-Y ex U/X60-84)"
label values outcome outcomelab 

sort outcome comparator analysis
by outcome comparator: gen n=_n

gen xpos = 0.15
gen xpos2 = 0.1

gen analysislong = "Primary analysis"' if analysis=="original"
replace analysislong = "Confirmed COVID-19" if analysis=="U071"
replace analysislong = "Fine & Gray model" if analysis=="FGmodel"
replace analysislong = "Adj non-PH" if analysis=="ADJNONPH"
replace analysislong = "Adj critical care" if analysis=="ADJCRITCARE"
replace analysislong = "Adj care home" if analysis=="ADJCAREHOME""

scatter n adjhr || rcap lci uci n, hor || scatter n xpos, m(i) mlab(analysislong) mlabsize(vsmall) || if comparator=="flu", subtitle(,size(small)) by(outcome, legend(off)) xscale(log) xline(1,lp(dash)) xtitle("HR/sHR* & 95% CI") ylabel(none) ytitle("")
graph export analysis/output/an_processout_SAresults_VSFLU.svg, as(svg)

scatter n adjhr || rcap lci uci n, hor || scatter n xpos2, m(i) mlab(analysislong) mlabsize(vsmall) || if comparator=="2019gp", subtitle(,size(small)) by(outcome, legend(off)) xscale(log) xline(1,lp(dash)) xtitle("HR/sHR & 95% CI") ylabel(none) ytitle("") xlab (1 2 5 10)
graph export analysis/output/an_processout_SAresults_VS2019gp.svg, as(svg)












































