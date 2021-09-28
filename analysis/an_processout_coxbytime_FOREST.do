*an_processout_coxbytime_FOREST

cap postutil clear
tempfile estimates
postfile estimates str6 ctrl str20 outcome timestratum hr lei uci pinteraction using `estimates', replace

foreach ctrl of any 2019gp flu{
foreach outcome of any COMPOSITE DEATH otherinfections cancer_ex_nmsc endo_nutr_metabol mentalhealth nervoussystem circulatory respiratorylrti respiratory digestive musculoskeletal genitourinary external {

if "`outcome'"!="COMPOSITE" & "`outcome'"!="DEATH" estimates use analysis/output/models/an_coxbytime_causespecific_R2`outcome'_c`ctrl'_MATCHFACONLY

else estimates use analysis/output/models/an_coxbytime_R2_`outcome'vs`ctrl'_MINADJ

test 1.exposed#22.timesinceentry 1.exposed#82.timesinceentry
local pint = r(p)

lincom 1.exposed , eform
post estimates ("`ctrl'") ("`outcome'") (0) (r(estimate)) (r(lb)) (r(ub)) (`pint')
lincom 1.exposed + 1.exposed#22. timesinceentry, eform
post estimates ("`ctrl'") ("`outcome'") (22) (r(estimate)) (r(lb)) (r(ub)) (`pint')
lincom 1.exposed + 1.exposed#82.timesinceentry, eform
post estimates ("`ctrl'") ("`outcome'") (82) (r(estimate)) (r(lb)) (r(ub)) (`pint')

}
}

postclose estimates
use `estimates', clear
foreach outcome of any 2019gp flu{

preserve

keep if ctrl=="`outcome'"
gen n=_n
gsort -n
 
gen counter=1
replace counter = 3 if timestratum==82 & _n>1

gen graphorder = sum(counter)

gen hrandci = string(hr, "%5.2f") + " (" + string(lci , "%5.2f") + "-" + string(uci , "%5.2f") + ")"
gen hrcipos = 30
gen modelpos = 0.003
 
gen outcometext = "Other infections (A)" if outcome=="otherinfections" & timestratum==0 
replace outcometext = "Cancers (C ex C44)" if outcome=="cancer_ex_nmsc" & timestratum==0
replace outcometext = "Endocrine, nutritional and metabolic (E)" if outcome=="endo_nutr_metabol" & timestratum==0
replace outcometext = "Mental health and cognitive (F/G30/X60-84)" if outcome=="mentalhealth" & timestratum==0
replace outcometext = "Nervous system (G, ex G30)" if outcome=="nervoussystem" & timestratum==0
replace outcometext = "Circulatory (I)" if outcome=="circulatory" & timestratum==0
replace outcometext = "COVID/Flu/LRTI (J09-22, U071-072)" if outcome=="respiratorylrti" & timestratum==0 
replace outcometext = "Other respiratory (J23-99)" if outcome=="respiratory" & timestratum==0
replace outcometext = "Digestive (K)" if outcome=="digestive" & timestratum==0
replace outcometext = "Musculoskeletal (M)" if outcome=="musculoskeletal" & timestratum==0 
replace outcometext = "Genitourinary (N)" if outcome=="genitourinary" & timestratum==0
replace outcometext = "External causes (S-Y except U/X60-84)" if outcome=="external" & timestratum==0 

replace outcometext = "COMPOSITE (hospitalisation/death)" if outcome="COMPOSITE" & timestratum==0
replace outcometext = "ALL CAUSE HORTALITY" if outcome=="DEATH" & timestratum=0
     
gen pintstr = "(p-interaction <0.001)" if pinteraction<0.001 & timestratum==82
replace pintstr = "(p-interaction = " + string(pinteraction, "%4.3f") + ")" if pinteraction>=0.001 & timestratum==82

local outcomelab "vs 2019 general population controls"
if "`outcome'"=="flu" local outcomelab "vs flu"


scatter graphorder hr if time==0 , msize(small) mcol(black) || rcap lci uci graphorder if time==0 , hor lw(thin) lc(black) ///
|| scatter graphorder hr if time=22 , msize(small) mcol(gs5) || rcap lci uci graphorder if time==22, hor Iw(thin) lc(gs7) ///
|| scatter graphorder hr if tim==82 , msize(small) mcol(gsia) || rcap lci uci graphorder if time==82, hor lw(thin) lc(gsi0) ///
|| scatter graphorder hrcipos, m(i) mlab(hrandci) mlabsize(vsmall) mlabcol(black) ///
|| scatter graphorder modelpos, m(i) mlab(outcometext) mlabsize(vsmall) mlabcol (black) ///
|| scatter graphorder modelpos, m(i) mlab(pintstr) mlabsize(vsmall) mlabcol(gs7) ///
||, xscale(log range(0.004 320)) xline(1, lp(dash)) xlab(0.5 1 2 5 10 20) ysize(10) ytitle("") yscale(off range(70)) ylab(0 70, nogrid) ytick(none) legend(cols(1) order(1 3 5) label(1 "<30 days (from hospital discharge date)") label(3 "30-<90 days") label(5 "90+ days") size(vsmall)) xtitle(HR and 95% CI) ///
 text(70 0.0025 "`outcomelab'", size(small) placement(e)) ///
 text (70 35 "HR and 95% CI", size(vsmall) placement(e)) name(_`outcome', replace)

restore
} /*outcome 2019gp, flu*/

grc1leg _2019gp _flu, rows(1) name(combined, replace)
graph combine combined, ysize(5) iscale(*.7)

graph export analysis/output/an_processout_coxbytime_FOREST.svg, as(svg) replace