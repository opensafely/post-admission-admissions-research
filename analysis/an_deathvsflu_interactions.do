
cap log close

log using analysis/output/an_deathvsflu_interactions, replace t

use analysis/cr_append_process_data, clear

*Death
*vs 2017_19-flu controls
include analysis/stsetfordeath1ocare.doi
keep if group==1|group==2
	
*By age
stcox exposed age1 age2 age3 male i.stp 1.exposed#2.agegroup 1.exposed#3.agegroup 1.exposed#4.agegroup 1.exposed#5.agegroup 1.exposed#6.agegroup

lincom exposed, hr
lincom exposed + 1.exposed#2.agegroup, hr	
lincom exposed + 1.exposed#3.agegroup, hr	
lincom exposed + 1.exposed#4.agegroup, hr	
lincom exposed + 1.exposed#5.agegroup, hr	
lincom exposed + 1.exposed#6.agegroup, hr	

*By length stay and days critical care
stcox i.exposed##i.hosp_lte_1 age1 age2 age3 male i.stp 
test 1.exposed#1.hosp_lte_1w
lincom 1.exposed, hr
lincom 1.exposed + 1.exposed#1.hosp_lte_1w, hr

safecount if _d==1 & group==2 & anycrit==1
stcox exposed age1 age2 age3 male i.stp if anycrit==0

log close