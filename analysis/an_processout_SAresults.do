
*an_processout_SAresults

postutil clear
tempfile results
postfile results str12 analysis str20 outcome str10 comparator adjhr lci uci using `results'

foreach outcome of any composite death circulatory cancer_ex_nmsc respiratory respiratorylrti digestive mentalhealth nervoussystem genitourinary endo_nutr_metabol external musculoskeletal  otherinfections {
    
	foreach SA of any original FGmodel ADJNONPH ADJCAREHOME ADJCRITCARE U071 {
	
	foreach comparator of any flu gp2019 {
	
	*load the estimates
	*post the hr lci uci
	
	*ORIGINAL 
	
	
	*FG MODEL (only applies to c-s outcomes)
	an_FG_causespecific_R2circulatory_cflu_COMORBS_LSTYLE_ETHIMD
	
	*adjNONPH
	an_sensanalyses_deathvsfluADJNONPH (not for deaths vs gp )
	an_SAcausespecificcirculatory_vsfluADJNONPH (selected c-s only)
	
	*adjCAREHOME
	an_sensanalyses_deathvsfluADJCRITCARE (composite death)
	an_SAcausespecificcirculatory_vsfluADJCAREHOME
	
	*adjCRITCARE
	an_sensanalyses_deathvsfluADJCAREHOME (composite death) ; vs flu only
	an_SAcausespecificcirculatory_vsfluADJCRITCARE ; vs flu only

	*u071
	an_sensanalyses... (composite death)
	an_SAcausespecificcirculatory_vsfluU071

	
	} /*comparator*/
	} /*SA*/
	
} /*outcome*/



