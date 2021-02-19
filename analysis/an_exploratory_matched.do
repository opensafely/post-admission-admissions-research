
use ./analysis/cr_getmatches, clear

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
replace exitdate = died_date_ons if died_date_ons<exitdate
replace exitdate = censordate if censordate<exitdate

replace readmission = 0 if exitdate<admitted2_date & exposed==1
replace readmission = 0 if exitdate<admitted_date & exposed==0

stset exitdate, fail(readmission) enter(entrydate) origin(entrydate)

sts graph , ci by(exposed)

stcox exposed, strata(setid)

