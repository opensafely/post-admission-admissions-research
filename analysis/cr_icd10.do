*use "C:\Program Files\Stata16\ado\base\_\__icd10.dta", clear

*clear
*insheet using "C:\Dropbox\WORK\MAIN\ADHOC\COVID19\tpp\hospital readmissions\icdclaml2019en.csv", c

use "C:\Dropbox\WORK\MAIN\ADHOC\COVID19\tpp\hospital readmissions/allWHOicd10codes", clear

preserve
keep if substr(icd10,1,1)=="I" 
outsheet using "C:\Dropbox\WORK\MAIN\ADHOC\COVID19\tpp\hospital readmissions\cr_icd10_circulatory.csv", c nonames replace
restore

preserve
keep if substr(icd10,1,1)=="C" & substr(icd10,1,3)!="C44"
outsheet using "C:\Dropbox\WORK\MAIN\ADHOC\COVID19\tpp\hospital readmissions\cr_icd10_cancer_ex_nmsc.csv", c nonames replace
restore

preserve
keep if substr(icd10,1,1)=="J"
outsheet using "C:\Dropbox\WORK\MAIN\ADHOC\COVID19\tpp\hospital readmissions\cr_icd10_respiratory.csv", c nonames replace
restore

preserve
keep if substr(icd10,1,1)=="K"
outsheet using "C:\Dropbox\WORK\MAIN\ADHOC\COVID19\tpp\hospital readmissions\cr_icd10_digestive.csv", c nonames replace
restore

preserve
keep if substr(icd10,1,1)=="F"|(substr(icd10,1,1)=="X" & (real(substr(icd10,2,2))>=60 & real(substr(icd10,2,2))<=84))
outsheet using "C:\Dropbox\WORK\MAIN\ADHOC\COVID19\tpp\hospital readmissions\cr_icd10_mentalhealth.csv", c nonames replace
restore

preserve
keep if substr(icd10,1,1)=="G"
outsheet using "C:\Dropbox\WORK\MAIN\ADHOC\COVID19\tpp\hospital readmissions\cr_icd10_nervoussystem.csv", c nonames replace
restore

preserve
keep if substr(icd10,1,1)=="N"
outsheet using "C:\Dropbox\WORK\MAIN\ADHOC\COVID19\tpp\hospital readmissions\cr_icd10_genitourinary.csv", c nonames replace
restore

preserve
keep if substr(icd10,1,1)=="E"
outsheet using "C:\Dropbox\WORK\MAIN\ADHOC\COVID19\tpp\hospital readmissions\cr_icd10_endocrine_nutritional_metabolic.csv", c nonames replace
restore

preserve
keep if substr(icd10,1,1)=="S" ///
 |substr(icd10,1,1)=="T" ///
 |substr(icd10,1,1)=="V" ///
 |substr(icd10,1,1)=="W" ///
 |(substr(icd10,1,1)=="X" ///
  & !(real(substr(icd10,2,2))>=60 & real(substr(icd10,2,2))<=84))
outsheet using "C:\Dropbox\WORK\MAIN\ADHOC\COVID19\tpp\hospital readmissions\cr_icd10_external.csv", c nonames replace
restore

preserve
keep if substr(icd10,1,1)=="A"
outsheet using "C:\Dropbox\WORK\MAIN\ADHOC\COVID19\tpp\hospital readmissions\cr_icd10_otherinfections.csv", c nonames replace
restore

preserve
keep if substr(icd10,1,1)=="M"
outsheet using "C:\Dropbox\WORK\MAIN\ADHOC\COVID19\tpp\hospital readmissions\cr_icd10_musculoskeletal.csv", c nonames replace
restore

