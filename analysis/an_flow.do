*kb 22/3/21

* Open a log file
cap log close
log using ./analysis/output/an_flow, replace t

clear
noi di "importing csv"
import delimited ./output/input_covdischarged.csv

di "STARTING COUNT FROM IMPORT:"
cou

qui{

/*
* Age: Exclude those with implausible ages
assert age<.
noi di "DROPPING AGE<105:" 
drop if age>105

* Sex: Exclude categories other than M and F
assert inlist(sex, "M", "F", "I", "U")
noi di "DROPPING GENDER NOT M/F:" 
drop if inlist(sex, "I", "U")

/*  IMD  */
* Group into 5 groups
rename imd imd_o
egen imd = cut(imd_o), group(5) icodes
replace imd = imd + 1
replace imd = . if imd_o==-1
drop imd_o

* Reverse the order (so high is more deprived)
recode imd 5=1 4=2 3=3 2=4 1=5 .=.

label define imd 1 "1 least deprived" 2 "2" 3 "3" 4 "4" 5 "5 most deprived" 
label values imd imd 

noi di "DROPPING IF NO IMD" 
drop if imd>=.
*/


******************************
*  Convert strings to dates  *
******************************

capture confirm var died_date_1ocare
if _rc==0 local died_date_1ocare "died_date_1ocare"

* Process variables with exact dates (admissions, deaths)
foreach var of varlist 	admitted1_date					///
						discharged1_date				///
						admitted2_date					///
						discharged2_date				///
						admitted3_date					///
						discharged3_date				///
						admitted4_date					///
						discharged4_date				///
						admitted5_date					///
						discharged5_date				///
						died_date_ons					///
						`died_date_1ocare'				///
						patient_index_date				{
							confirm string variable `var'
							rename `var' _tmp
							gen `var' = date(_tmp, "YMD")
							drop _tmp
							format %d `var'
						}
						
* Process variables with nearest month dates only						
						
foreach var of varlist 	bmi_date_measured 				///
						creatinine_date					///
						bp_sys_date_measured			///
						hba1c_mmol_per_mol_date			///
						hba1c_percentage_date			///
						haem_cancer						///
						lung_cancer						///
						other_cancer					///
						temporary_immunodeficiency		///
						aplastic_anaemia				{
						    confirm string variable `var'
							replace `var' = `var' + "-15"
							rename `var' `var'_dstr
							replace `var'_dstr = " " if `var'_dstr == "-15"
							gen `var'_date = date(`var'_dstr, "YMD") 
							order `var'_date, after(`var'_dstr)
							drop `var'_dstr
							format `var'_date %td
						}

rename bmi_date_measured_date      	bmi_date_measured
rename bp_sys_date_measured_date   	bp_sys_date
rename creatinine_date_date 		creatinine_date
rename hba1c_percentage_date_date  	hba1c_percentage_date
rename hba1c_mmol_per_mol_date_date hba1c_mmol_per_mol_date

}

********* DEFAULT CENSORING IS MAX OUTCOME DATE MINUS 7 **********
summ died_date_ons
global deathcensor = r(max)-7


noi di _dup(30) "*"
noi di "COUNTS START HERE"
noi di _dup(30) "*"
cou

*tie together admissions that are within 1 week of previous discharge
gen finaldischargedate = discharged1_date
replace finaldischargedate = discharged2_date if admitted2_date<=(discharged1_date+7)
replace finaldischargedate = discharged3_date if admitted2_date<=(discharged1_date+7) & admitted3_date<=(discharged2_date+7)
replace finaldischargedate = discharged4_date if admitted2_date<=(discharged1_date+7) & admitted3_date<=(discharged2_date+7) & admitted4_date<=(discharged3_date+7)
format %d finaldischargedate
*drop if there is a single day admission in the chain of admissions, as cannot then get f-up:
drop if finaldischargedate==discharged4_date & discharged4_date == admitted4_date
*drop if we get to the 5th readmission with all short gaps
drop if admitted2_date<=(discharged1_date+7) & admitted3_date<=(discharged2_date+7) & admitted4_date<=(discharged3_date+7) & admitted5_date<=(discharged4_date+7)

gen entrydate = finaldischargedate+8
format %d entrydate

cou

local diedsource "ons"
*drop if died date on/before discharge date
cou if died_date_`diedsource'<entrydate /*total*/

cou if died_date_`diedsource'==finaldischargedate
cou if died_date_`diedsource'<finaldischargedate
cou if died_date_`diedsource'<=finaldischargedate /*died during hosp*/
cou
cou if died_date_`diedsource'>finaldischargedate & died_date_`diedsource'<entrydate /*died within 7d of discharge*/
drop if died_date_`diedsource'<entrydate
cou

/*  IMD  */
* Group into 5 groups
rename imd imd_o
egen imd = cut(imd_o), group(5) icodes
replace imd = imd + 1
replace imd = . if imd_o==-1
drop imd_o



cou if age>105|(sex!="M"&sex!="F")| imd==.

drop if age>105

assert inlist(sex, "M", "F", "I", "U")
noi di "DROPPING GENDER NOT M/F:" 
drop if inlist(sex, "I", "U")

drop if imd==.

cou

/*
*FURTHER EXCLUSIONS AND DATE PROCESSING:
*drop if initial admission/discharge are on the same day
drop if admitted1_date==discharged1_date
*/




*drop if later than 60d before latest sus data
summ discharged1_date, f d
scalar censordate = r(max) - 60
drop if entrydate>=censordate

cou

*Only keep if COVID/FLU was the primary reason for hospitalisation
keep if admitted1_reason=="U071"|admitted1_reason=="U072"
cou 


log close

