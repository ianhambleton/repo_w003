** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap2-cvd-summary-table.do
    //  project:				    WHO Global Health Estimates
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	26-Apr-2021
    //  algorithm task			    Preparing Data for a summary CVD table

    ** General algorithm set-up
    version 17
    clear all
    macro drop _all
    set more 1
    set linesize 80

    ** Set working directories: this is for DATASET and LOGFILE import and export

    ** DATASETS to encrypted SharePoint folder
    local datapath "X:\OneDrive - The University of the West Indies\Writing\w003\data"

    ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    local logpath "X:\OneDrive - The University of the West Indies\Writing\w003\tech-docs"

    ** REPORTS and Other outputs
    local outputpath "X:\OneDrive - The University of the West Indies\Writing\w003\outputs"

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\chap2-cvd-summary-table", replace
** HEADER -----------------------------------------------------

** Mortality Rate statistics first
use "`datapath'\from-who\chap2_cvd_mr", clear

** Create new GHE CoD order for Table 
gen cod = 1 if ghecause==1130 
replace cod = 2 if ghecause==1140
replace cod = 3 if ghecause==1120
replace cod = 4 if ghecause==1150
replace cod = 5 if ghecause==1110
replace cod = 6 if ghecause==1100
drop if ghecause==1160 
#delimit ; 
label define cod_   1 "ischaemic" 
                    2 "stroke" 
                    3 "hypertensive" 
                    4 "cardiomyopathy etc" 
                    5 "rheumatic" 
                    6 "all cvd", modify ;
#delimit cr
label values cod cod_ 

** COLUMN 1
** Number of deaths in the Americas in 2019 by GHE CoD 
** Women and men combined 
preserve 
    keep if region==2000 & year==2019 
    collapse (sum) dths, by(cod)
    tabdisp cod  , cell(dths) format(%12.0fc)
restore

** COLUMNS 2 (women) and 4 (men)
** Mortality Rate in 2019
preserve
    sort sex cod 
    replace arate = arate* 100000 
    keep if region==2000 & year==2019 
    ** Women 
    tabdisp cod if sex==2, cell(arate) format(%12.1fc) 
    ** Men 
    tabdisp cod if sex==1, cell(arate) format(%12.1fc) 
restore 



** COLUMN 3. 
** Sparkline of Mortality Rate change over time (Women) 
keep if region==2000

** Color Scheme
colorpalette ptol, rainbow n(6)  nograph
local list r(p) 
** (MEN --> sex = 2)
local men `r(p3)'
** (Women --> sex = 1)
local women `r(p5)'

** Zero line for shading boundary 
gen y = 0 

** Relative Rate 
gen ar1 = arate if year==2000
bysort sex cod : egen ar2 = min(ar1)
drop ar1 
gen rel_arate = arate/ar2

** Women 
forval a = 1(1)6 { 
    #delimit ;
        gr twoway 
            (rarea rel_arate y year if cod==`a' & sex==2 & region==2000 , sort lw(none) color("`women'%25"))
            (line rel_arate year if cod==`a' & sex==2 & region==2000, sort lc("`women'") fc("`women'") lw(3.5) msize(5))
            (sc rel_arate year if cod==`a' & sex==2 & region==2000, sort m(O) mfc("gs16") mlw(2) mlc("`women'") msize(5) )
            ,
                plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
                graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
                ysize(6) xsize(20)
                
                xlab(, 
                labs(medsmall) nogrid glc(gs14) angle(0) labgap(3))
                xscale(off lw(vthin) range(1999.5(0.5)2019.5))  
                xtitle("", margin(t=3) size(medsmall)) 
                yscale(off lw(vthin) ) 
                ylab(,nogrid)
                legend(off)
                name(spark_`a'_women)
                ;
        #delimit cr
}
** Men 
forval a = 1(1)6 { 
    #delimit ;
        gr twoway 
            (rarea rel_arate y year if cod==`a' & sex==1 & region==2000 , sort lw(none) color("`men'%25"))
            (line rel_arate year if cod==`a' & sex==1 & region==2000, sort lc("`men'") fc("`men'") lw(3.5) msize(5))
            (sc rel_arate year if cod==`a' & sex==1 & region==2000, sort m(O) mfc("gs16") mlw(2) mlc("`men'") msize(5) )
            ,
                plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
                graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
                ysize(6) xsize(20)
                
                xlab(, 
                labs(medsmall) nogrid glc(gs14) angle(0) labgap(3))
                xscale(off lw(vthin) range(1999.5(0.5)2019.5))  
                xtitle("", margin(t=3) size(medsmall)) 
                yscale(off lw(vthin) ) 
                ylab(,nogrid)
                legend(off)
                name(spark_`a'_men)
                ;
        #delimit cr
}


