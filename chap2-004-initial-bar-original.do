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
    local datapath "C:\yasuki\Sync\output\analyse-write\w003\data"

    ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    local logpath "C:\yasuki\Sync\output\analyse-write\w003\tech-docs"

    ** REPORTS and Other outputs
    local outputpath "C:\yasuki\Sync\output\analyse-write\w003\outputs"

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\chap2-004-initial-bar", replace
** HEADER -----------------------------------------------------

tempfile t1

** 15-Sep-2021
** NOTE
** We don't need the final -chap2_000_adjusted- dataset as we're just using DEATHS and DALYs 
** In this initial Chapter 2 overview.

** Mortality COUNT 
use "`datapath'\from-who\chap2_000_mr", clear
rename cases dths
keep year sex ghecause region dths 
save `t1', replace 

** DALY COUNT
use "`datapath'\from-who\chap2_000_daly", clear
rename cases daly
keep year sex ghecause region daly 
merge 1:1 year sex ghecause region using `t1' 
drop _merge
format daly %15.1fc
format dths %15.1fc

/// ** Restrict
/// keep if sex<3
/// keep if region==2000

** 100 all-cause
** 200 Communicable, maternal etc
** 400 CVD
** 500 Cancer
** 600 respiratory
** 700/31 Diabetes
** 800 mental / neurological
** 900 Injuries

#delimit ;
keep if ghecause==100 |
        ghecause==200 |
        ghecause==300 |
        ghecause==400 |
        ghecause==500 |
        ghecause==600 |
        ghecause==31  |
        ghecause==800 |
        ghecause==900 |
        ghecause==1000 ;
recode ghecause (100=1) (200=2) (300=9) (400=3) (500=4) (600=5) (31=6) (800 900=7) (1000=8);
label define ghecause_ 
                        1 "all cause"
                        2 "communicable"
                        3 "CVD"
                        4 "Cancers"
                        5 "Chronic Respiratory Diseases"
                        6 "Diabetes"
                        7 "Mental Health / Neurological"
                        8 "External Causes"
                        9 "NCDs", modify;
#delimit cr

** Collapse to sum mental health and neurological 
collapse (sum) dths daly, by(year sex ghecause region)
sort region ghecause sex year


** --------------------------
** Associated statistics
** --------------------------
** Percentage of death / disability due to ALL 6 GROUPS
** Women and men combined
preserve
    keep if sex==3 & region==2000
    keep if year==2000 | year==2019 
    reshape wide dths daly , i(year sex) j(ghecause) 
    
    forval x = 2(1)9 {
        gen pdths`x' = (dths`x'/dths1)*100
        gen pdaly`x' = (daly`x'/daly1)*100
        sort pdths`x'
        list year pdths`x'
        sort pdaly`x'
        list year pdaly`x' 
    }
    order year pdths* pdaly*
    egen pdths_groups = rowtotal( pdths3 pdths4 pdths5 pdths6 pdths7 pdths8)
    egen pdaly_groups = rowtotal( pdaly3 pdaly4 pdaly5 pdaly6 pdaly7 pdaly8)
    list year pdths_*, linesize(150)
    list year pdaly_*, linesize(150)
restore

** Percentage of death / disability due to each condition
** Women and men combined
preserve
    keep if sex==3 & region==2000
    keep if year==2000 | year==2019 
    reshape wide dths daly , i(year sex) j(ghecause) 
    ///egen tdeath = rowtotal(dths3 dths4 dths5 dths6 dths7 dths8)
    ///egen tdaly = rowtotal(daly3 daly4 daly5 daly6 daly7 daly8) 
    
    forval x = 2(1)9 {
        gen pdths`x' = (dths`x'/dths1)*100
        gen pdaly`x' = (daly`x'/daly1)*100
        sort pdths`x'
        list year pdths`x'
        sort pdaly`x'
        list year pdaly`x' 
    }
    order year pdths* pdaly*
    gen pdths34 = pdths3 + pdths4
    egen pdths_all = rowtotal(pdths2 pdths3 pdths4 pdths5 pdths6 pdths7 pdths8)
    egen pdaly_all = rowtotal(pdaly2 pdaly3 pdaly4 pdaly5 pdaly6 pdaly7 pdaly8)
    order pdths34, after(pdths4)
    list year pdths*, linesize(150)
    list year pdaly*, linesize(150)
restore

** Percentage of death / disability due to NCDs and External Causes
** Women and men combined
preserve
    keep if sex==3 & region==2000
    keep if year==2000 | year==2019 
    reshape wide dths daly , i(year sex) j(ghecause) 
    gen ncd_inj1 = dths8 + dths9
    gen ncd_inj2 = daly8 + daly9
    format ncd_inj1 %12.1fc
    
    gen pdths = (ncd_inj1/dths1)*100
    gen pdaly = (ncd_inj2/daly1)*100
    sort pdths
    list year pdths
    sort pdaly
    list year pdaly 
restore

** Percentage of death / disability due to each condition
** Women
preserve
    keep if sex==2 & region==2000
    keep if year==2000 | year==2019 
    reshape wide dths daly , i(year sex) j(ghecause) 
    ///egen tdeath = rowtotal(dths3 dths4 dths5 dths6 dths7 dths8)
    ///egen tdaly = rowtotal(daly3 daly4 daly5 daly6 daly7 daly8) 
    
    forval x = 2(1)9 {
        gen pdths`x' = (dths`x'/dths1)*100
        gen pdaly`x' = (daly`x'/daly1)*100
        sort pdths`x'
        list year pdths`x'
        sort pdaly`x'
        list year pdaly`x' 
    }
    order year pdths* pdaly*
    gen pdths34 = pdths3 + pdths4
    egen pdths_all = rowtotal(pdths2 pdths3 pdths4 pdths5 pdths6 pdths7 pdths8)
    egen pdaly_all = rowtotal(pdaly2 pdaly3 pdaly4 pdaly5 pdaly6 pdaly7 pdaly8)
    order pdths34, after(pdths4)
    list year pdths*, linesize(150)
    list year pdaly*, linesize(150)
restore

** Percentage of death / disability due to each condition
** Men
preserve
    keep if sex==1 & region==2000
    keep if year==2000 | year==2019 
    reshape wide dths daly , i(year sex) j(ghecause) 
    ///egen tdeath = rowtotal(dths3 dths4 dths5 dths6 dths7 dths8)
    ///egen tdaly = rowtotal(daly3 daly4 daly5 daly6 daly7 daly8) 
    
    forval x = 2(1)9 {
        gen pdths`x' = (dths`x'/dths1)*100
        gen pdaly`x' = (daly`x'/daly1)*100
        sort pdths`x'
        list year pdths`x'
        sort pdaly`x'
        list year pdaly`x' 
    }
    order year pdths* pdaly*
    gen pdths34 = pdths3 + pdths4
    egen pdths_all = rowtotal(pdths2 pdths3 pdths4 pdths5 pdths6 pdths7 pdths8)
    egen pdaly_all = rowtotal(pdaly2 pdaly3 pdaly4 pdaly5 pdaly6 pdaly7 pdaly8)
    order pdths34, after(pdths4)
    list year pdths*, linesize(150)
    list year pdaly*, linesize(150)
restore


** Percentage increase 2000 to 2019
preserve
    keep if sex==3 & region==2000
    keep if year==2000 | year==2019 
    replace dths = dths * (-1) 
    reshape wide dths daly , i(ghecause sex) j(year) 
    gen pdths = ((dths2019-dths2000)/dths2000)*100
    gen pdaly = ((daly2019-daly2000)/daly2000)*100
    sort pdths
    list ghecause pdths
    sort pdaly
    list ghecause pdaly 
restore



** Restrict for production of graphic
keep if sex<3
keep if region==2000

** -------------------------------------------------------------------
** GRAPHIC
** -------------------------------------------------------------------

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

** Legend outer boundaries 
local outer1 695 2013 730 2013 730 2018 695 2018 695 2013
local outer2 635 2013 670 2013 670 2018 635 2018 635 2013
local outer3 575 2013 610 2013 610 2018 575 2018 575 2013

** DEATHS will be NEGATIVE ON X-AXIS to give the chart
** a 'population-pyramid' style
replace dths = dths * (-1) 

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

local yaxis 2003 3900000 2034 3900000 
local yaxis_sym 2034 3900000 

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
        (line yr dths if ghecause==3 & sex==1,  lw(0.25) lc("`cvd1'%75") lp("l"))
		(line yr dths if ghecause==3 & sex==2 , lw(0.25) lc("`cvd1'%75") lp("-"))
        (line yr dths if ghecause==4 & sex==1,  lw(0.25) lc("`can1'%75") lp("l"))
		(line yr dths if ghecause==4 & sex==2 , lw(0.25) lc("`can1'%75") lp("-"))
        (line yr dths if ghecause==5 & sex==1,  lw(0.25) lc("`crd1'%75") lp("l"))
		(line yr dths if ghecause==5 & sex==2 , lw(0.25) lc("`crd1'%75") lp("-"))
        (line yr dths if ghecause==6 & sex==1,  lw(0.25) lc("`dia1'%75") lp("l"))
		(line yr dths if ghecause==6 & sex==2 , lw(0.25) lc("`dia1'%75") lp("-"))
        (line yr dths if ghecause==7 & sex==1,  lw(0.25) lc("`men1'%75") lp("l"))
		(line yr dths if ghecause==7 & sex==2 , lw(0.25) lc("`men1'%75") lp("-"))
        (line yr dths if ghecause==8 & sex==1,  lw(0.25) lc("`inj1'%75") lp("l"))
		(line yr dths if ghecause==8 & sex==2 , lw(0.25) lc("`inj1'%75") lp("-"))

        (line yr daly2 if ghecause==3 & sex==1,  lw(0.25) lc("`cvd2'%75") lp("l"))
		(line yr daly2 if ghecause==3 & sex==2 , lw(0.25) lc("`cvd2'%75") lp("-"))
        (line yr daly2 if ghecause==4 & sex==1,  lw(0.25) lc("`can2'%75") lp("l"))
		(line yr daly2 if ghecause==4 & sex==2 , lw(0.25) lc("`can2'%75") lp("-"))
        (line yr daly2 if ghecause==5 & sex==1,  lw(0.25) lc("`crd2'%75") lp("l"))
		(line yr daly2 if ghecause==5 & sex==2 , lw(0.25) lc("`crd2'%75") lp("-"))
        (line yr daly2 if ghecause==6 & sex==1,  lw(0.25) lc("`dia2'%75") lp("l"))
		(line yr daly2 if ghecause==6 & sex==2 , lw(0.25) lc("`dia2'%75") lp("-"))
        (line yr daly2 if ghecause==7 & sex==1,  lw(0.25) lc("`men2'%75") lp("l"))
		(line yr daly2 if ghecause==7 & sex==2 , lw(0.25) lc("`men2'%75") lp("-"))
        (line yr daly2 if ghecause==8 & sex==1,  lw(0.25) lc("`inj2'%75") lp("l"))
		(line yr daly2 if ghecause==8 & sex==2 , lw(0.25) lc("`inj2'%75") lp("-"))

        /// PANEL Borders
        (scatteri `outer1' , recast(area) lw(0.1) lc(gs10) fc(none) lp("l") )
        (scatteri `outer2a' , recast(line) lw(0.1) lc(gs10) fc(none) lp("l") )
        (scatteri `outer2b' , recast(line) lw(0.1) lc(gs10) fc(none) lp("l") )
        (scatteri `outer2c' , recast(line) lw(0.1) lc(gs10) fc(none) lp("l") )
        (scatteri `outer3a' , recast(line) lw(0.1) lc(gs10) fc(none) lp("l") )
        (scatteri `outer3b' , recast(line) lw(0.1) lc(gs10) fc(none) lp("l"))
        (scatteri `outer3c' , recast(line) lw(0.1) lc(gs10) fc(none) lp("l") )
        (scatteri `outer4a' , recast(line) lw(0.1) lc(gs10) fc(none) lp("l") )
        (scatteri `outer4b' , recast(line) lw(0.1) lc(gs10) fc(none) lp("l") )
        (scatteri `outer4c' , recast(line) lw(0.1) lc(gs10) fc(none) lp("l") )
        (scatteri `outer5a' , recast(line) lw(0.1) lc(gs10) fc(none) lp("l") )
        (scatteri `outer5b' , recast(line) lw(0.1) lc(gs10) fc(none) lp("l") )
        (scatteri `outer5c' , recast(line) lw(0.1) lc(gs10) fc(none) lp("l") )
        (scatteri `outer6a' , recast(line) lw(0.1) lc(gs10) fc(none) lp("l") )
        (scatteri `outer6b' , recast(line) lw(0.1) lc(gs10) fc(none) lp("l") )
        (scatteri `outer6c' , recast(line) lw(0.1) lc(gs10) fc(none) lp("l") )   

        /// Y-Axis indicator line for time between 2000 and 2019
        (scatteri `yaxis' , recast(line) lw(0.5) lc("gs12") fc(none) )   
        (scatteri `yaxis_sym' , msymbol(A) mc("gs12") msize(2.5) msangle(180))   
		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 
			ysize(16) xsize(15)

			xlab(-1000000 "1m" -500000 "500k" 1000000 "10m" 2000000 "20m" 3000000 "30m" , 
			valuelabel labc(gs0) labs(2.5) notick nogrid glc(gs16) angle(0) format(%9.0f))
			xscale(noline lw(vthin) range(-1100000(100000)4440000) ) 
			xtitle(" ", size(3) color(gs0) margin(l=0 r=0 t=0 b=0)) 
            xmtick(-1000000 -500000 1000000 2000000 3000000, tlc(gs10))
			
			ylab(none ,
			valuelabel labc(gs8) labs(2.5) tlc(gs8) notick nogrid glc(gs16) angle(0) format(%9.0f))
			yscale(noline reverse lw(none) lc(gs16) noextend range(1985(10)2265)) 
			ytitle("", color(gs8) size(3) margin(l=1 r=1 t=1 b=1)) 

            /// Region Titles 
           text(2020 3600000 "Cardiovascular" "Disease"         ,  place(w) size(2.5) color(gs8) just(right))
           text(2065 3600000 "Cancers"                          ,  place(w) size(2.5) color(gs8) just(right))
           text(2110 3600000 "Respiratory" "Diseases"   ,  place(w) size(2.5) color(gs8) just(right))
           text(2155 3600000 "Diabetes"                         ,  place(w) size(2.5) color(gs8) just(right))
           text(2200 3600000 "Mental Health /" "Neurological"   ,  place(w) size(2.5) color(gs8) just(right))
           text(2245 3600000 "External" "Causes"                ,  place(w) size(2.5) color(gs8) just(right))

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
            text(2004 4000000 "2000",  place(e) size(3.5) color(gs10))
            text(2037 4000000 "2019",  place(e) size(3.5) color(gs10))

			legend(off)
			name(chap2_intro)
			;
#delimit cr	

** Export to Vector Graphic
** DEC 22nd, 2022
graph export "`outputpath'\reports\2024-edits\graphics\fig10.svg", replace
graph export "`outputpath'\reports\2024-edits\graphics\fig10.pdf", replace

