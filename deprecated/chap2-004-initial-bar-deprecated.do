** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap2-004-initial-bar.do
    //  project:				    WHO Global Health Estimates
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	4-JUL-2021
    //  algorithm task			    Initial Bar chart for Chapter 2

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
    log using "`logpath'\chap2-004-initial-bar", replace
** HEADER -----------------------------------------------------

tempfile t1 t2 

** DEATHS. Countries.
** Append PAHO sub-regions and append WHO regions
use "`datapath'\from-who\chap2_deaths_panel", clear
append using "`datapath'\from-who\chap2_deaths_panel_both"
sort year sex ghecause region
label define sex_ 1 "men" 2 "women" 3 "both" , modify
label values sex sex_ 
save `t1', replace 

** DALY
use "`datapath'\from-who\chap2_daly_panel" , clear
append using "`datapath'\from-who\chap2_daly_panel_both"
sort year sex ghecause region
label define sex_ 1 "men" 2 "women" 3 "both" , modify
label values sex sex_ 
save `t2', replace 

** Merge the deaths datasettempfile d1 
use `t1', clear 
merge 1:1 year sex ghecause region using `t2' 
drop _merge 

** Region labelling
#delimit ; 
label define region_   
                    1 "Antigua and Barbuda"
                    2 "Argentina"
                    3 "Bahamas"
                    4 "Barbados"
                    5 "Bolivia"
                    6 "Brazil"
                    7 "Belize"
                    8 "Canada"
                    9 "Chile"
                    10 "Colombia"
                    11 "Costa Rica"
                    12 "Cuba"
                    13 "Dominican Republic"
                    14 "Ecuador"
                    15 "El Salvador"
                    16 "Grenada"
                    17 "Guatemala"
                    18 "Guyana"
                    19 "Haiti"
                    20 "Honduras"
                    21 "Jamaica"
                    22 "Mexico"
                    23 "Nicaragua"
                    24 "Panama"
                    25 "Paraguay"
                    26 "Peru"
                    27 "Saint Lucia"
                    28 "Saint Vincent and the Grenadines"
                    29 "Suriname"
                    30 "Trinidad and Tobago"
                    31 "United States"
                    32 "Uruguay"
                    33 "Venezuela"
                    
                    100 "north america"
                    200 "southern cone"
                    300 "central america"
                    400 "andean" 
                    500 "latin caribbean"
                    600 "non-latin caribbean"
                    700 "brazil"
                    800 "mexico"

                    1000 "africa"
                    2000 "americas"
                    3000 "eastern mediterranean"
                    4000 "europe" 
                    5000 "south-east asia"
                    6000 "western pacific", modify;                      
#delimit cr 
label values region region_ 

** Save the JOINED Mortality Rate file
label data "Deaths and DALYs: Countries, PAHO sub-regions, WHO regions"
save "`datapath'\from-who\chap2_initial_panel", replace

** Restrict to Entire region of the Americas
keep if region==2000
drop iso3c iso3n who_region paho_subregion region
format dths %12.01fc
format daly %15.01fc
order ghecause sex year pop dths daly 
sort ghecause sex year

** Percentage of All-cause due to NCDs + Injuries
preserve 
    keep if sex==3
    drop pop sex
    keep if ghecause==1 | ghecause==2 | ghecause==8
    reshape wide dths daly , i(year) j(ghecause)
    gen dths_perc = ( (dths2 + dths8)/dths1) * 100
    gen daly_perc = ( (daly2 + daly8)/daly1) * 100
    tabdisp year, cellvar(dths_perc) format(%9.1f)
    tabdisp year, cellvar(daly_perc) format(%9.1f)
restore
** Change between 2000 and 2019 
preserve 
    keep if year==2000 | year==2019
    keep if sex==3
    drop pop 
    reshape wide dths daly , i(ghecause) j(year)
    gen dths_perc = ( (dths2019 - dths2000)/dths2000) * 100
    gen daly_perc = ( (daly2019 - daly2000)/daly2000) * 100
    tabdisp ghecause if ghecause>2, cellvar(dths_perc) format(%9.1f)
    tabdisp ghecause if ghecause>2, cellvar(daly_perc) format(%9.1f)
restore
** Change between 2000 and 2019  
preserve
    keep if year==2000 | year==2019
    keep if sex==3
    drop pop 
    gen ghe = 1 if ghecause==1
    replace ghe = 2 if ghecause>1 
    reshape wide dths daly , i(year ghecause) j(ghe)
    bysort year: egen all_dths = min(dths1) 
    bysort year: egen all_daly = min(daly1) 
    drop dths1 daly1
    format all_dths all_daly %15.0fc 
    rename dths2 dths 
    rename daly2 daly
    gen dp = (dths/all_dths) * 100
    gen dalyp = (daly/all_daly) * 100
    sort ghecause year 
    tabdisp ghecause if year==2019 , cellvar(dp) format(%9.1f)
    tabdisp ghecause if year==2019 , cellvar(dalyp) format(%9.1f)
restore

** DALY numbers in 2019 by GHECAUSE
preserve
    keep if year==2019 & sex==3
    egen all = max(daly) 
    format all %16.1fc
    **drop if ghecause<=2
    gsort -daly
    gen idaly = _n
    gsort -dths
    gen idths = _n
    sort idaly
    gen daly_perc = (daly/all) * 100
restore

** DALY numbers in 2019 by GHECAUSE - sex specific
preserve
    keep if year==2019 & sex<3
    drop year pop
    reshape wide dths daly, i(ghecause) j(sex)
    egen all_daly1 = max(daly1) 
    egen all_dths1 = max(dths1)
    egen all_daly2 = max(daly2) 
    egen all_dths2 = max(dths2)
    drop if ghecause<=2

    gsort -daly1
    gen idaly1 = _n
    gsort -dths1
    gen idths1 = _n
    gsort -daly2
    gen idaly2 = _n
    gsort -dths2
    gen idths2 = _n

    gen daly1_perc = (daly1/all_daly1) * 100
    gen daly2_perc = (daly2/all_daly2) * 100
    gen dths1_perc = (dths1/all_dths1) * 100
    gen dths2_perc = (dths2/all_dths2) * 100
    order ghecause idaly1 daly1_perc idaly2 daly2_perc idths1 dths1_perc idths2 dths2_perc
restore

** Change between 2000 and 2019 
/*preserve 
    keep if year==2000 | year==2019
    keep if sex==3
    keep if ghecause>2
    drop pop 
    bysort year : egen dth_sum = sum(dths) 
    bysort year : egen daly_sum = sum(daly) 
    format dth_sum %15.1fc
    format daly_sum %15.1fc
    gen p_dths = (dths/dth_sum) * 100
    gen p_daly = (daly/daly_sum) * 100
    sort ghecause year

    reshape wide dths daly , i(ghecause) j(year)
    gen dths_perc = ( (dths2019 - dths2000)/dths2000) * 100
    gen daly_perc = ( (daly2019 - daly2000)/daly2000) * 100
    tabdisp ghecause if ghecause>2, cellvar(dths_perc) format(%9.1f)
    tabdisp ghecause if ghecause>2, cellvar(daly_perc) format(%9.1f)
restore
*/


** -------------------------------------------------------------------
** GRAPHIC
** -------------------------------------------------------------------

** Drop All-Cause and All-NCDs 
drop if ghecause==1 | ghecause==2 
drop if sex==3

** Creating PANELS by shifting CoD causes along the Y-AXIS
** CVD              (GHECAUSE = 3)
** Cancer           (GHECAUSE = 4)
** CRD              (GHECAUSE = 5)
** Diabetes         (GHECAUSE = 6)
** Mental Health    (GHECAUSE = 7)
** external Causes  (GHECAUSE = 8)
gen yr = . 
replace yr = year      if ghecause==3 & sex==1
replace yr = year + 21 if ghecause==3 & sex==2
replace yr = year + 45 if ghecause==4 & sex==1
replace yr = year + 66 if ghecause==4 & sex==2
replace yr = year +  90 if ghecause==5 & sex==1
replace yr = year + 111 if ghecause==5 & sex==2
replace yr = year + 135 if ghecause==6 & sex==1
replace yr = year + 156 if ghecause==6 & sex==2
replace yr = year + 180 if ghecause==7 & sex==1
replace yr = year + 201 if ghecause==7 & sex==2
replace yr = year + 225 if ghecause==8 & sex==1
replace yr = year + 246 if ghecause==8 & sex==2
order year yr

** generate -locals- from the d3 qualitative-paired color scheme
colorpalette d3, 20 n(20) nograph
local list r(p) 
** CVD
local cvd1 `r(p9)'
local cvd2 `r(p10)'
** Cancer 
local can1 `r(p1)'
local can2 `r(p2)'
** CRD
local crd1 `r(p5)'
local crd2 `r(p6)'
** Diabetes
local dia1 `r(p17)'
local dia2 `r(p18)'
** Mental Health
local men1 `r(p3)'
local men2 `r(p4)'
** External causes
local inj1 `r(p7)'
local inj2 `r(p8)'

** Jitter men and women by a horizontal fraction to improve visual
** replace yr1 = yr1 - 3 if sex==1 
** replace yr1 = yr1 + 3 if sex==2 

** Legend outer boundaries 
local outer1 695 2013 730 2013 730 2018 695 2018 695 2013
local outer2 635 2013 670 2013 670 2018 635 2018 635 2013
local outer3 575 2013 610 2013 610 2018 575 2018 575 2013

** DEATHS will be NEGATIVE ON X-AXIS to give the chart
** a 'population-pyramid' style
replace dths = dths * (-1) 

** Reshape to wide by sex 
** This we need to allow the egenration of horizontal area charts
** reshape wide dths daly pop yr, i(year ghecause) j(sex) 

** Each chart runs from zero to the death or DALY value
** In actual fact, these zeros are above/below true zero
** TO allow panel headings to be uincluded in the middle of the chart
gen dth_zero = -50000
gen daly_zero = 50000

gen daly2 = daly/10 

** Our boundary points
local outer1 2223 -1750000 2267 -1750000 2267 3700000 2223 3700000 2223 -1750000 
local outer2a 2178 -1750000 2222 -1750000  
local outer2b 2178 -1750000 2178 3700000  
local outer2c 2222 3700000 2178 3700000 
local outer3a 2133 -1750000 2177 -1750000  
local outer3b 2133 -1750000 2133 3700000  
local outer3c 2177 3700000 2133 3700000 
local outer4a 2088 -1750000 2132 -1750000  
local outer4b 2088 -1750000 2088 3700000  
local outer4c 2132 3700000 2088 3700000 
local outer5a 2043 -1750000 2087 -1750000  
local outer5b 2043 -1750000 2043 3700000  
local outer5c 2087 3700000 2043 3700000 
local outer6a 1998 -1750000 2042 -1750000  
local outer6b 1998 -1750000 1998 3700000  
local outer6c 2042 3700000 1998 3700000 

local yaxis 2003 490000 2016 490000 

#delimit ;
	gr twoway 


		/// Shaded bars for each Cause of Death
	    /// CVD 
        (rarea dth_zero dths yr     if ghecause==3 & sex==1, horizontal lw(none) color("`cvd1'%50"))
	    (rarea dth_zero dths yr     if ghecause==3 & sex==2, horizontal lw(none) color("`cvd1'%50"))
        (rarea daly_zero daly2 yr   if ghecause==3 & sex==1, horizontal lw(none) color("`cvd2'%50"))
	    (rarea daly_zero daly2 yr   if ghecause==3 & sex==2, horizontal lw(none) color("`cvd2'%50"))
	    /// Cancer 
        (rarea dth_zero dths yr     if ghecause==4 & sex==1, horizontal lw(none) color("`can1'%50"))
	    (rarea dth_zero dths yr     if ghecause==4 & sex==2, horizontal lw(none) color("`can1'%50"))
        (rarea daly_zero daly2 yr   if ghecause==4 & sex==1, horizontal lw(none) color("`can2'%50"))
	    (rarea daly_zero daly2 yr   if ghecause==4 & sex==2, horizontal lw(none) color("`can2'%50"))
	    /// CRD 
        (rarea dth_zero dths yr     if ghecause==5 & sex==1, horizontal lw(none) color("`crd1'%50"))
	    (rarea dth_zero dths yr     if ghecause==5 & sex==2, horizontal lw(none) color("`crd1'%50"))
        (rarea daly_zero daly2 yr   if ghecause==5 & sex==1, horizontal lw(none) color("`crd2'%50"))
	    (rarea daly_zero daly2 yr   if ghecause==5 & sex==2, horizontal lw(none) color("`crd2'%50"))
	    /// Diabetes 
        (rarea dth_zero dths yr     if ghecause==6 & sex==1, horizontal lw(none) color("`dia1'%50"))
	    (rarea dth_zero dths yr     if ghecause==6 & sex==2, horizontal lw(none) color("`dia1'%50"))
        (rarea daly_zero daly2 yr   if ghecause==6 & sex==1, horizontal lw(none) color("`dia2'%50"))
	    (rarea daly_zero daly2 yr   if ghecause==6 & sex==2, horizontal lw(none) color("`dia2'%50"))
	    /// Mental Health
        (rarea dth_zero dths yr     if ghecause==7 & sex==1, horizontal lw(none) color("`men1'%50"))
	    (rarea dth_zero dths yr     if ghecause==7 & sex==2, horizontal lw(none) color("`men1'%50"))
        (rarea daly_zero daly2 yr   if ghecause==7 & sex==1, horizontal lw(none) color("`men2'%50"))
	    (rarea daly_zero daly2 yr   if ghecause==7 & sex==2, horizontal lw(none) color("`men2'%50"))
	    /// External Causes
        (rarea dth_zero dths yr     if ghecause==8 & sex==1, horizontal lw(none) color("`inj1'%50"))
	    (rarea dth_zero dths yr     if ghecause==8 & sex==2, horizontal lw(none) color("`inj1'%50"))
        (rarea daly_zero daly2 yr   if ghecause==8 & sex==1, horizontal lw(none) color("`inj2'%50"))
	    (rarea daly_zero daly2 yr   if ghecause==8 & sex==2, horizontal lw(none) color("`inj2'%50"))

		/// Men (1) and Women (2) lines for each GHE-CAUSE
        (line yr dths if ghecause==3 & sex==1,  lw(0.25) lc("`cvd1'%75"))
		(line yr dths if ghecause==3 & sex==2 , lw(0.25) lc("`cvd1'%75") lp("-"))
        (line yr dths if ghecause==4 & sex==1,  lw(0.25) lc("`can1'%75"))
		(line yr dths if ghecause==4 & sex==2 , lw(0.25) lc("`can1'%75") lp("-"))
        (line yr dths if ghecause==5 & sex==1,  lw(0.25) lc("`crd1'%75"))
		(line yr dths if ghecause==5 & sex==2 , lw(0.25) lc("`crd1'%75") lp("-"))
        (line yr dths if ghecause==6 & sex==1,  lw(0.25) lc("`dia1'%75"))
		(line yr dths if ghecause==6 & sex==2 , lw(0.25) lc("`dia1'%75") lp("-"))
        (line yr dths if ghecause==7 & sex==1,  lw(0.25) lc("`men1'%75"))
		(line yr dths if ghecause==7 & sex==2 , lw(0.25) lc("`men1'%75") lp("-"))
        (line yr dths if ghecause==8 & sex==1,  lw(0.25) lc("`inj1'%75"))
		(line yr dths if ghecause==8 & sex==2 , lw(0.25) lc("`inj1'%75") lp("-"))

        (line yr daly2 if ghecause==3 & sex==1,  lw(0.25) lc("`cvd2'%75"))
		(line yr daly2 if ghecause==3 & sex==2 , lw(0.25) lc("`cvd2'%75") lp("-"))
        (line yr daly2 if ghecause==4 & sex==1,  lw(0.25) lc("`can2'%75"))
		(line yr daly2 if ghecause==4 & sex==2 , lw(0.25) lc("`can2'%75") lp("-"))
        (line yr daly2 if ghecause==5 & sex==1,  lw(0.25) lc("`crd2'%75"))
		(line yr daly2 if ghecause==5 & sex==2 , lw(0.25) lc("`crd2'%75") lp("-"))
        (line yr daly2 if ghecause==6 & sex==1,  lw(0.25) lc("`dia2'%75"))
		(line yr daly2 if ghecause==6 & sex==2 , lw(0.25) lc("`dia2'%75") lp("-"))
        (line yr daly2 if ghecause==7 & sex==1,  lw(0.25) lc("`men2'%75"))
		(line yr daly2 if ghecause==7 & sex==2 , lw(0.25) lc("`men2'%75") lp("-"))
        (line yr daly2 if ghecause==8 & sex==1,  lw(0.25) lc("`inj2'%75"))
		(line yr daly2 if ghecause==8 & sex==2 , lw(0.25) lc("`inj2'%75") lp("-"))

        /// PANEL Borders
        (scatteri `outer1' , recast(area) lw(0.1) lc(gs10) fc(none) )
        (scatteri `outer2a' , recast(line) lw(0.1) lc(gs10) fc(none) )
        (scatteri `outer2b' , recast(line) lw(0.1) lc(gs10) fc(none) )
        (scatteri `outer2c' , recast(line) lw(0.1) lc(gs10) fc(none) )
        (scatteri `outer3a' , recast(line) lw(0.1) lc(gs10) fc(none) )
        (scatteri `outer3b' , recast(line) lw(0.1) lc(gs10) fc(none) )
        (scatteri `outer3c' , recast(line) lw(0.1) lc(gs10) fc(none) )
        (scatteri `outer4a' , recast(line) lw(0.1) lc(gs10) fc(none) )
        (scatteri `outer4b' , recast(line) lw(0.1) lc(gs10) fc(none) )
        (scatteri `outer4c' , recast(line) lw(0.1) lc(gs10) fc(none) )
        (scatteri `outer5a' , recast(line) lw(0.1) lc(gs10) fc(none) )
        (scatteri `outer5b' , recast(line) lw(0.1) lc(gs10) fc(none) )
        (scatteri `outer5c' , recast(line) lw(0.1) lc(gs10) fc(none) )
        (scatteri `outer6a' , recast(line) lw(0.1) lc(gs10) fc(none) )
        (scatteri `outer6b' , recast(line) lw(0.1) lc(gs10) fc(none) )
        (scatteri `outer6c' , recast(line) lw(0.1) lc(gs10) fc(none) )   

        /// Y-Axis text
        (scatteri `yaxis' , recast(line) lw(0.4) lc("`cvd1'") fc(none) )   
        (scatteri `yaxis' ,              mc("`cvd1'") msize(0.75))   
		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 
			ysize(16) xsize(14)

			xlab(-1000000 "1m" -500000 "500k" 1000000 "10m" 2000000 "20m" 3000000 "30m" , 
			valuelabel labc(gs0) labs(2.5) notick nogrid glc(gs16) angle(0) format(%9.0f))
			xscale(noline lw(vthin) range(-1100000(100000)1000000) ) 
			xtitle(" ", size(3) color(gs0) margin(l=0 r=0 t=0 b=0)) 
            xmtick(-1000000 -500000 1000000 2000000 3000000, tlc(gs10))
			
			ylab(none ,
			valuelabel labc(gs8) labs(2.5) tlc(gs8) notick nogrid glc(gs16) angle(0) format(%9.0f))
			yscale(noline reverse lw(none) lc(gs16) noextend range(1985(10)2265)) 
			ytitle("", color(gs8) size(3) margin(l=1 r=1 t=1 b=1)) 

            /// Region Titles 
           text(2020 3500000 "Cardiovascular" "Disease"         ,  place(w) size(2.5) color(gs8) just(right))
           text(2065 3500000 "Cancers"                          ,  place(w) size(2.5) color(gs8) just(right))
           text(2110 3500000 "Chronic Respiratory" "Diseases"   ,  place(w) size(2.5) color(gs8) just(right))
           text(2155 3500000 "Diabetes"                         ,  place(w) size(2.5) color(gs8) just(right))
           text(2200 3500000 "Mental Health /" "Neurological"   ,  place(w) size(2.5) color(gs8) just(right))
           text(2245 3500000 "External" "Causes"                ,  place(w) size(2.5) color(gs8) just(right))

            /// Gender text 
           text(2010 -1700000 "Men"    ,  place(e) size(2.5) color(gs8) just(right))
           text(2030 -1700000 "Women"  ,  place(e) size(2.5) color(gs8) just(right))
           text(2055 -1700000 "Men"    ,  place(e) size(2.5) color(gs8) just(right))
           text(2075 -1700000 "Women"  ,  place(e) size(2.5) color(gs8) just(right))
           text(2100 -1700000 "Men"    ,  place(e) size(2.5) color(gs8) just(right))
           text(2120 -1700000 "Women"  ,  place(e) size(2.5) color(gs8) just(right))
           text(2145 -1700000 "Men"    ,  place(e) size(2.5) color(gs8) just(right))
           text(2165 -1700000 "Women"  ,  place(e) size(2.5) color(gs8) just(right))
           text(2190 -1700000 "Men"    ,  place(e) size(2.5) color(gs8) just(right))
           text(2210 -1700000 "Women"  ,  place(e) size(2.5) color(gs8) just(right))
           text(2235 -1700000 "Men"    ,  place(e) size(2.5) color(gs8) just(right))
           text(2255 -1700000 "Women"  ,  place(e) size(2.5) color(gs8) just(right))

            /// Legend Text
            text(1992 -1000000 "Deaths",  place(e) size(3.3) color(gs8))   
            text(1992  1000000 "DALYs",  place(w) size(3.3) color(gs8))   

			/// Y-Axis text
            text(2004 100000 "2000",  place(e) size(2.5) color(`cvd1'))
            text(2015 560000 "2019",  place(e) size(2.5) color(`cvd1'))

			legend(off)
			name(chap2_intro)
			;
#delimit cr	


/*

                    2145 "men"  
                    2165 "women" 
                    2190 "men"  
                    2210 "women" 
                    2235 "men"  
                    2255 "women"

