cap log close
log using analysis/output/an_cox_causespecific, replace t

local allgraphs

foreach deathhandling of any csdeath alldeathcens {

foreach csoutcome of any admitted_circulatory_date admitted_cancer_ex_nmsc_date admitted_respiratory_date admitted_digestive_date admitted_mentalhealth_date admitted_nervoussystem_date admitted_genitourinary_date admitted_endo_nutr_metabol_date admitted_external_date admitted_musculoskeletal_date  admitted_otherinfections_date   /*admitted_any_date*/ {


di _n _dup(50) "*" 
di "`csoutcome'"
	
use analysis/cr_append_process_data, clear
drop if group==3
if "`deathhandling'"=="csdeath" drop if group==2 & entrydate<d(1/1/2019)

if "`csoutcome'"=="admitted_circulatory_date" scalar thisreason = 1
if "`csoutcome'"=="admitted_cancer_ex_nmsc_date" scalar thisreason = 2 
if "`csoutcome'"=="admitted_respiratory_date" scalar thisreason = 3 
if "`csoutcome'"=="admitted_digestive_date" scalar thisreason = 4 
if "`csoutcome'"=="admitted_mentalhealth_date" scalar thisreason = 5 
if "`csoutcome'"=="admitted_nervoussystem_date" scalar thisreason = 6 
if "`csoutcome'"=="admitted_genitourinary_date" scalar thisreason = 7 
if "`csoutcome'"=="admitted_endo_nutr_metabol_date" scalar thisreason = 8  
if "`csoutcome'"=="admitted_external_date" scalar thisreason = 9 
if "`csoutcome'"=="admitted_musculoskeletal_date" scalar thisreason = 11 
if "`csoutcome'"=="admitted_otherinfections_date" scalar thisreason = 12 

local thisreason = thisreason

*classify cause of death
gen d_icd10_3 = substr(died_cause_ons,1,3) 

gen died_reason = 1 if substr(d_icd10_3,1,1)=="I"
replace died_reason = 2 if substr(d_icd10_3,1,1)=="C"
replace died_reason = 3 if substr(d_icd10_3,1,1)=="J"
replace died_reason = 4 if substr(d_icd10_3,1,1)=="K"
replace died_reason = 5 if substr(d_icd10_3,1,1)=="F" ///
  |(substr(d_icd10_3,1,1)=="X" ///
  & (real(substr(d_icd10_3,2,2))>=60 & real(substr(d_icd10_3,2,2))<=84))
replace died_reason = 6 if substr(d_icd10_3,1,1)=="G"
replace died_reason = 7 if substr(d_icd10_3,1,1)=="N"
replace died_reason = 8 if substr(d_icd10_3,1,1)=="E"
replace died_reason = 9 if substr(d_icd10_3,1,1)=="S" ///
 |substr(d_icd10_3,1,1)=="T" ///
 |substr(d_icd10_3,1,1)=="V" ///
 |substr(d_icd10_3,1,1)=="W" ///
 |(substr(d_icd10_3,1,1)=="X" ///
  & !(real(substr(d_icd10_3,2,2))>=60 & real(substr(d_icd10_3,2,2))<=84))
replace died_reason = 10 if d_icd10_3=="U07" & (readmission_reason=="U071"|admitted_any_reason=="U071"|died_cause_ons=="U071"|readmission_reason=="U072"|admitted_any_reason=="U072"|died_cause_ons=="U072")
replace died_reason = 11 if substr(d_icd10_3,1,1)=="A"
replace died_reason = 12 if substr(d_icd10_3,1,1)=="M"
replace died_reason = 13 if died_reason==. & d_icd!=""
*replace died_reason = 14 if readmission==3
replace died_reason = 0 if died_date_ons==.

label define died_reasonlab 0 "None" 1 "Circulatory" 2 "Cancers" ///
 3 "Respiratory" 4 "Digestive" 5 "Mental health" ///
 6 "Nervous system" 7 "Genitourinary" 8 "Endocrine, nutritional and metabolic" ///
 9 "External causes" 10 "COVID" 11 "Other infections" 12 "Musculoskeletal" 13 "Other" 14 "Any cause death", modify
label values died_reason died_reasonlab

*get exit dates for cause specific
summ readmission_date, f d
replace censordate = r(max)-60 if group ==1
replace censordate = r(max)-60-365 if group==3|group==4

if "`deathhandling'"=="csdeath" local diedvar "died_date_ons"
else if "`deathhandling'"=="alldeathcens" local diedvar "died_date_1ocare"

gen CSexit = `csoutcome'
replace CSexit = `diedvar' if `diedvar'<=CSexit
replace CSexit = censordate if censordate<CSexit
replace CSexit = CSexit+0.5 if CSexit==entrydate
format %d CSexit
if "`deathhandling'"=="csdeath" gen CSfail = (CSexit==`csoutcome')|(CSexit==died_date_ons & died_reason==thisreason)
else if "`deathhandling'"=="alldeathcens" gen CSfail = (CSexit==`csoutcome')

stset CSexit, fail(CSfail) origin(entrydate) enter(entrydate) 

sts graph , by(group) fail name(`deathhandling'_`thisreason', replace)

stcox exposed age male i.region_real if group==1|group==2
estimates save analysis/output/models/an_cox_causespecific`thisreason'_cflu_MATCHFACONLY_`deathhandling', replace
stcox exposed age male i.region_real i.ethnicity i.imd i.obese4cat i.smoke_nomiss htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression if group==1|group==2 
estimates save analysis/output/models/an_cox_causespecific`thisreason'_cflu_FULLADJ_`deathhandling', replace
stcox exposed if group==1|group==4, strata(setid)
estimates save analysis/output/models/an_cox_causespecific`thisreason'_c2019gp_MATCHFACONLY_`deathhandling', replace
stcox exposed i.ethnicity i.imd i.obese4cat i.smoke_nomiss htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression if group==1|group==4, strata(setid)
estimates save analysis/output/models/an_cox_causespecific`thisreason'_c2019gp_FULLADJ_`deathhandling', replace

local allgraphs "`allgraphs' `deathhandling'_`thisreason'"

}
}

graph combine `allgraphs'
graph export an_cox_causespecific_KMGRAPHS.svg, as(svg) replace

log close
