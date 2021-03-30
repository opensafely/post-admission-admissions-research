*use "C:\Program Files\Stata16\ado\base\_\__icd10.dta", clear

*clear
*insheet using "C:\Dropbox\WORK\MAIN\ADHOC\COVID19\tpp\hospital readmissions\icdclaml2019en.csv", c

use "C:\Dropbox\WORK\MAIN\ADHOC\COVID19\tpp\hospital readmissions/allWHOicd10codes", clear

preserve
keep if substr(icd10,1,1)=="I" 
replace icd10 = icd10 + "X" if length(icd10)==3
outsheet using "C:\Dropbox\WORK\MAIN\ADHOC\COVID19\tpp\hospital readmissions\cr_icd10_circulatory.csv", c nonames replace
outsheet using "C:\Github\post-admission-admissions-research\codelists/local-codelists\cr_icd10_circulatory.csv", c replace
restore


preserve
keep if substr(icd10,1,1)=="C" & substr(icd10,1,3)!="C44"
replace icd10 = icd10 + "X" if length(icd10)==3
outsheet using "C:\Dropbox\WORK\MAIN\ADHOC\COVID19\tpp\hospital readmissions\cr_icd10_cancer_ex_nmsc.csv", c nonames replace
outsheet using "C:\Github\post-admission-admissions-research\codelists/local-codelists\cr_icd10_cancer_ex_nmsc.csv", c replace
restore

preserve
keep if substr(icd10,1,1)=="J"
keep if real(substr(icd10,2,2))>=23
replace icd10 = icd10 + "X" if length(icd10)==3
outsheet using "C:\Dropbox\WORK\MAIN\ADHOC\COVID19\tpp\hospital readmissions\cr_icd10_respiratory.csv", c nonames replace
outsheet using "C:\Github\post-admission-admissions-research\codelists/local-codelists\cr_icd10_respiratory.csv", c replace
restore

preserve
keep if substr(icd10,1,1)=="J"
keep if real(substr(icd10,2,2))>=09 & real(substr(icd10,2,2))<=22
replace icd10 = icd10 + "X" if length(icd10)==3
outsheet using "C:\Dropbox\WORK\MAIN\ADHOC\COVID19\tpp\hospital readmissions\cr_icd10_respiratorylrti.csv", c nonames replace
outsheet using "C:\Github\post-admission-admissions-research\codelists/local-codelists\cr_icd10_respiratorylrti.csv", c replace
restore


preserve
keep if substr(icd10,1,1)=="K"
replace icd10 = icd10 + "X" if length(icd10)==3
outsheet using "C:\Dropbox\WORK\MAIN\ADHOC\COVID19\tpp\hospital readmissions\cr_icd10_digestive.csv", c nonames replace
outsheet using "C:\Github\post-admission-admissions-research\codelists/local-codelists\cr_icd10_digestive.csv", c replace

restore

preserve
keep if substr(icd10,1,1)=="F"|(substr(icd10,1,1)=="X" & (real(substr(icd10,2,2))>=60 & real(substr(icd10,2,2))<=84))
replace icd10 = icd10 + "X" if length(icd10)==3
outsheet using "C:\Dropbox\WORK\MAIN\ADHOC\COVID19\tpp\hospital readmissions\cr_icd10_mentalhealth.csv", c nonames replace
outsheet using "C:\Github\post-admission-admissions-research\codelists/local-codelists\cr_icd10_mentalhealth.csv", c replace
restore

preserve
keep if substr(icd10,1,1)=="G"
replace icd10 = icd10 + "X" if length(icd10)==3
outsheet using "C:\Dropbox\WORK\MAIN\ADHOC\COVID19\tpp\hospital readmissions\cr_icd10_nervoussystem.csv", c nonames replace
outsheet using "C:\Github\post-admission-admissions-research\codelists/local-codelists\cr_icd10_nervoussystem.csv", c replace
restore

preserve
keep if substr(icd10,1,1)=="N"
replace icd10 = icd10 + "X" if length(icd10)==3
outsheet using "C:\Dropbox\WORK\MAIN\ADHOC\COVID19\tpp\hospital readmissions\cr_icd10_genitourinary.csv", c nonames replace
outsheet using "C:\Github\post-admission-admissions-research\codelists/local-codelists\cr_icd10_genitourinary.csv", c replace
restore

preserve
keep if substr(icd10,1,1)=="E"
replace icd10 = icd10 + "X" if length(icd10)==3
outsheet using "C:\Dropbox\WORK\MAIN\ADHOC\COVID19\tpp\hospital readmissions\cr_icd10_endocrine_nutritional_metabolic.csv", c nonames replace
outsheet using "C:\Github\post-admission-admissions-research\codelists/local-codelists\cr_icd10_endocrine_nutritional_metabolic.csv", c replace
restore

preserve
keep if substr(icd10,1,1)=="S" ///
 |substr(icd10,1,1)=="T" ///
 |substr(icd10,1,1)=="V" ///
 |substr(icd10,1,1)=="W" ///
 |(substr(icd10,1,1)=="X" ///
  & !(real(substr(icd10,2,2))>=60 & real(substr(icd10,2,2))<=84))
replace icd10 = icd10 + "X" if length(icd10)==3
outsheet using "C:\Dropbox\WORK\MAIN\ADHOC\COVID19\tpp\hospital readmissions\cr_icd10_external.csv", c nonames replace
outsheet using "C:\Github\post-admission-admissions-research\codelists/local-codelists\cr_icd10_external.csv", c replace
restore

preserve
keep if substr(icd10,1,1)=="A"
replace icd10 = icd10 + "X" if length(icd10)==3
outsheet using "C:\Dropbox\WORK\MAIN\ADHOC\COVID19\tpp\hospital readmissions\cr_icd10_otherinfections.csv", c nonames replace
outsheet using "C:\Github\post-admission-admissions-research\codelists/local-codelists\cr_icd10_otherinfections.csv", c replace
restore

preserve
keep if substr(icd10,1,1)=="M"
replace icd10 = icd10 + "X" if length(icd10)==3
outsheet using "C:\Dropbox\WORK\MAIN\ADHOC\COVID19\tpp\hospital readmissions\cr_icd10_musculoskeletal.csv", c nonames replace
outsheet using "C:\Github\post-admission-admissions-research\codelists/local-codelists\cr_icd10_musculoskeletal.csv", c replace

restore

