/* generate.do v0.00             damiancclarke             yyyy-mm-dd:2015-08-17
----|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

Generate comuna-level teen pregnancy indicators.

*/

vers 11
clear all
set more off
cap log close

*-------------------------------------------------------------------------------
*--- (1) globals (relative)
*-------------------------------------------------------------------------------
global NAC "../data/nacimientos"
global COM "../data/comunas"
global POP "../data/poblacion"
global DAT "../data"
global LOG "../log"

log using "$LOG/generate.txt", text replace


*-------------------------------------------------------------------------------
*--- (2) Birth comuna names
*-------------------------------------------------------------------------------
foreach y of numlist 2001(1)2006 {
    use "$NAC/NAC`y'"
    keep if edad_m>=15&edad_m<20
    gen nacimientos = 1
    collapse (sum) nacimientos, by(comuna)
    rename comuna comunacode20002008
    merge m:1 comunacode20002008 using "$COM/comunacodes"
    replace nacimientos = 0 if nacimientos == .
    drop v20 _merge
    gen agno = `y'
    tempfile f`y'
    save `f`y''
}

foreach y of numlist 2007(1)2009 {
    use "$NAC/NAC`y'"
    keep if edad_m>=15&edad_m<20
    gen nacimientos = 1
    collapse (sum) nacimientos, by(comuna)
    rename comuna comunacode20082010
    merge m:1 comunacode20082010 using "$COM/comunacodes"
    replace nacimientos = 0 if nacimientos == .
    drop v20 _merge
    gen agno = `y'
    tempfile f`y'
    save `f`y''
}

foreach y of numlist 2010(1)2012 {
    use "$NAC/NAC`y'"
    keep if edad_m>=15&edad_m<20
    gen nacimientos = 1
    collapse (sum) nacimientos, by(comuna)
    rename comuna comunacode2010
    merge m:1 comunacode2010 using "$COM/comunacodes"
    replace nacimientos = 0 if nacimientos == .
    drop v20 _merge
    gen agno = `y'
    tempfile f`y'
    save `f`y''
}

clear
append using `f2001' `f2002' `f2003' `f2004' `f2005' `f2006'
append using `f2007' `f2008' `f2009' `f2010' `f2011' `f2012'
gen dom_comuna = upper(comuna)
replace dom_comuna = subinstr(dom_comuna, "é", "E", .)
replace dom_comuna = subinstr(dom_comuna, "ñ", "Ñ", .)
replace dom_comuna = subinstr(dom_comuna, "á", "A", .)
replace dom_comuna = subinstr(dom_comuna, "Á", "A", .)
replace dom_comuna = subinstr(dom_comuna, "í", "I", .)
replace dom_comuna = subinstr(dom_comuna, "ó", "O", .)
replace dom_comuna = subinstr(dom_comuna, "ú", "U", .)
replace dom_comuna = subinstr(dom_comuna, "ü", "Ü", .)
replace dom_comuna = "ISLA DE PASCUA" if regexm(dom_comuna, "DE PASCUA")==1
replace dom_comuna = "PEDRO AGUIRRE CERDA" if regexm(dom_comuna, "AGUIRRE CERDA")

save "$DAT/embarazoAdolescente", replace

*-------------------------------------------------------------------------------
*--- (3) Poblacion
*-------------------------------------------------------------------------------
insheet using "$POP/pop1519.csv", comma clear
keep dom_comuna d2001-d2012
foreach y of numlist 2001 2002 2003 {
    replace d`y'="" if d`y'=="NA"
    destring d`y', replace
}

reshape long d, i(dom_comuna) j(agno)
rename d population

replace dom_comuna = "ISLA DE PASCUA" if regexm(dom_comuna, "DE PASCUA")==1
replace dom_comuna = "PEDRO AGUIRRE CERDA" if regexm(dom_comuna, "AGUIRRE CERDA")

merge 1:m dom_comuna agno using "$DAT/embarazoAdolescente"
gen teenPreg = nacimientos/population
drop _merge
save "$DAT/embarazoAdolescente", replace

*-------------------------------------------------------------------------------
*--- (4) Pill
*-------------------------------------------------------------------------------
insheet using "$DAT/pildora/raw.csv", delim(";") clear
collapse (sum) cantidad, by(comuna region agno)
rename cantidad pildora

gen dom_comuna = upper(comuna)
replace dom_comuna = subinstr(dom_comuna, "é", "E", .)
replace dom_comuna = subinstr(dom_comuna, "ñ", "Ñ", .)
replace dom_comuna = subinstr(dom_comuna, "á", "A", .)
replace dom_comuna = subinstr(dom_comuna, "Á", "A", .)
replace dom_comuna = subinstr(dom_comuna, "í", "I", .)
replace dom_comuna = subinstr(dom_comuna, "ó", "O", .)
replace dom_comuna = subinstr(dom_comuna, "ú", "U", .)
replace dom_comuna = subinstr(dom_comuna, "ü", "Ü", .)
replace dom_comuna = "CONCON" if dom_comuna == "CON CON"

replace agno = agno+1
drop if agno==2013
merge 1:1 agno dom_comuna using "$DAT/embarazoAdolescente"


drop _merge
replace pildora = 0 if pildora==.
gen pillComuna = pildora>0

encode dom_comuna    , gen(cc)
gen rc = regioncode2008
keep agno regioncode2008 comuna pillComuna nacimientos population cc rc

lab var agno        "Año de nacimientos"
lab var region      "Región de nacimiento"
lab var comuna      "Comuna de nacimiento"
lab var pillComuna  "Se entregó la pildora AE en esta comuna el año anterior"
lab var nacimientos "Número de nacimientos a madres de entre 15-19 años"
lab var population  "Población comunal de 15-19 (F) según INE"
lab var cc          "Comuna code"
lab var rc          "Region code"

save "$DAT/embarazoAdolescente", replace
