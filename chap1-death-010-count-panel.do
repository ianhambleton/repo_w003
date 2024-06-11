** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap1-death-010-count-panel.do
    //  project:				    WHO Global Health Estimates
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	16-Apr-2021
    //  algorithm task			    Panel graphic - number of deaths

    ** General algorithm set-up
    version 17
    clear all
    macro drop _all
    set more 1
    set linesize 80

    ** Set working directories: this is for DATASET and LOGFILE import and export

    ** DATASETS to encrypted SharePoint folder
    local datapath "C:\yasuki\Sync\output\analyse-write\w003\data"

    ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    local logpath "C:\yasuki\Sync\output\analyse-write\w003\tech-docs"

    ** REPORTS and Other outputs
    local outputpath "C:\yasuki\Sync\output\analyse-write\w003\outputs"

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\chap1-death-010-count-panel", replace
** HEADER -----------------------------------------------------

** Loading COD dataset for world regions
** Limit to just the wide COD groups and save - as preparation for analytics

** ------------------------------------------------------------
** 10 Communicable, maternal, perinatal and nutritional conditions
** 600 Noncommunicable diseases
** 1510 Injuries
** ------------------------------------------------------------
tempfile afr amr emr eur sear wpr world
** Africa (AFR)
use "`datapath'\from-who\who-ghe-deaths-001-who1", replace
    keep if ghecause==10 | ghecause==600 | ghecause==1510
    drop if age<0 
    ** Collapse AGE ut of dataset 
    collapse (sum) dths dths_low dths_up pop, by(ghecause year who_region)
    save `afr' , replace

** Americas (AMR)
use "`datapath'\from-who\who-ghe-deaths-001-who2", replace
    keep if ghecause==10 | ghecause==600 | ghecause==1510
    drop if age<0 
    ** Collapse AGE ut of dataset 
    collapse (sum) dths dths_low dths_up pop, by(ghecause year who_region)
    save `amr' , replace

** Eastern Mediterranean (EMR)
use "`datapath'\from-who\who-ghe-deaths-001-who3", replace
    keep if ghecause==10 | ghecause==600 | ghecause==1510
    drop if age<0 
    ** Collapse AGE ut of dataset 
    collapse (sum) dths dths_low dths_up pop, by(ghecause year who_region)
    save `emr' , replace

** Europe (EUR)
use "`datapath'\from-who\who-ghe-deaths-001-who4", replace
    keep if ghecause==10 | ghecause==600 | ghecause==1510
    drop if age<0 
    ** Collapse AGE ut of dataset 
    collapse (sum) dths dths_low dths_up pop, by(ghecause year who_region)
    save `eur' , replace

** South-East Asia (SEAR)
use "`datapath'\from-who\who-ghe-deaths-001-who5", replace
    keep if ghecause==10 | ghecause==600 | ghecause==1510
    drop if age<0 
    ** Collapse AGE ut of dataset 
    collapse (sum) dths dths_low dths_up pop, by(ghecause year who_region)
    save `sear' , replace

** Western Pacific (WPR)
use "`datapath'\from-who\who-ghe-deaths-001-who6", replace
    keep if ghecause==10 | ghecause==600 | ghecause==1510
    drop if age<0 
    ** Collapse AGE ut of dataset 
    collapse (sum) dths dths_low dths_up pop, by(ghecause year who_region)
    save `wpr' , replace

** GLOBAL
use `afr', clear 
    append using `amr'
    append using `emr'
    append using `eur'
    append using `sear'
    append using `wpr'
    collapse (sum) dths dths_low dths_up pop, by(ghecause year)
    save `world' , replace

** Join the WHO regions
use `afr', clear 
    append using `amr'
    append using `emr'
    append using `eur'
    append using `sear'
    append using `wpr'
    save "`datapath'\from-who\chap1_deaths_001", replace

** ------------------------------------------------------------
** GRAPHIC
** ------------------------------------------------------------

** Per 1,000 
replace dths = dths/1000
** GRAPHIC ordered by umber of deaths
** low to high
** EMR, AMR, EUR, AFR, WPR, SEAR
gen yr1 = . 
replace yr1 = year if who_region==3
replace yr1 = year + 20 if who_region==2
replace yr1 = year + 40 if who_region==4
replace yr1 = year + 60 if who_region==1
replace yr1 = year + 80 if who_region==6
replace yr1 = year + 100 if who_region==5
order year yr1 

drop dths_low dths_up 
reshape wide dths , i(who_region year) j(ghecause) 

** injuries
gen zero = 0 
gen inj = dths1510 
gen ncd = dths600 + inj 
gen com = dths10 + ncd

** generate a local for the ColorBrewer color scheme
colorpalette ptol, rainbow n(9)  nograph
local list r(p) 
** (COM --> ghecause = 10)
local com `r(p3)'
** (NCD --> ghecause = 600)
local ncd `r(p6)'
** (INJ --> ghecause = 1510)
local inj `r(p9)'

** Jitter men by a fraction to improve visual
/// replace yr1 = yr1 - 0.2 if sex==1 
/// replace yr1 = yr1 + 0.2 if sex==2 

** Legend outer limits for graphing 
local outer1 12800 2001 13400 2001 13400 2006 12800 2006 12800 2001 
local outer2 11800 2001 12400 2001 12400 2006 11800 2006 11800 2001 
local outer3 10800 2001 11400 2001 11400 2006 10800 2006 10800 2001 



#delimit ;
	gr twoway 
		/// Africa
        (rarea zero inj yr1 if who_region==1 , lw(none) color("`inj'%25"))
        (rarea inj ncd yr1 if  who_region==1 , lw(none) color("`ncd'%25"))
        (rarea ncd com yr1 if  who_region==1 , lw(none) color("`com'%25"))
		/// Americas
        (rarea zero inj yr1 if who_region==2 , lw(none) color("`inj'%25"))
        (rarea inj ncd yr1 if  who_region==2 , lw(none) color("`ncd'%25"))
        (rarea ncd com yr1 if  who_region==2 , lw(none) color("`com'%25"))
		/// Eastern Mediterranean
        (rarea zero inj yr1 if who_region==3 , lw(none) color("`inj'%25"))
        (rarea inj ncd yr1 if  who_region==3 , lw(none) color("`ncd'%25"))
        (rarea ncd com yr1 if  who_region==3 , lw(none) color("`com'%25"))
		/// Europe
        (rarea zero inj yr1 if who_region==4 , lw(none) color("`inj'%25"))
        (rarea inj ncd yr1 if  who_region==4 , lw(none) color("`ncd'%25"))
        (rarea ncd com yr1 if  who_region==4 , lw(none) color("`com'%25"))
		/// SEAR
        (rarea zero inj yr1 if who_region==5 , lw(none) color("`inj'%25"))
        (rarea inj ncd yr1 if  who_region==5 , lw(none) color("`ncd'%25"))
        (rarea ncd com yr1 if  who_region==5 , lw(none) color("`com'%25"))
		/// Wetern Pacific
        (rarea zero inj yr1 if who_region==6 , lw(none) color("`inj'%25"))
        (rarea inj ncd yr1 if  who_region==6 , lw(none) color("`ncd'%25"))
        (rarea ncd com yr1 if  who_region==6 , lw(none) color("`com'%25"))

        /// droplines
        (function y=14000, range(2000 2120) lc(gs12) dropline(2019.5 2039.5 2059.5 2079.5 2099.5 2119.5))

        /// Legend
        (scatteri `outer1' , recast(area) lw(none) lc("`com'%25") fc("`com'%25")  )
        (scatteri `outer2' , recast(area) lw(none) lc("`ncd'%25") fc("`ncd'%25")  )
        (scatteri `outer3' , recast(area) lw(none) lc("`inj'%25") fc("`inj'%25")  )
		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 
			ysize(8) xsize(18)

			xlab(none, 
			valuelabel labc(gs0) labs(2.5) notick nogrid glc(gs16) angle(45) format(%9.0f))
			xscale(noline lw(vthin)) 
			xtitle(" ", size(3) color(gs0) margin(l=1 r=1 t=1 b=1)) 
	
			ylab(0(2000)14000,
			valuelabel labc(gs8) labs(3) tlc(gs8) nogrid glc(gs16) angle(0) format(%9.0f))
			yscale(lw(vthin) lc(gs8) range(0(1000)16000) noextend) 
			ytitle("Number of deaths (1,000s)", color(gs8) size(3) margin(l=1 r=1 t=1 b=1)) 

            /// Region Titles 
            text(15000 2010 "Eastern" "Mediterranean",  place(c) size(3) color(gs5))
            text(15000 2030 "The" "Americas",  place(c) size(3) color(gs5))
            text(15000 2050 "Europe",  place(c) size(3) color(gs5))   
            text(15000 2070 "Africa",  place(c) size(3) color(gs5))
            text(15000 2090 "Western" "Pacific",  place(c) size(3) color(gs5))
            text(15000 2110 "South-East" "Asia",  place(c) size(3) color(gs5))

            /// Legend Text
            text(13100   2007 "CMPN",  place(e) size(3) color(gs8))   
            text(12100   2007 "NCDs",  place(e) size(3) color(gs8))   
            text(11100   2007 "Injuries",  place(e) size(3) color(gs8))   

			/// X-Axis text
            text(-250 2001 "2000",  place(e) size(3) color(gs8))
            text(-250 2018 "2019",  place(w) size(3) color(gs8))
            text(-250 2021 "2000",  place(e) size(3) color(gs8))
            text(-250 2038 "2019",  place(w) size(3) color(gs8))
            text(-250 2041 "2000",  place(e) size(3) color(gs8))
            text(-250 2058 "2019",  place(w) size(3) color(gs8))
            text(-250 2061 "2000",  place(e) size(3) color(gs8))
            text(-250 2078 "2019",  place(w) size(3) color(gs8))
            text(-250 2081 "2000",  place(e) size(3) color(gs8))
            text(-250 2098 "2019",  place(w) size(3) color(gs8))
            text(-250 2101 "2000",  place(e) size(3) color(gs8))
            text(-250 2118 "2019",  place(w) size(3) color(gs8))

			legend(off size(2.5) position(9) nobox ring(0) bm(t=1 b=4 l=5 r=0) colf cols(1)
			region(fcolor(gs16)  lw(none) margin(zero)) 
			order(2 1) 
			lab(1 "xx") 
			lab(2 "xx") 		
            )
			name(deaths_panel)
			;
#delimit cr	


** Version 2 - legend outside


** Legend outer limits for graphing 
local outer1 16800 2039     17400 2039      17400 2044      16800 2044      16800 2039 
local outer2 16800 2054     17400 2054      17400 2059      16800 2059      16800 2054 
local outer3 16800 2069     17400 2069      17400 2074      16800 2074      16800 2069 



#delimit ;
	gr twoway 
		/// Africa
        (rarea zero inj yr1 if who_region==1 , lw(none) color("`inj'%25"))
        (rarea inj ncd yr1 if  who_region==1 , lw(none) color("`ncd'%25"))
        (rarea ncd com yr1 if  who_region==1 , lw(none) color("`com'%25"))
		/// Americas
        (rarea zero inj yr1 if who_region==2 , lw(none) color("`inj'%25"))
        (rarea inj ncd yr1 if  who_region==2 , lw(none) color("`ncd'%25"))
        (rarea ncd com yr1 if  who_region==2 , lw(none) color("`com'%25"))
		/// Eastern Mediterranean
        (rarea zero inj yr1 if who_region==3 , lw(none) color("`inj'%25"))
        (rarea inj ncd yr1 if  who_region==3 , lw(none) color("`ncd'%25"))
        (rarea ncd com yr1 if  who_region==3 , lw(none) color("`com'%25"))
		/// Europe
        (rarea zero inj yr1 if who_region==4 , lw(none) color("`inj'%25"))
        (rarea inj ncd yr1 if  who_region==4 , lw(none) color("`ncd'%25"))
        (rarea ncd com yr1 if  who_region==4 , lw(none) color("`com'%25"))
		/// SEAR
        (rarea zero inj yr1 if who_region==5 , lw(none) color("`inj'%25"))
        (rarea inj ncd yr1 if  who_region==5 , lw(none) color("`ncd'%25"))
        (rarea ncd com yr1 if  who_region==5 , lw(none) color("`com'%25"))
		/// Wetern Pacific
        (rarea zero inj yr1 if who_region==6 , lw(none) color("`inj'%25"))
        (rarea inj ncd yr1 if  who_region==6 , lw(none) color("`ncd'%25"))
        (rarea ncd com yr1 if  who_region==6 , lw(none) color("`com'%25"))

        /// droplines
        (function y=14000, range(2000 2120) lc(gs12) dropline(2019.5 2039.5 2059.5 2079.5 2099.5 2119.5))

        /// Legend
        (scatteri `outer1' , recast(area) lw(none) lc("`com'%25") fc("`com'%25")  )
        (scatteri `outer2' , recast(area) lw(none) lc("`ncd'%25") fc("`ncd'%25")  )
        (scatteri `outer3' , recast(area) lw(none) lc("`inj'%25") fc("`inj'%25")  )
        (function y=16000, range(2039 2081) lp("l") lc(gs14) lw(0.4))

		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 
			ysize(8) xsize(18)

			xlab(none, 
			valuelabel labc(gs0) labs(2.5) notick nogrid glc(gs16) angle(45) format(%9.0f))
			xscale(noline lw(vthin)) 
			xtitle(" ", size(3) color(gs0) margin(l=1 r=1 t=1 b=1)) 
	
			ylab(0(2000)14000,
			valuelabel labc(gs8) labs(3) tlc(gs8) nogrid glc(gs16) angle(0) format(%9.0f))
			yscale(lw(vthin) lc(gs8) range(-500(500)18000) noextend) 
			ytitle("Number of deaths (1 000s)", color(gs8) size(3) margin(l=1 r=1 t=1 b=1)) 

            /// Region Titles 
            text(15000 2010 "Eastern" "Mediterranean",  place(c) size(3) color(gs5))
            text(15000 2030 "The" "Americas",  place(c) size(3) color(gs5))
            text(15000 2050 "Europe",  place(c) size(3) color(gs5))   
            text(15000 2070 "Africa",  place(c) size(3) color(gs5))
            text(15000 2090 "Western" "Pacific",  place(c) size(3) color(gs5))
            text(15000 2110 "South-East" "Asia",  place(c) size(3) color(gs5))

            /// Legend Text
            text(17100   2045 "CMPN",  place(e) size(3) color(gs8))   
            text(17100   2060 "NCDs",  place(e) size(3) color(gs8))   
            text(17100   2075 "Injuries",  place(e) size(3) color(gs8))   

			/// X-Axis text
            text(-500 2001 "2000",  place(e) size(3) color(gs8))
            text(-500 2018 "2019",  place(w) size(3) color(gs8))
            text(-500 2021 "2000",  place(e) size(3) color(gs8))
            text(-500 2038 "2019",  place(w) size(3) color(gs8))
            text(-500 2041 "2000",  place(e) size(3) color(gs8))
            text(-500 2058 "2019",  place(w) size(3) color(gs8))
            text(-500 2061 "2000",  place(e) size(3) color(gs8))
            text(-500 2078 "2019",  place(w) size(3) color(gs8))
            text(-500 2081 "2000",  place(e) size(3) color(gs8))
            text(-500 2098 "2019",  place(w) size(3) color(gs8))
            text(-500 2101 "2000",  place(e) size(3) color(gs8))
            text(-500 2118 "2019",  place(w) size(3) color(gs8))

			legend(off size(2.5) position(9) nobox ring(0) bm(t=1 b=4 l=5 r=0) colf cols(1)
			region(fcolor(gs16)  lw(none) margin(zero)) 
			order(2 1) 
			lab(1 "xx") 
			lab(2 "xx") 		
            )
			name(deaths_panel2)
			;
#delimit cr	
** Export to Vector Graphic
** DEC 22nd, 2022
graph export "`outputpath'\reports\2024-edits\graphics\fig5.svg", replace
graph export "`outputpath'\reports\2024-edits\graphics\fig5.pdf", replace

