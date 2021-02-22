


gen icd10_3 = substr(cause,1,3) if real(substr(cause,1,1))==. 
/*nb there appear to be virtually no valid ICD9 "E" codes in the underlying cod
..these should be E followed by 3 numbers (800 to 999) with no dp
..there is just a single record of E872, which I am ignoring as could 
..easily be an ICD10 missing the dp
..hence the assumption above that it's an ICD9 iff it starts with a number*/

cou
cou if strpos(icd10map, ",")>0

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
replace codbroad = 10 if substr(icd10_3,1,1)=="A"
replace codbroad = 11 if substr(icd10_3,1,1)=="M"
replace codbroad = 12 if codbroad==.

label define codbroadlab 1 "Circulatory" 2 "Cancers" ///
 3 "Respiratory" 4 "Digestive" 5 "Mental health" ///
 6 "Nervous system" 7 "Genitourinary" 8 "Endocrine, nutritional and metabolic" ///
 9 "External causes" 10 "Infections" 11 "Musculoskeletal" 12 "Other", modify
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
 9 "External causes" 10 "Infections" 11 "Musculoskeletal" 12 "Other", modify
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
 900 "External causes" 1000 "Infections" 1100 "Musculoskeletal" 1200 "Other", modify

/*record these labels in a dataset for use in other progs (e.g. labelling graphs)
preserve
bysort codspecific: keep if _n==1
keep codspecific
sort codspecific
decode codspecific, gen(codspecificlab)
label values codspecific
saveold "$datadir\cr_groupcausesofdeath_CODSPECIFICLAB", replace
restore

save "$datadir\cr_groupcausesofdeath",replace
*/