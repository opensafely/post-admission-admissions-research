
*an_processout_SAresults

postutil clear
tempfile results
postfile results str12 analysis str20 outcome str10 comparator adjhr lci uci using `results'

foreach outcome of any composite death circulatory cancer_ex_nmsc respiratory respiratorylrti digestive mentalhealth nervoussystem genitourinary endo_nutr_metabol external musculoskeletal  otherinfections {
    
	foreach SA of any original FGmodel ADJNONPH ADJCAREHOME ADJCRITCARE U071 {
	
	foreach comparator of any flu gp2019 {
	
	*load the estimates
		
	*ORIGINAL 
	local outcomeupper = upper("`outcome'")
	if "`SA'"=="original"{
		if ("`outcome'"=="death"|"`outcome'"=="composite") cap estimates use analysis/output/models/an_cox_R2_`outcomeupper'vs`comparator'_COMORBS_LSTYLE_ETHIMD
		else cap estimates use analysis/output/models/an_cox_causespecific_R2`outcome'_c`comparator'_COMORBS_LSTYLE_ETHIMD, replace
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
	if _rc==0{
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
save analysis/output/an_processout_SAresults, replace 
log close




