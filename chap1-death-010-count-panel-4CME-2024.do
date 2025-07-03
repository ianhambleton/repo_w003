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
/*
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
replace yr1 = year if who_region==2
/// replace yr1 = year + 20 if who_region==2
/// replace yr1 = year + 40 if who_region==4
/// replace yr1 = year + 60 if who_region==1
/// replace yr1 = year + 80 if who_region==6
/// replace yr1 = year + 100 if who_region==5
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
local outer1 8800 2001 9400 2001 9400 2004 8800 2004 8800 2001 
local outer2 7800 2001 8400 2001 8400 2004 7800 2004 7800 2001 
local outer3 6800 2001 7400 2001 7400 2004 6800 2004 6800 2001 



#delimit ;
	gr twoway 
		/// Americas
        (rarea zero inj yr1 if who_region==2 , lw(none) color("`inj'%25"))
        (rarea inj ncd yr1 if  who_region==2 , lw(none) color("`ncd'%25"))
        (rarea ncd com yr1 if  who_region==2 , lw(none) color("`com'%25"))

        /// droplines
        (function y=10000, range(2000 2020) lc(gs12) dropline(2019.5))

        /// Legend
        (scatteri `outer1' , recast(area) lw(none) lc("`com'%25") fc("`com'%25")  )
        (scatteri `outer2' , recast(area) lw(none) lc("`ncd'%25") fc("`ncd'%25")  )
        (scatteri `outer3' , recast(area) lw(none) lc("`inj'%25") fc("`inj'%25")  )
		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 
			ysize(16) xsize(12)

			xlab(none, 
			valuelabel labc(gs0) labs(2.5) notick nogrid glc(gs16) angle(45) format(%9.0f))
			xscale(noline lw(vthin)) 
			xtitle(" ", size(3) color(gs0) margin(l=1 r=1 t=1 b=1)) 
	
			ylab(0 2000 "2m" 4000 "4m" 6000 "6m" 8000 "8m" 10000 "10m",
			valuelabel labc(gs8) labs(6) tlc(gs8) nogrid glc(gs16) angle(0) format(%9.0f))
			yscale(lw(vthin) lc(gs8) range(0(1000)11000) noextend) 
			ytitle(" ", color(gs8) size(6) margin(l=1 r=1 t=1 b=1)) 

            /// Region Titles 
            text(10500 2010 "The Americas",  place(c) size(7) color(gs5))

            /// Legend Text
            text(9100   2005 "Comm.",  place(e) size(5) color(gs8))   
            text(8100   2005 "NCDs",  place(e) size(5) color(gs8))   
            text(7100   2005 "Injuries",  place(e) size(5) color(gs8))   

			/// X-Axis text
            text(-250 2001 "2000",  place(e) size(6) color(gs8))
            text(-250 2018 "2019",  place(w) size(6) color(gs8))

			legend(off size(2.5) position(9) nobox ring(0) bm(t=1 b=4 l=5 r=0) colf cols(1)
			region(fcolor(gs16)  lw(none) margin(zero)) 
			order(2 1) 
			lab(1 "xx") 
			lab(2 "xx") 		
            )
			name(deaths_panel)
			;
#delimit cr	


*/

** SECOND CHART NOW OVERLAYING CVD

** ------------------------------------------------------------
** 10 Communicable, maternal, perinatal and nutritional conditions
** 600 Noncommunicable diseases
** 1510 Injuries
** ------------------------------------------------------------
tempfile afr amr emr eur sear wpr world
** Africa (AFR)
use "`datapath'\from-who\who-ghe-deaths-001-who1", replace
    keep if ghecause==10 | ghecause==600 | ghecause==1510 | ghecause==1100
    drop if age<0 
    ** Collapse AGE ut of dataset 
    collapse (sum) dths dths_low dths_up pop, by(ghecause year who_region)
    save `afr' , replace

** Americas (AMR)
use "`datapath'\from-who\who-ghe-deaths-001-who2", replace
    keep if ghecause==10 | ghecause==600 | ghecause==1510 | ghecause==1100
    drop if age<0 
    ** Collapse AGE ut of dataset 
    collapse (sum) dths dths_low dths_up pop, by(ghecause year who_region)
    save `amr' , replace

** Eastern Mediterranean (EMR)
use "`datapath'\from-who\who-ghe-deaths-001-who3", replace
    keep if ghecause==10 | ghecause==600 | ghecause==1510 | ghecause==1100
    drop if age<0 
    ** Collapse AGE ut of dataset 
    collapse (sum) dths dths_low dths_up pop, by(ghecause year who_region)
    save `emr' , replace

** Europe (EUR)
use "`datapath'\from-who\who-ghe-deaths-001-who4", replace
    keep if ghecause==10 | ghecause==600 | ghecause==1510 | ghecause==1100
    drop if age<0 
    ** Collapse AGE ut of dataset 
    collapse (sum) dths dths_low dths_up pop, by(ghecause year who_region)
    save `eur' , replace

** South-East Asia (SEAR)
use "`datapath'\from-who\who-ghe-deaths-001-who5", replace
    keep if ghecause==10 | ghecause==600 | ghecause==1510 | ghecause==1100
    drop if age<0 
    ** Collapse AGE ut of dataset 
    collapse (sum) dths dths_low dths_up pop, by(ghecause year who_region)
    save `sear' , replace

** Western Pacific (WPR)
use "`datapath'\from-who\who-ghe-deaths-001-who6", replace
    keep if ghecause==10 | ghecause==600 | ghecause==1510 | ghecause==1100
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
replace yr1 = year if who_region==2
/// replace yr1 = year + 20 if who_region==2
/// replace yr1 = year + 40 if who_region==4
/// replace yr1 = year + 60 if who_region==1
/// replace yr1 = year + 80 if who_region==6
/// replace yr1 = year + 100 if who_region==5
order year yr1 

drop dths_low dths_up 
reshape wide dths , i(who_region year) j(ghecause) 

gen dths2000 = dths600 - dths1100
** injuries
gen zero = 0 
gen inj = dths1510 
gen cvd = dths1100 + inj
gen ncd = dths2000 + cvd 
gen com = dths10 + ncd

** generate a local for the ColorBrewer color scheme
colorpalette ptol, rainbow n(9)  nograph
local list r(p) 
** (COM --> ghecause = 10)
local com `r(p1)'
** (NCD --> ghecause = 1100)
local cvd `r(p3)'
** (NCD --> ghecause = 2000)
local ncd `r(p6)'
** (INJ --> ghecause = 1510)
local inj `r(p9)'

** Jitter men by a fraction to improve visual
/// replace yr1 = yr1 - 0.2 if sex==1 
/// replace yr1 = yr1 + 0.2 if sex==2 

** Legend outer limits for graphing 
local outer1 8800 2001 9400 2001 9400 2004 8800 2004 8800 2001 
local outer2 7800 2001 8400 2001 8400 2004 7800 2004 7800 2001 
local outer3 6800 2001 7400 2001 7400 2004 6800 2004 6800 2001 



#delimit ;
	gr twoway 
		/// Americas
        (rarea zero inj yr1 if who_region==2 , lw(none) color("`inj'%25"))
        (rarea inj cvd yr1 if  who_region==2 , lw(none) color("`cvd'%25"))
        (rarea cvd ncd yr1 if  who_region==2 , lw(none) color("`ncd'%25"))
        (rarea ncd com yr1 if  who_region==2 , lw(none) color("`com'%25"))

        /// droplines
        (function y=10000, range(2000 2020) lc(gs12) dropline(2019.5))

        /// Legend
        (scatteri `outer1' , recast(area) lw(none) lc("`com'%25") fc("`com'%25")  )
        (scatteri `outer2' , recast(area) lw(none) lc("`ncd'%25") fc("`ncd'%25")  )
        (scatteri `outer3' , recast(area) lw(none) lc("`inj'%25") fc("`inj'%25")  )
		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 
			ysize(16) xsize(12)

			xlab(none, 
			valuelabel labc(gs0) labs(2.5) notick nogrid glc(gs16) angle(45) format(%9.0f))
			xscale(noline lw(vthin)) 
			xtitle(" ", size(3) color(gs0) margin(l=1 r=1 t=1 b=1)) 
	
			ylab(0 2000 "2m" 4000 "4m" 6000 "6m" 8000 "8m" 10000 "10m",
			valuelabel labc(gs8) labs(6) tlc(gs8) nogrid glc(gs16) angle(0) format(%9.0f))
			yscale(lw(vthin) lc(gs8) range(0(1000)11000) noextend) 
			ytitle(" ", color(gs8) size(6) margin(l=1 r=1 t=1 b=1)) 

            /// Region Titles 
            text(10500 2010 "The Americas",  place(c) size(7) color(gs5))

            /// Legend Text
            text(9100   2005 "Comm.",  place(e) size(5) color(gs8))   
            text(8100   2005 "NCDs",  place(e) size(5) color(gs8))   
            text(7100   2005 "Injuries",  place(e) size(5) color(gs8))   

			/// X-Axis text
            text(-250 2001 "2000",  place(e) size(6) color(gs8))
            text(-250 2018 "2019",  place(w) size(6) color(gs8))

			legend(off size(2.5) position(9) nobox ring(0) bm(t=1 b=4 l=5 r=0) colf cols(1)
			region(fcolor(gs16)  lw(none) margin(zero)) 
			order(2 1) 
			lab(1 "xx") 
			lab(2 "xx") 		
            )
			name(deaths_panel)
			;
#delimit cr	


