
*an_desctable
*KB 9/7/2020


*******************************************************************************
*Generic code to output one row of table
cap prog drop generaterow
program define generaterow
syntax, variable(varname) condition(string) 
	
	*put the varname and condition to left so that alignment can be checked vs shell
	file write tablecontent ("`variable'") _tab ("`condition'") _tab
	
	foreach exposed of numlist 0 1{
	
	safecount if exposed==`exposed'
	local denom_exposed_`exposed'=r(N)
		
	safecount if `variable' `condition' & exposed==`exposed'
	local cellcount = r(N)
	local colpct = 100*(r(N)/`denom_exposed_`exposed'')
	file write tablecontent (`cellcount')  (" (") %3.1f (`colpct') (")") 
	if `exposed'==0 file write tablecontent _tab
		else file write tablecontent _n
	}
	
end

*******************************************************************************
*Generic code to output one section (varible) within table (calls above)
cap prog drop tabulatevariable
prog define tabulatevariable
syntax, variable(varname) start(real) end(real) [missing] 

	foreach varlevel of numlist `start'/`end'{ 
		generaterow, variable(`variable') condition("==`varlevel'") 
	}
	if "`missing'"!="" generaterow, variable(`variable') condition(">=.") 

end

*******************************************************************************


*Set up output file
cap file close tablecontent
file open tablecontent using ./analysis/output/an_desctable.txt, write text replace

use ./analysis/cr_getmatches,clear

gen byte cons=1
tabulatevariable, variable(cons) start(1) end(1) 
file write tablecontent _n 

tabulatevariable, variable(agegroup) start(1) end(6)  
qui summ age if exposed==0, d
file write tablecontent ("age") _tab ("median-iqr") _tab %3.0f (r(p50))  (" (")  (r(p25)) ("-") (r(p75)) (")")  _tab
qui summ age if exposed==1, d
file write tablecontent _tab %3.0f  (r(p50))  (" (") (r(p25)) ("-") (r(p75)) (")")  _n

file write tablecontent _n 
tabulatevariable, variable(male) start(1) end(0) 
file write tablecontent _n 

tabulatevariable, variable(obese4cat) start(1) end(4) 
file write tablecontent _n 

tabulatevariable, variable(smoke_nomiss) start(1) end(3) 
file write tablecontent _n 

tabulatevariable, variable(ethnicity) start(1) end(5) missing 
file write tablecontent _n 

tabulatevariable, variable(imd) start(1) end(5) 
file write tablecontent _n 
file write tablecontent _n 

**COMORBIDITIES
*HYPERTENSION
tabulatevariable, variable(hypertension) start(1) end(1) 			
*RESPIRATORY
tabulatevariable, variable(chronic_respiratory_disease) start(1) end(1) 
*ASTHMA
tabulatevariable, variable(asthmacat) start(2) end(3)  /*no ocs, then with ocs*/
*CARDIAC
tabulatevariable, variable(chronic_cardiac_disease) start(1) end(1) 
*DIABETES
tabulatevariable, variable(diabcat) start(2) end(4)  /*controlled, then uncontrolled, then missing a1c*/
file write tablecontent _n
*CANCER EX HAEM
tabulatevariable, variable(cancer_exhaem_cat) start(2) end(4)  /*<1, 1-4.9, 5+ years ago*/
file write tablecontent _n
*CANCER HAEM
tabulatevariable, variable(cancer_haem_cat) start(2) end(4)  /*<1, 1-4.9, 5+ years ago*/
file write tablecontent _n
*REDUCED KIDNEY FUNCTION
tabulatevariable, variable(reduced_kidney_function_cat) start(2) end(3) 
*DIALYSIS
*tabulatevariable, variable(dialysis) start(1) end(1) 
*LIVER
tabulatevariable, variable(chronic_liver_disease) start(1) end(1) 
*STROKE
tabulatevariable, variable(stroke) start(1) end(1) 
*DEMENTIA
tabulatevariable, variable(dementia) start(1) end(1) 
*OTHER NEURO
tabulatevariable, variable(other_neuro) start(1) end(1) 
*ORGAN TRANSPLANT
tabulatevariable, variable(organ_transplant) start(1) end(1) 
*SPLEEN
tabulatevariable, variable(spleen) start(1) end(1) 
*RA_SLE_PSORIASIS
tabulatevariable, variable(ra_sle_psoriasis) start(1) end(1) 
*OTHER IMMUNOSUPPRESSION
tabulatevariable, variable(other_immunosuppression) start(1) end(1) 

cou if bmicat==. & exposed==0
file write tablecontent _n _n ("*missing BMI included in 'not obese' (unexposed group: ") (r(N)) 
cou if bmicat==. & exposed==1
file write tablecontent (", exposed group: ") (r(N)) (";") 
cou if bmicat==. & exposed==0
file write tablecontent ("missing smoking included in 'never smoker' (unexposed group: ") (r(N)) 
cou if bmicat==. & exposed==1
file write tablecontent (", exposed group: ") (r(N)) (")")
			
file close tablecontent


