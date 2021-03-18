log using logs/model.log
import delimited output/input_covdischarged.csv
log close

do analysis/cr_getmatches /*not re-run since correction to censor date - fixes currently at top of cr_..stset*/
do analysis/cr_stsetmatcheddata_ALLCONTROLS

do analysis/an_descriptive

do analysis/an_desctable
do analysis/an_cumulativeincidence

do analysis/an_cox

winexec "c:/program files/stata16/statamp-64.exe" do analysis/an_crreg_outcome 1 flu
winexec "c:/program files/stata16/statamp-64.exe" do analysis/an_crreg_outcome 2 flu
winexec "c:/program files/stata16/statamp-64.exe" do analysis/an_crreg_outcome 3 flu
winexec "c:/program files/stata16/statamp-64.exe" do analysis/an_crreg_outcome 4 flu
winexec "c:/program files/stata16/statamp-64.exe" do analysis/an_crreg_outcome 5 flu
winexec "c:/program files/stata16/statamp-64.exe" do analysis/an_crreg_outcome 6 flu
winexec "c:/program files/stata16/statamp-64.exe" do analysis/an_crreg_outcome 7 flu
winexec "c:/program files/stata16/statamp-64.exe" do analysis/an_crreg_outcome 8 flu
winexec "c:/program files/stata16/statamp-64.exe" do analysis/an_crreg_outcome 9 flu
winexec "c:/program files/stata16/statamp-64.exe" do analysis/an_crreg_outcome 10 flu
winexec "c:/program files/stata16/statamp-64.exe" do analysis/an_crreg_outcome 11 flu
winexec "c:/program files/stata16/statamp-64.exe" do analysis/an_crreg_outcome 12 flu
winexec "c:/program files/stata16/statamp-64.exe" do analysis/an_crreg_outcome 13 flu

winexec "c:/program files/stata16/statamp-64.exe" do analysis/an_crreg_outcome 1 2019gp
winexec "c:/program files/stata16/statamp-64.exe" do analysis/an_crreg_outcome 2 2019gp
winexec "c:/program files/stata16/statamp-64.exe" do analysis/an_crreg_outcome 3 2019gp
winexec "c:/program files/stata16/statamp-64.exe" do analysis/an_crreg_outcome 4 2019gp
winexec "c:/program files/stata16/statamp-64.exe" do analysis/an_crreg_outcome 5 2019gp
winexec "c:/program files/stata16/statamp-64.exe" do analysis/an_crreg_outcome 6 2019gp
winexec "c:/program files/stata16/statamp-64.exe" do analysis/an_crreg_outcome 7 2019gp
winexec "c:/program files/stata16/statamp-64.exe" do analysis/an_crreg_outcome 8 2019gp
winexec "c:/program files/stata16/statamp-64.exe" do analysis/an_crreg_outcome 9 2019gp
winexec "c:/program files/stata16/statamp-64.exe" do analysis/an_crreg_outcome 10 2019gp
winexec "c:/program files/stata16/statamp-64.exe" do analysis/an_crreg_outcome 11 2019gp
winexec "c:/program files/stata16/statamp-64.exe" do analysis/an_crreg_outcome 12 2019gp
winexec "c:/program files/stata16/statamp-64.exe" do analysis/an_crreg_outcome 13 2019gp

do analysis/an_processout_crreg
