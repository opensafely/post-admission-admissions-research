********************************************************************************
*
*
*	Project:		Post COVID-admission admissions
*
*	Programmed by:	Krishnan
*
********************************************************************************
*
*	Purpose:		This do-file creates the variables required for matching
*  
********************************************************************************

local poolnumber `1'

* Open a log file
cap log close
log using ./analysis/output/cr_create_pool_basicdata_`poolnumber', replace t

clear
noi di "import delimited ./output/input_pool`poolnumber'.csv"
import delimited ./output/input_pool`poolnumber'.csv

di "STARTING COUNT FROM IMPORT:"
cou

*keep only variables that may be needed for matching
keep patient_id age sex stp region admitted_date discharged_date died_date_ons

* Age: Exclude those with implausible ages
assert age<.
noi di "DROPPING AGE<105:" 
drop if age>105

* Sex: Exclude categories other than M and F
assert inlist(sex, "M", "F", "I", "U")
noi di "DROPPING GENDER NOT M/F:" 
drop if inlist(sex, "I", "U")


******************************
*  Convert strings to dates  *
******************************

* Process variables with exact dates (admissions, deaths)
foreach var of varlist 	admitted_date					///
						discharged_date				///
						died_date_ons 					{
							confirm string variable `var'
							rename `var' _tmp
							gen `var' = date(_tmp, "YMD")
							drop _tmp
							format %d `var'
						}
					
**********************
*  Recode variables  *
**********************

* Sex
assert inlist(sex, "M", "F")
gen male = (sex=="M")
drop sex
			
* STP 
rename stp stp_old
bysort stp_old: gen stp = 1 if _n==1
replace stp = sum(stp)
drop stp_old



order patient_id region stp age male

***************
*  Save data  *
***************

sort patient_id

save ./analysis/cr_create_pool_basicdata_`poolnumber', replace

log close

