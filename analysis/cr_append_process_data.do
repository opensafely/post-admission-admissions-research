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

replace setid=patient_id if group==1 


**STSET FOR COMPOSITE OUTCOME OF SUS HOSP OR PRIMARY CARE DEATH
summ readmission_date, f d
replace censordate = r(max)-60 if group ==1
replace censordate = r(max)-60-365 if group==3|group==4

replace dereg_date="" if substr(dereg_date,1,4)=="9999"
replace dereg_date = dereg_date + "-30" if dereg_date!="" 
gen _dereg_date = date(dereg_date, "YMD") + 2
format %d _dereg
drop dereg
rename _dereg dereg_date

replace censordate = min(censordate, dereg_date)
drop exitdate readmission
gen exitdate = readmission_date if readmission_date<=censordate & group!=4
replace exitdate = admitted_any_date if admitted_any_date<=censordate & group==4

gen readmission = (exitdate<.)

replace exitdate = died_date_1ocare if died_date_1ocare <. & died_date_1ocare<=exitdate & died_date_1ocare<=censordate
format %d exitdate
assert died_date_1ocare<. if readmission ==0 & exitdate<. 
replace readmission = 3 if readmission ==0 & exitdate<.
replace exitdate = censordate if exitdate==. 

replace readmission = 2 if readmission==1 & (readmission_reason!="U071"&readmission_reason!="U072") 

replace exitdate = exitdate+0.5 if exitdate==entrydate
stset exitdate, fail(readmission) enter(entrydate) origin(entrydate)



**CLASSIFY READMISSIONS
gen icd10_3 = substr(readmission_reason,1,3) if (group==1|group==2|group==3) & (readmission==1|readmission==2)
replace icd10_3 = substr(admitted_any_reason,1,3) if group==4 & (readmission==1|readmission==2)


gen readm_reason_broad = 1 if substr(icd10_3,1,1)=="A"
replace readm_reason_broad = 2 if substr(icd10_3,1,1)=="C"
replace readm_reason_broad = 3 if substr(icd10_3,1,1)=="E"
replace readm_reason_broad = 4 if substr(icd10_3,1,1)=="F" ///
  |(substr(icd10_3,1,1)=="X" ///
  & (real(substr(icd10_3,2,2))>=60 & real(substr(icd10_3,2,2))<=84))
replace readm_reason_broad = 5 if substr(icd10_3,1,1)=="G"
replace readm_reason_broad = 6 if substr(icd10_3,1,1)=="I"
replace readm_reason_broad = 7 if (substr(icd10_3,1,1)=="J" & real(substr(icd10_3,2,2))>=09 & real(substr(icd10_3,2,2))<=22)|(icd10_3=="U071"|icd10_3=="U072")
replace readm_reason_broad = 8 if substr(icd10_3,1,1)=="J" & real(substr(icd10_3,2,2))>=23
replace readm_reason_broad = 9 if substr(icd10_3,1,1)=="K"
replace readm_reason_broad = 10 if substr(icd10_3,1,1)=="M"
replace readm_reason_broad = 11 if substr(icd10_3,1,1)=="N"
replace readm_reason_broad = 12 if substr(icd10_3,1,1)=="S" ///
 |substr(icd10_3,1,1)=="T" ///
 |substr(icd10_3,1,1)=="V" ///
 |substr(icd10_3,1,1)=="W" ///
 |(substr(icd10_3,1,1)=="X" ///
  & !(real(substr(icd10_3,2,2))>=60 & real(substr(icd10_3,2,2))<=84))
replace readm_reason_broad = 13 if readm_reason_broad==. & icd!=""
replace readm_reason_broad = 14 if readmission==3
replace readm_reason_broad = 0 if readmission==0

label define readm_reason_broadlab ///
0 "None" 	///
1 "Other infections (A)" ///
2 "Cancers (C)" ///
3 "Endocrine, nutritional and metabolic (E)" ///
4 "Mental and behavioural (F, X60-84)" ///
5 "Nervous system (G)" ///
6 "Circulatory (I)" ///
7 "COVID/Influenza/Pneumonia/LRTI (J09-22, U07.1/2)" ///
71 "COVID-19 (U07.1/2)" ///
8 "Respiratory (J23-99)" ///
9 "Digestive (K)" ///
10 "Musculoskeletal (M)" /// 
11 "Genitourinary (N)" ///
12 "External causes (S-Y exc X60-84)" ///
13 "Other" ///
14 "Any cause death", modify
 label values readm_reason_broad readm_reason_broadlab

gen readm_reason_specific = readm_reason_broad
/*label define readm_reason_specificlab 0 "None" 1 "Circulatory" 2 "Cancers" ///
 3 "Respiratory" 4 "Digestive" 5 "Mental health" ///
 6 "Nervous system" 7 "Genitourinary" 8 "Endocrine, nutritional and metabolic" ///
 9 "External causes" 10 "COVID" 11 "Infections" 12 "Musculoskeletal" 13 "Other" 14 "Any cause death", modify
 label values readm_reason_specific readm_reason_specificlab
*/
label copy readm_reason_broadlab readm_reason_specificlab
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
 300 "Endocrine, nutritional and metabolic" 400 "Other mental and behavioural" 500 "Other nervous system" ///
 600 "Other circulatory" 700 "Other LRTI" 800 "Other respiratory" ///
 900 "Other digestive" 1000 "Musculoskeletal" 1100 "Genitourinary" 1200 "External causes" 1300 "Other" 1400 "Any cause death", modify

gen exposed=(group==1)
 
label define exposedlab 0 "Control" 1 "Exposed (prior COVID hospitalisation)"
label values exposed exposedlab

label define grouplab 1 "Hospitalised COVID-19" 2 "Hospitalised flu 2017_19" 3 "Hospitalised pneumonia 2019" 4 "General pop 2019" 
label values group grouplab

gen monthentry = month(entrydate)
encode region, gen(region_real)

stset exitdate, fail(readmission) enter(entrydate) origin(entrydate)

*****PREP FOR CAUSE SPECIFIC ANALYSIS
*include covid with flu/pneum/lrti
replace admitted_respiratorylrti_date = min(admitted_respiratorylrti_date, admitted_covid_date)

*classify cause of death
gen d_icd10_3 = substr(died_cause_ons,1,3) 

gen died_reason = 1 if substr(d_icd10_3,1,1)=="A"
replace died_reason = 2 if substr(d_icd10_3,1,1)=="C"
replace died_reason = 3 if substr(d_icd10_3,1,1)=="E"
replace died_reason = 4 if substr(d_icd10_3,1,1)=="F" ///
  |(substr(d_icd10_3,1,1)=="X" ///
  & (real(substr(d_icd10_3,2,2))>=60 & real(substr(d_icd10_3,2,2))<=84))
replace died_reason = 5 if substr(d_icd10_3,1,1)=="G"
replace died_reason = 6 if substr(d_icd10_3,1,1)=="I"
replace died_reason = 7 if (substr(d_icd10_3,1,1)=="J" & real(substr(d_icd10_3,2,2))>=09 & real(substr(d_icd10_3,2,2))<=22)|(d_icd10_3=="U071"|d_icd10_3=="U072")
replace died_reason = 8 if substr(d_icd10_3,1,1)=="J" & real(substr(d_icd10_3,2,2))>=23
replace died_reason = 9 if substr(d_icd10_3,1,1)=="K"
replace died_reason = 10 if substr(d_icd10_3,1,1)=="M"
replace died_reason = 11 if substr(d_icd10_3,1,1)=="N"
replace died_reason = 12 if substr(d_icd10_3,1,1)=="S" ///
 |substr(d_icd10_3,1,1)=="T" ///
 |substr(d_icd10_3,1,1)=="V" ///
 |substr(d_icd10_3,1,1)=="W" ///
 |(substr(d_icd10_3,1,1)=="X" ///
  & !(real(substr(d_icd10_3,2,2))>=60 & real(substr(d_icd10_3,2,2))<=84))
replace died_reason = 13 if died_reason==. & d_icd!=""

label copy readm_reason_broadlab died_reasonlab
label values died_reason died_reasonlab


foreach csoutcome of any circulatory cancer_ex_nmsc respiratory respiratorylrti digestive mentalhealth nervoussystem genitourinary endo_nutr_metabol external musculoskeletal  otherinfections {

	
	if "`csoutcome'"=="otherinfections" scalar thisreason = 1
	if "`csoutcome'"=="cancer_ex_nmsc" scalar thisreason = 2 
	if "`csoutcome'"=="endo_nutr_metabol" scalar thisreason = 3 
	if "`csoutcome'"=="mentalhealth" scalar thisreason = 4 
	if "`csoutcome'"=="nervoussystem" scalar thisreason = 5 
	if "`csoutcome'"=="circulatory" scalar thisreason = 6 
	if "`csoutcome'"=="respiratorylrti" scalar thisreason = 7 
	if "`csoutcome'"=="respiratory" scalar thisreason = 8  
	if "`csoutcome'"=="digestive" scalar thisreason = 9 
	if "`csoutcome'"=="musculoskeletal" scalar thisreason = 10 
	if "`csoutcome'"=="genitourinary" scalar thisreason = 11 
	if "`csoutcome'"=="external" scalar thisreason = 12

local thisreason = thisreason

*get exit dates for cause specific
gen CSexit_`csoutcome' = admitted_`csoutcome'_date
replace CSexit_`csoutcome' = died_date_ons if died_date_ons<=CSexit_`csoutcome'
replace CSexit_`csoutcome' = censordate if censordate<CSexit_`csoutcome'
format %d CSexit_`csoutcome'
gen CSfail_`csoutcome' = (CSexit_`csoutcome'==admitted_`csoutcome'_date)|(CSexit_`csoutcome'==died_date_ons & died_reason==thisreason)
replace CSexit_`csoutcome' = CSexit_`csoutcome'+0.5 if CSexit_`csoutcome'==entrydate
}

save analysis/cr_append_process_data, replace

log close
