
use analysis/cr_stsetmatcheddata_ALLCONTROLS, clear

*Composite outcome
sts graph, failure by(exposed_allcontrols) xtitle(Days from index date) legend(cols(1) label(1 "hospitalised COVID") label(2 "general population 2020") label(3 "general population 2019") label(4 "hospitalised pneumonia (2019)")) title("") xtitle(Days from index date)
graph export analysis/output/an_cumulativeincidence_composite.svg, as(svg) replace

*Composite outcome, adjusted for age/sex
qui summ age if exposed==1
gen age_c = age-r(mean)
sts graph, failure by(exposed_allcontrols) xtitle(Days from index date) legend(cols(1) label(1 "hospitalised COVID") label(2 "general population 2020") label(3 "general population 2019") label(4 "hospitalised pneumonia (2019)")) title("") xtitle(Days from index date) adjustfor(age_c male)
graph export analysis/output/an_cumulativeincidence_composite_adjagesex.svg, as(svg) replace

*By type of readmission
streset , fail(readmission==1)
stcompet cuminc=ci, compet1(2) compet2(3) by(exposed_allcontrols)

twoway line cuminc _t if readmission==1, c(stairstep) sort || line cuminc _t if readmission==2, c(stairstep) sort  || line cuminc _t if readmission==3, c(stairstep) sort legend(label(1 "Admission - COVID-19") label(2 "Admission non-COVID") label(3 "Death")) xtitle(Days from index date) || , by(exposed_allcontrols) yscale(r(0 1))
graph export analysis/output/an_cumulativeincidence_cov_noncov_death.svg, as(svg) replace

*By reason for readmission/death
cap drop cuminc
streset , fail(readm_died_reason_b==10)
stcompet cuminc=ci, compet1(1) compet2(2) compet3(3) compet4(4) compet5(5) compet6(6) compet7(7) compet8(8) compet9(9) compet10(11) compet11(12) compet12(13) by(exposed_allcontrols)

twoway line cuminc _t if exposed_allcontrols==1 , c(stairstep) sort || line cuminc _t if exposed_allcontrols==2, c(stairstep) sort  ///
	|| line cuminc _t if exposed_allcontrols==3 , c(stairstep) sort || line cuminc _t if exposed_allcontrols==4 , c(stairstep) sort ///
	|| if readm_died_reason_b>0 ,  xtitle(Days from index date) legend(cols(1) label(1 "hospitalised COVID") label(2 "general population 2020") label(3 "general population 2019") label(4 "hospitalised pneumonia (2019)")) by(readm_died_reason_b)
graph export analysis/output/an_cumulativeincidence_causespecific.svg, as(svg) replace

