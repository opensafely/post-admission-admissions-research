cap log close
log using analysis/output/cr_append_process_data, replace t
use analysis/cr_append_process_data, clear

histogram entrydate if (group==1|group==2|group==4), by(group, cols(1)) 
graph export analysis/output/an_descriptive_EVENTSBYTIME.svg, as(svg) replace

gen monthyrentry = year(entrydate) * 100 + month(entrydate)

safetab monthyrent group  if group==2 & entrydate<d(1/11/2019)

safetab readmission group, col

safetab readm_reason_b group, col

log close
