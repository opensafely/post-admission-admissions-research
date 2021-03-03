*KB 25/2/21

cap log close
log using analysis/output/cr_stsetmatcheddata, replace t

use ./analysis/cr_getmatches, clear

summ readmission_date, f d
scalar censordate = r(max)-60

**************************************
/*TEMP - this is now done in cr_getmatches*/
*drop set if first covid discharge is <censor date
gen todrop = (coviddischargedate>=censordate) & exposed==1
by setid: drop if todrop[1]==1
drop todrop
safetab ex
*************************************


*drop set if first covid admission/discharge is same day
gen todrop = admitted1_date==discharged1_date & exposed==1
replace todrop = 1 if coviddischarge == readmission_date & exposed==1
cou if todrop==1 
by setid: drop if todrop[1]==1
drop todrop
safetab ex

*****************
by setid: gen N=_N
tab N if exposed==1

*****************
gen monthentry = month(coviddischargedate) if exposed==1
by setid: replace monthentry = monthentry[1]



gen entrydate  = coviddischargedate if exposed==1
replace entrydate = mdy(monthentry,1,2020) if exposed==0
format %d entrydate
assert readmission_date>=entrydate if readmission_date<.
assert admitted_date>=entrydate if admitted_date<.
gen exitdate = readmission_date if exposed==1 & readmission_date<=censordate
replace exitdate = admitted_date if exposed==0 & admitted_date<=censordate
format %d exitdate
gen readmission = (exitdate<.)

replace exitdate = died_date_ons if died_date_ons<. & died_date_ons<exitdate & died_date_ons<=censordate 
assert died_date_ons<. if readmission ==0 & exitdate<.
replace readmission = 3 if readmission ==0 & exitdate<.

replace exitdate = censordate if exitdate==.

replace readmission = 2 if readmission==1 & (readmission_reason!="U071"&readmission_reason!="U072") & exposed==1
replace readmission = 2 if readmission==1 & (admitted_reason!="U071"&admitted_reason!="U072")&exposed==0

replace exitdate = exitdate+0.5 if exitdate==entrydate

**CLASSIFY READMISSIONS
gen icd10_3 = substr(readmission_reason,1,3) if exposed==1 & (readmission==1|readmission==2)
replace icd10_3 = substr(admitted_reason,1,3) if exposed==0 & (readmission==1|readmission==2)
replace icd10_3 = substr(died_cause_ons,1,3) if readmission==3


gen readm_died_reason_broad = 1 if substr(icd10_3,1,1)=="I"
replace readm_died_reason_broad = 2 if substr(icd10_3,1,1)=="C"
replace readm_died_reason_broad = 3 if substr(icd10_3,1,1)=="J"
replace readm_died_reason_broad = 4 if substr(icd10_3,1,1)=="K"
replace readm_died_reason_broad = 5 if substr(icd10_3,1,1)=="F" ///
  |(substr(icd10_3,1,1)=="X" ///
  & (real(substr(icd10_3,2,2))>=60 & real(substr(icd10_3,2,2))<=84))
replace readm_died_reason_broad = 6 if substr(icd10_3,1,1)=="G"
replace readm_died_reason_broad = 7 if substr(icd10_3,1,1)=="N"
replace readm_died_reason_broad = 8 if substr(icd10_3,1,1)=="E"
replace readm_died_reason_broad = 9 if substr(icd10_3,1,1)=="S" ///
 |substr(icd10_3,1,1)=="T" ///
 |substr(icd10_3,1,1)=="V" ///
 |substr(icd10_3,1,1)=="W" ///
 |(substr(icd10_3,1,1)=="X" ///
  & !(real(substr(icd10_3,2,2))>=60 & real(substr(icd10_3,2,2))<=84))
replace readm_died_reason_broad = 10 if icd10_3=="U07" & (readmission_reason=="U071"|admitted_reason=="U071"|died_cause_ons=="U071"|readmission_reason=="U072"|admitted_reason=="U072"|died_cause_ons=="U072")
replace readm_died_reason_broad = 11 if substr(icd10_3,1,1)=="A"
replace readm_died_reason_broad = 12 if substr(icd10_3,1,1)=="M"
replace readm_died_reason_broad = 13 if readm_died_reason_broad==. & icd!=""

label define readm_died_reason_broadlab 1 "Circulatory" 2 "Cancers" ///
 3 "Respiratory" 4 "Digestive" 5 "Mental health" ///
 6 "Nervous system" 7 "Genitourinary" 8 "Endocrine, nutritional and metabolic" ///
 9 "External causes" 10 "COVID" 11 "Other infections" 12 "Musculoskeletal" 13 "Other", modify
 label values readm_died_reason_broad readm_died_reason_broadlab

gen readm_died_reason_specific = readm_died_reason_broad
label define readm_died_reason_specificlab 1 "Circulatory" 2 "Cancers" ///
 3 "Respiratory" 4 "Digestive" 5 "Mental health" ///
 6 "Nervous system" 7 "Genitourinary" 8 "Endocrine, nutritional and metabolic" ///
 9 "External causes" 10 "COVID" 11 "Infections" 12 "Musculoskeletal" 13 "Other", modify
 label values readm_died_reason_specific readm_died_reason_specificlab

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
replace readm_died_reason_specific = 100*readm_died_reason_specific + `startnum' if substr(icd10_3,1,1)=="`keyletter'" & real(substr(icd10_3,2,2))>=`startnum'&real(substr(icd10_3,2,2))<=`endnum'
sum readm_died_reason_specific if substr(icd10_3,1,1)=="`keyletter'" & real(substr(icd10_3,2,2))>=`startnum'&real(substr(icd10_3,2,2))<=`endnum'
local newnum = r(mean)
label define readm_died_reason_specificlab `newnum' "`name'", modify 
end

*Circulatory diseases
label define readm_died_reason_specificlab 1 "Other circulatory", modify
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
label define readm_died_reason_specificlab 2 "Other cancer", modify
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
replace readm_died_reason_specific = 503 if readm_died_reason_specific==500|readm_died_reason_specific==501|readm_died_reason_specific==630
icdgroup, range(X60-X84) name("Suicide/intentional self-harm")
icdgroup, range(J40-J47) name("Chronic lower respiratory disease")
icdgroup, range(J09-J18) name("Influenza and pneumonia")
icdgroup, range(K70-K77) name("Liver disease")

replace readm_died_reason_specific = 100*readm_died_reason_specific if readm_died_reason_specific<100
label define readm_died_reason_specificlab 100 "Other circulatory" 200 "Other cancers" ///
 300 "Other respiratory" 400 "Other digestive" 500 "Other mental health" ///
 600 "Nervous system" 700 "Genitourinary" 800 "Endocrine, nutritional and metabolic" ///
 900 "External causes" 1000 "COVID" 1100 "Other infections" 1200 "Musculoskeletal" 1300 "Other", modify

label define exposedlab 0 "Control" 1 "Exposed (prior COVID hospitalisation)"
label values exposed exposedlab

stset exitdate, fail(readmission) enter(entrydate) origin(entrydate)

save analysis/cr_stsetmatcheddata, replace

log close
