** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    paper2-140-figure3-version1.do
    //  project:				    WHO Global Health Estimates
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	16-Apr-2021
    //  algorithm task			    Panel graphic - proportion of deaths by AGE group

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
    log using "`logpath'\paper2-140-figure3-version1", replace
** HEADER -----------------------------------------------------

** XX
use "`datapath'\paper2-inj\dataset01", clear
/*
** DATASET preparation
drop paho_subregion daly dths pop_dalyr pop_mortr

** Keep sub-regional level (this will keep the 8 PAHO subregions of the Americas)
keep if (region<100) | region==2000

** Keep injury components
keep if ghecause>=48 & ghecause<=57
keep if year==2000 | year==2019
drop if sex==3

** Create rates for THE AMERICAS as denominator

** Create variable (by sex) with Mortality and DALY rates for the Americas
** This allows us to plot Americas on each panel
forval x = 1(1)3 {
	gen d`x' = dalyr if region==2000 & sex==`x'
	bysort ghecause year sex : egen d`x'_1 = min(d`x')
}
** DALY rates for Americas by Sex
gen dam = d1_1
replace dam = d2_1 if dam==. & d2_1<.
replace dam = d3_1 if dam==. & d3_1<.

** BEST (Lowest) rate in each year by sex 
bysort ghecause year sex : egen dt1 = min(dalyr) if region<2000
bysort ghecause year sex : egen dlo = min(dt1) 
** WORST (Highest) rate in each year by sex 
bysort ghecause year sex : egen dt2 = max(dalyr) if region<2000
bysort ghecause year sex : egen dhi = max(dt2) 

keep year sex ghecause region dalyr dam dlo dhi 


** ------------------------------------------------------
** GRAPHIC
egen kgroup = group(ghecause sex year)
gen tokeep = 0
sort ghecause sex year ghecause
replace tokeep = 1 if _n==1 | kgroup>kgroup[_n-1] 
keep if tokeep==1
drop kgroup tokeep region
** ------------------------------------------------------
tempfile graphic
save `graphic', replace

**                          (ghecause 48. road injury)
**                          (ghecause 49. poisonings)
**                          (ghecause 50. falls)
**                          (ghecause 51. fire and heat)
**                          (ghecause 52. drowning)
**                          (ghecause 53. mechanical forces)
**                          (ghecause 54. natural disasters)
**                          (ghecause 55. self harm)
**                          (ghecause 56. interpersonal violence)
**                          (ghecause 57. collective violence)

** Loop through Injury categories
forval x = 48(1)57 {
    use `graphic', clear
    keep if ghecause==`x'
    sort sex year
    gen ind = _n

	#delimit ;
	gr twoway 
		/// Line between mon and max
		(rspike dlo dhi ind , 		hor lc(gs10) lw(0.35))
		/// Minimum points
		(sc ind dlo, 				msize(12) m(o) mlc(gs0) mfc("255 255 191") mlw(0.1))
		/// Maximum points
		(sc ind dhi , 				msize(12) m(o) mlc(gs0) mfc("253 174 97") mlw(0.1))
		/// Caribbean average
		(sc ind dam ,			 	msize(10) m(o) mlc(gs10) mfc(gs10) mlw(0.1))
		,
			graphregion(color(gs16)) ysize(2.5)
			bgcolor(gs16)
			
			xlab( , labs(7) nogrid glc(gs16))
			xscale( ) 
			xtitle("", size(7) margin(l=2 r=2 t=5 b=2)) 
			
			ylab(1 "Men 2000" 2 "Men 2019" 3 "Women 2000" 4 "Women 2019"  
					,
			labs(7) tstyle(major_notick) nogrid glc(gs16) angle(0) format(%9.0f))
			yscale(noline lw(vthin) reverse range(0(1)5)) 
			ytitle("", size(3) margin(l=2 r=5 t=2 b=2)) 

			legend(off)
            name(ep`x')
			;
	#delimit cr
}
