
use ./analysis/cr_getmatches, clear

*drop set if first covid admission/discharge is same day
gen todrop = admitted1_date==discharged1_date & exposed==1
by setid: drop if todrop[1]==1
drop todrop

*drop set if entry/exit on same day (artefact of single day admissions looping in study def)
gen todrop = coviddischarge == readmission_date & exposed==1
by setid: drop if todrop[1]==1
drop todrop


gen monthentry = month(coviddischargedate) if exposed==1
by setid: replace monthentry = monthentry[1]

gen entrydate  = coviddischargedate if exposed==1
replace entrydate = mdy(monthentry,1,2020) if exposed==0
format %d entrydate
gen exitdate = readmission_date if exposed==1
replace exitdate = admitted_date if exposed==0
format %d exitdate
gen readmission = (exitdate<.)

summ discharged1_date, f d
scalar censordate = r(max)

replace exitdate = died_date_ons if died_date_ons<exitdate
replace exitdate = censordate if censordate<exitdate

replace readmission = 0 if exitdate<readmission_date & exposed==1
replace readmission = 0 if exitdate<admitted_date & exposed==0

replace readmission = 2 if readmission==1 & (readmission_reason!="U071"&readmission_reason!="U072") & exposed==1
replace readmission = 2 if readmission==1 & (admitted_reason!="U071"&admitted_reason!="U072")&exposed==0

replace readmission = 3 if readmission==0 & exitdate==died_date_ons

replace exitdate = exitdate+0.5 if exitdate==entrydate

stset exitdate, fail(readmission) enter(entrydate) origin(entrydate)

**CLASSIFY READMISSIONS
gen icd10_3 = substr(readmission_reason,1,3) if exposed==1 & (readmission==1|readmission==2)
replace icd10_3 = substr(admitted_reason,1,3) if exposed==0 & (readmission==1|readmission==2)
replace icd10_3 = substr(died_cause_ons,1,3) if readmission==3


gen codbroad = 1 if substr(icd10_3,1,1)=="I"
replace codbroad = 2 if substr(icd10_3,1,1)=="C"
replace codbroad = 3 if substr(icd10_3,1,1)=="J"
replace codbroad = 4 if substr(icd10_3,1,1)=="K"
replace codbroad = 5 if substr(icd10_3,1,1)=="F" ///
  |(substr(icd10_3,1,1)=="X" ///
  & (real(substr(icd10_3,2,2))>=60 & real(substr(icd10_3,2,2))<=84))
replace codbroad = 6 if substr(icd10_3,1,1)=="G"
replace codbroad = 7 if substr(icd10_3,1,1)=="N"
replace codbroad = 8 if substr(icd10_3,1,1)=="E"
replace codbroad = 9 if substr(icd10_3,1,1)=="S" ///
 |substr(icd10_3,1,1)=="T" ///
 |substr(icd10_3,1,1)=="V" ///
 |substr(icd10_3,1,1)=="W" ///
 |(substr(icd10_3,1,1)=="X" ///
  & !(real(substr(icd10_3,2,2))>=60 & real(substr(icd10_3,2,2))<=84))
replace codbroad = 10 if icd10_3=="U07" & (readmission_reason=="U071"|admitted_reason=="U071"|died_cause_ons=="U071"|readmission_reason=="U072"|admitted_reason=="U072"|died_cause_ons=="U072")
replace codbroad = 11 if substr(icd10_3,1,1)=="A"
replace codbroad = 12 if substr(icd10_3,1,1)=="M"
replace codbroad = 13 if codbroad==. & icd!=""

label define codbroadlab 1 "Circulatory" 2 "Cancers" ///
 3 "Respiratory" 4 "Digestive" 5 "Mental health" ///
 6 "Nervous system" 7 "Genitourinary" 8 "Endocrine, nutritional and metabolic" ///
 9 "External causes" 10 "COVID" 11 "Other infections" 12 "Musculoskeletal" 13 "Other", modify
 label values codbroad codbroadlab

/*record these labels in a dataset for use in other progs (e.g. labelling graphs)
preserve
bysort codbroad: keep if _n==1
keep codbroad
sort codbroad
decode codbroad, gen(codbroadlab)
keep codbroadlab
save "$datadir\cr_groupcausesofdeath_CODBROADLAB", replace
restore
*/
 
*Make a more detailed classification for circulatory, cancers and other key cods

gen codspecific = codbroad
label define codspecificlab 1 "Circulatory" 2 "Cancers" ///
 3 "Respiratory" 4 "Digestive" 5 "Mental health" ///
 6 "Nervous system" 7 "Genitourinary" 8 "Endocrine, nutritional and metabolic" ///
 9 "External causes" 10 "COVID" 11 "Infections" 12 "Musculoskeletal" 13 "Other", modify
 label values codspecific codspecificlab

cap prog drop icdgroup
prog define icdgroup
syntax, range(string) name(string)
noi di "`range'"
local keyletter = substr("`range'",1,1)
local startnum = real(substr("`range'",2,2))
local endnum = real(substr("`range'",6,2))
noi di "`keyletter'"
noi di "`name'"
noi di "`startnum'"
noi di "`endnum'"
replace codspecific = 100*codspecific + `startnum' if substr(icd10_3,1,1)=="`keyletter'" & real(substr(icd10_3,2,2))>=`startnum'&real(substr(icd10_3,2,2))<=`endnum'
sum codspecific if substr(icd10_3,1,1)=="`keyletter'" & real(substr(icd10_3,2,2))>=`startnum'&real(substr(icd10_3,2,2))<=`endnum'
local newnum = r(mean)
label define codspecificlab `newnum' "`name'", modify 
end

*Circulatory diseases
label define codspecificlab 1 "Other circulatory", modify
icdgroup, range(I11-I11) name("Hypertensive heart disease")
icdgroup, range(I20-I25) name("Ischaemic heart disease")
icdgroup, range(I26-I26) name("Pulmonary embolism")
icdgroup, range(I48-I48) name("Atrial fibrillation/flutter")
icdgroup, range(I50-I50) name("Heart failure")
icdgroup, range(I60-I69) name("Cerebrovascular disease")
icdgroup, range(I71-I71) name("Aortic aneurysm")
icdgroup, range(I73-I73) name("Other peripheral vascular disease")
icdgroup, range(I80-I80) name("Phlebitis/thrombophlebitis")

*Cancers
label define codspecificlab 2 "Other cancer", modify
icdgroup, range(C15-C15) name("Oesophageal cancer")
icdgroup, range(C16-C16) name("Stomach cancer")
icdgroup, range(C18-C21) name("Colorectal cancer")
icdgroup, range(C22-C22) name("Liver cancer")
icdgroup, range(C25-C25) name("Pancreatic cancer")
icdgroup, range(C34-C34) name("Lung cancer")
icdgroup, range(C43-C43) name("Malignant melanoma")
icdgroup, range(C45-C45) name("Mesothelioma")
icdgroup, range(C50-C50) name("Breast cancer")
icdgroup, range(C56-C56) name("Ovarian cancer")
icdgroup, range(C61-C61) name("Prostate cancer")
icdgroup, range(C64-C64) name("Kidney cancer")
icdgroup, range(C67-C67) name("Bladder cancer")
icdgroup, range(C71-C72) name("Brain/CNS cancer")
icdgroup, range(C80-C80) name("Cancer unspecified")
icdgroup, range(C81-C96) name("Haematological cancer")

icdgroup, range(F00-F01) name("Dementia and alzheimers")
icdgroup, range(F03-F03) name("Dementia and alzheimers")
icdgroup, range(G30-G30) name("Dementia and alzheimers")
replace codspecific = 503 if codspecific==500|codspecific==501|codspecific==630
icdgroup, range(X60-X84) name("Suicide/intentional self-harm")
icdgroup, range(J40-J47) name("Chronic lower respiratory disease")
icdgroup, range(J09-J18) name("Influenza and pneumonia")
icdgroup, range(K70-K77) name("Liver disease")

replace codspecific = 100*codspecific if codspecific<100
label define codspecificlab 100 "Other circulatory" 200 "Other cancers" ///
 300 "Other respiratory" 400 "Other digestive" 500 "Other mental health" ///
 600 "Nervous system" 700 "Genitourinary" 800 "Endocrine, nutritional and metabolic" ///
 900 "External causes" 1000 "COVID" 1100 "Other infections" 1200 "Musculoskeletal" 1300 "Other", modify

gen crcats = 0 if readmission == 0
replace crcats = 1 if readmission == 1
replace crcats = 10*codbroad if readmission == 2
replace crcats = 3 if readmission == 3
 
stset exitdate, fail(crcats==1) enter(entrydate) origin(entrydate)
stcompet cuminc=ci, compet1(10) compet2(20) compet3(30) compet4(40) compet5(50) compet6(60) compet7(70) compet8(80) compet9(90) compet10(110) compet11(120) compet12(130) compet13(3) by(exposed)

twoway line cuminc _t if exposed==0, c(stairstep) sort || line cuminc _t if exposed==1, c(stairstep) sort  ||, legend(label(1 "Controls") label(2 "Exposed")) || , by(crcats) 

stcox exposed, strata(setid)
stcox exposed i.ethnicity i.imd , strata(setid)
stcox exposed i.ethnicity i.imd i.obese4cat i.smoke_nomiss, strata(setid) 
stcox exposed i.ethnicity i.imd i.obese4cat i.smoke_nomiss htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression, strata(setid) 

foreach crcat of any 1 10 20 30 40 50 60 70 80 90 110 120 3 { 
noi di _dup(50) "*"
noi di "CRCAT `crcat'"
noi di _dup(50) "*"
stset exitdate, fail(crcats==`crcat') enter(entrydate) origin(entrydate)
stcox exposed, strata(setid)
stcox exposed i.ethnicity i.imd i.obese4cat i.smoke_nomiss htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression, strata(setid) 
}


sts graph ,  f ci by(exposed)

stcox exposed, strata(setid)

stcox exposed i.ethnicity i.imd , strata(setid)
stcox exposed i.ethnicity i.imd i.obese4cat i.smoke_nomiss, strata(setid) 
stcox exposed i.ethnicity i.imd i.obese4cat i.smoke_nomiss htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression, strata(setid) 

stcox i.exposed##i.diabcat i.ethnicity i.imd i.obese4cat i.smoke_nomiss htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression, strata(setid) 


*Type of readmission
stset exitdate, fail(readmission==1) enter(entrydate) origin(entrydate)
stcompet cuminc=ci, compet1(2) compet2(3) by(exposed)

twoway line cuminc _t if readmission==1, c(stairstep) sort || line cuminc _t if readmission==2, c(stairstep) sort  || line cuminc _t if readmission==3, c(stairstep) sort legend(label(1 "readmission - covid") label(2 "readmission non-covid") label(3 "death")) || , by(exposed) yscale(r(0 1))

gen readmission_detail = readmission
