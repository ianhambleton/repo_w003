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
/// use "`datapath'\from-who\chap1_mortrate_001", clear
/// append using "`datapath'\from-who\chap1_mortrate_002"
/// ** Rates per 100,000
/// replace crate = crate * 100000
/// replace arate = arate * 100000
/// replace aupp = aupp * 100000
/// replace alow = alow * 100000
/// format pop %15.0fc

use "`datapath'\from-who\chap2_000_adjusted", clear
** Keep sub-regional level (this will keep the 8 PAHO subregions of the Americas)
keep if region>=100 & region <1000
** Interested only in the THREE major disease groups
** 200	communicable
** 300	NCD
** 1000 Injuries
keep if ghecause==200 | ghecause==300 | ghecause==1000
rename ghecause ghecause_orig 
gen ghecause = . 
replace ghecause = 10 if ghecause_orig==200
replace ghecause = 20 if ghecause_orig==300
replace ghecause = 30 if ghecause_orig==1000
label define ghecause_ 10 "Communicable" 20 "NCDs" 30 "Injuries",modify
label values ghecause ghecause_ 

** DROP DALYs
drop daly dalyr pop_dalyr dths
rename mortr arate
rename pop_mortr pop

** -------------------------------------------------------------------
** GRAPHIC
** -------------------------------------------------------------------

** Creating PANEL by shifting sub-regions along the x-axis
gen yr1 = . 
replace yr1 = year if region==100
replace yr1 = year + 21 if region==200
replace yr1 = year + 42 if region==300
replace yr1 = year + 63 if region==400
replace yr1 = year + 84 if region==500
replace yr1 = year + 105 if region==600
replace yr1 = year + 126 if region==700
replace yr1 = year + 147 if region==800
order year yr1 

** generate a local for the ColorBrewer color scheme
colorpalette ptol, rainbow n(9)  nograph
local list r(p) 
** (COM --> ghecause = 200 / 10)
local com `r(p3)'
** (NCD --> ghecause = 300 / 20)
local ncd `r(p6)'
** (INJ --> ghecause = 1000 / 30)
local inj `r(p9)'

** Jitter men and woemn by a horizontal fraction to improve visual
replace yr1 = yr1 - 0.2 if ghecause==10 
replace yr1 = yr1 + 0.2 if ghecause==20
replace yr1 = yr1 + 0.4 if ghecause==30

** Legend outer limits for graphing 
local outer1 695 2013 730 2013 730 2018 695 2018 695 2013
local outer2 635 2013 670 2013 670 2018 635 2018 635 2013
local outer3 575 2013 610 2013 610 2018 575 2018 575 2013

reshape wide arate pop, i(year yr1 ghecause region) j(sex) 

** SAVE THE DATASET FOR GRAPHIC
tempfile graphic
save `graphic', replace


** Associated stats for text
** COM/NCDs/INJ in 2000 and 2019, women and men separately, and women+men combined
use "`datapath'\from-who\chap2_000_adjusted", clear
	keep if (region>=100 & region <1000) | region==2000
	keep if ghecause==200 | ghecause==300 | ghecause==1000
	keep if year==2000 | year==2019 
	** Listing of rates by subregion
	format mortr %15.1fc 
	sort year ghecause sex mortr 
	list year ghecause sex region mortr , sep(9)
	** Decline between 2000 and 2019 by SEX 
	drop daly dalyr pop_dalyr dths pop_mortr 
	preserve
		reshape wide mortr , i(ghecause region sex) j(year)
		gen diff = mortr2019 - mortr2000
		gen ratio = ( (mortr2019 - mortr2000) / mortr2000) * 100
		gsort ghecause sex -diff
		list ghecause sex region diff ratio , sep(9)
	restore

** Associated stats for text
** COM/NCDs/INJ --> difference between women and men in 2000 and 2019
use "`datapath'\from-who\chap2_000_adjusted", clear
	keep if (region>=100 & region <1000) | region==2000
	keep if ghecause==200 | ghecause==300 | ghecause==1000
	keep if year==2000 | year==2019 
	** Difference between women and men by GHECAUSE 
	drop daly dalyr pop_dalyr dths pop_mortr 
	preserve
		reshape wide mortr , i(ghecause region year) j(sex)
		gen diff = mortr1 - mortr2
		gen ratio = ( (mortr1 - mortr2) / mortr1) * 100
		gsort ghecause year -diff
		list ghecause year region diff ratio , sep(9)
	restore

** Associated stats for Table 1.3
** COM/NCDs/INJ in 2019, women and men separately
use "`datapath'\from-who\chap2_000_adjusted", clear
	keep if (region>=100 & region <1000) | (region>=1000 & region<=6000)
	keep if ghecause==200 | ghecause==300 | ghecause==1000
	keep if sex<3
	keep if year==2019 
	** Listing of rates by subregion
	format mortr %15.1fc 
	gsort ghecause -sex region 
	list year ghecause sex region mortr if region>=1000, sep(6)
	list year ghecause sex region mortr if region<1000, sep(8)



** LOAD THE DATASET that was prepared above for the graphic
use `graphic', clear

** Turn Latin Caribbean 2010 injury rate into plottable value for visual
** This makes the extremely high rate for 2010 visible to reflect the Haitian earthquake
replace arate1 = 700 if region==500 & ghecause==30 & year==2010 & arate1>600
replace arate2 = 300 if region==500 & ghecause==30 & year==2010 & arate2>600


#delimit ;
	gr twoway 
		/// North America
	    (rarea arate1 arate2 yr1 if ghecause==10 & region==100 , lw(none) color("`com'%15"))
	    (rarea arate1 arate2 yr1 if ghecause==20 & region==100 , lw(none) color("`ncd'%15"))
	    (rarea arate1 arate2 yr1 if ghecause==30 & region==100 , lw(none) color("`inj'%15"))
		/// Southern Cone
	    (rarea arate1 arate2 yr1 if ghecause==10 & region==200 , lw(none) color("`com'%15"))
	    (rarea arate1 arate2 yr1 if ghecause==20 & region==200 , lw(none) color("`ncd'%15"))
	    (rarea arate1 arate2 yr1 if ghecause==30 & region==200 , lw(none) color("`inj'%15"))
		/// Central America
	    (rarea arate1 arate2 yr1 if ghecause==10 & region==300 , lw(none) color("`com'%15"))
	    (rarea arate1 arate2 yr1 if ghecause==20 & region==300 , lw(none) color("`ncd'%15"))
	    (rarea arate1 arate2 yr1 if ghecause==30 & region==300 , lw(none) color("`inj'%15"))
		/// Andean
	    (rarea arate1 arate2 yr1 if ghecause==10 & region==400 , lw(none) color("`com'%15"))
	    (rarea arate1 arate2 yr1 if ghecause==20 & region==400 , lw(none) color("`ncd'%15"))
	    (rarea arate1 arate2 yr1 if ghecause==30 & region==400 , lw(none) color("`inj'%15"))
		/// Latin Caribbean
	    (rarea arate1 arate2 yr1 if ghecause==10 & region==500 , lw(none) color("`com'%15"))
	    (rarea arate1 arate2 yr1 if ghecause==20 & region==500 , lw(none) color("`ncd'%15"))
	    /// HIGH RATE due to Haiti earthquake in 2010
		(rarea arate1 arate2 yr1 if ghecause==30 & region==500 & year>=2009 & year<=2011, lw(none) color("`inj'%5"))
	    (rarea arate1 arate2 yr1 if ghecause==30 & region==500 & year<2010,  lw(none) color("`inj'%15"))
	    (rarea arate1 arate2 yr1 if ghecause==30 & region==500 & year>2010,  lw(none) color("`inj'%15"))

		/// non-Latin Caribbean
	    (rarea arate1 arate2 yr1 if ghecause==10 & region==600 , lw(none) color("`com'%15"))
	    (rarea arate1 arate2 yr1 if ghecause==20 & region==600 , lw(none) color("`ncd'%15"))
	    (rarea arate1 arate2 yr1 if ghecause==30 & region==600 , lw(none) color("`inj'%15"))
		/// Brazil
	    (rarea arate1 arate2 yr1 if ghecause==10 & region==700 , lw(none) color("`com'%15"))
	    (rarea arate1 arate2 yr1 if ghecause==20 & region==700 , lw(none) color("`ncd'%15"))
	    (rarea arate1 arate2 yr1 if ghecause==30 & region==700 , lw(none) color("`inj'%15"))
		/// Mexico
	    (rarea arate1 arate2 yr1 if ghecause==10 & region==800 , lw(none) color("`com'%15"))
	    (rarea arate1 arate2 yr1 if ghecause==20 & region==800 , lw(none) color("`ncd'%15"))
	    (rarea arate1 arate2 yr1 if ghecause==30 & region==800 , lw(none) color("`inj'%15"))

		/// MEN (1). COM. NORTH AMERICA.
        (line arate1 yr1 if ghecause==10 & region==100  , lw(0.2) lc("`com'%40") lp("l"))
		(line arate1 yr1 if ghecause==20 & region==100  , lw(0.2) lc("`ncd'%40") lp("l"))
		(line arate1 yr1 if ghecause==30 & region==100  , lw(0.2) lc("`inj'%40") lp("l"))
		(line arate2 yr1 if ghecause==10 & region==100  , lw(0.2) lc("`com'%40") lp("-"))
		(line arate2 yr1 if ghecause==20 & region==100  , lw(0.2) lc("`ncd'%40") lp("-"))
		(line arate2 yr1 if ghecause==30 & region==100  , lw(0.2) lc("`inj'%40") lp("-"))

		/// MEN (1). COM. CENTRAL AMERICA.
		(line arate1 yr1 if ghecause==10 & region==200  , lw(0.2) lc("`com'%40") lp("l"))
		(line arate1 yr1 if ghecause==20 & region==200  , lw(0.2) lc("`ncd'%40") lp("l"))
		(line arate1 yr1 if ghecause==30 & region==200  , lw(0.2) lc("`inj'%40") lp("l"))
		(line arate2 yr1 if ghecause==10 & region==200  , lw(0.2) lc("`com'%40") lp("-"))
		(line arate2 yr1 if ghecause==20 & region==200  , lw(0.2) lc("`ncd'%40") lp("-"))
		(line arate2 yr1 if ghecause==30 & region==200  , lw(0.2) lc("`inj'%40") lp("-"))

		/// MEN (1). COM. ANDEAN
		(line arate1 yr1 if ghecause==10 & region==300  , lw(0.2) lc("`com'%40") lp("l"))
		(line arate1 yr1 if ghecause==20 & region==300  , lw(0.2) lc("`ncd'%40") lp("l"))
		(line arate1 yr1 if ghecause==30 & region==300  , lw(0.2) lc("`inj'%40") lp("l"))
		(line arate2 yr1 if ghecause==10 & region==300  , lw(0.2) lc("`com'%40") lp("-"))
		(line arate2 yr1 if ghecause==20 & region==300  , lw(0.2) lc("`ncd'%40") lp("-"))
		(line arate2 yr1 if ghecause==30 & region==300  , lw(0.2) lc("`inj'%40") lp("-"))

		/// MEN (1). COM. SOUTHERN CONE
		(line arate1 yr1 if ghecause==10 & region==400  , lw(0.2) lc("`com'%40") lp("l"))
		(line arate1 yr1 if ghecause==20 & region==400  , lw(0.2) lc("`ncd'%40") lp("l"))
		(line arate1 yr1 if ghecause==30 & region==400  , lw(0.2) lc("`inj'%40") lp("l"))
		(line arate2 yr1 if ghecause==10 & region==400  , lw(0.2) lc("`com'%40") lp("-"))
		(line arate2 yr1 if ghecause==20 & region==400  , lw(0.2) lc("`ncd'%40") lp("-"))
		(line arate2 yr1 if ghecause==30 & region==400  , lw(0.2) lc("`inj'%40") lp("-"))
        
		/// MEN (1). COM. LATIN CARIBBEAN
		(line arate1 yr1 if ghecause==10 & region==500                , lw(0.2) lc("`com'%40") lp("l"))
		(line arate1 yr1 if ghecause==20 & region==500                , lw(0.2) lc("`ncd'%40") lp("l"))
		(line arate1 yr1 if ghecause==30 & region==500 & year>=2009 & year<=2011   , lw(0.2) lc("`inj'%10") lp("l"))
		(line arate1 yr1 if ghecause==30 & region==500 & year<2010    , lw(0.2) lc("`inj'%40") lp("l"))
		(line arate1 yr1 if ghecause==30 & region==500 & year>2010    , lw(0.2) lc("`inj'%40") lp("l"))
		(line arate2 yr1 if ghecause==10 & region==500                , lw(0.2) lc("`com'%40") lp("-"))
		(line arate2 yr1 if ghecause==20 & region==500                , lw(0.2) lc("`ncd'%40") lp("-"))
		(line arate2 yr1 if ghecause==30 & region==500 & year>=2009 & year<=2011   , lw(0.2) lc("`inj'%10"))
		(line arate2 yr1 if ghecause==30 & region==500 & year<2010    , lw(0.2) lc("`inj'%40"))
		(line arate2 yr1 if ghecause==30 & region==500 & year>2010    , lw(0.2) lc("`inj'%40"))

		/// MEN (1). COM. NON_LATIN CARIBBEAN.
		(line arate1 yr1 if ghecause==10 & region==600  , lw(0.2) lc("`com'%40") lp("l"))
		(line arate1 yr1 if ghecause==20 & region==600  , lw(0.2) lc("`ncd'%40") lp("l"))
		(line arate1 yr1 if ghecause==30 & region==600  , lw(0.2) lc("`inj'%40") lp("l"))
		(line arate2 yr1 if ghecause==10 & region==600  , lw(0.2) lc("`com'%40") lp("-"))
		(line arate2 yr1 if ghecause==20 & region==600  , lw(0.2) lc("`ncd'%40") lp("-"))
		(line arate2 yr1 if ghecause==30 & region==600  , lw(0.2) lc("`inj'%40") lp("-"))
        
		/// MEN (1). COM. BRAZIL.
		(line arate1 yr1 if ghecause==10 & region==700  , lw(0.2) lc("`com'%40") lp("l"))
		(line arate1 yr1 if ghecause==20 & region==700  , lw(0.2) lc("`ncd'%40") lp("l"))
		(line arate1 yr1 if ghecause==30 & region==700  , lw(0.2) lc("`inj'%40") lp("l"))
		(line arate2 yr1 if ghecause==10 & region==700  , lw(0.2) lc("`com'%40") lp("-"))
		(line arate2 yr1 if ghecause==20 & region==700  , lw(0.2) lc("`ncd'%40") lp("-"))
		(line arate2 yr1 if ghecause==30 & region==700  , lw(0.2) lc("`inj'%40") lp("-"))

		/// MEN (1). COM. MEXICO.
		(line arate1 yr1 if ghecause==10 & region==800  , lw(0.2) lc("`com'%40") lp("l"))
		(line arate1 yr1 if ghecause==20 & region==800  , lw(0.2) lc("`ncd'%40") lp("l"))
		(line arate1 yr1 if ghecause==30 & region==800  , lw(0.2) lc("`inj'%40") lp("l"))
		(line arate2 yr1 if ghecause==10 & region==800  , lw(0.2) lc("`com'%40") lp("-"))
		(line arate2 yr1 if ghecause==20 & region==800  , lw(0.2) lc("`ncd'%40") lp("-"))
		(line arate2 yr1 if ghecause==30 & region==800  , lw(0.2) lc("`inj'%40") lp("-"))
        
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
            text(790 2031 "Central" "America",  place(c) size(3) color(gs5))
            text(790 2053 "Andean",  place(c) size(3) color(gs5))
            text(790 2074 "Southern" "Cone",  place(c) size(3) color(gs5))
            text(790 2095 "Latin" "Caribbean",  place(c) size(3) color(gs5))
            text(790 2116 "non-Latin" "Caribbean",  place(c) size(3) color(gs5))
            text(790 2137 "Brazil",  place(c) size(3) color(gs5))
            text(790 2158 "Mexico",  place(c) size(3) color(gs5))

            /// Legend Text
            text(708 2034 "Men",  place(w) size(3) color(gs8))   
            text(648 2034 "Women",  place(w) size(3) color(gs8))   
            text(712 2012 "CMPN",  place(w) size(3) color(gs8))   
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

** -----------------------------------------------------
** Version 2 - legend outside
** -----------------------------------------------------

** Legend outer limits for graphing 
local outer1 860 2077 890 2077 890 2082 860 2082 860 2077

local outer2 860 2092 890 2092 890 2097 860 2097 860 2092

local outer3 860 2106 890 2106 890 2111 860 2111 860 2106

#delimit ;
	gr twoway 
		/// North America
	    (rarea arate1 arate2 yr1 if ghecause==10 & region==100 , lw(none) color("`com'%15"))
	    (rarea arate1 arate2 yr1 if ghecause==20 & region==100 , lw(none) color("`ncd'%15"))
	    (rarea arate1 arate2 yr1 if ghecause==30 & region==100 , lw(none) color("`inj'%15"))
		/// Southern Cone
	    (rarea arate1 arate2 yr1 if ghecause==10 & region==200 , lw(none) color("`com'%15"))
	    (rarea arate1 arate2 yr1 if ghecause==20 & region==200 , lw(none) color("`ncd'%15"))
	    (rarea arate1 arate2 yr1 if ghecause==30 & region==200 , lw(none) color("`inj'%15"))
		/// Central America
	    (rarea arate1 arate2 yr1 if ghecause==10 & region==300 , lw(none) color("`com'%15"))
	    (rarea arate1 arate2 yr1 if ghecause==20 & region==300 , lw(none) color("`ncd'%15"))
	    (rarea arate1 arate2 yr1 if ghecause==30 & region==300 , lw(none) color("`inj'%15"))
		/// Andean
	    (rarea arate1 arate2 yr1 if ghecause==10 & region==400 , lw(none) color("`com'%15"))
	    (rarea arate1 arate2 yr1 if ghecause==20 & region==400 , lw(none) color("`ncd'%15"))
	    (rarea arate1 arate2 yr1 if ghecause==30 & region==400 , lw(none) color("`inj'%15"))
		/// Latin Caribbean
	    (rarea arate1 arate2 yr1 if ghecause==10 & region==500 , lw(none) color("`com'%15"))
	    (rarea arate1 arate2 yr1 if ghecause==20 & region==500 , lw(none) color("`ncd'%15"))
	    /// HIGH RATE due to Haiti earthquake in 2010
		(rarea arate1 arate2 yr1 if ghecause==30 & region==500 & year>=2009 & year<=2011, lw(none) color("`inj'%5"))
	    (rarea arate1 arate2 yr1 if ghecause==30 & region==500 & year<2010,  lw(none) color("`inj'%15"))
	    (rarea arate1 arate2 yr1 if ghecause==30 & region==500 & year>2010,  lw(none) color("`inj'%15"))

		/// non-Latin Caribbean
	    (rarea arate1 arate2 yr1 if ghecause==10 & region==600 , lw(none) color("`com'%15"))
	    (rarea arate1 arate2 yr1 if ghecause==20 & region==600 , lw(none) color("`ncd'%15"))
	    (rarea arate1 arate2 yr1 if ghecause==30 & region==600 , lw(none) color("`inj'%15"))
		/// Brazil
	    (rarea arate1 arate2 yr1 if ghecause==10 & region==700 , lw(none) color("`com'%15"))
	    (rarea arate1 arate2 yr1 if ghecause==20 & region==700 , lw(none) color("`ncd'%15"))
	    (rarea arate1 arate2 yr1 if ghecause==30 & region==700 , lw(none) color("`inj'%15"))
		/// Mexico
	    (rarea arate1 arate2 yr1 if ghecause==10 & region==800 , lw(none) color("`com'%15"))
	    (rarea arate1 arate2 yr1 if ghecause==20 & region==800 , lw(none) color("`ncd'%15"))
	    (rarea arate1 arate2 yr1 if ghecause==30 & region==800 , lw(none) color("`inj'%15"))

		/// MEN (1). COM. NORTH AMERICA.
        (line arate1 yr1 if ghecause==10 & region==100  , lw(0.2) lc("`com'%40") lp("l"))
		(line arate1 yr1 if ghecause==20 & region==100  , lw(0.2) lc("`ncd'%40") lp("l"))
		(line arate1 yr1 if ghecause==30 & region==100  , lw(0.2) lc("`inj'%40") lp("l"))
		(line arate2 yr1 if ghecause==10 & region==100  , lw(0.2) lc("`com'%40") lp("-"))
		(line arate2 yr1 if ghecause==20 & region==100  , lw(0.2) lc("`ncd'%40") lp("-"))
		(line arate2 yr1 if ghecause==30 & region==100  , lw(0.2) lc("`inj'%40") lp("-"))

		/// MEN (1). COM. CENTRAL AMERICA.
		(line arate1 yr1 if ghecause==10 & region==200  , lw(0.2) lc("`com'%40") lp("l"))
		(line arate1 yr1 if ghecause==20 & region==200  , lw(0.2) lc("`ncd'%40") lp("l"))
		(line arate1 yr1 if ghecause==30 & region==200  , lw(0.2) lc("`inj'%40") lp("l"))
		(line arate2 yr1 if ghecause==10 & region==200  , lw(0.2) lc("`com'%40") lp("-"))
		(line arate2 yr1 if ghecause==20 & region==200  , lw(0.2) lc("`ncd'%40") lp("-"))
		(line arate2 yr1 if ghecause==30 & region==200  , lw(0.2) lc("`inj'%40") lp("-"))

		/// MEN (1). COM. ANDEAN
		(line arate1 yr1 if ghecause==10 & region==300  , lw(0.2) lc("`com'%40") lp("l"))
		(line arate1 yr1 if ghecause==20 & region==300  , lw(0.2) lc("`ncd'%40") lp("l"))
		(line arate1 yr1 if ghecause==30 & region==300  , lw(0.2) lc("`inj'%40") lp("l"))
		(line arate2 yr1 if ghecause==10 & region==300  , lw(0.2) lc("`com'%40") lp("-"))
		(line arate2 yr1 if ghecause==20 & region==300  , lw(0.2) lc("`ncd'%40") lp("-"))
		(line arate2 yr1 if ghecause==30 & region==300  , lw(0.2) lc("`inj'%40") lp("-"))

		/// MEN (1). COM. SOUTHERN CONE
		(line arate1 yr1 if ghecause==10 & region==400  , lw(0.2) lc("`com'%40") lp("l"))
		(line arate1 yr1 if ghecause==20 & region==400  , lw(0.2) lc("`ncd'%40") lp("l"))
		(line arate1 yr1 if ghecause==30 & region==400  , lw(0.2) lc("`inj'%40") lp("l"))
		(line arate2 yr1 if ghecause==10 & region==400  , lw(0.2) lc("`com'%40") lp("-"))
		(line arate2 yr1 if ghecause==20 & region==400  , lw(0.2) lc("`ncd'%40") lp("-"))
		(line arate2 yr1 if ghecause==30 & region==400  , lw(0.2) lc("`inj'%40") lp("-"))
        
		/// MEN (1). COM. LATIN CARIBBEAN
		(line arate1 yr1 if ghecause==10 & region==500                , lw(0.2) lc("`com'%40") lp("l"))
		(line arate1 yr1 if ghecause==20 & region==500                , lw(0.2) lc("`ncd'%40") lp("l"))
		(line arate1 yr1 if ghecause==30 & region==500 & year>=2009 & year<=2011   , lw(0.2) lc("`inj'%10") lp("l"))
		(line arate1 yr1 if ghecause==30 & region==500 & year<2010    , lw(0.2) lc("`inj'%40") lp("l"))
		(line arate1 yr1 if ghecause==30 & region==500 & year>2010    , lw(0.2) lc("`inj'%40") lp("l"))
		(line arate2 yr1 if ghecause==10 & region==500                , lw(0.2) lc("`com'%40") lp("-"))
		(line arate2 yr1 if ghecause==20 & region==500                , lw(0.2) lc("`ncd'%40") lp("-"))
		(line arate2 yr1 if ghecause==30 & region==500 & year>=2009 & year<=2011   , lw(0.2) lc("`inj'%10"))
		(line arate2 yr1 if ghecause==30 & region==500 & year<2010    , lw(0.2) lc("`inj'%40"))
		(line arate2 yr1 if ghecause==30 & region==500 & year>2010    , lw(0.2) lc("`inj'%40"))

		/// MEN (1). COM. NON_LATIN CARIBBEAN.
		(line arate1 yr1 if ghecause==10 & region==600  , lw(0.2) lc("`com'%40") lp("l"))
		(line arate1 yr1 if ghecause==20 & region==600  , lw(0.2) lc("`ncd'%40") lp("l"))
		(line arate1 yr1 if ghecause==30 & region==600  , lw(0.2) lc("`inj'%40") lp("l"))
		(line arate2 yr1 if ghecause==10 & region==600  , lw(0.2) lc("`com'%40") lp("-"))
		(line arate2 yr1 if ghecause==20 & region==600  , lw(0.2) lc("`ncd'%40") lp("-"))
		(line arate2 yr1 if ghecause==30 & region==600  , lw(0.2) lc("`inj'%40") lp("-"))
        
		/// MEN (1). COM. BRAZIL.
		(line arate1 yr1 if ghecause==10 & region==700  , lw(0.2) lc("`com'%40") lp("l"))
		(line arate1 yr1 if ghecause==20 & region==700  , lw(0.2) lc("`ncd'%40") lp("l"))
		(line arate1 yr1 if ghecause==30 & region==700  , lw(0.2) lc("`inj'%40") lp("l"))
		(line arate2 yr1 if ghecause==10 & region==700  , lw(0.2) lc("`com'%40") lp("-"))
		(line arate2 yr1 if ghecause==20 & region==700  , lw(0.2) lc("`ncd'%40") lp("-"))
		(line arate2 yr1 if ghecause==30 & region==700  , lw(0.2) lc("`inj'%40") lp("-"))

		/// MEN (1). COM. MEXICO.
		(line arate1 yr1 if ghecause==10 & region==800  , lw(0.2) lc("`com'%40") lp("l"))
		(line arate1 yr1 if ghecause==20 & region==800  , lw(0.2) lc("`ncd'%40") lp("l"))
		(line arate1 yr1 if ghecause==30 & region==800  , lw(0.2) lc("`inj'%40") lp("l"))
		(line arate2 yr1 if ghecause==10 & region==800  , lw(0.2) lc("`com'%40") lp("-"))
		(line arate2 yr1 if ghecause==20 & region==800  , lw(0.2) lc("`ncd'%40") lp("-"))
		(line arate2 yr1 if ghecause==30 & region==800  , lw(0.2) lc("`inj'%40") lp("-"))
        
        /// droplines
       (function y=750, range(2000 2167) lc(gs12) dropline(2020 2041 2062 2083 2104 2125 2146 2167))

        /// Legend
        (function y=875, range(2047 2052) lp("l") lc(gs10) lw(0.4))
        (function y=875, range(2060 2065) lp("-") lc(gs10) lw(0.4))
        (scatteri `outer1' , recast(area) lw(none) lc("`com'%35") fc("`com'%35")  )
        (scatteri `outer2' , recast(area) lw(none) lc("`ncd'%35") fc("`ncd'%35")  )
        (scatteri `outer3' , recast(area) lw(none) lc("`inj'%35") fc("`inj'%35")  )
        (function y=850, range(2041 2125) lp("l") lc(gs14) lw(0.4))

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
			ysize(6) xsize(15)

			xlab(none, 
			valuelabel labc(gs0) labs(2.5) notick nogrid glc(gs16) angle(45) format(%9.0f))
			xscale(noline lw(vthin)) 
			xtitle(" ", size(3) color(gs0) margin(l=1 r=1 t=1 b=1)) 
			
			ylab(0(100)700,
			valuelabel labc(gs8) labs(2.5) tlc(gs8) nogrid glc(gs16) angle(0) format(%9.0f))
			yscale(lw(vthin) lc(gs8) range(-20(20)960) noextend) 
			ytitle("Mortality rate (per 100,000)", color(gs8) size(3) margin(l=1 r=1 t=1 b=1)) 
            ymtick(0(50)750)

            /// Region Titles 
            text(790 2010 "North" "America",  place(c) size(2.5) color(gs5))
            text(790 2031 "Central" "America",  place(c) size(2.5) color(gs5))
            text(790 2053 "Andean",  place(c) size(2.5) color(gs5))
            text(790 2074 "Southern" "Cone",  place(c) size(2.5) color(gs5))
            text(790 2095 "Latin" "Caribbean",  place(c) size(2.5) color(gs5))
            text(790 2116 "non-Latin" "Caribbean",  place(c) size(2.5) color(gs5))
            text(790 2137 "Brazil",  place(c) size(2.5) color(gs5))
            text(790 2158 "Mexico",  place(c) size(2.5) color(gs5))

            /// Legend Text
            text(875 2057 "Men",  place(w) size(2.5) color(gs8))   
            text(875 2072 "Women",  place(w) size(2.5) color(gs8))   
            text(875 2087 "CMPN",  place(w) size(2.5) color(gs8))   
            text(875 2102 "NCDs",  place(w) size(2.5) color(gs8))   
            text(875 2117 "Injuries",  place(w) size(2.5) color(gs8))   

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
            text(370 2095 "Haitian earthquake" " " "Injury rate (men)" "977 per 100k" " " "Injury rate (women)" "614 per 100k",  place(c) size(2.5) color(gs10) just(right))

			legend(off)
			name(mr_panel2)
			;
#delimit cr	
