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


** Load population file from: 
**      paper2-100-datasets.do 
use "`datapath'/paper2-inj/dataset01", clear
drop paho_subregion daly dths pop_dalyr pop_mortr

** Keep sub-regional level (this will keep the 8 PAHO subregions of the Americas)
keep if (region>=100 & region <1000) | region==2000

** Keep 1000 Injuries
keep if ghecause==1000
drop ghecause

** Create rates for THE AMERICAS as denominator

** Create variable (by sex) with Mortality and DALY rates for the Americas
** This allows us to plot Americas on each panel
forval x = 1(1)3 {
	gen d`x' = dalyr if region==2000 & sex==`x'
	gen m`x' = mortr if region==2000 & sex==`x'
	bysort year sex : egen d`x'_1 = min(d`x')
	bysort year sex : egen m`x'_1 = min(m`x')
}
** DALY rates for Americas by Sex
gen dam = d1_1
replace dam = d2_1 if dam==. & d2_1<.
replace dam = d3_1 if dam==. & d3_1<.
gen mam = m1_1
replace mam = m2_1 if mam==. & m2_1<.
replace mam = m3_1 if mam==. & m3_1<.

** BEST (Lowest) rate in each year by sex 
	bysort year sex : egen d = min(dalyr) if region<2000
	bysort year sex : egen m = min(mortr) if region<2000
	bysort year sex : egen dlo = min(dalyr) 
	bysort year sex : egen mlo = min(mortr) 


** Relative Difference between Sub-Region and Americas
gen drel_sr_am = dalyr/dam 
gen mrel_sr_am = mortr/mam 
** Absolute Difference between Sub-Region and Americas
gen dab_sr_am = dalyr - dam 
gen mab_sr_am = mortr - mam 

** Relative Difference between Sub-Region and LOWEST rate
gen drel_sr_lo = dalyr/dlo 
gen mrel_sr_lo = mortr/mlo 
** Absolute Difference between Sub-Region and LOWEST rate
gen dab_sr_lo = dalyr - dlo 
gen mab_sr_lo = mortr - mlo 

drop d1* d2* d3* m1* m2* m3* d m 

** Labelling
label var dalyr "DALY rate (per 100,000)"
label var mortr "Mortality rate (per 100,000)"
label var dam "DALY rate for the Americas by year and sex"
label var mam "Mortality rate for the Americas by year and sex"
label var dlo "Lowest subregional DALY rate by year and sex"
label var mlo "Lowest subregional mortality by year and sex"
label var drel_sr_am "Relative DALY rate diff between subregion and Americas"
label var mrel_sr_am "Relative Mortality rate diff between subregion and Americas"
label var dab_sr_am "Absolute DALY rate diff between subregion and Americas"
label var mab_sr_am "Absolute Mortality rate diff between subregion and Americas"
label var drel_sr_lo "Relative DALY rate diff between subregion and lowest rate"
label var mrel_sr_lo "Relative Mortality rate diff between subregion and lowest rate"
label var  dab_sr_lo "Absolute DALY rate diff between subregion and lowest rate"
label var  mab_sr_lo "Absolute Mortality rate diff between subregion and lowest rate"

**! ------------------------------------------------------------------------
**! CALCULATE ASSOCIATED METRICS HERE BEFORE CONVERTING TO WIDE FOR PLOTTING
**! ------------------------------------------------------------------------



** -------------------------------------------------------------------
** GRAPHIC 1
** -------------------------------------------------------------------

keep year sex region mortr mam daly dam
reshape wide mortr mam dalyr dam, i(year region) j(sex)
drop if region==2000

** Creating HORIZONTAL PANELS by shifting sub-regions along the x-axis
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
colorpalette d3, 20 n(20)  nograph
local list r(p) 
local mort `r(p3)'
local daly `r(p9)'
local am `r(p15)'

** Legend outer limits for graphing 
local outer1 695 2013 730 2013 730 2018 695 2018 695 2013
local outer2 635 2013 670 2013 670 2018 635 2018 635 2013
local outer3 575 2013 610 2013 610 2018 575 2018 575 2013
** Legend outer limits for graphing 
local outer1 860 2077 890 2077 890 2082 860 2082 860 2077
local outer2 860 2092 890 2092 890 2097 860 2097 860 2092
local outer3 860 2106 890 2106 890 2111 860 2111 860 2106

** Turn Latin Caribbean 2010 injury rate into plottable value for visual
** This makes the extremely high rate for 2010 visible to reflect the Haitian earthquake
replace mortr1 = 175 if region==500 & year==2010 & mortr1>600
replace mortr2 = 150 if region==500 & year==2010 & mortr2>600


** MORTALITY
** #delimit ;
** 	gr twoway 
** 		/// 100. North America
** 		/// 200. Central America
** 		/// 300. Andean
** 		/// 400. Southern Cone
** 		/// 500. Latin Caribbean
** 		/// 600. non-Latin Caribbean
** 		/// 700. Brazil
** 		/// 800. Mexico
** 		(line  mam3 yr1		 		if region==100 , lw(0.2) lc("`am'%80") lp("-"))
** 		(line mortr1 yr1 			if region==100 , lw(0.2) lc("`mort'%80") lp("l"))
** 		(line mortr2 yr1			if region==100 , lw(0.2) lc("`mort'%80") lp("-"))
** 	    (rarea mortr1 mortr2 yr1 	if region==100 , lw(none) color("`mort'%15"))
** 
** 		(line  mam3 yr1		 		if region==200 , lw(0.2) lc("`am'%80") lp("-"))
** 		(line mortr1 yr1 			if region==200 , lw(0.2) lc("`mort'%80") lp("l"))
** 		(line mortr2 yr1			if region==200 , lw(0.2) lc("`mort'%80") lp("-"))
** 	    (rarea mortr1 mortr2 yr1 	if region==200 , lw(none) color("`mort'%15"))
** 
** 		(line  mam3 yr1		 		if region==300 , lw(0.2) lc("`am'%80") lp("-"))
** 		(line mortr1 yr1 			if region==300 , lw(0.2) lc("`mort'%80") lp("l"))
** 		(line mortr2 yr1			if region==300 , lw(0.2) lc("`mort'%80") lp("-"))
** 	    (rarea mortr1 mortr2 yr1 	if region==300 , lw(none) color("`mort'%15"))
** 
** 		(line  mam3 yr1		 		if region==400 , lw(0.2) lc("`am'%80") lp("-"))
** 		(line mortr1 yr1 			if region==400 , lw(0.2) lc("`mort'%80") lp("l"))
** 		(line mortr2 yr1			if region==400 , lw(0.2) lc("`mort'%80") lp("-"))
** 	    (rarea mortr1 mortr2 yr1 	if region==400 , lw(none) color("`mort'%15"))
** 
** 		(line  mam3 yr1		 		if region==500 , lw(0.2) lc("`am'%80") lp("-"))
** 		(line mortr1 yr1 			if region==500 & year<2010, lw(0.2) lc("`mort'%80") lp("l"))
** 		(line mortr2 yr1			if region==500 & year<2010, lw(0.2) lc("`mort'%80") lp("-"))
** 		(line mortr1 yr1 			if region==500 & year>2010, lw(0.2) lc("`mort'%80") lp("l"))
** 		(line mortr2 yr1			if region==500 & year>2010, lw(0.2) lc("`mort'%80") lp("-"))
** 	    (rarea mortr1 mortr2 yr1 	if region==500 & year<2010, lw(none) color("`mort'%15"))
** 	    (rarea mortr1 mortr2 yr1 	if region==500 & year>2010, lw(none) color("`mort'%15"))
** 
** 		(line  mam3 yr1		 		if region==600 , lw(0.2) lc("`am'%80") lp("-"))
** 		(line mortr1 yr1 			if region==600 , lw(0.2) lc("`mort'%80") lp("l"))
** 		(line mortr2 yr1			if region==600 , lw(0.2) lc("`mort'%80") lp("-"))
** 	    (rarea mortr1 mortr2 yr1 	if region==600 , lw(none) color("`mort'%15"))
** 
** 		(line  mam3 yr1		 		if region==700 , lw(0.2) lc("`am'%80") lp("-"))
** 		(line mortr1 yr1 			if region==700 , lw(0.2) lc("`mort'%80") lp("l"))
** 		(line mortr2 yr1			if region==700 , lw(0.2) lc("`mort'%80") lp("-"))
** 	    (rarea mortr1 mortr2 yr1 	if region==700 , lw(none) color("`mort'%15"))
** 
** 		(line  mam3 yr1		 		if region==800 , lw(0.2) lc("`am'%80") lp("-"))
** 		(line mortr1 yr1 			if region==800 , lw(0.2) lc("`mort'%80") lp("l"))
** 		(line mortr2 yr1			if region==800 , lw(0.2) lc("`mort'%80") lp("-"))
** 	    (rarea mortr1 mortr2 yr1 	if region==800 , lw(none) color("`mort'%15"))
** 
**         /// droplines
**        (function y=210, range(2000 2167) lc(gs12) dropline(2020 2041 2062 2083 2104 2125 2146 2167))
** 
** 		/// Legend
**         /// (function y=875, range(2047 2052) lp("l") lc(gs10) lw(0.4))
**         /// (function y=875, range(2060 2065) lp("-") lc(gs10) lw(0.4))
**         /// (scatteri `outer1' , recast(area) lw(none) lc("`com'%35") fc("`com'%35")  )
**         /// (scatteri `outer2' , recast(area) lw(none) lc("`ncd'%35") fc("`ncd'%35")  )
**         /// (scatteri `outer3' , recast(area) lw(none) lc("`mort'%35") fc("`mort'%35")  )
**         /// (function y=850, range(2041 2125) lp("l") lc(gs14) lw(0.4))
** 
** 		/// X-Axis lines
**         (function y=-13, range(2000 2019) lp("l") lc(gs12) lw(0.2))
**         (function y=-13, range(2021 2040) lp("l") lc(gs12) lw(0.2))
**         (function y=-13, range(2042 2061) lp("l") lc(gs12) lw(0.2))
**         (function y=-13, range(2063 2082) lp("l") lc(gs12) lw(0.2))
**         (function y=-13, range(2084 2103) lp("l") lc(gs12) lw(0.2))
**         (function y=-13, range(2105 2124) lp("l") lc(gs12) lw(0.2))
**         (function y=-13, range(2126 2145) lp("l") lc(gs12) lw(0.2))
**         (function y=-13, range(2147 2166) lp("l") lc(gs12) lw(0.2))
** 		,
** 			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 		
** 			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 
** 			ysize(4) xsize(16)
** 
** 			xlab(none, 
** 			valuelabel labc(gs0) labs(4) notick nogrid glc(gs16) angle(45) format(%9.0f))
** 			xscale(noline lw(vthin)) 
** 			xtitle(" ", size(3) color(gs0) margin(l=1 r=1 t=1 b=1)) 
** 			
** 			ylab(0(50)200,
** 			valuelabel labc(gs8) labs(4) tlc(gs8) nogrid glc(gs16) angle(0) format(%9.0f))
** 			yscale(lw(vthin) lc(gs8) noextend range(-20(20)240)) 
** 			ytitle("Mortality rate (per 100,000) ", color(gs8) size(4) margin(l=1 r=1 t=1 b=1)) 
**             ymtick(0(25)200)
** 
**             /// Region Titles 
**             text(225 2010 "North" "America",  place(c) size(4) color(gs5))
**             text(225 2031 "Central" "America",  place(c) size(4) color(gs5))
**             text(225 2053 "Andean",  place(c) size(4) color(gs5))
**             text(225 2074 "Southern" "Cone",  place(c) size(4) color(gs5))
**             text(225 2095 "Latin" "Caribbean",  place(c) size(4) color(gs5))
**             text(225 2116 "non-Latin" "Caribbean",  place(c) size(4) color(gs5))
**             text(225 2137 "Brazil",  place(c) size(4) color(gs5))
**             text(225 2158 "Mexico",  place(c) size(4) color(gs5))
** 
**             /// Legend Text
**             /// text(875 2057 "Men",  place(w) size(2.5) color(gs8))   
**             /// text(875 2072 "Women",  place(w) size(2.5) color(gs8))   
**             /// text(875 2087 "CMPN",  place(w) size(2.5) color(gs8))   
**             /// text(875 2102 "NCDs",  place(w) size(2.5) color(gs8))   
**             /// text(875 2117 "Injuries",  place(w) size(2.5) color(gs8))   
** 
** 			
** 	        /// STAR for Latin Caribbean
**             text(120 2093.5 "{&lowast}",  place(e) size(6) color("`mort'"))	
** 	
** 			/// X-Axis text
**             text(0 2000 "2000",  place(e) size(4) color(gs8))
**             text(0 2019 "2019",  place(w) size(4) color(gs8))
**             text(0 2021 "2000",  place(e) size(4) color(gs8))
**             text(0 2040 "2019",  place(w) size(4) color(gs8))
**             text(0 2042 "2000",  place(e) size(4) color(gs8))
**             text(0 2061 "2019",  place(w) size(4) color(gs8))
**             text(0 2063 "2000",  place(e) size(4) color(gs8))
**             text(0 2082 "2019",  place(w) size(4) color(gs8))
**             text(0 2084 "2000",  place(e) size(4) color(gs8))
**             text(0 2103 "2019",  place(w) size(4) color(gs8))
**             text(0 2105 "2000",  place(e) size(4) color(gs8))
**             text(0 2124 "2019",  place(w) size(4) color(gs8))
**             text(0 2126 "2000",  place(e) size(4) color(gs8))
**             text(0 2145 "2019",  place(w) size(4) color(gs8))
**             text(0 2147 "2000",  place(e) size(4) color(gs8))
**             text(0 2166 "2019",  place(w) size(4) color(gs8))
** 
** 			/// Text explaining the earthquake year in 2010 in the Latin caribbean
**             /// text(370 2095 "Haitian earthquake" " " "Injury rate (men)" "977 per 100k" " " "Injury rate (women)" "614 per 100k",  place(c) size(2.5) color(gs10) just(right))
** 
** 			legend(off)
** 			name(figure1a)
** 			;
** #delimit cr	



** INJURY BURDEN
#delimit ;
	gr twoway 
		/// 100. North America
		/// 200. Central America
		/// 300. Andean
		/// 400. Southern Cone
		/// 500. Latin Caribbean
		/// 600. non-Latin Caribbean
		/// 700. Brazil
		/// 800. Mexico
		(line  dam3 yr1		 		if region==100 , lw(0.2) lc("`am'%80") lp("-"))
		(line dalyr1 yr1 			if region==100 , lw(0.2) lc("`daly'%80") lp("l"))
		(line dalyr2 yr1			if region==100 , lw(0.2) lc("`daly'%80") lp("-"))
	    (rarea dalyr1 dalyr2 yr1 	if region==100 , lw(none) color("`daly'%15"))

		(line  dam3 yr1		 		if region==200 , lw(0.2) lc("`am'%80") lp("-"))
		(line dalyr1 yr1 			if region==200 , lw(0.2) lc("`daly'%80") lp("l"))
		(line dalyr2 yr1			if region==200 , lw(0.2) lc("`daly'%80") lp("-"))
	    (rarea dalyr1 dalyr2 yr1 	if region==200 , lw(none) color("`daly'%15"))

		(line  dam3 yr1		 		if region==300 , lw(0.2) lc("`am'%80") lp("-"))
		(line dalyr1 yr1 			if region==300 , lw(0.2) lc("`daly'%80") lp("l"))
		(line dalyr2 yr1			if region==300 , lw(0.2) lc("`daly'%80") lp("-"))
	    (rarea dalyr1 dalyr2 yr1 	if region==300 , lw(none) color("`daly'%15"))

		(line  dam3 yr1		 		if region==400 , lw(0.2) lc("`am'%80") lp("-"))
		(line dalyr1 yr1 			if region==400 , lw(0.2) lc("`daly'%80") lp("l"))
		(line dalyr2 yr1			if region==400 , lw(0.2) lc("`daly'%80") lp("-"))
	    (rarea dalyr1 dalyr2 yr1 	if region==400 , lw(none) color("`daly'%15"))

		(line  dam3 yr1		 		if region==500 , lw(0.2) lc("`am'%80") lp("-"))
		(line dalyr1 yr1 			if region==500 & year<2010, lw(0.2) lc("`daly'%80") lp("l"))
		(line dalyr2 yr1			if region==500 & year<2010, lw(0.2) lc("`daly'%80") lp("-"))
		(line dalyr1 yr1 			if region==500 & year>2010, lw(0.2) lc("`daly'%80") lp("l"))
		(line dalyr2 yr1			if region==500 & year>2010, lw(0.2) lc("`daly'%80") lp("-"))
	    (rarea dalyr1 dalyr2 yr1 	if region==500 & year<2010, lw(none) color("`daly'%15"))
	    (rarea dalyr1 dalyr2 yr1 	if region==500 & year>2010, lw(none) color("`daly'%15"))

		(line  dam3 yr1		 		if region==600 , lw(0.2) lc("`am'%80") lp("-"))
		(line dalyr1 yr1 			if region==600 , lw(0.2) lc("`daly'%80") lp("l"))
		(line dalyr2 yr1			if region==600 , lw(0.2) lc("`daly'%80") lp("-"))
	    (rarea dalyr1 dalyr2 yr1 	if region==600 , lw(none) color("`daly'%15"))

		(line  dam3 yr1		 		if region==700 , lw(0.2) lc("`am'%80") lp("-"))
		(line dalyr1 yr1 			if region==700 , lw(0.2) lc("`daly'%80") lp("l"))
		(line dalyr2 yr1			if region==700 , lw(0.2) lc("`daly'%80") lp("-"))
	    (rarea dalyr1 dalyr2 yr1 	if region==700 , lw(none) color("`daly'%15"))

		(line  dam3 yr1		 		if region==800 , lw(0.2) lc("`am'%80") lp("-"))
		(line dalyr1 yr1 			if region==800 , lw(0.2) lc("`daly'%80") lp("l"))
		(line dalyr2 yr1			if region==800 , lw(0.2) lc("`daly'%80") lp("-"))
	    (rarea dalyr1 dalyr2 yr1 	if region==800 , lw(none) color("`daly'%15"))

        /// droplines
       (function y=10500, range(2000 2167) lc(gs12) dropline(2020 2041 2062 2083 2104 2125 2146 2167))

		/// Legend
        /// (function y=875, range(2047 2052) lp("l") lc(gs10) lw(0.4))
        /// (function y=875, range(2060 2065) lp("-") lc(gs10) lw(0.4))
        /// (scatteri `outer1' , recast(area) lw(none) lc("`com'%35") fc("`com'%35")  )
        /// (scatteri `outer2' , recast(area) lw(none) lc("`ncd'%35") fc("`ncd'%35")  )
        /// (scatteri `outer3' , recast(area) lw(none) lc("`daly'%35") fc("`daly'%35")  )
        /// (function y=850, range(2041 2125) lp("l") lc(gs14) lw(0.4))

		/// X-Axis lines
        (function y=-300, range(2000 2019) lp("l") lc(gs12) lw(0.2))
        (function y=-300, range(2021 2040) lp("l") lc(gs12) lw(0.2))
        (function y=-300, range(2042 2061) lp("l") lc(gs12) lw(0.2))
        (function y=-300, range(2063 2082) lp("l") lc(gs12) lw(0.2))
        (function y=-300, range(2084 2103) lp("l") lc(gs12) lw(0.2))
        (function y=-300, range(2105 2124) lp("l") lc(gs12) lw(0.2))
        (function y=-300, range(2126 2145) lp("l") lc(gs12) lw(0.2))
        (function y=-300, range(2147 2166) lp("l") lc(gs12) lw(0.2))
		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 
			ysize(3) xsize(16)

			xlab(none, 
			valuelabel labc(gs0) labs(4) notick nogrid glc(gs16) angle(45) format(%9.0f))
			xscale(noline lw(vthin)) 
			xtitle(" ", size(3) color(gs0) margin(l=1 r=1 t=1 b=1)) 
			
			ylab(0 2000 "2k" 4000 "4k" 6000 "6k" 8000 "8k" 10000 "10k",
			valuelabel labc(gs8) labs(4) tlc(gs8) nogrid glc(gs16) angle(0) format(%9.0f))
			yscale(lw(vthin) lc(gs8) noextend range(-500(500)11000)) 
			ytitle("Disease Burden (DALYs per 100,000) ", color(gs8) size(4) margin(l=1 r=1 t=1 b=1)) 
            ymtick(0(1000)10000)

            /// Region Titles 
            text(9500 2018 "North" "America",  place(w) just(right) size(4) color(gs5))
            text(9500 2039 "Central" "America",  place(w) just(right) size(4) color(gs5))
            text(9500 2060 "Andean",  place(w) just(right) size(4) color(gs5))
            text(9500 2081 "Southern" "Cone",  place(w) just(right) size(4) color(gs5))
            text(9500 2102 "Latin" "Caribbean",  place(w) just(right) size(4) color(gs5))
            text(9500 2123 "non-Latin" "Caribbean",  place(w) just(right) size(4) color(gs5))
            text(9500 2144 "Brazil",  place(w) just(right) size(4) color(gs5))
            text(9500 2165 "Mexico",  place(w) just(right) size(4) color(gs5))

            /// Legend Text
            /// text(875 2057 "Men",  place(w) size(2.5) color(gs8))   
            /// text(875 2072 "Women",  place(w) size(2.5) color(gs8))   
            /// text(875 2087 "CMPN",  place(w) size(2.5) color(gs8))   
            /// text(875 2102 "NCDs",  place(w) size(2.5) color(gs8))   
            /// text(875 2117 "Injuries",  place(w) size(2.5) color(gs8))   

			
	        /// STAR for Latin Caribbean
            text(7000 2093.25 "{&lowast}",  place(e) size(6) color("`daly'"))	
	
			/// X-Axis text
            text(0 2000 "2000",  place(e) size(4) color(gs8))
            text(0 2019 "2019",  place(w) size(4) color(gs8))
            text(0 2021 "2000",  place(e) size(4) color(gs8))
            text(0 2040 "2019",  place(w) size(4) color(gs8))
            text(0 2042 "2000",  place(e) size(4) color(gs8))
            text(0 2061 "2019",  place(w) size(4) color(gs8))
            text(0 2063 "2000",  place(e) size(4) color(gs8))
            text(0 2082 "2019",  place(w) size(4) color(gs8))
            text(0 2084 "2000",  place(e) size(4) color(gs8))
            text(0 2103 "2019",  place(w) size(4) color(gs8))
            text(0 2105 "2000",  place(e) size(4) color(gs8))
            text(0 2124 "2019",  place(w) size(4) color(gs8))
            text(0 2126 "2000",  place(e) size(4) color(gs8))
            text(0 2145 "2019",  place(w) size(4) color(gs8))
            text(0 2147 "2000",  place(e) size(4) color(gs8))
            text(0 2166 "2019",  place(w) size(4) color(gs8))

			/// Text explaining the earthquake year in 2010 in the Latin caribbean
            /// text(370 2095 "Haitian earthquake" " " "Injury rate (men)" "977 per 100k" " " "Injury rate (women)" "614 per 100k",  place(c) size(2.5) color(gs10) just(right))

			legend(off)
			name(figure1b)
			;
#delimit cr	

