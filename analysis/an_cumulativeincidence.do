
use analysis/cr_append_process_data, clear

drop if group==3

*Age centring for age-adj KMs
qui summ age if exposed==1
gen age_c = age-r(mean)


*Composite outcome
sts graph, failure by(group) xtitle(Days from index date) legend(cols(1)) title("") xtitle(Days from index date) name(composite, replace)
graph export analysis/output/an_cumulativeincidence_composite.svg, as(svg) replace

*Composite outcome, adjusted for age/sex
sts graph, failure by(group) xtitle(Days from index date) legend(cols(1)) title("") xtitle(Days from index date) adjustfor(age_c male) name(composite_agesex, replace)
graph export analysis/output/an_cumulativeincidence_composite_adjagesex.svg, as(svg) replace

*Death outcome
preserve
	include analysis/setfordeath.doi
	sts graph, failure by(group) legend(cols(1)) title("") xtitle(Days from index date) name(death, replace)
	graph export analysis/output/an_cumulativeincidence_death.svg, as(svg) replace
	sts graph, failure by(group) adjustfor(age_c male) legend(cols(1)) title("")  xtitle(Days from index date) name(death_agesex, replace)
	graph export analysis/output/an_cumulativeincidence_death_adjagesex.svg, as(svg) replace
restore

*By reason for readmission/death
*can't do for pre2019 flu
drop if group==2 & entrydate<d(1/1/2019)


foreach csoutcome of any otherinfections cancer_ex_nmsc endo_nutr_metabol mentalhealth nervoussystem circulatory respiratorylrti respiratory digestive musculoskeletal genitourinary external {

replace CSfail_`csoutcome' = 2 if CSfail_`csoutcome'==0 & CSexit_`csoutcome'==died_date_ons
replace CSfail_`csoutcome' = 2 if CSfail_`csoutcome'==0 & CSexit_`csoutcome'>=died_date_ons+0.49 & CSexit_`csoutcome'<=died_date_ons+0.51
stset CSexit_`csoutcome', fail(CSfail_`csoutcome'=1) origin(entrydate) enter(entrydate) 

stcompet cuminc_`csoutcome'=ci, compet1(2) by(group)
gen t_`csoutcome'=_t
}

global allgraphs

foreach csoutcome of any otherinfections cancer_ex_nmsc endo_nutr_metabol mentalhealth nervoussystem circulatory respiratorylrti respiratory digestive musculoskeletal genitourinary external {
	
if "`csoutcome'"=="otherinfections"  local outcometext = "Other infections (A)" 
if "`csoutcome'"=="cancer_ex_nmsc" local outcometext = "Cancers (C ex C44)" 
if "`csoutcome'"=="endo_nutr_metabol" local outcometext = "Endocrine, nutritional and metabolic (E)" 
if "`csoutcome'"=="mentalhealth" local outcometext = "Mental and behavioural (F/X60-84)" 
if "`csoutcome'"=="nervoussystem" local outcometext = "Nervous system (G)" 
if "`csoutcome'"=="circulatory" local outcometext = "Circulatory (I)" 
if "`csoutcome'"=="respiratorylrti"  local outcometext = "COVID/Flu/LRTI (J09-22, U071-072)" 
if "`csoutcome'"=="respiratory" local outcometext = "Other respiratory (J23-99)" 
if "`csoutcome'"=="digestive" local outcometext = "Digestive (K)" 
if "`csoutcome'"=="musculoskeletal"  local outcometext = "Musculoskeletal (M)" 
if "`csoutcome'"=="genitourinary" local outcometext = "Genitourinary (N)" 
if "`csoutcome'"=="external"  local outcometext = "External causes (S-Y except U/X60-84)" 

	
twoway line cuminc_`csoutcome' t_`csoutcome' if group==1 & CSfail_`csoutcome'==1, c(stairstep) sort lc(black) ///
		|| line cuminc_`csoutcome' t_`csoutcome'  if group==2 & CSfail_`csoutcome'==1, c(stairstep) sort  lc(black) lp(dash) ///
		|| line cuminc_`csoutcome' t_`csoutcome' if group==4 & CSfail_`csoutcome'==1, c(stairstep) sort lc(gs7) lp(dash)  ///
		|| if t_`csoutcome'<=200 ,  xtitle(Days from index date) legend(cols(2) holes(2) label(1 "Hospitalised COVID-19") label(2 "Hospitalised flu 2019") label(3 "General pop 2019")  size(small)) name(`csoutcome', replace) title("`outcometext'") yscale(range(0.1)) ylab(0.02 0.04 0.06 0.08 0.10)
global allgraphs "$allgraphs `csoutcome'"

}	

grc1leg  $allgraphs, iscale(*.6)
graph export analysis/output/an_cumulativeincidence_causespecific.svg, as(svg) replace


