** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap2-004-initial-panel.do
    //  project:				    WHO Global Health Estimates
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	26-Apr-2021
    //  algorithm task			    Preparing CVD mortality rates: Countries of the Americas

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
    log using "`logpath'\chap2-004-initial-panel", replace
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



** -------------------------------------------------------------------
** GRAPHIC
** -------------------------------------------------------------------
drop if ghecause==1 | ghecause==2 

** Creating PANEL by shifting sub-regions along the x-axis
** EMR, AMR, EUR, AFR, WPR, SEAR
gen yr1 = . 
replace yr1 = year if ghecause==3
replace yr1 = year + 21 if ghecause==4
replace yr1 = year + 42 if ghecause==5
replace yr1 = year + 63 if ghecause==6
replace yr1 = year + 84 if ghecause==7
replace yr1 = year + 105 if ghecause==8
order year yr1 

** generate a local for the ColorBrewer color scheme
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

** Legend outer limits for graphing 
local outer1 695 2013 730 2013 730 2018 695 2018 695 2013
local outer2 635 2013 670 2013 670 2018 635 2018 635 2013
local outer3 575 2013 610 2013 610 2018 575 2018 575 2013

reshape wide dths daly pop, i(year yr1 ghecause) j(sex) 

/*

#delimit ;
	gr twoway 
		/// Area between men and women for each GHE-CAUSE
	    (rarea dths1 dths2 yr1 if ghecause==3 , lw(none) color("`cvd1'%50"))
	    (rarea dths1 dths2 yr1 if ghecause==4 , lw(none) color("`can1'%50"))
	    (rarea dths1 dths2 yr1 if ghecause==5 , lw(none) color("`crd1'%50"))
	    (rarea dths1 dths2 yr1 if ghecause==6 , lw(none) color("`dia1'%50"))
	    (rarea dths1 dths2 yr1 if ghecause==7 , lw(none) color("`men1'%50"))
	    (rarea dths1 dths2 yr1 if ghecause==8 , lw(none) color("`inj1'%50"))


		/// Men (1) and Women (2) lines for each GHE-CAUSE
        (line dths1 yr1 if ghecause==3 , lw(0.2) lc("`cvd1'%75"))
		(line dths2 yr1 if ghecause==3 , lw(0.2) lc("`cvd1'%75") lp("-"))
        (line dths1 yr1 if ghecause==4 , lw(0.2) lc("`can1'%75"))
		(line dths2 yr1 if ghecause==4 , lw(0.2) lc("`can1'%75") lp("-"))     
        (line dths1 yr1 if ghecause==5 , lw(0.2) lc("`crd1'%75"))
		(line dths2 yr1 if ghecause==5 , lw(0.2) lc("`crd1'%75") lp("-"))   
        (line dths1 yr1 if ghecause==6 , lw(0.2) lc("`dia1'%75"))
		(line dths2 yr1 if ghecause==6 , lw(0.2) lc("`dia1'%75") lp("-"))   
        (line dths1 yr1 if ghecause==7 , lw(0.2) lc("`men1'%75"))
		(line dths2 yr1 if ghecause==7 , lw(0.2) lc("`men1'%75") lp("-"))   
        (line dths1 yr1 if ghecause==8 , lw(0.2) lc("`inj1'%75"))
		(line dths2 yr1 if ghecause==8 , lw(0.2) lc("`inj1'%75") lp("-"))   

        /// droplines
        (function y=1100000, range(2000 2125) lc(gs12) dropline(2020 2041 2062 2083 2104 2125))

        /// Legend
        (function y=225000, range(2001 2006) lc(gs10) lw(0.4))
        (function y=175000, range(2001 2006) lp("-") lc(gs10) lw(0.4))

		/// X-Axis lines
        (function y=-30000, range(2000 2019) lc(gs12) lw(0.2))
        (function y=-30000, range(2021 2040) lc(gs12) lw(0.2))
        (function y=-30000, range(2042 2061) lc(gs12) lw(0.2))
        (function y=-30000, range(2063 2082) lc(gs12) lw(0.2))
        (function y=-30000, range(2084 2103) lc(gs12) lw(0.2))
        (function y=-30000, range(2105 2124) lc(gs12) lw(0.2))
		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 
			ysize(7.5) xsize(15)

			xlab(none, 
			valuelabel labc(gs0) labs(2.5) notick nogrid glc(gs16) angle(45) format(%9.0f))
			xscale(noline lw(vthin) range(2000(5)2085) ) 
			xtitle(" ", size(3) color(gs0) margin(l=1 r=1 t=1 b=1)) 
			
			ylab(0 200000 "200k" 400000 "400k" 600000 "600k" 800000 "800k" 1000000 "1m" ,
			valuelabel labc(gs8) labs(2.5) tlc(gs8) nogrid glc(gs16) angle(0) format(%9.0f))
			yscale( lw(vthin) lc(gs8) noextend range(0(200000)1300000)) 
			ytitle("Deaths", color(gs8) size(3) margin(l=1 r=1 t=1 b=1)) 
            ymtick(0(100000)1100000)

            /// Region Titles 
            text(1050000 2010 "Cardiovascular" "Disease" ,  place(c) size(3) color(gs5))
            text(1050000 2031 "Cancers",  place(c) size(3) color(gs5))
            text(1050000 2053 "Chronic Respiratory" "Diseases",  place(c) size(3) color(gs5))
            text(1050000 2074 "Diabetes",  place(c) size(3) color(gs5))
            text(1050000 2095 "Mental Health /" "Neurological",  place(c) size(3) color(gs5))
            text(1050000 2116 "External" "Causes",  place(c) size(3) color(gs5))

            /// Legend Text
            text(225000 2007 "Men",  place(e) size(3) color(gs8))   
            text(175000 2007 "Women",  place(e) size(3) color(gs8))   

			/// X-Axis text
            text(0 2000 "2000",  place(e) size(2.5) color(gs8))
            text(0 2019 "2019",  place(w) size(2.5) color(gs8))
            text(0 2021 "2000",  place(e) size(2.5) color(gs8))
            text(0 2040 "2019",  place(w) size(2.5) color(gs8))
            text(0 2042 "2000",  place(e) size(2.5) color(gs8))
            text(0 2061 "2019",  place(w) size(2.5) color(gs8))
            text(0 2063 "2000",  place(e) size(2.5) color(gs8))
            text(0 2082 "2019",  place(w) size(2.5) color(gs8))
            text(0 2084 "2000",  place(e) size(2.5) color(gs8))
            text(0 2103 "2019",  place(w) size(2.5) color(gs8))
            text(0 2105 "2000",  place(e) size(2.5) color(gs8))
            text(0 2124 "2019",  place(w) size(2.5) color(gs8))

			legend(off)
			name(death_panel)
			;
#delimit cr	


*/

#delimit ;
	gr twoway 
		/// Area between men and women for each GHE-CAUSE
	    (rarea daly1 daly2 yr1 if ghecause==3 , lw(none) color("`cvd2'%50"))
	    (rarea daly1 daly2 yr1 if ghecause==4 , lw(none) color("`can2'%50"))
	    (rarea daly1 daly2 yr1 if ghecause==5 , lw(none) color("`crd2'%50"))
	    (rarea daly1 daly2 yr1 if ghecause==6 , lw(none) color("`dia2'%50"))
	    (rarea daly1 daly2 yr1 if ghecause==7 , lw(none) color("`men2'%50"))
	    (rarea daly1 daly2 yr1 if ghecause==8 , lw(none) color("`inj2'%50"))


		/// Men (1) and Women (2) lines for each GHE-CAUSE
        (line daly1 yr1 if ghecause==3 , lw(0.2) lc("`cvd2'%75"))
		(line daly2 yr1 if ghecause==3 , lw(0.2) lc("`cvd2'%75") lp("-"))
        (line daly1 yr1 if ghecause==4 , lw(0.2) lc("`can2'%75"))
		(line daly2 yr1 if ghecause==4 , lw(0.2) lc("`can2'%75") lp("-"))     
        (line daly1 yr1 if ghecause==5 , lw(0.2) lc("`crd2'%75"))
		(line daly2 yr1 if ghecause==5 , lw(0.2) lc("`crd2'%75") lp("-"))   
        (line daly1 yr1 if ghecause==6 , lw(0.2) lc("`dia2'%75"))
		(line daly2 yr1 if ghecause==6 , lw(0.2) lc("`dia2'%75") lp("-"))   
        (line daly1 yr1 if ghecause==7 , lw(0.2) lc("`men2'%75"))
		(line daly2 yr1 if ghecause==7 , lw(0.2) lc("`men2'%75") lp("-"))   
        (line daly1 yr1 if ghecause==8 , lw(0.2) lc("`inj2'%75"))
		(line daly2 yr1 if ghecause==8 , lw(0.2) lc("`inj2'%75") lp("-"))   

        /// droplines
        (function y=40000000, range(2000 2125) lc(gs12) dropline(2020 2041 2062 2083 2104 2125))

        /// Legend
        (function y=8000000, range(2001 2006) lc(gs10) lw(0.4))
        (function y=6000000, range(2001 2006) lp("-") lc(gs10) lw(0.4))

		/// X-Axis lines
        (function y=-30000, range(2000 2019) lc(gs12) lw(0.2))
        (function y=-30000, range(2021 2040) lc(gs12) lw(0.2))
        (function y=-30000, range(2042 2061) lc(gs12) lw(0.2))
        (function y=-30000, range(2063 2082) lc(gs12) lw(0.2))
        (function y=-30000, range(2084 2103) lc(gs12) lw(0.2))
        (function y=-30000, range(2105 2124) lc(gs12) lw(0.2))
		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 
			ysize(7.5) xsize(15)

			xlab(none, 
			valuelabel labc(gs0) labs(2.5) notick nogrid glc(gs16) angle(45) format(%9.0f))
			xscale(noline lw(vthin) range(2000(5)2085) ) 
			xtitle(" ", size(3) color(gs0) margin(l=1 r=1 t=1 b=1)) 
			
			ylab(0 10000000 "10m" 20000000 "20m" 30000000 "30m" 40000000 "40m" ,
			valuelabel labc(gs8) labs(2.5) tlc(gs8) nogrid glc(gs16) angle(0) format(%9.0f))
			yscale( lw(vthin) lc(gs8) noextend range(0(1000000)42000000)) 
			ytitle("Deaths", color(gs8) size(3) margin(l=1 r=1 t=1 b=1)) 
            ymtick(0(2000000)40000000, tlc(gs8))

            /// Region Titles 
            text(38000000 2010 "Cardiovascular" "Disease" ,  place(c) size(3) color(gs5))
            text(38000000 2031 "Cancers",  place(c) size(3) color(gs5))
            text(38000000 2053 "Chronic Respiratory" "Diseases",  place(c) size(3) color(gs5))
            text(38000000 2074 "Diabetes",  place(c) size(3) color(gs5))
            text(38000000 2095 "Mental Health /" "Neurological",  place(c) size(3) color(gs5))
            text(38000000 2116 "External" "Causes",  place(c) size(3) color(gs5))

            /// Legend Text
            text(8000000 2007 "Men",  place(e) size(3) color(gs8))   
            text(6000000 2007 "Women",  place(e) size(3) color(gs8))   

			/// X-Axis text
            text(1000000 2000 "2000",  place(e) size(2.5) color(gs8))
            text(1000000 2019 "2019",  place(w) size(2.5) color(gs8))
            text(1000000 2021 "2000",  place(e) size(2.5) color(gs8))
            text(1000000 2040 "2019",  place(w) size(2.5) color(gs8))
            text(1000000 2042 "2000",  place(e) size(2.5) color(gs8))
            text(1000000 2061 "2019",  place(w) size(2.5) color(gs8))
            text(1000000 2063 "2000",  place(e) size(2.5) color(gs8))
            text(1000000 2082 "2019",  place(w) size(2.5) color(gs8))
            text(1000000 2084 "2000",  place(e) size(2.5) color(gs8))
            text(1000000 2103 "2019",  place(w) size(2.5) color(gs8))
            text(1000000 2105 "2000",  place(e) size(2.5) color(gs8))
            text(1000000 2124 "2019",  place(w) size(2.5) color(gs8))

			legend(off)
			name(daly_panel)
			;
#delimit cr	
