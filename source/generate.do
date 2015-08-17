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
