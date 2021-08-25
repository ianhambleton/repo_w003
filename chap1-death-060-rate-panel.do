** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap1-death-060-rate-panel.do
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
    log using "`logpath'\chap1-death-060-rate-panel", replace
** HEADER -----------------------------------------------------

** Use MR datasets
use "`datapath'\from-who\chap1_mortrate_001", clear
append using "`datapath'\from-who\chap1_mortrate_002"

** Rates per 100,000
replace crate = crate * 100000
replace arate = arate * 100000
replace aupp = aupp * 100000
replace alow = alow * 100000
format pop %15.0fc

** -------------------------------------------------------------------
** GRAPHIC
** -------------------------------------------------------------------

** Creating PANEL by shifting sub-regions along the x-axis
gen yr1 = . 
replace yr1 = year if region==1
replace yr1 = year + 21 if region==2
replace yr1 = year + 42 if region==3
replace yr1 = year + 63 if region==4
replace yr1 = year + 84 if region==5
replace yr1 = year + 105 if region==6
replace yr1 = year + 126 if region==7
replace yr1 = year + 147 if region==8
order year yr1 

** generate a local for the ColorBrewer color scheme
colorpalette ptol, rainbow n(9)  nograph
local list r(p) 
** (COM --> ghecause = 10)
local com `r(p3)'
** (NCD --> ghecause = 600)
local ncd `r(p6)'
** (INJ --> ghecause = 1510)
local inj `r(p9)'

** Jitter men and woemn by a horizontal fraction to improve visual
replace yr1 = yr1 - 0.2 if ghecause==10 
replace yr1 = yr1 + 0.2 if ghecause==20 
replace yr1 = yr1 + 0.4 if ghecause==30 

** Legend outer limits for graphing 
local outer1 695 2013 730 2013 730 2018 695 2018 695 2013
local outer2 635 2013 670 2013 670 2018 635 2018 635 2013
local outer3 575 2013 610 2013 610 2018 575 2018 575 2013

reshape wide crate arate alow aupp ase pop, i(year yr1 ghecause region) j(sex) 

** Associated stats for text
** NCDs in 2000 and 2019, women and men separately
preserve
	keep if year==2000 | year==2019
	keep region ghecause year arate1 arate2 
	order region ghecause year arate1 arate2 
	sort region ghecause year  
	keep if region<100  | region==200
	sort ghecause year arate2
	gen diff = arate1 - arate2 
	gen ratio = ( (arate1-arate2) / arate1) * 100
	keep if year==2019
	gsort ghecause -diff 
restore

** STATISTICS FOR ACCOMPANYING TEXT 
** subregional differences, women and men combined
** Want % fall between 2000 and 2019 for each subregion (NCDs)
preserve
use "`datapath'\from-who\chap1_mortrate_001_both", clear
	keep if year==2000 | year==2019
	keep region ghecause year arate
	order region ghecause year arate
	sort region ghecause year 
	replace arate = arate * 100000
	reshape wide arate , i(region ghecause) j(year)
	gen diff = ((arate2000 - arate2019)/arate2000) * 100
	gsort ghecause -diff
	gsort ghecause arate2019
restore

** Regional differences, women and men combined
** Difference between causes in 2019
preserve
use "`datapath'\from-who\chap1_mortrate_002_both", clear
	keep if year==2019
	keep region ghecause year arate
	order region ghecause year arate
	sort region ghecause year 
	replace arate = arate * 100000
	reshape wide arate , i(region year) j(ghecause)
	** 20-NCD   10-COM    30-INJ
	gen diff10 = arate20/arate10
	gen diff30 = arate20/arate30
restore

** Regional differences, women and men combined
** Want % fall between 2000 and 2019 for each subregion (NCDs)
preserve
use "`datapath'\from-who\chap1_mortrate_002_both", clear
	keep if year==2000 | year==2019
	keep region ghecause year arate
	order region ghecause year arate
	sort region ghecause year 
	replace arate = arate * 100000
	reshape wide arate , i(region ghecause) j(year)
	** 20-NCD   10-COM    30-INJ
	gen diff = arate2000 - arate2019 
	gen perc = (diff/arate2000) * 100 
restore

** Turn Latin Caribbean 2010 injury rate into plottable value for visual
replace arate1 = 700 if region==5 & ghecause==30 & year==2010 & arate1>600
replace arate2 = 300 if region==5 & ghecause==30 & year==2010 & arate2>600


#delimit ;
	gr twoway 
		/// North America
	    (rarea arate1 arate2 yr1 if ghecause==10 & region==1 , lw(none) color("`com'%15"))
	    (rarea arate1 arate2 yr1 if ghecause==20 & region==1 , lw(none) color("`ncd'%15"))
	    (rarea arate1 arate2 yr1 if ghecause==30 & region==1 , lw(none) color("`inj'%15"))
		/// Southern Cone
	    (rarea arate1 arate2 yr1 if ghecause==10 & region==2 , lw(none) color("`com'%15"))
	    (rarea arate1 arate2 yr1 if ghecause==20 & region==2 , lw(none) color("`ncd'%15"))
	    (rarea arate1 arate2 yr1 if ghecause==30 & region==2 , lw(none) color("`inj'%15"))
		/// Central America
	    (rarea arate1 arate2 yr1 if ghecause==10 & region==3 , lw(none) color("`com'%15"))
	    (rarea arate1 arate2 yr1 if ghecause==20 & region==3 , lw(none) color("`ncd'%15"))
	    (rarea arate1 arate2 yr1 if ghecause==30 & region==3 , lw(none) color("`inj'%15"))
		/// Andean
	    (rarea arate1 arate2 yr1 if ghecause==10 & region==4 , lw(none) color("`com'%15"))
	    (rarea arate1 arate2 yr1 if ghecause==20 & region==4 , lw(none) color("`ncd'%15"))
	    (rarea arate1 arate2 yr1 if ghecause==30 & region==4 , lw(none) color("`inj'%15"))
		/// Latin Caribbean
	    (rarea arate1 arate2 yr1 if ghecause==10 & region==5 , lw(none) color("`com'%15"))
	    (rarea arate1 arate2 yr1 if ghecause==20 & region==5 , lw(none) color("`ncd'%15"))
	    /// HIGH RATE due to Haiti earthquake in 2010
		(rarea arate1 arate2 yr1 if ghecause==30 & region==5 & year>=2009 & year<=2011, lw(none) color("`inj'%5"))
	    (rarea arate1 arate2 yr1 if ghecause==30 & region==5 & year<2010,  lw(none) color("`inj'%15"))
	    (rarea arate1 arate2 yr1 if ghecause==30 & region==5 & year>2010,  lw(none) color("`inj'%15"))

		/// non-Latin Caribbean
	    (rarea arate1 arate2 yr1 if ghecause==10 & region==6 , lw(none) color("`com'%15"))
	    (rarea arate1 arate2 yr1 if ghecause==20 & region==6 , lw(none) color("`ncd'%15"))
	    (rarea arate1 arate2 yr1 if ghecause==30 & region==6 , lw(none) color("`inj'%15"))
		/// Brazil
	    (rarea arate1 arate2 yr1 if ghecause==10 & region==7 , lw(none) color("`com'%15"))
	    (rarea arate1 arate2 yr1 if ghecause==20 & region==7 , lw(none) color("`ncd'%15"))
	    (rarea arate1 arate2 yr1 if ghecause==30 & region==7 , lw(none) color("`inj'%15"))
		/// Mexico
	    (rarea arate1 arate2 yr1 if ghecause==10 & region==8 , lw(none) color("`com'%15"))
	    (rarea arate1 arate2 yr1 if ghecause==20 & region==8 , lw(none) color("`ncd'%15"))
	    (rarea arate1 arate2 yr1 if ghecause==30 & region==8 , lw(none) color("`inj'%15"))

		/// MEN (1). COM. NORTH AMERICA.
        (line arate1 yr1 if ghecause==10 & region==1  , lw(0.2) lc("`com'%40"))
		(line arate1 yr1 if ghecause==20 & region==1  , lw(0.2) lc("`ncd'%40"))
		(line arate1 yr1 if ghecause==30 & region==1  , lw(0.2) lc("`inj'%40"))
		(line arate2 yr1 if ghecause==10 & region==1  , lw(0.2) lc("`com'%40") lp("-"))
		(line arate2 yr1 if ghecause==20 & region==1  , lw(0.2) lc("`ncd'%40") lp("-"))
		(line arate2 yr1 if ghecause==30 & region==1  , lw(0.2) lc("`inj'%40") lp("-"))

		/// MEN (1). COM. SOUTHERN CONE
		(line arate1 yr1 if ghecause==10 & region==2  , lw(0.2) lc("`com'%40"))
		(line arate1 yr1 if ghecause==20 & region==2  , lw(0.2) lc("`ncd'%40"))
		(line arate1 yr1 if ghecause==30 & region==2  , lw(0.2) lc("`inj'%40"))
		(line arate2 yr1 if ghecause==10 & region==2  , lw(0.2) lc("`com'%40") lp("-"))
		(line arate2 yr1 if ghecause==20 & region==2  , lw(0.2) lc("`ncd'%40") lp("-"))
		(line arate2 yr1 if ghecause==30 & region==2  , lw(0.2) lc("`inj'%40") lp("-"))

		/// MEN (1). COM. CENTRAL AMERICA.
		(line arate1 yr1 if ghecause==10 & region==3  , lw(0.2) lc("`com'%40"))
		(line arate1 yr1 if ghecause==20 & region==3  , lw(0.2) lc("`ncd'%40"))
		(line arate1 yr1 if ghecause==30 & region==3  , lw(0.2) lc("`inj'%40"))
		(line arate2 yr1 if ghecause==10 & region==3  , lw(0.2) lc("`com'%40") lp("-"))
		(line arate2 yr1 if ghecause==20 & region==3  , lw(0.2) lc("`ncd'%40") lp("-"))
		(line arate2 yr1 if ghecause==30 & region==3  , lw(0.2) lc("`inj'%40") lp("-"))

		/// MEN (1). COM. ANDEAN
		(line arate1 yr1 if ghecause==10 & region==4  , lw(0.2) lc("`com'%40"))
		(line arate1 yr1 if ghecause==20 & region==4  , lw(0.2) lc("`ncd'%40"))
		(line arate1 yr1 if ghecause==30 & region==4  , lw(0.2) lc("`inj'%40"))
		(line arate2 yr1 if ghecause==10 & region==4  , lw(0.2) lc("`com'%40") lp("-"))
		(line arate2 yr1 if ghecause==20 & region==4  , lw(0.2) lc("`ncd'%40") lp("-"))
		(line arate2 yr1 if ghecause==30 & region==4  , lw(0.2) lc("`inj'%40") lp("-"))
        
		/// MEN (1). COM. LATIN CARIBBEAN
		(line arate1 yr1 if ghecause==10 & region==5                , lw(0.2) lc("`com'%40"))
		(line arate1 yr1 if ghecause==20 & region==5                , lw(0.2) lc("`ncd'%40"))
		(line arate1 yr1 if ghecause==30 & region==5 & year>=2009 & year<=2011   , lw(0.2) lc("`inj'%10"))
		(line arate1 yr1 if ghecause==30 & region==5 & year<2010    , lw(0.2) lc("`inj'%40"))
		(line arate1 yr1 if ghecause==30 & region==5 & year>2010    , lw(0.2) lc("`inj'%40"))
		(line arate2 yr1 if ghecause==10 & region==5                , lw(0.2) lc("`com'%40") lp("-"))
		(line arate2 yr1 if ghecause==20 & region==5                , lw(0.2) lc("`ncd'%40") lp("-"))
		(line arate2 yr1 if ghecause==30 & region==5 & year>=2009 & year<=2011   , lw(0.2) lc("`inj'%10"))
		(line arate2 yr1 if ghecause==30 & region==5 & year<2010    , lw(0.2) lc("`inj'%40"))
		(line arate2 yr1 if ghecause==30 & region==5 & year>2010    , lw(0.2) lc("`inj'%40"))

		/// MEN (1). COM. NON_LATIN CARIBBEAN.
		(line arate1 yr1 if ghecause==10 & region==6  , lw(0.2) lc("`com'%40"))
		(line arate1 yr1 if ghecause==20 & region==6  , lw(0.2) lc("`ncd'%40"))
		(line arate1 yr1 if ghecause==30 & region==6  , lw(0.2) lc("`inj'%40"))
		(line arate2 yr1 if ghecause==10 & region==6  , lw(0.2) lc("`com'%40") lp("-"))
		(line arate2 yr1 if ghecause==20 & region==6  , lw(0.2) lc("`ncd'%40") lp("-"))
		(line arate2 yr1 if ghecause==30 & region==6  , lw(0.2) lc("`inj'%40") lp("-"))
        
		/// MEN (1). COM. BRAZIL.
		(line arate1 yr1 if ghecause==10 & region==7  , lw(0.2) lc("`com'%40"))
		(line arate1 yr1 if ghecause==20 & region==7  , lw(0.2) lc("`ncd'%40"))
		(line arate1 yr1 if ghecause==30 & region==7  , lw(0.2) lc("`inj'%40"))
		(line arate2 yr1 if ghecause==10 & region==7  , lw(0.2) lc("`com'%40") lp("-"))
		(line arate2 yr1 if ghecause==20 & region==7  , lw(0.2) lc("`ncd'%40") lp("-"))
		(line arate2 yr1 if ghecause==30 & region==7  , lw(0.2) lc("`inj'%40") lp("-"))

		/// MEN (1). COM. MEXICO.
		(line arate1 yr1 if ghecause==10 & region==8  , lw(0.2) lc("`com'%40"))
		(line arate1 yr1 if ghecause==20 & region==8  , lw(0.2) lc("`ncd'%40"))
		(line arate1 yr1 if ghecause==30 & region==8  , lw(0.2) lc("`inj'%40"))
		(line arate2 yr1 if ghecause==10 & region==8  , lw(0.2) lc("`com'%40") lp("-"))
		(line arate2 yr1 if ghecause==20 & region==8  , lw(0.2) lc("`ncd'%40") lp("-"))
		(line arate2 yr1 if ghecause==30 & region==8  , lw(0.2) lc("`inj'%40") lp("-"))
        
        /// droplines
       (function y=750, range(2000 2167) lc(gs12) dropline(2020 2041 2062 2083 2104 2125 2146 2167))

        /// Legend
        (function y=708, range(2035 2039) lc(gs10) lw(0.4))
        (function y=648, range(2035 2039) lp("-") lc(gs10) lw(0.4))
        (scatteri `outer1' , recast(area) lw(none) lc("`com'%35") fc("`com'%35")  )
        (scatteri `outer2' , recast(area) lw(none) lc("`ncd'%35") fc("`ncd'%35")  )
        (scatteri `outer3' , recast(area) lw(none) lc("`inj'%35") fc("`inj'%35")  )

		/// X-Axis lines
        (function y=-17, range(2000 2019) lc(gs12) lw(0.2))
        (function y=-17, range(2021 2040) lc(gs12) lw(0.2))
        (function y=-17, range(2042 2061) lc(gs12) lw(0.2))
        (function y=-17, range(2063 2082) lc(gs12) lw(0.2))
        (function y=-17, range(2084 2103) lc(gs12) lw(0.2))
        (function y=-17, range(2105 2124) lc(gs12) lw(0.2))
        (function y=-17, range(2126 2145) lc(gs12) lw(0.2))
        (function y=-17, range(2147 2166) lc(gs12) lw(0.2))

		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 
			ysize(5) xsize(15)

			xlab(none, 
			valuelabel labc(gs0) labs(2.5) notick nogrid glc(gs16) angle(45) format(%9.0f))
			xscale(noline lw(vthin)) 
			xtitle(" ", size(3) color(gs0) margin(l=1 r=1 t=1 b=1)) 
			
			ylab(0(100)700,
			valuelabel labc(gs8) labs(2.5) tlc(gs8) nogrid glc(gs16) angle(0) format(%9.0f))
			yscale(lw(vthin) lc(gs8) range(-20(50)850) noextend) 
			ytitle("Mortality rate (per 100,000)", color(gs8) size(3) margin(l=1 r=1 t=1 b=1)) 
            ymtick(0(50)750)

            /// Region Titles 
            text(790 2010 "North" "America",  place(c) size(3) color(gs5))
            text(790 2031 "Southern" "Cone",  place(c) size(3) color(gs5))
            text(790 2053 "Central" "America",  place(c) size(3) color(gs5))
            text(790 2074 "Andean",  place(c) size(3) color(gs5))
            text(790 2095 "Latin" "Caribbean",  place(c) size(3) color(gs5))
            text(790 2116 "non-Latin" "Caribbean",  place(c) size(3) color(gs5))
            text(790 2137 "Brazil",  place(c) size(3) color(gs5))
            text(790 2158 "Mexico",  place(c) size(3) color(gs5))

            /// Legend Text
            text(708 2034 "Men",  place(w) size(3) color(gs8))   
            text(648 2034 "Women",  place(w) size(3) color(gs8))   
            text(712 2012 "Communicable",  place(w) size(3) color(gs8))   
            text(652 2012   "NCDs",  place(w) size(3) color(gs8))   
            text(592 2012   "Injuries",  place(w) size(3) color(gs8))   

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
            text(0 2126 "2000",  place(e) size(2.5) color(gs8))
            text(0 2145 "2019",  place(w) size(2.5) color(gs8))
            text(0 2147 "2000",  place(e) size(2.5) color(gs8))
            text(0 2166 "2019",  place(w) size(2.5) color(gs8))

			/// Text explaining the earthquake year in 2010 in the Latin caribbean
            text(370 2096 "Haitian earthquake" " " "Injury rate (men)" "977 per 100k" " " "Injury rate (women)" "614 per 100k",  place(c) size(2.5) color(gs10) just(right))

			legend(off)
			name(mr_panel)
			;
#delimit cr	

