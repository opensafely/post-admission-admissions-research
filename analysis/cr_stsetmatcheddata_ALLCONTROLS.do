*KB 25/2/21

cap log close
log using analysis/output/cr_stsetmatcheddata_ALLCONTROLS, replace t

use ./analysis/cr_getmatches, clear
gen data2020=1

summ readmission_date, f d
scalar censordate2020 = r(max)-60
scalar censordate2019 = r(max)-60-365

**************************************
/*TEMP - this is now done in cr_getmatches*/
*drop set if first covid discharge is <censor date
gen todrop = (coviddischargedate>=censordate2020) & exposed==1
by setid: drop if todrop[1]==1
drop todrop
safetab ex
*************************************

append using ./analysis/cr_getmatches2019
replace data2020=0 if data2020==.

sort exposed patient_id data2020
by exposed patient_id: assert _N==2 if exposed==1
by exposed patient_id: drop if _n==2 & exposed==1

gen byte analysis2020 = exposed==1 | data2020==1
gen byte analysis2019 = exposed==1 | data2020==0

drop data2020

*PNEUMONIA
append using ./analysis/cr_pneum2019
gen analysispneum = exposed==1|(analysis2019!=1&analysis2020!=1)
replace exposed=0 if analysispneum==1 & exposed!=1

append using ./analysis/cr_flu2017_19
gen analysisflu = exposed==1|(analysis2019!=1&analysis2020!=1&analysispneum!=1)
replace exposed=0 if analysisflu==1 & exposed!=1
*only keep where flu primary reason for hospitalisation
drop if analysisflu==1 & exposed==0 & !(admitted1_reason=="J090"|admitted1_reason=="J100"|admitted1_reason=="J101"|admitted1_reason=="J108"|admitted1_reason=="J110"|admitted1_reason=="J111"|admitted1_reason=="J118")

*FLU PNEUM PROCESSING
foreach flupneum of any pneum flu{
	*Drop hosps before 2019
	drop if analysis`flupneum'==1 & exposed==0 & discharged1_date>d(31/12/2019)
	*tie together admissions that are within the same day of a previous discharge
	gen `flupneum'dischargedate = discharged1_date if  analysis`flupneum'==1 & exposed==0
	replace `flupneum'dischargedate = discharged2_date if discharged1_date==admitted2_date &  analysis`flupneum'==1 & exposed==0
	replace `flupneum'dischargedate = discharged3_date if discharged1_date==admitted2_date & discharged2_date==admitted3_date &  analysis`flupneum'==1 & exposed==0
	replace `flupneum'dischargedate = discharged4_date if discharged1_date==admitted2_date & discharged2_date==admitted3_date & discharged3_date==admitted4_date &  analysis`flupneum'==1 & exposed==0
	format %d `flupneum'dischargedate
	*drop if died date on/before discharge date
	cou if died_date_ons==`flupneum'dischargedate &  analysis`flupneum'==1 & exposed==0
	cou if died_date_ons<`flupneum'dischargedate &  analysis`flupneum'==1 & exposed==0
	drop if died_date_ons<=`flupneum'dischargedate &  analysis`flupneum'==1 & exposed==0
	*drop if disch date was after the censoring date
	drop if analysis`flupneum'==1 & exposed==0 & `flupneum'dischargedate>censordate2019
	*drop if admission/discharge is the same day
	drop if admitted1_date==discharged1_date & analysis`flupneum'==1 & exposed==0
	*get readmission date 
	replace readmission_date = admitted2_date if  analysis`flupneum'==1 & exposed==0
	replace readmission_reason = admitted2_reason if    analysis`flupneum'==1 & exposed==0
	replace readmission_date = admitted3_date if discharged1_date==admitted2_date &  analysis`flupneum'==1 & exposed==0
	replace readmission_reason = admitted3_reason if discharged1_date==admitted2_date &  analysis`flupneum'==1 & exposed==0
	replace readmission_date = admitted4_date if discharged1_date==admitted2_date & discharged2_date==admitted3_date &  analysis`flupneum'==1 & exposed==0
	replace readmission_reason = admitted4_reason if discharged1_date==admitted2_date & discharged2_date==admitted3_date &  analysis`flupneum'==1 & exposed==0
	replace readmission_date = admitted5_date if discharged1_date==admitted2_date & discharged2_date==admitted3_date & discharged3_date==admitted4_date &  analysis`flupneum'==1 & exposed==0
	replace readmission_reason = admitted5_reason if discharged1_date==admitted2_date & discharged2_date==admitted3_date & discharged3_date==admitted4_date &  analysis`flupneum'==1 & exposed==0
}

	
for num 2019 2020: replace analysisX=0 if (analysispneum==1|analysisflu==1) & exposed!=1
replace analysispneum=0 if analysisflu==1 & exposed!=1

gsort setid -exposed analysis2019

*drop set if first covid admission/discharge is same day
gen todrop = admitted1_date==discharged1_date & exposed==1
replace todrop = 1 if coviddischarge == readmission_date & exposed==1
cou if todrop==1 
by setid: drop if todrop[1]==1

drop todrop
foreach analysistype of any 2019 2020 pneum flu {
safetab ex if analysis`analysistype'==1
}

*****************
foreach analysistype of any 2019 2020 {
preserve
keep if analysis`analysistype'==1
by setid: gen N=_N if setid<.
tab N if exposed==1 
restore
}

gen monthentry = month(coviddischargedate) if exposed==1
by setid: replace monthentry = monthentry[1]

gen entrydate  = coviddischargedate if exposed==1
replace entrydate = mdy(monthentry,1,2020) if exposed==0 & analysis2020==1
replace entrydate = mdy(monthentry,1,2019) if exposed==0 & analysis2019==1
replace entrydate = pneumdischargedate if exposed==0 & analysispneum==1
replace entrydate = fludischargedate if exposed==0 & analysisflu==1
drop monthentry

format %d entrydate
format %d readmission_date

gen monthentry = month(entrydate)

qui summ entrydate if analysis2020==1
gen latestfupflu = fludischargedate + censordate2020 - r(min) if analysisflu==1 & exposed==0

assert readmission_date>=entrydate if readmission_date<.
assert admitted_date>=entrydate if admitted_date<.
gen exitdate = readmission_date if exposed==1 & readmission_date<=censordate2020
replace exitdate = readmission_date if exposed==0 & (analysispneum==1|analysisflu==1) & readmission_date<=censordate2019 & readmission_date<=latestfupflu
replace exitdate = admitted_date if exposed==0 & admitted_date<=censordate2020 & analysis2020==1
replace exitdate = admitted_date if exposed==0 & admitted_date<=censordate2019 & analysis2019==1
format %d exitdate
gen readmission = (exitdate<.)

replace exitdate = died_date_ons if died_date_ons<. & died_date_ons<exitdate & died_date_ons<=censordate2020 & (exposed==1|analysis2020==1)
replace exitdate = died_date_ons if died_date_ons<. & died_date_ons<exitdate & died_date_ons<=censordate2019 & exposed==0 & (analysis2019==1|analysispneum==1)
replace exitdate = died_date_1ocare if died_date_1ocare<. & died_date_1ocare<exitdate & died_date_1ocare<=censordate2019 & exposed==0 & analysisflu==1 & died_date_1ocare<=latestfupflu
 
assert died_date_ons<. if readmission ==0 & exitdate<. & !(analysisflu==1&exposed==0)
assert died_date_1ocare<. if readmission ==0 & exitdate<. & (analysisflu==1&exposed==0)
replace readmission = 3 if readmission ==0 & exitdate<.

replace exitdate = censordate2020 if exitdate==. & (exposed==1|analysis2020==1)
replace exitdate = censordate2019 if exitdate==. & exposed==0 & (analysis2019==1|analysispneum==1)
replace exitdate = min(censordate2019, latestfupflu) if exitdate==. & exposed==0 & (analysisflu==1)

replace readmission = 2 if readmission==1 & (readmission_reason!="U071"&readmission_reason!="U072") & exposed==1
replace readmission = 2 if readmission==1 & (readmission_reason!="U071"&readmission_reason!="U072") & exposed==0 & (analysispneum==1|analysisflu==1)
replace readmission = 2 if readmission==1 & (admitted_reason!="U071"&admitted_reason!="U072") & exposed==0 & (analysis2020==1|analysis2019==1)

replace exitdate = exitdate+0.5 if exitdate==entrydate

**CLASSIFY READMISSIONS
gen icd10_3 = substr(readmission_reason,1,3) if (exposed==1|analysispn==1|analysisflu==1) & (readmission==1|readmission==2)
replace icd10_3 = substr(admitted_reason,1,3) if (exposed==0 & (analysis2019==1|analysis2020==1)) & (readmission==1|readmission==2)
*replace icd10_3 = substr(died_cause_ons,1,3) if readmission==3


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
replace readm_died_reason_broad = 14 if readmission==3
replace readm_died_reason_broad = 0 if readmission==0

label define readm_died_reason_broadlab 0 "None" 1 "Circulatory" 2 "Cancers" ///
 3 "Respiratory" 4 "Digestive" 5 "Mental health" ///
 6 "Nervous system" 7 "Genitourinary" 8 "Endocrine, nutritional and metabolic" ///
 9 "External causes" 10 "COVID" 11 "Other infections" 12 "Musculoskeletal" 13 "Other" 14 "Any cause death", modify
 label values readm_died_reason_broad readm_died_reason_broadlab

gen readm_died_reason_specific = readm_died_reason_broad
label define readm_died_reason_specificlab 0 "None" 1 "Circulatory" 2 "Cancers" ///
 3 "Respiratory" 4 "Digestive" 5 "Mental health" ///
 6 "Nervous system" 7 "Genitourinary" 8 "Endocrine, nutritional and metabolic" ///
 9 "External causes" 10 "COVID" 11 "Infections" 12 "Musculoskeletal" 13 "Other" 14 "Any cause death", modify
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
if `newnum'!=. label define readm_died_reason_specificlab `newnum' "`name'", modify 
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
 900 "External causes" 1000 "COVID" 1100 "Other infections" 1200 "Musculoskeletal" 1300 "Other" 1400 "Any cause death", modify

label define exposedlab 0 "Control" 1 "Exposed (prior COVID hospitalisation)"
label values exposed exposedlab

gen exposed_allcontrols = exposed
replace exposed_allcontrols = 2 if exposed==0 & analysis2020==1
replace exposed_allcontrols = 3 if exposed==0 & analysis2019==1
replace exposed_allcontrols = 4 if exposed==0 & analysispneum==1
replace exposed_allcontrols = 5 if exposed==0 & analysisflu==1

label define exposed_allcontrolslab 1 "Exposed" 2 "2020 general pop" 3 "2019 general pop" 4 "2019 hospitalised pneumonia" 5 "2017_19 hospitalised flu"
label values exposed_allcontrols exposed_allcontrolslab

stset exitdate, fail(readmission) enter(entrydate) origin(entrydate)

save analysis/cr_stsetmatcheddata_ALLCONTROLS, replace

log close
