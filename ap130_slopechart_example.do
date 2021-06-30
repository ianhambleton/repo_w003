** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			        ap130-slopechart.do
    //  project:				        WHO Global Health Estimates
    //  analysts:				        Ian HAMBLETON
    // 	date last modified	            5-April-2021
    //  algorithm task			        Slopechart example

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
    log using "`logpath'\ap130-slopechart", replace
** HEADER -----------------------------------------------------

** UN deaths equiplot example
use "`datapath'\from-who\who-ghe-daly-002-who2", replace
keep if year==2000 | year==2019 
drop if age < 0 
drop daly_low daly_up un_region who_region
collapse (sum) daly pop, by(year ghecause)
format daly %15.0fc
** Drop all the grouped causes 
#delimit ; 
drop if ghecause == 0 |         /* All causes */
        ghecause == 600 |       /* Communicable */
        ghecause == 1510 |      /* Imjuries */
        ghecause == 10 ;        /* Communicable */
#delimit cr 

** Reshape to wide for each year

** 2000 Top X conditions / and groups of conditions
reshape wide daly pop, i(ghecause) j(year)
gsort -daly2000 
gen order2000 = _n 
gsort -daly2019 
gen order2019 = _n 
reshape long daly pop order, i(ghecause) j(year)

gen ycode = .
replace ycode = 1 if year==2000
replace ycode = 10 if year==2019

** Top 20 in 2000
gen ordert = order
replace ordert = . if year==2019
bysort ghecause: egen order2000 = min(ordert)
drop ordert
** Top 20 in 2019
gen ordert = order
replace ordert = . if year==2000
bysort ghecause: egen order2019 = min(ordert)
drop ordert

** Keep top 10 in  either 2000 or 2019 
sort order2000 year 
keep if order2000<=10 | order2019<=10

** Fix those out of top 10 to drop to values 12 and lower
** 14 in 2000 --> 12  /* neurological */
** 22 in 2000 --> 13  /* diabetes */
** 16 in 2019 --> 12  /* neonatal */
** 17 in 2019 --> 13  /* infectious */
replace order2000 = 11 if order2000==14 & ghecause==940
replace order     = 11 if order    ==14 & ghecause==940
replace order2000 = 12 if order2000==22 & ghecause==800
replace order     = 12 if order    ==22 & ghecause==800
replace order2019 = 11 if order2019==16 & ghecause==490
replace order     = 11 if order    ==16 & ghecause==490
replace order2019 = 12 if order2019==17 & ghecause==20    
replace order     = 12 if order    ==17 & ghecause==20



** Color palette
** Categorical tableau 
** Blue --> 31 119 180 (darker) 174 199 232 (lighter)
** Red --> 214 39 40 (darker) 152 223 138 (lighter)
** Grey --> 127 127 127 (darker)  199 199 199 (lighter)
#delimit ;
	gr twoway 
		/// Number 1 (SAME - GRAY)
		(function y = 0.5, range(-2 24) lc("127 127 127%50")) 
        (line order ycode if ghecause==1100, lw(1.5) lc("127 127 127%50"))
        (sc order2000 ycode if ghecause==1100 & year==2000  , msize(10) m(o) mc("127 127 127*0.5") mlw(0.2))
        (sc order2019 ycode if ghecause==1100 & year==2019 , msize(10) m(o) mc("127 127 127*0.5") mlw(0.2))
		/// Number 2 (SAME - GRAY)
		(line order ycode if ghecause==610, lw(1.5) lc("127 127 127%50"))
        (sc order2000 ycode if ghecause==610 & year==2000  , msize(10) m(o) mc("127 127 127*0.5") mlw(0.2))
        (sc order2019 ycode if ghecause==610 & year==2019 , msize(10) m(o) mc("127 127 127*0.5") mlw(0.2))
		/// Number 3 (SAME - GRAY)
		(line order ycode if ghecause==820, lw(1.5) lc("127 127 127%50"))
        (sc order2000 ycode if ghecause==820 & year==2000  , msize(10) m(o) mc("127 127 127*0.5") mlw(0.2))
        (sc order2019 ycode if ghecause==820 & year==2019 , msize(10) m(o) mc("127 127 127*0.5") mlw(0.2))
		/// Number 4 (SAME - GRAY)
		(line order ycode if ghecause==1520, lw(1.5) lc("127 127 127%50"))
        (sc order2000 ycode if ghecause==1520 & year==2000  , msize(10) m(o) mc("127 127 127*0.5") mlw(0.2))
        (sc order2019 ycode if ghecause==1520 & year==2019 , msize(10) m(o) mc("127 127 127*0.5") mlw(0.2))
		/// Number 5 (DOWN - BLUE)
        (line order ycode if ghecause==1130, lw(1.5) lc("31 119 180%50"))
        (sc order2000 ycode if ghecause==1130 & year==2000 , msize(10) m(o) mc("31 119 180*0.5") mlw(0.2))
        (sc order2019 ycode if ghecause==1130 & year==2019 , msize(10) m(o) mc("31 119 180*0.5") mlw(0.2))
		/// Number 6 (DOWN - BLUE)
        (line order ycode if ghecause==490, lw(1.5) lc("31 119 180%15"))
        (sc order2000 ycode if ghecause==490 & year==2000 , msize(10) m(o) mc("31 119 180*0.5") mlw(0.2))
        (sc order2019 ycode if ghecause==490 & year==2019 , msize(10) m(o) mc("31 119 180*0.15") mlw(0.2))
		/// Number 7 (UP - RED)
        (line order ycode if ghecause==1340, lw(1.5) lc("214 39 40%50"))
        (sc order2000 ycode if ghecause==1340 & year==2000 , msize(10) m(o) mc("214 39 40*0.5") mlw(0.2))
        (sc order2019 ycode if ghecause==1340 & year==2019 , msize(10) m(o) mc("214 39 40*0.5") mlw(0.2))
		/// Number 8 (DOWN - BLUE)
        (line order ycode if ghecause==20, lw(1.5) lc("31 119 180%15"))
        (sc order2000 ycode if ghecause==20 & year==2000 , msize(10) m(o) mc("31 119 180*0.5") mlw(0.2))
        (sc order2019 ycode if ghecause==20 & year==2019 , msize(10) m(o) mc("31 119 180*0.15") mlw(0.2))
		/// Number 9 (UP - RED)
        (line order ycode if ghecause==1600, lw(1.5) lc("214 39 40%50"))
        (sc order2000 ycode if ghecause==1600 & year==2000 , msize(10) m(o) mc("214 39 40*0.5") mlw(0.2))
        (sc order2019 ycode if ghecause==1600 & year==2019 , msize(10) m(o) mc("214 39 40*0.5") mlw(0.2))
		/// Number 10 (UP - RED)
        (line order ycode if ghecause==1170, lw(1.5) lc("214 39 40%50"))
        (sc order2000 ycode if ghecause==1170 & year==2000 , msize(10) m(o) mc("214 39 40*0.5") mlw(0.2))
        (sc order2019 ycode if ghecause==1170 & year==2019 , msize(10) m(o) mc("214 39 40*0.5") mlw(0.2))
		/// Number 14 (UP - RED)
        (line order ycode if ghecause==940, lw(1.5) lc("214 39 40%15"))
        (sc order2000 ycode if ghecause==940 & year==2000 , msize(10) m(o) mc("214 39 40*0.15") mlw(0.2))
        (sc order2019 ycode if ghecause==940 & year==2019 , msize(10) m(o) mc("214 39 40*0.5") mlw(0.2))
		/// Number 22 (UP - RED)
        (line order ycode if ghecause==800, lw(1.5) lc("214 39 40%15"))
        (sc order2000 ycode if ghecause==800 & year==2000 , msize(10) m(o) mc("214 39 40*0.15") mlw(0.2))
        (sc order2019 ycode if ghecause==800 & year==2019 , msize(10) m(o) mc("214 39 40*0.5") mlw(0.2))
		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			ysize(10) xsize(5)

			xlab(none, 
            notick tlc(gs0) labc(gs0) notick nogrid glc(gs16))
			xscale(noline range(-2(1)25)) 
			xtitle(" ", size(5) color(gs0) margin(l=2 r=2 t=5 b=2)) 
			
			ylab(none,
			valuelabel labc(gs0) labs(6) tstyle(major_notick) nogrid glc(gs16) angle(0) format(%9.0f))
			yscale(reverse noline lw(vthin) range(0(0.5)12.5)) 
			ytitle("", size(5) margin(l=2 r=5 t=2 b=2)) 

            title("DALYs in the Americas", size(7) color(gs0) position(11))

            /// Circle numbering 
            text(0.2 1 "2000",  place(c) size(6) color("127 127 127*0.5"))
            text(0.2 10 "2019",  place(c) size(6) color("127 127 127*0.5"))

            /// Circle numbering 
            text(1 1 "1",  place(c) size(5) color(gs0))
            text(1 10 "1",  place(c) size(5) color(gs0))
            text(2 1 "2",  place(c) size(5) color(gs0))
            text(2 10 "2",  place(c) size(5) color(gs0))
            text(3 1 "3",  place(c) size(5) color(gs0))
            text(3 10 "3",  place(c) size(5) color(gs0))
            text(4 1 "4",  place(c) size(5) color(gs0))
            text(4 10 "4",  place(c) size(5) color(gs0))
            text(5 1 "5",  place(c) size(5) color(gs0))
            text(5 10 "5",  place(c) size(5) color(gs0))
            text(6 1 "6",  place(c) size(5) color(gs0))
            text(6 10 "6",  place(c) size(5) color(gs0))
            text(7 1 "7",  place(c) size(5) color(gs0))
            text(7 10 "7",  place(c) size(5) color(gs0))
            text(8 1 "8",  place(c) size(5) color(gs0))
            text(8 10 "8",  place(c) size(5) color(gs0))
            text(9 1 "9",  place(c) size(5) color(gs0))
            text(9 10 "9",  place(c) size(5) color(gs0))
            text(10 1 "10",  place(c) size(5) color(gs0))
            text(10 10 "10",  place(c) size(5) color(gs0))
            text(11 10 "16",  place(c) size(5) color(gs0))
            text(12 10 "17",  place(c) size(5) color(gs0))
            text(11 1 "14",  place(c) size(5) color(gs0))
            text(12 1 "22",  place(c) size(5) color(gs0))
            /// Disease coding 
            text(1 12 "Cardiovascular",  place(e) size(5) color(gs0))
            text(2 12 "Cancers",  place(e) size(5) color(gs0))
            text(3 12 "Mental",  place(e) size(5) color(gs0))
            text(4 12 "Unint injury",  place(e) size(5) color(gs0))
            text(5 12 "Musculoskeletal",  place(e) size(5) color(gs0))
            text(6 12 "Ischemic heart dis.",  place(e) size(5) color(gs0))
            text(7 12 "Int injury",  place(e) size(5) color(gs0))
            text(8 12 "Neurological",  place(e) size(5) color(gs0))
            text(9 12 "Respiratory",  place(e) size(5) color(gs0))
            text(10 12 "Diabetes",  place(e) size(5) color(gs0))
            text(11 12 "Neonatal",  place(e) size(5) color(gs0))
            text(12 12 "Infectious",  place(e) size(5) color(gs0))
			legend(off)
			name(slopechart1)
			;
#delimit cr	
