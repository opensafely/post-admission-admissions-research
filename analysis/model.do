log using logs/model.log
import delimited output/input_covdischarged.csv
log close

do analysis/cr_getmatches /*not re-run since correction to censor date - fixes currently at top of cr_..stset*/
do analysis/cr_stsetmatcheddata_ALLCONTROLS

do analysis/an_desctable
do analysis/an_cumulativeincidence

do analysis/an_cox_composite

winexec "c:/program files/stata16/statamp-64.exe" do analysis/an_crreg_outcome 1
winexec "c:/program files/stata16/statamp-64.exe" do analysis/an_crreg_outcome 2
winexec "c:/program files/stata16/statamp-64.exe" do analysis/an_crreg_outcome 3
winexec "c:/program files/stata16/statamp-64.exe" do analysis/an_crreg_outcome 4
winexec "c:/program files/stata16/statamp-64.exe" do analysis/an_crreg_outcome 5
winexec "c:/program files/stata16/statamp-64.exe" do analysis/an_crreg_outcome 6
winexec "c:/program files/stata16/statamp-64.exe" do analysis/an_crreg_outcome 7
winexec "c:/program files/stata16/statamp-64.exe" do analysis/an_crreg_outcome 8
winexec "c:/program files/stata16/statamp-64.exe" do analysis/an_crreg_outcome 9
winexec "c:/program files/stata16/statamp-64.exe" do analysis/an_crreg_outcome 10
winexec "c:/program files/stata16/statamp-64.exe" do analysis/an_crreg_outcome 11
winexec "c:/program files/stata16/statamp-64.exe" do analysis/an_crreg_outcome 12
winexec "c:/program files/stata16/statamp-64.exe" do analysis/an_crreg_outcome 13

do analysis/an_processout_crreg
