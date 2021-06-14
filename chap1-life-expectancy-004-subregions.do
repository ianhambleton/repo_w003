** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap1-life-expectancy-004-subregions.do
    //  project:				    WHO Global Health Estimates
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	16-Apr-2021
    //  algorithm task			    Chapter 1 - Life Expectancy

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
    log using "`logpath'\chap1-life-expectancy-004-subregions", replace
** HEADER -----------------------------------------------------

** LIFE EXPECTANCY STATISTICS for CHAPTER ONE

** LOAD THE FULL LIFE TABLE DATASET 
use "`datapath'\from-who\lifetables\who-lifetable-2019-all", clear
keep if ghocode==35
keep if agroup==1 | agroup==14 
** APPEND the HALE regional dataset 
append using "`datapath'\from-who\lifetables\who-hale-2019-country"
label define ghocode_ 100 "hale",modify 
label values ghocode ghocode_ 
keep if year==2000 | year==2019

** Drop the major regions
drop if country==""

** Create subregions

** (1) North America        USA, CAN
** (2) Southern Cone        ARG, CHL, PRY, URY
** (3) Central America      CRI, SLV, GTM, HND, NIC, PAN
** (4) Andean               BOL, COL, ECU, PER, VEN
** (5) Latin Caribbean      CUB, DOM, HTI
** (6) non-latin Caribbean  ATG, BHS, BLZ, BRB, GRD, GUY, JAM, LCA, SUR, TTO, VCT
** (7) Brazil               BRA
** (8) Mexico               MEX
gen sr = . 
replace sr = 1 if country=="USA" | country=="CAN"
replace sr = 2 if country=="ARG" | country=="CHL" | country=="PRY" | country=="URY"
replace sr = 3 if country=="CRI" | country=="SLV" | country=="GTM" | country=="HND" | country=="NIC" | country=="PAN"
replace sr = 4 if country=="BOL" | country=="COL" | country=="ECU" | country=="PER" | country=="VEN"
replace sr = 5 if country=="CUB" | country=="DOM" | country=="HTI" 
replace sr = 6 if country=="ATG" | country=="BHS" | country=="BLZ" | country=="BRB" | country=="GRD" | country=="GUY" | country=="JAM" | country=="LCA" | country=="SUR" | country=="TTO" | country=="VCT"
replace sr = 7 if country=="BRA"
replace sr = 8 if country=="MEX"


#delimit ; 
label define sr_    1 "north america"
                    2 "southern cone"
                    3 "central america"
                    4 "andean" 
                    5 "latin caribbean"
                    6 "non-latin caribbean"
                    7 "brazil"
                    8 "mexico", modify; 
#delimit cr 
label values sr sr_ 

** Fillin missing country names (in -ex- file, not in -hale- file)
** Then sort
sort country ghocode 
replace cname = cname[_n-1] if cname=="" & cname[_n-1]!="" 
sort ghocode agroup sr country year sex agroup
order ghocode agroup sr country cname year sex agroup
drop wbregion 


** GRAPHIC 
keep if agroup==1

** X-axis based on sub-region + ghocode
gen     yax = 1 if sr==1 & ghocode==35 
replace yax = 2 if sr==1 & ghocode==100 
replace yax = 3 if sr==2 & ghocode==35 
replace yax = 4 if sr==2 & ghocode==100
replace yax = 5 if sr==3 & ghocode==35 
replace yax = 6 if sr==3 & ghocode==100
replace yax = 7 if sr==4 & ghocode==35 
replace yax = 8 if sr==4 & ghocode==100
replace yax = 9 if sr==5 & ghocode==35 
replace yax = 10 if sr==5 & ghocode==100
replace yax = 11 if sr==6 & ghocode==35 
replace yax = 12 if sr==6 & ghocode==100
replace yax = 13 if sr==7 & ghocode==35 
replace yax = 14 if sr==7 & ghocode==100
replace yax = 15 if sr==8 & ghocode==35 
replace yax = 16 if sr==8 & ghocode==100

** Y-axis is Life Expectancy / Healthy Life Expectancy 
** Median (IQR) mortality rate for each subregion (but most without enough countries)
forval x = 1(1)8 {
    sum metric if sr==`x' & ghocode==35, detail 
    local p50_`x'a = r(p50)
    local p25_`x'a = r(p25)
    local p75_`x'a = r(p75)
    local max_`x'a = r(max)
    sum metric if sr==`x' & ghocode==100, detail 
    local p50_`x'b = r(p50)
    local p25_`x'b = r(p25)
    local p75_`x'b = r(p75)
    local max_`x'b = r(max)
}

** Outer boxes
local outer1 40 0.6 90 0.6 90 2.4 40 2.4  40 0.6 
local outer2 40 2.6 90 2.6 90 4.4 40 4.4  40 2.6 
local outer3 40 4.6 90 4.6 90 6.4 40 6.4  40 4.6 
local outer4 40 6.6 90 6.6 90 8.4 40 8.4  40 6.6 
local outer5 40 8.6 90 8.6 90 10.4 40 10.4  40 8.6 
local outer6 40 10.6 90 10.6 90 12.4 40 12.4  40 10.6 
local outer7 40 12.6 90 12.6 90 14.4 40 14.4  40 12.6 
local outer8 40 14.6 90 14.6 90 16.4 40 16.4  40 14.6 

** 25th to 75th percentile boxes 
** sub-region 6: non-latin Caribbean
local iqr1a `p25_1a' 0.6 `p75_1a' 0.6 `p75_1a' 1.4 `p25_1a' 1.4  `p25_1a' 0.6 
local iqr1b `p25_1b' 1.6 `p75_1b' 1.6 `p75_1b' 2.4 `p25_1b' 2.4  `p25_1b' 1.6 
local iqr2a `p25_2a' 2.6 `p75_2a' 2.6 `p75_2a' 3.4 `p25_2a' 3.4  `p25_2a' 2.6 
local iqr2b `p25_2b' 3.6 `p75_2b' 3.6 `p75_2b' 4.4 `p25_2b' 4.4  `p25_2b' 3.6 
local iqr3a `p25_3a' 4.6 `p75_3a' 4.6 `p75_3a' 5.4 `p25_3a' 5.4  `p25_3a' 4.6 
local iqr3b `p25_3b' 5.6 `p75_3b' 5.6 `p75_3b' 6.4 `p25_3b' 6.4  `p25_3b' 5.6 
local iqr4a `p25_4a' 6.6 `p75_4a' 6.6 `p75_4a' 7.4 `p25_4a' 7.4  `p25_4a' 6.6 
local iqr4b `p25_4b' 7.6 `p75_4b' 7.6 `p75_4b' 8.4 `p25_4b' 8.4  `p25_4b' 7.6 
local iqr5a `p25_5a' 8.6 `p75_5a' 8.6 `p75_5a' 9.4 `p25_5a' 9.4  `p25_5a' 8.6 
local iqr5b `p25_5b' 9.6 `p75_5b' 9.6 `p75_5b' 10.4 `p25_5b' 10.4  `p25_5b' 9.6 
local iqr6a `p25_6a' 10.6 `p75_6a' 10.6 `p75_6a' 11.4 `p25_6a' 11.4  `p25_6a' 10.6 
local iqr6b `p25_6b' 11.6 `p75_6b' 11.6 `p75_6b' 12.4 `p25_6b' 12.4  `p25_6b' 11.6 

** Max values for each subregion 
bysort sr sex year ghocode: egen srmax = max(metric) 
bysort sr sex year ghocode: egen srmin = min(metric) 

** generate a local for the ColorBrewer color scheme
colorpalette ptol, rainbow n(12)  nograph
local list r(p) 
** (LE --> sex = 1)
local le `r(p1)'
** (HALE --> sex = 2)
local hale `r(p4)'

** Jitter LE for hidden circles
replace metric = metric+0.4 if ghocode==35 & year==2019 & sex==3 & country=="GTM"
replace metric = metric+0.4 if ghocode==35 & year==2019 & sex==3 & country=="SLV"
replace metric = metric-0.2 if ghocode==35 & year==2019 & sex==3 & country=="ECU"
replace metric = metric-0.2 if ghocode==100 & year==2019 & sex==3 & country=="ECU"


** Statistics for associated text 

** --------------------------------------------
** LE
** --------------------------------------------

** LE, ordered from highest to lowest
preserve
    keep if ghocode==35 & year==2019 & sex==3
    gsort -metric 
    gen order = _n 
    labmask order, values(cname)
    tabdisp order , cell(metric) format(%9.1f)
restore

** LE, ordered by subregon, then by LE from highest to lowest
preserve 
    keep if ghocode==35 & year==2019 & sex==3
    bysort sr : egen max = max(metric)
    bysort sr : egen min = min(metric)
    gen diff = max - min
    gen pdiff = (diff / max) * 100
    gsort sr -metric 
    list sr cname metric diff pdiff, sepby(sr) linesize(120)
restore

** LE, for entire region - then by LE from highest to lowest
preserve 
    keep if ghocode==35 & year==2019 & sex==3
    egen max = max(metric)
    egen min = min(metric)
    gen diff = max - min
    gen pdiff = (diff / max) * 100
    gsort -metric 
    list cname metric diff pdiff, linesize(120)
restore

** --------------------------------------------
** HALE 
** --------------------------------------------

** HALE, ordered from highest to lowest
preserve
    keep if ghocode==100 & year==2019 & sex==3
    gsort -metric 
    gen order = _n 
    labmask order, values(cname)
    tabdisp order , cell(metric) format(%9.1f)
restore

** HALE, ordered by subregon, then by LE from highest to lowest
preserve 
    keep if ghocode==100 & year==2019 & sex==3
    bysort sr : egen max = max(metric)
    bysort sr : egen min = min(metric)
    gen diff = max - min
    gen pdiff = (diff / max) * 100
    gsort sr -metric 
    list sr cname metric diff pdiff, sepby(sr) linesize(120)
restore

** HALE, for entire region - then by LE from highest to lowest
preserve 
    keep if ghocode==100 & year==2019 & sex==3
    egen max = max(metric)
    egen min = min(metric)
    gen diff = max - min
    gen pdiff = (diff / max) * 100
    gsort -metric 
    list cname metric diff pdiff, linesize(120)
restore

** YEARS IN LESS THAN FULL HEALTH (shortest, longest, difference)
preserve
    keep if year==2019
    keep if sex==3 
    drop yax srmax srmin
    reshape wide metric, i(sr country) j(ghocode)
    rename metric35 le 
    rename metric100 hale

    gen ih = le - hale
    gen ihp = ((le - hale) / le) * 100
    gsort -ihp
    list cname le hale ih ihp, linesize(120)
restore


#delimit ;
	gr twoway 
        /// 25th to 75th percentiles
        /// (scatteri `iqr5a' , recast(area) color("orange*0.2")  )
        /// (scatteri `iqr5b' , recast(area) color("orange*0.2")  )
        /// (scatteri `iqr6a' , recast(area) color("orange*0.2")  )
        /// (scatteri `iqr6b' , recast(area) color("orange*0.2")  )

		/// median values
        /// (function y=`p50_1a' if yax==1,     range(0.6 1.4)      lc(gs10) lw(0.05))
		/// (function y=`p50_1b' if yax==2,     range(1.6 2.4)      lc(gs10) lw(0.05))
        /// (function y=`p50_2a' if yax==3,     range(2.6 3.4)      lc(gs10) lw(0.05))
		/// (function y=`p50_2b' if yax==4,     range(3.6 4.4)      lc(gs10) lw(0.05))
        /// (function y=`p50_3a' if yax==5,     range(4.6 5.4)      lc(gs10) lw(0.05))
		/// (function y=`p50_3b' if yax==6,     range(5.6 6.4)      lc(gs10) lw(0.05))
        /// (function y=`p50_4a' if yax==7,     range(6.6 7.4)      lc(gs10) lw(0.05))
		/// (function y=`p50_4b' if yax==8,     range(7.6 8.4)      lc(gs10) lw(0.05))
        /// (function y=`p50_5a' if yax==9,     range(8.6 9.4)      lc(gs10) lw(0.05))
		/// (function y=`p50_5b' if yax==10,    range(9.6 10.4)     lc(gs10) lw(0.05))
        /// (function y=`p50_6a' if yax==11,    range(10.6 11.4)    lc(gs10) lw(0.05))
		/// (function y=`p50_6b' if yax==12,    range(11.6 12.4)    lc(gs10) lw(0.05))

		/// outer boxes 
        (scatteri `outer1' , recast(area) lw(0.2) lc(gs10) fc(none)  )
        (scatteri `outer2' , recast(area) lw(0.2) lc(gs10) fc(none)  )
        (scatteri `outer3' , recast(area) lw(0.2) lc(gs10) fc(none)  )
        (scatteri `outer4' , recast(area) lw(0.2) lc(gs10) fc(none)  )
        (scatteri `outer5' , recast(area) lw(0.2) lc(gs10) fc(none)  )
        (scatteri `outer6' , recast(area) lw(0.2) lc(gs10) fc(none)  )
        (scatteri `outer7' , recast(area) lw(0.2) lc(gs10) fc(none)  )
        (scatteri `outer8' , recast(area) lw(0.2) lc(gs10) fc(none)  )

		/// country values
        
        /// North America
        (rbar srmax srmin yax   if year==2019 & sex==3 & sr==1 & ghocode==35 , fc("`le'%50") barw(0.025) lw(none))
        (sc metric yax          if year==2019 & sex==3 & sr==1 & ghocode==35 , msize(4.5) m(oh) mlc("`le'%45") mfc("`le'%45") mlw(0.1))
        (sc srmax yax           if year==2019 & sex==3 & sr==1 & ghocode==35 , msize(4.5) m(o) mlc("`le'") mfc("`le'*0.5") mlw(0.025))
        (sc srmin yax           if year==2019 & sex==3 & sr==1 & ghocode==35 , msize(4.5) m(o) mlc("`le'") mfc("`le'*0.5") mlw(0.025))
        (rbar srmax srmin yax   if year==2019 & sex==3 & sr==1 & ghocode==100 , fc("`hale'%50") barw(0.025) lw(none))
        (sc metric yax          if year==2019 & sex==3 & sr==1 & ghocode==100 , msize(4.5) m(oh) mlc("`hale'%45") mfc("`hale'%45") mlw(0.1))
        (sc srmax yax           if year==2019 & sex==3 & sr==1 & ghocode==100 , msize(4.5) m(o) mlc("`hale'") mfc("`hale'*0.5") mlw(0.025))
        (sc srmin yax           if year==2019 & sex==3 & sr==1 & ghocode==100 , msize(4.5) m(o) mlc("`hale'") mfc("`hale'*0.5") mlw(0.025))

        /// southern cone
        (rbar srmax srmin yax   if year==2019 & sex==3 & sr==2 & ghocode==35 , fc("`le'%50") barw(0.025) lw(none))
        (sc metric yax          if year==2019 & sex==3 & sr==2 & ghocode==35 , msize(4.5) m(oh) mlc("`le'%45") mfc("`le'%45") mlw(0.1))
        (sc srmax yax           if year==2019 & sex==3 & sr==2 & ghocode==35 , msize(4.5) m(o) mlc("`le'") mfc("`le'*0.5") mlw(0.025))
        (sc srmin yax           if year==2019 & sex==3 & sr==2 & ghocode==35 , msize(4.5) m(o) mlc("`le'") mfc("`le'*0.5") mlw(0.025))
        (rbar srmax srmin yax   if year==2019 & sex==3 & sr==2 & ghocode==100 , fc("`hale'%50") barw(0.025) lw(none))
        (sc metric yax          if year==2019 & sex==3 & sr==2 & ghocode==100 , msize(4.5) m(oh) mlc("`hale'%45") mfc("`hale'%45") mlw(0.1))
        (sc srmax yax           if year==2019 & sex==3 & sr==2 & ghocode==100 , msize(4.5) m(o) mlc("`hale'") mfc("`hale'*0.5") mlw(0.025))
        (sc srmin yax           if year==2019 & sex==3 & sr==2 & ghocode==100 , msize(4.5) m(o) mlc("`hale'") mfc("`hale'*0.5") mlw(0.025))

        /// central america
        (rbar srmax srmin yax   if year==2019 & sex==3 & sr==3 & ghocode==35 , fc("`le'%50") barw(0.025) lw(none))
        (sc metric yax          if year==2019 & sex==3 & sr==3 & ghocode==35 , msize(4.5) m(oh) mlc("`le'%45") mfc("`le'%45") mlw(0.1))
        (sc srmax yax           if year==2019 & sex==3 & sr==3 & ghocode==35 , msize(4.5) m(o) mlc("`le'") mfc("`le'*0.5") mlw(0.025))
        (sc srmin yax           if year==2019 & sex==3 & sr==3 & ghocode==35 , msize(4.5) m(o) mlc("`le'") mfc("`le'*0.5") mlw(0.025))
        (rbar srmax srmin yax   if year==2019 & sex==3 & sr==3 & ghocode==100 , fc("`hale'%50") barw(0.025) lw(none))
        (sc metric yax          if year==2019 & sex==3 & sr==3 & ghocode==100 , msize(4.5) m(oh) mlc("`hale'%45") mfc("`hale'%45") mlw(0.1))
        (sc srmax yax           if year==2019 & sex==3 & sr==3 & ghocode==100 , msize(4.5) m(o) mlc("`hale'") mfc("`hale'*0.5") mlw(0.025))
        (sc srmin yax           if year==2019 & sex==3 & sr==3 & ghocode==100 , msize(4.5) m(o) mlc("`hale'") mfc("`hale'*0.5") mlw(0.025))

        /// andean
        (rbar srmax srmin yax   if year==2019 & sex==3 & sr==4 & ghocode==35 , fc("`le'%50") barw(0.025) lw(none))
        (sc metric yax          if year==2019 & sex==3 & sr==4 & ghocode==35 , msize(4.5) m(oh) mlc("`le'%45") mfc("`le'%45") mlw(0.1))
        (sc srmax yax           if year==2019 & sex==3 & sr==4 & ghocode==35 , msize(4.5) m(o) mlc("`le'") mfc("`le'*0.5") mlw(0.025))
        (sc srmin yax           if year==2019 & sex==3 & sr==4 & ghocode==35 , msize(4.5) m(o) mlc("`le'") mfc("`le'*0.5") mlw(0.025))
        (rbar srmax srmin yax   if year==2019 & sex==3 & sr==4 & ghocode==100 , fc("`hale'%50") barw(0.025) lw(none))
        (sc metric yax          if year==2019 & sex==3 & sr==4 & ghocode==100 , msize(4.5) m(oh) mlc("`hale'%45") mfc("`hale'%45") mlw(0.1))
        (sc srmax yax           if year==2019 & sex==3 & sr==4 & ghocode==100 , msize(4.5) m(o) mlc("`hale'") mfc("`hale'*0.5") mlw(0.025))
        (sc srmin yax           if year==2019 & sex==3 & sr==4 & ghocode==100 , msize(4.5) m(o) mlc("`hale'") mfc("`hale'*0.5") mlw(0.025))

        /// Latin Caribbean 
        (rbar srmax srmin yax   if year==2019 & sex==3 & sr==5 & ghocode==35 , fc("`le'%50") barw(0.025) lw(none))
        (sc metric yax          if year==2019 & sex==3 & sr==5 & ghocode==35 , msize(4.5) m(oh) mlc("`le'%45") mfc("`le'%45") mlw(0.1))
        (sc srmax yax           if year==2019 & sex==3 & sr==5 & ghocode==35 , msize(4.5) m(o) mlc("`le'") mfc("`le'*0.5") mlw(0.025))
        (sc srmin yax           if year==2019 & sex==3 & sr==5 & ghocode==35 , msize(4.5) m(o) mlc("`le'") mfc("`le'*0.5") mlw(0.025))
        (rbar srmax srmin yax   if year==2019 & sex==3 & sr==5 & ghocode==100 , fc("`hale'%50") barw(0.025) lw(none))
        (sc metric yax          if year==2019 & sex==3 & sr==5 & ghocode==100 , msize(4.5) m(oh) mlc("`hale'%45") mfc("`hale'%45") mlw(0.1))
        (sc srmax yax           if year==2019 & sex==3 & sr==5 & ghocode==100 , msize(4.5) m(o) mlc("`hale'") mfc("`hale'*0.5") mlw(0.025))
        (sc srmin yax           if year==2019 & sex==3 & sr==5 & ghocode==100 , msize(4.5) m(o) mlc("`hale'") mfc("`hale'*0.5") mlw(0.025))
        
        /// non-Latin Caribbean 
        (rbar srmax srmin yax   if year==2019 & sex==3 & sr==6 & ghocode==35 , fc("`le'%50") barw(0.025) lw(none))
        (sc metric yax          if year==2019 & sex==3 & sr==6 & ghocode==35 , msize(4.5) m(oh) mlc("`le'%45") mfc("`le'%45") mlw(0.1))
        (sc srmax yax           if year==2019 & sex==3 & sr==6 & ghocode==35 , msize(4.5) m(o) mlc("`le'") mfc("`le'*0.5") mlw(0.025))
        (sc srmin yax           if year==2019 & sex==3 & sr==6 & ghocode==35 , msize(4.5) m(o) mlc("`le'") mfc("`le'*0.5") mlw(0.025))
        (rbar srmax srmin yax   if year==2019 & sex==3 & sr==6 & ghocode==100 , fc("`hale'%50") barw(0.025) lw(none))
        (sc metric yax          if year==2019 & sex==3 & sr==6 & ghocode==100 , msize(4.5) m(oh) mlc("`hale'%45") mfc("`hale'%45") mlw(0.1))
        (sc srmax yax           if year==2019 & sex==3 & sr==6 & ghocode==100 , msize(4.5) m(o) mlc("`hale'") mfc("`hale'*0.5") mlw(0.025))
        (sc srmin yax           if year==2019 & sex==3 & sr==6 & ghocode==100 , msize(4.5) m(o) mlc("`hale'") mfc("`hale'*0.5") mlw(0.025))

        /// Brazil
        (rbar srmax srmin yax   if year==2019 & sex==3 & sr==7 & ghocode==35 , fc("`le'%50") barw(0.025) lw(none))
        (sc metric yax          if year==2019 & sex==3 & sr==7 & ghocode==35 , msize(4.5) m(oh) mlc("`le'%45") mfc("`le'%45") mlw(0.1))
        (sc srmax yax           if year==2019 & sex==3 & sr==7 & ghocode==35 , msize(4.5) m(o) mlc("`le'") mfc("`le'*0.5") mlw(0.025))
        (sc srmin yax           if year==2019 & sex==3 & sr==7 & ghocode==35 , msize(4.5) m(o) mlc("`le'") mfc("`le'*0.5") mlw(0.025))
        (rbar srmax srmin yax   if year==2019 & sex==3 & sr==7 & ghocode==100 , fc("`hale'%50") barw(0.025) lw(none))
        (sc metric yax          if year==2019 & sex==3 & sr==7 & ghocode==100 , msize(4.5) m(oh) mlc("`hale'%45") mfc("`hale'%45") mlw(0.1))
        (sc srmax yax           if year==2019 & sex==3 & sr==7 & ghocode==100 , msize(4.5) m(o) mlc("`hale'") mfc("`hale'*0.5") mlw(0.025))
        (sc srmin yax           if year==2019 & sex==3 & sr==7 & ghocode==100 , msize(4.5) m(o) mlc("`hale'") mfc("`hale'*0.5") mlw(0.025))        

        /// Mexico
        (rbar srmax srmin yax   if year==2019 & sex==3 & sr==8 & ghocode==35 , fc("`le'%50") barw(0.025) lw(none))
        (sc metric yax          if year==2019 & sex==3 & sr==8 & ghocode==35 , msize(4.5) m(oh) mlc("`le'%45") mfc("`le'%45") mlw(0.1))
        (sc srmax yax           if year==2019 & sex==3 & sr==8 & ghocode==35 , msize(4.5) m(o) mlc("`le'") mfc("`le'*0.5") mlw(0.025))
        (sc srmin yax           if year==2019 & sex==3 & sr==8 & ghocode==35 , msize(4.5) m(o) mlc("`le'") mfc("`le'*0.5") mlw(0.025))
        (rbar srmax srmin yax   if year==2019 & sex==3 & sr==8 & ghocode==100 , fc("`hale'%50") barw(0.025) lw(none))
        (sc metric yax          if year==2019 & sex==3 & sr==8 & ghocode==100 , msize(4.5) m(oh) mlc("`hale'%45") mfc("`hale'%45") mlw(0.1))
        (sc srmax yax           if year==2019 & sex==3 & sr==8 & ghocode==100 , msize(4.5) m(o) mlc("`hale'") mfc("`hale'*0.5") mlw(0.025))
        (sc srmin yax           if year==2019 & sex==3 & sr==8 & ghocode==100 , msize(4.5) m(o) mlc("`hale'") mfc("`hale'*0.5") mlw(0.025))

		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=3 t=5)) 
			ysize(6) xsize(12)

			xlab(none, notick labs(2) tlc(gs0) labc(gs0) notick nogrid glc(gs16))
			xscale(noline ) 
			xtitle("", size(5) color(gs0) margin(l=2 r=2 t=5 b=2)) 
			
			ylab(,
			valuelabel labc(gs0) labs(3) tstyle(major_notick) nogrid glc(gs16) angle(0) format(%9.0f))
			yscale(noline lw(vthin) range(40(2)94)) 
			ytitle("Life Expectancy / Healthy Life Expectancy at birth (yrs)", size(3) margin(l=2 r=2 t=2 b=2)) 

			/// X-Axis text
            text(41.5 1 "LE",  place(c) size(3) color(gs8))
            text(41.5 2 "HALE",  place(c) size(3) color(gs8))
            text(41.5 3 "LE",  place(c) size(3) color(gs8))
            text(41.5 4 "HALE",  place(c) size(3) color(gs8))
            text(41.5 5 "LE",  place(c) size(3) color(gs8))
            text(41.5 6 "HALE",  place(c) size(3) color(gs8))
            text(41.5 7 "LE",  place(c) size(3) color(gs8))
            text(41.5 8 "HALE",  place(c) size(3) color(gs8))
            text(41.5 9 "LE",  place(c) size(3) color(gs8))
            text(41.5 10 "HALE",  place(c) size(3) color(gs8))
            text(41.5 11 "LE",  place(c) size(3) color(gs8))
            text(41.5 12 "HALE",  place(c) size(3) color(gs8))
            text(41.5 13 "LE",  place(c) size(3) color(gs8))
            text(41.5 14 "HALE",  place(c) size(3) color(gs8))
            text(41.5 15 "LE",  place(c) size(3) color(gs8))
            text(41.5 16 "HALE",  place(c) size(3) color(gs8))

            /// Sub-regions 
            text(93 1.5 "North" "America",  place(c) size(3) color(gs5))
            text(93 3.5 "Southern" "Cone",  place(c) size(3) color(gs5))
            text(93 5.5 "Central" "America",  place(c) size(3) color(gs5))
            text(93 7.5 "Andean",  place(c) size(3) color(gs5))
            text(93 9.5 "Latin" "Caribbean",  place(c) size(3) color(gs5))
            text(93 11.5 "non-Latin" "Caribbean",  place(c) size(3) color(gs5))
            text(93 13.5 "Brazil",  place(c) size(3) color(gs5))
            text(93 15.5 "Mexico",  place(c) size(3) color(gs5))

			legend(off size(5) position(11) ring(1) bm(t=1 b=4 l=5 r=0) colf cols(2)
			region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2)) 
			order(2 3) 
			lab(2 "Questionnaire") 
			lab(3 "Objective") 		
			)
			name(subregion1)
			;
#delimit cr	
