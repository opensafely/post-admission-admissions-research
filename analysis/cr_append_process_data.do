*KB 25/2/21

cap log close
log using analysis/output/cr_append_process_data, replace t

use ./analysis/cr_create_analysis_dataset_COVID, clear
gen group = 1
append using ./analysis/cr_create_analysis_dataset_FLU
replace group = 2 if group==.
append using ./analysis/cr_create_analysis_dataset_PNEUM
replace group = 3 if group==.
append using ./analysis/cr_getmatches2019
replace group = 4 if group==.

stset exitdate, fail(readmission) enter(entrydate) origin(entrydate)

replace setid=patient_id if group==1 

**CLASSIFY READMISSIONS
gen icd10_3 = substr(readmission_reason,1,3) if (group==1|group==2|group==3) & (readmission==1|readmission==2)
replace icd10_3 = substr(admitted_reason,1,3) if group==4 & (readmission==1|readmission==2)

gen readm_reason_broad = 1 if substr(icd10_3,1,1)=="I"
replace readm_reason_broad = 2 if substr(icd10_3,1,1)=="C"
replace readm_reason_broad = 3 if substr(icd10_3,1,1)=="J"
replace readm_reason_broad = 4 if substr(icd10_3,1,1)=="K"
replace readm_reason_broad = 5 if substr(icd10_3,1,1)=="F" ///
  |(substr(icd10_3,1,1)=="X" ///
  & (real(substr(icd10_3,2,2))>=60 & real(substr(icd10_3,2,2))<=84))
replace readm_reason_broad = 6 if substr(icd10_3,1,1)=="G"
replace readm_reason_broad = 7 if substr(icd10_3,1,1)=="N"
replace readm_reason_broad = 8 if substr(icd10_3,1,1)=="E"
replace readm_reason_broad = 9 if substr(icd10_3,1,1)=="S" ///
 |substr(icd10_3,1,1)=="T" ///
 |substr(icd10_3,1,1)=="V" ///
 |substr(icd10_3,1,1)=="W" ///
 |(substr(icd10_3,1,1)=="X" ///
  & !(real(substr(icd10_3,2,2))>=60 & real(substr(icd10_3,2,2))<=84))
replace readm_reason_broad = 10 if icd10_3=="U07" & (readmission_reason=="U071"|admitted_reason=="U071"|died_cause_ons=="U071"|readmission_reason=="U072"|admitted_reason=="U072"|died_cause_ons=="U072")
replace readm_reason_broad = 11 if substr(icd10_3,1,1)=="A"
replace readm_reason_broad = 12 if substr(icd10_3,1,1)=="M"
replace readm_reason_broad = 13 if readm_reason_broad==. & icd!=""
replace readm_reason_broad = 14 if readmission==3
replace readm_reason_broad = 0 if readmission==0

label define readm_reason_broadlab 0 "None" 1 "Circulatory" 2 "Cancers" ///
 3 "Respiratory" 4 "Digestive" 5 "Mental health" ///
 6 "Nervous system" 7 "Genitourinary" 8 "Endocrine, nutritional and metabolic" ///
 9 "External causes" 10 "COVID" 11 "Other infections" 12 "Musculoskeletal" 13 "Other" 14 "Any cause death", modify
 label values readm_reason_broad readm_reason_broadlab

gen readm_reason_specific = readm_reason_broad
label define readm_reason_specificlab 0 "None" 1 "Circulatory" 2 "Cancers" ///
 3 "Respiratory" 4 "Digestive" 5 "Mental health" ///
 6 "Nervous system" 7 "Genitourinary" 8 "Endocrine, nutritional and metabolic" ///
 9 "External causes" 10 "COVID" 11 "Infections" 12 "Musculoskeletal" 13 "Other" 14 "Any cause death", modify
 label values readm_reason_specific readm_reason_specificlab

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
replace readm_reason_specific = 100*readm_reason_specific + `startnum' if substr(icd10_3,1,1)=="`keyletter'" & real(substr(icd10_3,2,2))>=`startnum'&real(substr(icd10_3,2,2))<=`endnum'
sum readm_reason_specific if substr(icd10_3,1,1)=="`keyletter'" & real(substr(icd10_3,2,2))>=`startnum'&real(substr(icd10_3,2,2))<=`endnum'
local newnum = r(mean)
if `newnum'!=. label define readm_reason_specificlab `newnum' "`name'", modify 
end

*Circulatory diseases
label define readm_reason_specificlab 1 "Other circulatory", modify
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
label define readm_reason_specificlab 2 "Other cancer", modify
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
replace readm_reason_specific = 503 if readm_reason_specific==500|readm_reason_specific==501|readm_reason_specific==630
icdgroup, range(X60-X84) name("Suicide/intentional self-harm")
icdgroup, range(J40-J47) name("Chronic lower respiratory disease")
icdgroup, range(J09-J18) name("Influenza and pneumonia")
icdgroup, range(K70-K77) name("Liver disease")

replace readm_reason_specific = 100*readm_reason_specific if readm_reason_specific<100
label define readm_reason_specificlab 100 "Other circulatory" 200 "Other cancers" ///
 300 "Other respiratory" 400 "Other digestive" 500 "Other mental health" ///
 600 "Nervous system" 700 "Genitourinary" 800 "Endocrine, nutritional and metabolic" ///
 900 "External causes" 1000 "COVID" 1100 "Other infections" 1200 "Musculoskeletal" 1300 "Other" 1400 "Any cause death", modify

gen exposed=(group==1)
 
label define exposedlab 0 "Control" 1 "Exposed (prior COVID hospitalisation)"
label values exposed exposedlab

label define grouplab 1 "Hospitalised COVID-19" 2 "Hospitalised flu 2017_19" 3 "Hospitalised pneumonia 2019" 4 "General pop 2019" 
label values group grouplab

gen monthentry = month(entrydate)
encode region, gen(region_real)

stset exitdate, fail(readmission) enter(entrydate) origin(entrydate)

save analysis/cr_append_process_data, replace

log close
