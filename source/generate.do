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
    rename comuna comunacode20002008
    merge m:1 comunacode20002008 using "$COM/comunacodes"
    drop v20 _merge
    tempfile f`y'
    save `f`y''
}

foreach y of numlist 2007(1)2009 {
    use "$NAC/NAC`y'"
    rename comuna comunacode20082010
    merge m:1 comunacode20082010 using "$COM/comunacodes"
    drop v20 _merge
    tempfile f`y'
    save `f`y''
}

foreach y of numlist 2010(1)2012 {
    use "$NAC/NAC`y'"
    rename comuna comunacode2010
    merge m:1 comunacode2010 using "$COM/comunacodes"
    drop v20 _merge
    tempfile f`y'
    save `f`y''
}

