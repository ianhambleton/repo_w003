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
    local datapath "C:\Sync\CaribData\My Drive\output\analyse-write\w003\data"

    ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    local logpath "C:\Sync\CaribData\My Drive\output\analyse-write\w003\tech-docs"

    ** REPORTS and Other outputs
    local outputpath "C:\Sync\CaribData\My Drive\output\analyse-write\w003\outputs"

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\chap1-death-060-rate-panel", replace
** HEADER -----------------------------------------------------


** --------------------------------------------
** FIGURE 1A
** ALL
** --------------------------------------------

** Load population file from: 
**      paper2-100-datasets.do 
use "`datapath'/paper2-inj/dataset01", clear
drop paho_subregion daly dths pop_dalyr pop_mortr

** NOTE on 2010 earthquake --> and resulting burden of unintentional injuries
** in Haiti (DALY rate) 
preserve
	keep if year==2010 
	keep if region==19
	keep if ghecause>=1000
	list sex ghecause dalyr, sep(3)
restore

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
local daly `r(p1)'
local am `r(p15)'

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
		(line  dam3 yr1		 		if region==100 , lw(0.3) lc("`am'%80") lp("-"))
		(line dalyr1 yr1 			if region==100 , lw(0.3) lc("`daly'%80") lp("l"))
		(line dalyr2 yr1			if region==100 , lw(0.3) lc("`daly'%80") lp("-"))
	    (rarea dalyr1 dalyr2 yr1 	if region==100 , lw(none) color("`daly'%15"))

		(line  dam3 yr1		 		if region==200 , lw(0.3) lc("`am'%80") lp("-"))
		(line dalyr1 yr1 			if region==200 , lw(0.3) lc("`daly'%80") lp("l"))
		(line dalyr2 yr1			if region==200 , lw(0.3) lc("`daly'%80") lp("-"))
	    (rarea dalyr1 dalyr2 yr1 	if region==200 , lw(none) color("`daly'%15"))

		(line  dam3 yr1		 		if region==300 , lw(0.3) lc("`am'%80") lp("-"))
		(line dalyr1 yr1 			if region==300 , lw(0.3) lc("`daly'%80") lp("l"))
		(line dalyr2 yr1			if region==300 , lw(0.3) lc("`daly'%80") lp("-"))
	    (rarea dalyr1 dalyr2 yr1 	if region==300 , lw(none) color("`daly'%15"))

		(line  dam3 yr1		 		if region==400 , lw(0.3) lc("`am'%80") lp("-"))
		(line dalyr1 yr1 			if region==400 , lw(0.3) lc("`daly'%80") lp("l"))
		(line dalyr2 yr1			if region==400 , lw(0.3) lc("`daly'%80") lp("-"))
	    (rarea dalyr1 dalyr2 yr1 	if region==400 , lw(none) color("`daly'%15"))

		(line  dam3 yr1		 		if region==500 , lw(0.3) lc("`am'%80") lp("-"))
		(line dalyr1 yr1 			if region==500 & year<2010, lw(0.3) lc("`daly'%80") lp("l"))
		(line dalyr2 yr1			if region==500 & year<2010, lw(0.3) lc("`daly'%80") lp("-"))
		(line dalyr1 yr1 			if region==500 & year>2010, lw(0.3) lc("`daly'%80") lp("l"))
		(line dalyr2 yr1			if region==500 & year>2010, lw(0.3) lc("`daly'%80") lp("-"))
	    (rarea dalyr1 dalyr2 yr1 	if region==500 & year<2010, lw(none) color("`daly'%15"))
	    (rarea dalyr1 dalyr2 yr1 	if region==500 & year>2010, lw(none) color("`daly'%15"))

		(line  dam3 yr1		 		if region==600 , lw(0.3) lc("`am'%80") lp("-"))
		(line dalyr1 yr1 			if region==600 , lw(0.3) lc("`daly'%80") lp("l"))
		(line dalyr2 yr1			if region==600 , lw(0.3) lc("`daly'%80") lp("-"))
	    (rarea dalyr1 dalyr2 yr1 	if region==600 , lw(none) color("`daly'%15"))

		(line  dam3 yr1		 		if region==700 , lw(0.3) lc("`am'%80") lp("-"))
		(line dalyr1 yr1 			if region==700 , lw(0.3) lc("`daly'%80") lp("l"))
		(line dalyr2 yr1			if region==700 , lw(0.3) lc("`daly'%80") lp("-"))
	    (rarea dalyr1 dalyr2 yr1 	if region==700 , lw(none) color("`daly'%15"))

		(line  dam3 yr1		 		if region==800 , lw(0.3) lc("`am'%80") lp("-"))
		(line dalyr1 yr1 			if region==800 , lw(0.3) lc("`daly'%80") lp("l"))
		(line dalyr2 yr1			if region==800 , lw(0.3) lc("`daly'%80") lp("-"))
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
        (function y=-300, range(2000 2019) lp("l") lc(gs12) lw(0.3))
        (function y=-300, range(2021 2040) lp("l") lc(gs12) lw(0.3))
        (function y=-300, range(2042 2061) lp("l") lc(gs12) lw(0.3))
        (function y=-300, range(2063 2082) lp("l") lc(gs12) lw(0.3))
        (function y=-300, range(2084 2103) lp("l") lc(gs12) lw(0.3))
        (function y=-300, range(2105 2124) lp("l") lc(gs12) lw(0.3))
        (function y=-300, range(2126 2145) lp("l") lc(gs12) lw(0.3))
        (function y=-300, range(2147 2166) lp("l") lc(gs12) lw(0.3))
		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 
			ysize(3) xsize(16)

			xlab(none, 
			valuelabel labc(gs0) labs(5) notick nogrid glc(gs16) angle(45) format(%9.0f))
			xscale(noline lw(vthin)) 
			xtitle(" ", size(3) color(gs0) margin(l=1 r=1 t=1 b=1)) 
			
			ylab(0 2000 "2k" 4000 "4k" 6000 "6k" 8000 "8k" 10000 "10k",
			valuelabel labc(gs8) labs(5) tlc(gs8) nogrid glc(gs16) angle(0) format(%9.0f))
			yscale(lw(vthin) lc(gs8) noextend range(-500(500)11000)) 
			ytitle("Disease Burden" "(DALYs per 100,000)", color(gs8) size(5) margin(l=1 r=1 t=1 b=1)) 
            ymtick(0(1000)10000)

            /// Region Titles 
            text(9500 2018 "North" "America",  place(w) just(right) size(5) color(gs5))
            text(9500 2039 "Central" "America",  place(w) just(right) size(5) color(gs5))
            text(9500 2060 "Andean",  place(w) just(right) size(5) color(gs5))
            text(9500 2081 "Southern" "Cone",  place(w) just(right) size(5) color(gs5))
            text(9500 2102 "Latin" "Caribbean",  place(w) just(right) size(5) color(gs5))
            text(9500 2123 "non-Latin" "Caribbean",  place(w) just(right) size(5) color(gs5))
            text(9500 2144 "Brazil",  place(w) just(right) size(5) color(gs5))
            text(9500 2165 "Mexico",  place(w) just(right) size(5) color(gs5))

            /// Legend Text
            /// text(875 2057 "Men",  place(w) size(2.5) color(gs8))   
            /// text(875 2072 "Women",  place(w) size(2.5) color(gs8))   
            /// text(875 2087 "CMPN",  place(w) size(2.5) color(gs8))   
            /// text(875 2102 "NCDs",  place(w) size(2.5) color(gs8))   
            /// text(875 2117 "Injuries",  place(w) size(2.5) color(gs8))   

			
	        /// STAR for Latin Caribbean
            text(7000 2093.25 "{&lowast}",  place(e) size(6) color("`daly'"))	
	
			/// X-Axis text
            text(0 2000 "2000",  place(e) size(5) color(gs8))
            text(0 2019 "2019",  place(w) size(5) color(gs8))
            text(0 2021 "2000",  place(e) size(5) color(gs8))
            text(0 2040 "2019",  place(w) size(5) color(gs8))
            text(0 2042 "2000",  place(e) size(5) color(gs8))
            text(0 2061 "2019",  place(w) size(5) color(gs8))
            text(0 2063 "2000",  place(e) size(5) color(gs8))
            text(0 2082 "2019",  place(w) size(5) color(gs8))
            text(0 2084 "2000",  place(e) size(5) color(gs8))
            text(0 2103 "2019",  place(w) size(5) color(gs8))
            text(0 2105 "2000",  place(e) size(5) color(gs8))
            text(0 2124 "2019",  place(w) size(5) color(gs8))
            text(0 2126 "2000",  place(e) size(5) color(gs8))
            text(0 2145 "2019",  place(w) size(5) color(gs8))
            text(0 2147 "2000",  place(e) size(5) color(gs8))
            text(0 2166 "2019",  place(w) size(5) color(gs8))

			/// Text explaining the earthquake year in 2010 in the Latin caribbean
            /// text(370 2095 "Haitian earthquake" " " "Injury rate (men)" "977 per 100k" " " "Injury rate (women)" "614 per 100k",  place(c) size(2.5) color(gs10) just(right))

			legend(off)
			name(figure1a)
			;
			graph export "`outputpath'/articles/paper-injury/figure1a.png", replace width(4000);
#delimit cr	




** --------------------------------------------
** FIGURE 1B
** UNINTENTIONAL
** --------------------------------------------


** Load population file from: 
**      paper2-100-datasets.do 
use "`datapath'/paper2-inj/dataset01", clear
drop paho_subregion daly dths pop_dalyr pop_mortr

** Keep sub-regional level (this will keep the 8 PAHO subregions of the Americas)
keep if (region>=100 & region <1000) | region==2000

** Keep 1100 Unintentional Injuries
keep if ghecause==1100
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
local daly `r(p3)'
local am `r(p15)'

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
		(line  dam3 yr1		 		if region==100 , lw(0.3) lc("`am'%80") lp("-"))
		(line dalyr1 yr1 			if region==100 , lw(0.3) lc("`daly'%80") lp("l"))
		(line dalyr2 yr1			if region==100 , lw(0.3) lc("`daly'%80") lp("-"))
	    (rarea dalyr1 dalyr2 yr1 	if region==100 , lw(none) color("`daly'%15"))

		(line  dam3 yr1		 		if region==200 , lw(0.3) lc("`am'%80") lp("-"))
		(line dalyr1 yr1 			if region==200 , lw(0.3) lc("`daly'%80") lp("l"))
		(line dalyr2 yr1			if region==200 , lw(0.3) lc("`daly'%80") lp("-"))
	    (rarea dalyr1 dalyr2 yr1 	if region==200 , lw(none) color("`daly'%15"))

		(line  dam3 yr1		 		if region==300 , lw(0.3) lc("`am'%80") lp("-"))
		(line dalyr1 yr1 			if region==300 , lw(0.3) lc("`daly'%80") lp("l"))
		(line dalyr2 yr1			if region==300 , lw(0.3) lc("`daly'%80") lp("-"))
	    (rarea dalyr1 dalyr2 yr1 	if region==300 , lw(none) color("`daly'%15"))

		(line  dam3 yr1		 		if region==400 , lw(0.3) lc("`am'%80") lp("-"))
		(line dalyr1 yr1 			if region==400 , lw(0.3) lc("`daly'%80") lp("l"))
		(line dalyr2 yr1			if region==400 , lw(0.3) lc("`daly'%80") lp("-"))
	    (rarea dalyr1 dalyr2 yr1 	if region==400 , lw(none) color("`daly'%15"))

		(line  dam3 yr1		 		if region==500 , lw(0.3) lc("`am'%80") lp("-"))
		(line dalyr1 yr1 			if region==500 & year<2010, lw(0.3) lc("`daly'%80") lp("l"))
		(line dalyr2 yr1			if region==500 & year<2010, lw(0.3) lc("`daly'%80") lp("-"))
		(line dalyr1 yr1 			if region==500 & year>2010, lw(0.3) lc("`daly'%80") lp("l"))
		(line dalyr2 yr1			if region==500 & year>2010, lw(0.3) lc("`daly'%80") lp("-"))
	    (rarea dalyr1 dalyr2 yr1 	if region==500 & year<2010, lw(none) color("`daly'%15"))
	    (rarea dalyr1 dalyr2 yr1 	if region==500 & year>2010, lw(none) color("`daly'%15"))

		(line  dam3 yr1		 		if region==600 , lw(0.3) lc("`am'%80") lp("-"))
		(line dalyr1 yr1 			if region==600 , lw(0.3) lc("`daly'%80") lp("l"))
		(line dalyr2 yr1			if region==600 , lw(0.3) lc("`daly'%80") lp("-"))
	    (rarea dalyr1 dalyr2 yr1 	if region==600 , lw(none) color("`daly'%15"))

		(line  dam3 yr1		 		if region==700 , lw(0.3) lc("`am'%80") lp("-"))
		(line dalyr1 yr1 			if region==700 , lw(0.3) lc("`daly'%80") lp("l"))
		(line dalyr2 yr1			if region==700 , lw(0.3) lc("`daly'%80") lp("-"))
	    (rarea dalyr1 dalyr2 yr1 	if region==700 , lw(none) color("`daly'%15"))

		(line  dam3 yr1		 		if region==800 , lw(0.3) lc("`am'%80") lp("-"))
		(line dalyr1 yr1 			if region==800 , lw(0.3) lc("`daly'%80") lp("l"))
		(line dalyr2 yr1			if region==800 , lw(0.3) lc("`daly'%80") lp("-"))
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
        (function y=-300, range(2000 2019) lp("l") lc(gs12) lw(0.3))
        (function y=-300, range(2021 2040) lp("l") lc(gs12) lw(0.3))
        (function y=-300, range(2042 2061) lp("l") lc(gs12) lw(0.3))
        (function y=-300, range(2063 2082) lp("l") lc(gs12) lw(0.3))
        (function y=-300, range(2084 2103) lp("l") lc(gs12) lw(0.3))
        (function y=-300, range(2105 2124) lp("l") lc(gs12) lw(0.3))
        (function y=-300, range(2126 2145) lp("l") lc(gs12) lw(0.3))
        (function y=-300, range(2147 2166) lp("l") lc(gs12) lw(0.3))
		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 
			ysize(3) xsize(16)

			xlab(none, 
			valuelabel labc(gs0) labs(5) notick nogrid glc(gs16) angle(45) format(%9.0f))
			xscale(noline lw(vthin)) 
			xtitle(" ", size(3) color(gs0) margin(l=1 r=1 t=1 b=1)) 
			
			ylab(0 2000 "2k" 4000 "4k" 6000 "6k" 8000 "8k" 10000 "10k",
			valuelabel labc(gs8) labs(5) tlc(gs8) nogrid glc(gs16) angle(0) format(%9.0f))
			yscale(lw(vthin) lc(gs8) noextend range(-500(500)11000)) 
			ytitle("Disease Burden" "(DALYs per 100,000)", color(gs8) size(5) margin(l=1 r=1 t=1 b=1)) 
            ymtick(0(1000)10000)

            /// Region Titles 
            text(9500 2018 "North" "America",  place(w) just(right) size(5) color(gs5))
            text(9500 2039 "Central" "America",  place(w) just(right) size(5) color(gs5))
            text(9500 2060 "Andean",  place(w) just(right) size(5) color(gs5))
            text(9500 2081 "Southern" "Cone",  place(w) just(right) size(5) color(gs5))
            text(9500 2102 "Latin" "Caribbean",  place(w) just(right) size(5) color(gs5))
            text(9500 2123 "non-Latin" "Caribbean",  place(w) just(right) size(5) color(gs5))
            text(9500 2144 "Brazil",  place(w) just(right) size(5) color(gs5))
            text(9500 2165 "Mexico",  place(w) just(right) size(5) color(gs5))

            /// Legend Text
            /// text(875 2057 "Men",  place(w) size(2.5) color(gs8))   
            /// text(875 2072 "Women",  place(w) size(2.5) color(gs8))   
            /// text(875 2087 "CMPN",  place(w) size(2.5) color(gs8))   
            /// text(875 2102 "NCDs",  place(w) size(2.5) color(gs8))   
            /// text(875 2117 "Injuries",  place(w) size(2.5) color(gs8))   

			
	        /// STAR for Latin Caribbean
            text(4600 2093.25 "{&lowast}",  place(e) size(6) color("`daly'"))	
	
			/// X-Axis text
            text(0 2000 "2000",  place(e) size(5) color(gs8))
            text(0 2019 "2019",  place(w) size(5) color(gs8))
            text(0 2021 "2000",  place(e) size(5) color(gs8))
            text(0 2040 "2019",  place(w) size(5) color(gs8))
            text(0 2042 "2000",  place(e) size(5) color(gs8))
            text(0 2061 "2019",  place(w) size(5) color(gs8))
            text(0 2063 "2000",  place(e) size(5) color(gs8))
            text(0 2082 "2019",  place(w) size(5) color(gs8))
            text(0 2084 "2000",  place(e) size(5) color(gs8))
            text(0 2103 "2019",  place(w) size(5) color(gs8))
            text(0 2105 "2000",  place(e) size(5) color(gs8))
            text(0 2124 "2019",  place(w) size(5) color(gs8))
            text(0 2126 "2000",  place(e) size(5) color(gs8))
            text(0 2145 "2019",  place(w) size(5) color(gs8))
            text(0 2147 "2000",  place(e) size(5) color(gs8))
            text(0 2166 "2019",  place(w) size(5) color(gs8))

			/// Text explaining the earthquake year in 2010 in the Latin caribbean
            /// text(370 2095 "Haitian earthquake" " " "Injury rate (men)" "977 per 100k" " " "Injury rate (women)" "614 per 100k",  place(c) size(2.5) color(gs10) just(right))

			legend(off)
			name(figure1b)
			;
			graph export "`outputpath'/articles/paper-injury/figure1b.png", replace width(4000);
#delimit cr	




** --------------------------------------------
** FIGURE 1C
** INTENTIONAL
** --------------------------------------------

** Load population file from: 
**      paper2-100-datasets.do 
use "`datapath'/paper2-inj/dataset01", clear
drop paho_subregion daly dths pop_dalyr pop_mortr

** Keep sub-regional level (this will keep the 8 PAHO subregions of the Americas)
keep if (region>=100 & region <1000) | region==2000

** Keep 1100 Intentional Injuries
keep if ghecause==1200
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
local daly `r(p17)'
local am `r(p15)'

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
		(line  dam3 yr1		 		if region==100 , lw(0.3) lc("`am'%80") lp("-"))
		(line dalyr1 yr1 			if region==100 , lw(0.3) lc("`daly'%80") lp("l"))
		(line dalyr2 yr1			if region==100 , lw(0.3) lc("`daly'%80") lp("-"))
	    (rarea dalyr1 dalyr2 yr1 	if region==100 , lw(none) color("`daly'%15"))

		(line  dam3 yr1		 		if region==200 , lw(0.3) lc("`am'%80") lp("-"))
		(line dalyr1 yr1 			if region==200 , lw(0.3) lc("`daly'%80") lp("l"))
		(line dalyr2 yr1			if region==200 , lw(0.3) lc("`daly'%80") lp("-"))
	    (rarea dalyr1 dalyr2 yr1 	if region==200 , lw(none) color("`daly'%15"))

		(line  dam3 yr1		 		if region==300 , lw(0.3) lc("`am'%80") lp("-"))
		(line dalyr1 yr1 			if region==300 , lw(0.3) lc("`daly'%80") lp("l"))
		(line dalyr2 yr1			if region==300 , lw(0.3) lc("`daly'%80") lp("-"))
	    (rarea dalyr1 dalyr2 yr1 	if region==300 , lw(none) color("`daly'%15"))

		(line  dam3 yr1		 		if region==400 , lw(0.3) lc("`am'%80") lp("-"))
		(line dalyr1 yr1 			if region==400 , lw(0.3) lc("`daly'%80") lp("l"))
		(line dalyr2 yr1			if region==400 , lw(0.3) lc("`daly'%80") lp("-"))
	    (rarea dalyr1 dalyr2 yr1 	if region==400 , lw(none) color("`daly'%15"))

		(line  dam3 yr1		 		if region==500 , lw(0.3) lc("`am'%80") lp("-"))
		(line dalyr1 yr1 			if region==500 , lw(0.3) lc("`daly'%80") lp("l"))
		(line dalyr2 yr1			if region==500 , lw(0.3) lc("`daly'%80") lp("-"))
	    (rarea dalyr1 dalyr2 yr1 	if region==500 , lw(none) color("`daly'%15"))
		
		/// (line  dam3 yr1		 		if region==500 , lw(0.3) lc("`am'%80") lp("-"))
		/// (line dalyr1 yr1 			if region==500 & year<2010, lw(0.3) lc("`daly'%80") lp("l"))
		/// (line dalyr2 yr1			if region==500 & year<2010, lw(0.3) lc("`daly'%80") lp("-"))
		/// (line dalyr1 yr1 			if region==500 & year>2010, lw(0.3) lc("`daly'%80") lp("l"))
		/// (line dalyr2 yr1			if region==500 & year>2010, lw(0.3) lc("`daly'%80") lp("-"))
	    /// (rarea dalyr1 dalyr2 yr1 	if region==500 & year<2010, lw(none) color("`daly'%15"))
	    /// (rarea dalyr1 dalyr2 yr1 	if region==500 & year>2010, lw(none) color("`daly'%15"))

		(line  dam3 yr1		 		if region==600 , lw(0.3) lc("`am'%80") lp("-"))
		(line dalyr1 yr1 			if region==600 , lw(0.3) lc("`daly'%80") lp("l"))
		(line dalyr2 yr1			if region==600 , lw(0.3) lc("`daly'%80") lp("-"))
	    (rarea dalyr1 dalyr2 yr1 	if region==600 , lw(none) color("`daly'%15"))

		(line  dam3 yr1		 		if region==700 , lw(0.3) lc("`am'%80") lp("-"))
		(line dalyr1 yr1 			if region==700 , lw(0.3) lc("`daly'%80") lp("l"))
		(line dalyr2 yr1			if region==700 , lw(0.3) lc("`daly'%80") lp("-"))
	    (rarea dalyr1 dalyr2 yr1 	if region==700 , lw(none) color("`daly'%15"))

		(line  dam3 yr1		 		if region==800 , lw(0.3) lc("`am'%80") lp("-"))
		(line dalyr1 yr1 			if region==800 , lw(0.3) lc("`daly'%80") lp("l"))
		(line dalyr2 yr1			if region==800 , lw(0.3) lc("`daly'%80") lp("-"))
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
        (function y=-300, range(2000 2019) lp("l") lc(gs12) lw(0.3))
        (function y=-300, range(2021 2040) lp("l") lc(gs12) lw(0.3))
        (function y=-300, range(2042 2061) lp("l") lc(gs12) lw(0.3))
        (function y=-300, range(2063 2082) lp("l") lc(gs12) lw(0.3))
        (function y=-300, range(2084 2103) lp("l") lc(gs12) lw(0.3))
        (function y=-300, range(2105 2124) lp("l") lc(gs12) lw(0.3))
        (function y=-300, range(2126 2145) lp("l") lc(gs12) lw(0.3))
        (function y=-300, range(2147 2166) lp("l") lc(gs12) lw(0.3))
		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 
			ysize(3) xsize(16)

			xlab(none, 
			valuelabel labc(gs0) labs(5) notick nogrid glc(gs16) angle(45) format(%9.0f))
			xscale(noline lw(vthin)) 
			xtitle(" ", size(3) color(gs0) margin(l=1 r=1 t=1 b=1)) 
			
			ylab(0 2000 "2k" 4000 "4k" 6000 "6k" 8000 "8k" 10000 "10k",
			valuelabel labc(gs8) labs(5) tlc(gs8) nogrid glc(gs16) angle(0) format(%9.0f))
			yscale(lw(vthin) lc(gs8) noextend range(-500(500)11000)) 
			ytitle("Disease Burden" "(DALYs per 100,000)", color(gs8) size(5) margin(l=1 r=1 t=1 b=1)) 
            ymtick(0(1000)10000)

            /// Region Titles 
            text(9500 2018 "North" "America",  place(w) just(right) size(5) color(gs5))
            text(9500 2039 "Central" "America",  place(w) just(right) size(5) color(gs5))
            text(9500 2060 "Andean",  place(w) just(right) size(5) color(gs5))
            text(9500 2081 "Southern" "Cone",  place(w) just(right) size(5) color(gs5))
            text(9500 2102 "Latin" "Caribbean",  place(w) just(right) size(5) color(gs5))
            text(9500 2123 "non-Latin" "Caribbean",  place(w) just(right) size(5) color(gs5))
            text(9500 2144 "Brazil",  place(w) just(right) size(5) color(gs5))
            text(9500 2165 "Mexico",  place(w) just(right) size(5) color(gs5))

            /// Legend Text
            /// text(875 2057 "Men",  place(w) size(2.5) color(gs8))   
            /// text(875 2072 "Women",  place(w) size(2.5) color(gs8))   
            /// text(875 2087 "CMPN",  place(w) size(2.5) color(gs8))   
            /// text(875 2102 "NCDs",  place(w) size(2.5) color(gs8))   
            /// text(875 2117 "Injuries",  place(w) size(2.5) color(gs8))   

			
	        /// STAR for Latin Caribbean
            /// text(4600 2093.25 "{&lowast}",  place(e) size(6) color("`daly'"))	
	
			/// X-Axis text
            text(0 2000 "2000",  place(e) size(5) color(gs8))
            text(0 2019 "2019",  place(w) size(5) color(gs8))
            text(0 2021 "2000",  place(e) size(5) color(gs8))
            text(0 2040 "2019",  place(w) size(5) color(gs8))
            text(0 2042 "2000",  place(e) size(5) color(gs8))
            text(0 2061 "2019",  place(w) size(5) color(gs8))
            text(0 2063 "2000",  place(e) size(5) color(gs8))
            text(0 2082 "2019",  place(w) size(5) color(gs8))
            text(0 2084 "2000",  place(e) size(5) color(gs8))
            text(0 2103 "2019",  place(w) size(5) color(gs8))
            text(0 2105 "2000",  place(e) size(5) color(gs8))
            text(0 2124 "2019",  place(w) size(5) color(gs8))
            text(0 2126 "2000",  place(e) size(5) color(gs8))
            text(0 2145 "2019",  place(w) size(5) color(gs8))
            text(0 2147 "2000",  place(e) size(5) color(gs8))
            text(0 2166 "2019",  place(w) size(5) color(gs8))

			/// Text explaining the earthquake year in 2010 in the Latin caribbean
            /// text(370 2095 "Haitian earthquake" " " "Injury rate (men)" "977 per 100k" " " "Injury rate (women)" "614 per 100k",  place(c) size(2.5) color(gs10) just(right))

			legend(off)
			name(figure1c)
			;
			graph export "`outputpath'/articles/paper-injury/figure1c.png", replace width(4000);
#delimit cr	


/// ** -----------------------------------------------------------------------------
/// ** LEGEND
/// ** -----------------------------------------------------------------------------
/// ** generate a local for the ColorBrewer color scheme
/// colorpalette d3, 20 n(20) nograph
/// local list r(p) 
/// local inj `r(p1)'
/// local inju `r(p3)'
/// local inji `r(p17)'
/// local am `r(p15)'
/// 
/// 
/// ** Legend outer limits for graphing 
/// local outer1 10 13   12 13   12 15   10 15   10 13
/// local outer2 10 15.5   12 15.5   12 17.5   10 17.5   10 15.5
/// local outer3 10 18   12 18   12 20   10 20   10 18
/// 
/// #delimit ;
/// 	gr twoway 
/// 		/// Legend
///         (function y=10, range(1 4) lp("l") lc("`inj'") lw(2))
///         (function y=11, range(1 4) lp("l") lc("`inju'") lw(2))
///         (function y=12, range(1 4) lp("l") lc("`inji'") lw(2))
///         (function y=10, range(11 14) lp("-") lc("`inj'") lw(2))
///         (function y=11, range(11 14) lp("-") lc("`inju'") lw(2))
///         (function y=12, range(11 14) lp("-") lc("`inji'") lw(2))
///         (function y=11.5, range(23 26) lp("-") lc("`am'") lw(2))
///         (scatteri `outer1' , recast(area) lw(none) lc("`inj'%35") fc("`inj'%35")  )
///         (scatteri `outer2' , recast(area) lw(none) lc("`inju'%35") fc("`inju'%35")  )
///         (scatteri `outer3' , recast(area) lw(none) lc("`inji'%35") fc("`inji'%35")  )
/// 
/// 		,
/// 			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 		
/// 			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 
/// 			ysize(3) xsize(16)
/// 
/// 			xlab(none, 
/// 			valuelabel labc(gs0) labs(5) notick nogrid glc(gs16) angle(45) format(%9.0f))
/// 			xscale(noline lw(vthin) range(0(1)29)) 
/// 			xtitle(" ", size(3) color(gs0) margin(l=1 r=1 t=1 b=1)) 
/// 			
/// 			ylab(none,
/// 			valuelabel labc(gs8) labs(5) tlc(gs8) nogrid glc(gs16) angle(0) format(%9.0f))
/// 			yscale(noline lw(vthin) lc(gs8) noextend range(9.5(1)14)) 
/// 			ytitle("", color(gs8) size(5) margin(l=1 r=1 t=1 b=1)) 
///             ///ymtick(0(1000)10000)
/// 
/// 
///             /// Legend Text
///             text(12 5 "Men",  place(e) size(30) color(gs8))   
///             text(13 15 "Women",  place(e) size(30) color(gs8))   
///             text(13 13 "Difference between",  place(e) size(10) color(gs8))   
///             text(12.45 13 "Women and Men",  place(e) size(10) color(gs8))   
///             text(13 23 "Americas",  place(e) size(10) color(gs8))   
///             text(12.45 23 "average",  place(e) size(10) color(gs8))   
/// 
/// 			legend(off)
/// 			name(legend)
/// 			;
/// 			graph export "`outputpath'/articles/paper-injury/legend.png", replace width(4000);
/// #delimit cr	





** ------------------------------------------------------
** FIGURE 1: PDF
** ------------------------------------------------------
** CONSTRUCT SINGLE GRAPHIC FROM PANELS
** ------------------------------------------------------
    putpdf begin, pagesize(letter) landscape font("Calibri Light", 10) margin(top,0.5cm) margin(bottom,0.5cm) margin(left,0.5cm) margin(right,0.5cm)
** PAGE 1. INTRODUCTION
    putpdf paragraph ,  font("Calibri Light", 10)
    putpdf text ("Figure 1. ") , bold
    putpdf text ("Burden of injuries, unintentional injuries and intentional injuries between 2000 and 2019 in 8 subregions of the Americas, measured using Disability Adjusted life Years (DALY) rate per 100,000. ")
    putpdf text ("(Men: "), italic 
	putpdf text ("solid lines, ")
    putpdf text ("Women: "), italic 
	putpdf text ("dotted lines, ")
    putpdf text ("Difference between women and men: "), italic 
	putpdf text ("shaded regions, ")
    putpdf text ("Average for The Americas: "), italic 
	putpdf text ("grey line). ")

** LEGEND
    ///putpdf table f1 = (1,1), width(25%) border(all,single) halign(right)
    ///putpdf table f1(1,1)=image("`outputpath'/articles/paper-injury/article-draft/legend.png")

** FIGURE OF DAILY COVID-19 COUNT
    putpdf table f2 = (6,1), width(95%) border(all,nil) halign(center)
    putpdf table f2(1,1)=("(A) All injuries")
    putpdf table f2(3,1)=("(B) Unintentionl injuries")
    putpdf table f2(5,1)=("(C) Intentional injuries")
    putpdf table f2(2,1)=image("`outputpath'/articles/paper-injury/figure1a.png")
    putpdf table f2(4,1)=image("`outputpath'/articles/paper-injury/figure1b.png")
    putpdf table f2(6,1)=image("`outputpath'/articles/paper-injury/figure1c.png")

** FOOTNOTE
    putpdf paragraph ,  font("Calibri Light", 9)
    putpdf text ("* Note: ") , italic linebreak
    putpdf text ("Haitian earthquake in 2010 raised the injury burden (DALY rate per 100,000) to 168 thousand among men and 103 thousand among women") , italic

** Save the PDF
    local c_date = c(current_date)
    local date_string = subinstr("`c_date'", " ", "", .)
    ** putpdf save "`outputpath'/Figure_One_SS_`date_string'_grayscale", replace
    putpdf save "`outputpath'/articles/paper-injury/article-draft/Figure_1_`date_string'_color", replace

