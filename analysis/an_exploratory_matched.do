
use ./analysis/cr_getmatches, clear

tab ageg exposed, col
tab male exposed, col
tab region exposed, col
tab ethnicity exposed, col
tab obese4cat exposed, col
tab smoke_nomiss exposed, col

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
