
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
cap drop cuminc
streset , fail(readm_reason_b==10)
stcompet cuminc=ci, compet1(1) compet2(2) compet3(3) compet4(4) compet5(5) compet6(6) compet7(7) compet8(8) compet9(9) compet10(11) compet11(12) compet12(13) compet13(14) by(group)

twoway line cuminc _t if group==1 , c(stairstep) sort || line cuminc _t if group==2, c(stairstep) sort  ///
	|| line cuminc _t if group==4 , c(stairstep) sort ///
	|| if readm_reason_b>0 & readm_reason_b<14,  xtitle(Days from index date) legend(cols(2) label(1 "Hospitalised COVID-19") label(2 "Hospitalised flu 2017_19") label(3 "General pop 2019")  size(small)) by(readm_reason_b, yrescale) name(readm_reason, replace)
graph export analysis/output/an_cumulativeincidence_causespecific.svg, as(svg) replace


