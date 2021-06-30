** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			        p003-equiplot.do
    //  project:				        WHO Global Health Estimates
    //  analysts:				        Ian HAMBLETON
    // 	date last modified	            4-April-2021
    //  algorithm task			        Equiplot example

    ** General algorithm set-up
    version 16
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
    log using "`logpath'\p003-equiplot", replace
** HEADER -----------------------------------------------------

** UN deaths equiplot example
use "`datapath'\from-who\who-ghe-deaths-001-who2", clear
keep if year==2000 | year==2019 
keep if ghecause==10
drop if age < 0 
drop ghecause dths_low dths_up un_region who_region
collapse (sum) dths pop, by(year iso3c paho_subregion)
**! Crude rate (DO NOT USE IN FINAL ANALYSES)
gen mr_crude = (dths/pop)*100000
**reshape wide dths pop mr_crude, i(iso3c) j(year)

** ISO3c
sort iso3c 
gen id = _n 

** Year 
gen ycode=.
replace ycode = 1 if year==2000
replace ycode = 2 if year==2019 

** Median (IQR) mortality rate in each year
sum mr_crude if year==2000, detail 
local p50_2000 = r(p50)
local p25_2000 = r(p25)
local p75_2000 = r(p75)
local max_2000 = r(max)
sum mr_crude if year==2019, detail 
local p50_2019 = r(p50)
local p25_2019 = r(p25)
local p75_2019 = r(p75)
local max_2019 = r(max)

** Outer boxes
local outer1 0 0.5 500 0.5 500 1.5 0 1.5  0 0.5 
local outer2 0 1.5 500 1.5 500 2.5 0 2.5  0 1.5 

** 25th to 75th percentile boxes 
** 2000 and 2019
local iqr1 `p25_2000' 0.5 `p75_2000' 0.5 `p75_2000' 1.5 `p25_2000' 1.5  `p25_2000' 0.5 
local iqr2 `p25_2019' 1.5 `p75_2019' 1.5 `p75_2019' 2.5 `p25_2019' 2.5  `p25_2019' 1.5 

#delimit ;
	gr twoway 
		/// outer boxes 
        (scatteri `outer1' , recast(area) lw(0.2) lc(gs10) fc(none)  )
        /// 25th to 75th percentiles
        (scatteri `iqr1' , recast(area) color("orange*0.4")  )
        (scatteri `iqr2' , recast(area) color("orange*0.4")  )
		/// median values
        (function y=`p50_2000' if year==2000, range(0.5 1.5) lc(gs5))
		(function y=`p50_2019' if year==2019, range(1.5 2.5) lc(gs5))
		/// outer boxes 
        (scatteri `outer1' , recast(area) lw(0.2) lc(gs10) fc(none)  )
        (scatteri `outer2' , recast(area) lw(0.2) lc(gs10) fc(none)  )
		/// country values
        (sc mr_crude ycode if year==2000 , msize(7) m(oh) mlc(orange) mlw(0.2))
		(sc mr_crude ycode if year==2019 , msize(7) m(oh) mlc(orange) mlw(0.2))
		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			ysize(15) xsize(9)

			xlab(1 "2000" 2 "2019" , notick labs(7) tlc(gs0) labc(gs0) notick nogrid glc(gs16))
			xscale(noline range(0.5(0.5)2.5)) 
			xtitle(" ", size(5) color(gs0) margin(l=2 r=2 t=5 b=2)) 
			
			ylab(0(100)500,
			valuelabel labc(gs0) labs(6) tstyle(major_notick) nogrid glc(gs16) angle(0) format(%9.0f))
			yscale(noline lw(vthin) range(0(50)500)) 
			ytitle("", size(5) margin(l=2 r=5 t=2 b=2)) 

            title("Communicable Disease: Americas", size(5) color(gs10) position(11))
            subtitle("Mortality rate per 100,000", size(3.5) color(gs10) position(11))

			legend(off size(5) position(11) ring(1) bm(t=1 b=4 l=5 r=0) colf cols(2)
			region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2)) 
			order(2 3) 
			lab(2 "Questionnaire") 
			lab(3 "Objective") 		
			)
			name(eq1)
			;
#delimit cr	
gr export "X:\OneDrive - The University of the West Indies\repo_ianhambleton\repo_w003\example_graphics\equiplot1.jpg", replace

