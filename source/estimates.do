/* estimates.do v0.00            damiancclarke             yyyy-mm-dd:2015-08-17
----|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

Estimar el efecto de tener la píldora disponible de los datos administrativos de
MinSal.

Consultas: damian.clarke@economics.ox.ac.uk

*/

vers 11
clear all
set more off
cap log close

*-------------------------------------------------------------------------------
*--- (1) globals
*-------------------------------------------------------------------------------
global DAT "../data"
global OUT "../results"
global LOG "../log"

log using "$LOG/estimates.txt", text replace
cap mkdir $OUT

use "$DAT/embarazoAdolescente"
keep if agno>=2005
*-------------------------------------------------------------------------------
*--- (2a) basic regression
*-------------------------------------------------------------------------------
eststo: reg nacimientos pillComuna  i.agno i.cc                , cluster(cc)
eststo: reg nacimientos pillComuna  i.agno i.cc i.cc#c.agno    , cluster(cc)
eststo: reg nacimientos pillComunaA i.agno i.cc                , cluster(cc)
eststo: reg nacimientos pillComunaA i.agno i.cc i.cc#c.agno    , cluster(cc)
eststo: reg nacimientos pillComuna  i.agno i.cc [fw=population], cluster(cc)
eststo: reg nacimientos pillComunaA i.agno i.cc [fw=population], cluster(cc)

#delimit ;
esttab est1 est2 est3 est4 est5 est6, stats (r2 N, fmt(%9.2f %9.0g)
                                  label(R-squared Observations))
starlevel ("*" 0.10 "**" 0.05 "***" 0.01) collabels(none) label
title("Entrega de la Píldora y Nacimientos Adolescentes")
cells(b(star fmt(%-9.3f)) se(fmt(%-9.3f) par([ ]) ))
keep(pillComuna pillComunaAdolesc);
#delimit cr
exit
*-------------------------------------------------------------------------------
*--- (2b) Event study
*-------------------------------------------------------------------------------
use "$DAT/embarazoAdolescente"
keep if agno>2005

 bys comuna (agno): gen pill_n0 = pillC[_n-0]==1
bys comuna (agno): gen pill_n1 = pillC[_n-1]==1
bys comuna (agno): gen pill_n2 = pillC[_n-2]==1

bys comuna (agno): gen pill_p1 = pillC[_n+1]==1
bys comuna (agno): gen pill_p2 = pillC[_n+2]==1
bys comuna (agno): gen pill_p3 = pillC[_n+3]==1
bys comuna (agno): gen pill_p4 = pillC[_n+4]==1
bys comuna (agno): gen pill_p5 = pillC[_n+5]==1
bys comuna (agno): gen pill_p6 = pillC[_n+6]==1

local lags pill_n2 pill_n1 pill_n0 
local lead pill_p2 pill_p3 pill_p4 pill_p5 pill_p6
reg nacimientos i.cc i.agno `lags' `lead'

local j=0
gen j=.
qui gen Pillest=0 in 6
qui gen PilluCI=0 in 6
qui gen PilllCI=0 in 6
foreach var of varlist `lags' `lead' {
    local ++j
    replace j=`j' in `j'
    qui replace Pillest = _b[`var'] in `j'
    qui replace PilluCI = _b[`var']+1.96*_se[`var'] in `j'
    qui replace PilllCI = _b[`var']-1.96*_se[`var'] in `j'

}

gsort -j
gen time = _n-6 if j!=.


#delimit ;
twoway line Pillest time ||
  line PilluCI time, lpattern(dash) ||
  line PilllCI time, lpattern(dash) xline(-1) scheme(s1mono)
yline(0, lpattern(dash));
#delimit cr
graph export "$OUT/eventStudy.eps", as(eps) replace



