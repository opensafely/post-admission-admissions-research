
use ./analysis/cr_getmatches, clear

tab ageg exposed, col
tab male exposed, col
tab region exposed, col
tab ethnicity exposed, col
tab obese4cat exposed, col
tab smoke_nomiss exposed, col


gen monthentry = month(discharged1_date) if exposed==1
by setid: replace monthentry = monthentry[1]

gen entrydate  = discharged1_date if exposed==1
replace entrydate = mdy(monthentry,1,2020) if exposed==0
format %d entrydate
gen exitdate = admitted2_date if exposed==1
replace exitdate = admitted_date if exposed==0
format %d exitdate
gen readmission = (exitdate<.)

summ discharged1_date, f d
scalar censordate = r(max)

*drop set if later than 60d before latest sus data
gen todrop = admitted1_date >= censordate-60 if exposed==1
by setid: replace todrop = todrop[1]
drop if todrop==1
drop todrop

*drop set if died on or before date of 1st discharge 
gen todrop = died_date_ons <= discharged1_date & exposed==1
by setid: replace todrop = todrop[1]
drop if todrop==1
drop todrop

replace exitdate = died_date_ons if died_date_ons<exitdate
replace exitdate = censordate if censordate<exitdate

replace readmission = 0 if exitdate<admitted2_date & exposed==1
replace readmission = 0 if exitdate<admitted_date & exposed==0

replace readmission = 2 if readmission==1 & (admitted2_reason!="U071"&admitted2_reason!="U072") & exposed==1
replace readmission = 2 if readmission==1 & (admitted_reason!="U071"&admitted_reason!="U072")&exposed==0

replace readmission = 3 if readmission==0 & exitdate==died_date_ons

replace exitdate = exitdate+0.5 if exitdate==entrydate

*Controls who were not actually alive (edit in matching eligibility)
drop if died_date_ons<=entrydate & exposed==0

stset exitdate, fail(readmission) enter(entrydate) origin(entrydate)

gen samedayoutcome = readmission>=1 & (exitdate-entrydate)<0.6
tab readm sameday if exposed==1

sts graph , ci by(exposed)

*not counting those readmitted same day
gen entrydateplus1 = entrydate+1
stset exitdate, fail(readmission) enter(entrydateplus1) origin(entrydate) 
sts graph , ci by(exposed)


stcox exposed, strata(setid)

stcox exposed i.ethnicity i.imd , strata(setid)
stcox exposed i.ethnicity i.imd i.obese4cat i.smoke_nomiss, strata(setid) 
stcox exposed i.ethnicity i.imd i.obese4cat i.smoke_nomiss htdiag chronic_respiratory_disease i.asthmacat chronic_cardiac_disease i.diabcat i.cancer_exhaem_cat i.cancer_haem_cat i.reduced_kidney_function_cat2 chronic_liver_disease stroke dementia other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression, strata(setid) 

*Type of readmission
stset exitdate, fail(readmission==1) enter(entrydateplus1) origin(entrydate)
stcompet cuminc=ci, compet1(2) compet2(3) by(exposed)

twoway line cuminc _t if readmission==1, c(stairstep) sort || line cuminc _t if readmission==2, c(stairstep) sort  || line cuminc _t if readmission==3, c(stairstep) sort legend(label(1 "readmission - covid") label(2 "readmission non-covid") label(3 "death")) || , by(exposed)

twoway line cuminc _t if readmission==1, c(stairstep) sort || line cuminc _t if readmission==2, c(stairstep) sort  || , legend(label(1 "readmission - covid") label(2 "readmission non-covid") label(3 "death")) by(exposed)


sts graph , ci by(exposed)

gen readmission_detail = readmission
