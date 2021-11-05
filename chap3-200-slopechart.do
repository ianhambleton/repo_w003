** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			        chap2-006-initial-slopechart.do
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
    log using "`logpath'\chap2-006-initial-slopechart", replace
** HEADER -----------------------------------------------------

** Dataset
input caribbean   ca  na  sla tla r_car r_ca    r_na    r_sla   r_tla
1   1   3   4   4   1   1   0   0   0
2   3   4   2   2   1   1   0   0   0
3   2   2   3   1   1   1   1   0   0
4   7   1   1   3   0   1   0   1   1
5   5   5   5   5   1   1   0   0   0
6   6   6   6   6   0   0   0   0   0
7   8   7   8   7   1   0   0   0   0
8   4   8   7   8   1   1   1   0   0
end

#delimit ; 
label define tla_
                    1 "BMI"
                    2 "SBP"
                    3 "Tobacco"
                    4 "FPG"
                    5 "Diet"
                    6 "Alcohol"
                    7 "LDL"
                    8 "kidney", modify;
#delimit cr
label values tla tla_


** ---------------------------------------------------------
** PREPARE DATA FOR SLOPECHART GRAPHIC
** ---------------------------------------------------------


** Generate the X-axis 
gen ycode_car = 1 
gen ycode_ca = 21
gen ycode_na = 41
gen ycode_sla = 61
gen ycode_tla = 81

** Color scheme
colorpalette d3, 20 n(20) nograph
local list r(p) 
** Blue 
local blu1 `r(p1)'
local blu2 `r(p2)'
** Red
local red1 `r(p7)'
local red2 `r(p8)'
** Gray
local gry1 `r(p15)'
local gry2 `r(p16)'
** Orange
local ora1 `r(p3)'
local ora2 `r(p4)'
** Purple
local pur1 `r(p9)'
local pur2 `r(p10)'
** Grey
local gry1 `r(p15)'
local gry2 `r(p16)'

local outer1    25 -4     -5 -4     -5 45      25 45      25 -4 


#delimit ;
	gr twoway 

		/// outer boxes 
        /// (scatteri `outer1' , recast(area) lw(0.2) lc(gs10) fc(none)  )

		/// Header line
        /// (function y = 0.5, range(-2 24) lc("`gry'")) 
        /// (function y = -5, horizontal range(0 23) lc("`gry'")) 

        /// THE LINES
        (pcspike caribbean ycode_car ca ycode_ca    , lw(1) lc("`gry1'%20")) 
        (pcspike ca ycode_ca na ycode_na            , lw(1) lc("`gry1'%20")) 
        (pcspike na ycode_na sla ycode_sla          , lw(1) lc("`gry1'%20")) 
        (pcspike sla ycode_sla tla ycode_tla        , lw(1) lc("`gry1'%20")) 

		/// The Points
        (sc caribbean ycode_car if r_car==0  , msize(7) m(o) mlc("`gry1'*0.75") mfc("`gry2'*0.5") mlw(0.2))
        (sc ca ycode_ca         if r_ca ==0  , msize(7) m(o) mlc("`gry1'*0.75") mfc("`gry2'*0.5") mlw(0.2))
        (sc na ycode_na         if r_na ==0  , msize(7) m(o) mlc("`gry1'*0.75") mfc("`gry2'*0.5") mlw(0.2))
        (sc sla ycode_sla       if r_sla==0  , msize(7) m(o) mlc("`gry1'*0.75") mfc("`gry2'*0.5") mlw(0.2))
        (sc tla ycode_tla       if r_tla==0  , msize(7) m(o) mlc("`gry1'*0.75") mfc("`gry2'*0.5") mlw(0.2))

        (sc caribbean ycode_car if r_car==1  , msize(7) m(o) mlc("`red1'*0.75") mfc("`red2'*0.5") mlw(0.2))
        (sc ca ycode_ca         if r_ca ==1  , msize(7) m(o) mlc("`red1'*0.75") mfc("`red2'*0.5") mlw(0.2))
        (sc na ycode_na         if r_na ==1  , msize(7) m(o) mlc("`red1'*0.75") mfc("`red2'*0.5") mlw(0.2))
        (sc sla ycode_sla       if r_sla==1  , msize(7) m(o) mlc("`red1'*0.75") mfc("`red2'*0.5") mlw(0.2))
        (sc tla ycode_tla       if r_tla==1  , msize(7) m(o) mlc("`red1'*0.75") mfc("`red2'*0.5") mlw(0.2))

        		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			ysize(12) xsize(10)

			xlab(none, 
            notick tlc(gs0) labc(gs0) notick nogrid glc(gs16))
			xscale(noline  range(-35(10)120) ) 
			xtitle(" ", size(5) color(gs0) margin(l=0 r=0 t=0 b=0)) 
			
			ylab(none,
			valuelabel labc(gs0) labs(6) tstyle(major_notick) nogrid glc(gs16) angle(0) format(%9.0f))
			yscale(reverse noline lw(vthin) range(0(1)8) ) 
			ytitle("", size(5) margin(l=0 r=0 t=0 b=0)) 

            /// Numbering
            text(1 1 "1"                          ,  place(c) size(2.5) color("`red1'"))
            text(1 21 "1"                          ,  place(c) size(2.5) color("`red1'"))
            text(1 41 "1"                          ,  place(c) size(2.5) color("`gry1'"))
            text(1 61 "1"                          ,  place(c) size(2.5) color("`red1'"))
            text(1 81 "1"                          ,  place(c) size(2.5) color("`gry1'"))

            text( 2 1 "2"                          ,  place(c) size(2.5) color("`red1'"))
            text(2 21 "2"                          ,  place(c) size(2.5) color("`red1'"))
            text(2 41 "2"                          ,  place(c) size(2.5) color("`red1'"))
            text(2 61 "2"                          ,  place(c) size(2.5) color("`gry1'"))
            text(2 81 "2"                          ,  place(c) size(2.5) color("`gry1'"))

            text(3  1 "3"                          ,  place(c) size(2.5) color("`red1'"))
            text(3 21 "3"                          ,  place(c) size(2.5) color("`red1'"))
            text(3 41 "3"                          ,  place(c) size(2.5) color("`gry1'"))
            text(3 61 "3"                          ,  place(c) size(2.5) color("`gry1'"))
            text(3 81 "3"                          ,  place(c) size(2.5) color("`red1'"))
            
            text(4  1 "4"                          ,  place(c) size(2.5) color("`gry1'"))
            text(4 21 "4"                          ,  place(c) size(2.5) color("`red1'"))
            text(4 41 "4"                          ,  place(c) size(2.5) color("`gry1'"))
            text(4 61 "4"                          ,  place(c) size(2.5) color("`gry1'"))
            text(4 81 "4"                          ,  place(c) size(2.5) color("`gry1'"))

            text(5  1 "5"                          ,  place(c) size(2.5) color("`red1'"))
            text(5 21 "5"                          ,  place(c) size(2.5) color("`red1'"))
            text(5 41 "5"                          ,  place(c) size(2.5) color("`gry1'"))
            text(5 61 "5"                          ,  place(c) size(2.5) color("`gry1'"))
            text(5 81 "5"                          ,  place(c) size(2.5) color("`gry1'"))

            text(6  1 "6"                          ,  place(c) size(2.5) color("`gry1'"))
            text(6 21 "6"                          ,  place(c) size(2.5) color("`gry1'"))
            text(6 41 "6"                          ,  place(c) size(2.5) color("`gry1'"))
            text(6 61 "6"                          ,  place(c) size(2.5) color("`gry1'"))
            text(6 81 "6"                          ,  place(c) size(2.5) color("`gry1'"))

            text(7  1 "7"                          ,  place(c) size(2.5) color("`red1'"))
            text(7 21 "7"                          ,  place(c) size(2.5) color("`red1'"))
            text(7 41 "7"                          ,  place(c) size(2.5) color("`gry1'"))
            text(7 61 "7"                          ,  place(c) size(2.5) color("`gry1'"))
            text(7 81 "7"                          ,  place(c) size(2.5) color("`gry1'"))

            text(8  1 "8"                          ,  place(c) size(2.5) color("`red1'"))
            text(8 21 "8"                          ,  place(c) size(2.5) color("`gry1'"))
            text(8 41 "8"                          ,  place(c) size(2.5) color("`red1'"))
            text(8 61 "8"                          ,  place(c) size(2.5) color("`gry1'"))
            text(8 81 "8"                          ,  place(c) size(2.5) color("`gry1'"))

            /// Header
            text(0.2 1 "Caribbean"                          ,  place(c) size(2.5) color("`gry1'"))
            text(0.2 21 "Central" "America"                 ,  place(c) size(2.5) color("`gry1'"))
            text(0.2 41 "North" "America"                   ,  place(c) size(2.5) color("`gry1'"))
            text(0.2 61 "Southern" "Latin" "America"        ,  place(c) size(2.5) color("`gry1'"))
            text(0.2 81 "Tropical" "Latin" "America"        ,  place(c) size(2.5) color("`gry1'"))

            /// Disease coding 
            text(1 -5 "High Fasting" "Plasma Glucose"       ,  place(w) size(2.5) color("`gry1'") just(right))
            text(2 -5 "High Systolic" "Blood Pressure"      ,  place(w) size(2.5) color("`gry1'") just(right))
            text(3 -5 "High Body" "Mass Index"              ,  place(w) size(2.5) color("`gry1'") just(right))
            text(4 -5 "Tobacco"                             ,  place(w) size(2.5) color("`gry1'") just(right))
            text(5 -5 "Dietary Risks"                       ,  place(w) size(2.5) color("`gry1'") just(right))
            text(6 -5 "Alcohol Use"                         ,  place(w) size(2.5) color("`gry1'") just(right))
            text(7 -5 "High LDL" "Cholesterol"              ,  place(w) size(2.5) color("`gry1'") just(right))
            text(8 -5 "Kidney" "Dysfunction"                ,  place(w) size(2.5) color("`gry1'") just(right))

            text(1 87 "High Body" "Mass Index"              ,  place(e) size(2.5) color("`gry1'") just(left))
            text(2 87 "High Systolic" "Blood Pressure"      ,  place(e) size(2.5) color("`gry1'") just(left))
            text(3 87 "Tobacco"                             ,  place(e) size(2.5) color("`gry1'") just(left))
            text(4 87 "High Fasting" "Plasma Glucose"       ,  place(e) size(2.5) color("`gry1'") just(left)) 
            text(5 87 "Dietary Risks"                       ,  place(e) size(2.5) color("`gry1'") just(left)) 
            text(6 87 "Alcohol Use"                         ,  place(e) size(2.5) color("`gry1'") just(left)) 
            text(7 87 "High LDL" "Cholesterol"              ,  place(e) size(2.5) color("`gry1'") just(left))
            text(8 87 "Kidney" "Dysfunction"                ,  place(e) size(2.5) color("`gry1'") just(left))

			legend(off)
			name(slopechart_rf)
			;
#delimit cr	
