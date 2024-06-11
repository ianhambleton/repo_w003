** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			        chap2-008-initial-slopechart-who.do
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
    local datapath "C:\yasuki\Sync\output\analyse-write\w003\data"

    ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    local logpath "C:\yasuki\Sync\output\analyse-write\w003\tech-docs"

    ** REPORTS and Other outputs
    local outputpath "C:\yasuki\Sync\output\analyse-write\w003\outputs"

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\chap2-008-initial-slopechart-who", replace
** HEADER -----------------------------------------------------

import excel using "X:\OneDrive - The University of the West Indies\Writing\w003\outputs\reports\comments/Leading causes .xlsx", first sheet("Sheet1") clear

** Quintiles
gen q1 = .
replace q1 = 1 if morder<=4
replace q1 = 2 if morder>=5 & morder<=8 
replace q1 = 3 if morder>=9 & morder<=12 
replace q1 = 4 if morder>=13 & morder<=16
replace q1 = 5 if morder>=17 & morder<=20 
gen q2 = .
replace q2 = 1 if dorder<=4
replace q2 = 2 if dorder>=5 & dorder<=8 
replace q2 = 3 if dorder>=9 & dorder<=12 
replace q2 = 4 if dorder>=13 & dorder<=16
replace q2 = 5 if dorder>=17 & dorder<=20 

** ------------------------------------------------
** GRAPH PREPARATION
** ------------------------------------------------
** COLOR palette (GRAY, RED, BLUE)
colorpalette d3, 10 nograph
local list r(p) 
** (RED)
local red `r(p4)'
** (Blue)
local blu `r(p1)'
** (Grey)
local gry `r(p8)'
** COLOR for quintiles (groups of FOUR)
colorpalette RdYlBu , n(9) nogr
local list r(p) 
* Red / Orange / Yellow / Blue1 / Blue2
local q1 `r(p1)'
local q2 `r(p3)'
local q3 `r(p5)'
local q4 `r(p7)'
local q5 `r(p9)'

** Does cause exist in top-20 deaths and disability
gen twice = 0
replace twice = 1 if morder<. & dorder<.

** Vertical position of rank columns
gen circle1 = 10
gen circle2 = 20
sort morder
#delimit ;
	gr twoway 

		/// Header line
        (function y = 0, range(4 26) lc("`gry'")) 

        /// THE CONNECTING LINES
        (pcspike morder circle1 dorder circle2  , lw(1.25) lc("gs0%20")) 

		/// IHD. 1-(2000) 1-(2019)
        (sc morder circle1 if q1==1 & twice==0, msize(5) m(o) mlc("`q1'*0.7") mfc("gs5") mlw(2))
        (sc morder circle1 if q1==2 & twice==0, msize(5) m(o) mlc("`q2'*0.7") mfc("gs5") mlw(2))
        (sc morder circle1 if q1==3 & twice==0, msize(5) m(o) mlc("`q3'*0.7") mfc("gs5") mlw(2))
        (sc morder circle1 if q1==4 & twice==0, msize(5) m(o) mlc("`q4'*0.7") mfc("gs5") mlw(2))
        (sc morder circle1 if q1==5 & twice==0, msize(5) m(o) mlc("`q5'*0.7") mfc("gs5") mlw(2))
        (sc dorder circle2 if q2==1 & twice==0, msize(5) m(o) mlc("`q1'*0.7") mfc("gs5") mlw(2))
        (sc dorder circle2 if q2==2 & twice==0, msize(5) m(o) mlc("`q2'*0.7") mfc("gs5") mlw(2))
        (sc dorder circle2 if q2==3 & twice==0, msize(5) m(o) mlc("`q3'*0.7") mfc("gs5") mlw(2))
        (sc dorder circle2 if q2==4 & twice==0, msize(5) m(o) mlc("`q4'*0.7") mfc("gs5") mlw(2))
        (sc dorder circle2 if q2==5 & twice==0, msize(5) m(o) mlc("`q5'*0.7") mfc("gs5") mlw(2))

        (sc morder circle1 if q1==1 & twice==1, msize(8) m(o) mlc("gs0") mfc("`q1'*0.7") mlw(0.2))
        (sc morder circle1 if q1==2 & twice==1, msize(8) m(o) mlc("gs0") mfc("`q2'*0.7") mlw(0.2))
        (sc morder circle1 if q1==3 & twice==1, msize(8) m(o) mlc("gs0") mfc("`q3'*0.7") mlw(0.2))
        (sc morder circle1 if q1==4 & twice==1, msize(8) m(o) mlc("gs0") mfc("`q4'*0.7") mlw(0.2))
        (sc morder circle1 if q1==5 & twice==1, msize(8) m(o) mlc("gs0") mfc("`q5'*0.7") mlw(0.2))

        (sc dorder circle2 if q2==1 & twice==1, msize(8) m(o) mlc("gs0") mfc("`q1'*0.7") mlw(0.2))
        (sc dorder circle2 if q2==2 & twice==1, msize(8) m(o) mlc("gs0") mfc("`q2'*0.7") mlw(0.2))
        (sc dorder circle2 if q2==3 & twice==1, msize(8) m(o) mlc("gs0") mfc("`q3'*0.7") mlw(0.2))
        (sc dorder circle2 if q2==4 & twice==1, msize(8) m(o) mlc("gs0") mfc("`q4'*0.7") mlw(0.2))
        (sc dorder circle2 if q2==5 & twice==1, msize(8) m(o) mlc("gs0") mfc("`q5'*0.7") mlw(0.2))
        		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			ysize(12) xsize(7)

			xlab(none, 
            notick tlc(gs0) labc(gs0) notick nogrid glc(gs16))
			xscale(noline range(-12(1)42)) 
			xtitle(" ", size(5) color(gs0) margin(l=0 r=0 t=0 b=0)) 
			
			ylab(none,
			valuelabel labc(gs0) labs(6) tstyle(major_notick) nogrid glc(gs16) angle(0) format(%9.0f))
			yscale(reverse noline lw(vthin) range(19(-1)-2)) 
			ytitle("", size(5) margin(l=0 r=0 t=0 b=0)) 

            /// title("Disease burden", size(7) color(gs0) position(11))

            /// Header
            text(-1 5 "Disease" "Deaths"         ,  place(c) size(4.5) color(gs5))
            text(-1 25 "Disease" "Burden"  ,  place(c) size(4.5) color(gs5))

            /// Circle numbering 
            /// text(1 1 "1",  place(c) size(5) color(gs0))
            /// text(1 10 "1",  place(c) size(5) color(gs0))

            /// Disease coding 
            text(1 7  "Ischemic heart disease"  ,  place(w) size(3.75) color(gs10) just(right))
            text(1 23 "Ischemic heart disease"  ,  place(e) size(3.75) color(gs10) just(left))

            text(2 7  "Stroke"  ,  place(w) size(3.75) color(gs10) just(right))
            text(4 23 "Stroke"  ,  place(e) size(3.75) color(gs10) just(left))

            text(3 7   "Alzeimer/dementias"  ,  place(w) size(3.75) color(gs10) just(right))
            text(13 23 "Alzeimer/dementias"  ,  place(e) size(3.75) color(gs10) just(left))

            text(4 7  "COPD"    ,  place(w) size(3.75) color(gs10) just(right))
            text(7 23 "COPD"    ,  place(e) size(3.75) color(gs10) just(left))

            text(5 7   "Lower resp. inf."    ,  place(w) size(3.75) color(gs10) just(right))
            text(12 23 "Lower resp. inf."    ,  place(e) size(3.75) color(gs10) just(left))

            text(6 7  "Diabetes"    ,  place(w) size(3.75) color(gs10) just(right))
            text(2 23 "Diabetes"    ,  place(e) size(3.75) color(gs10) just(left))

            text(7 7   "Lung cancer"    ,  place(w) size(3.75) color(gs10) just(right))
            text(16 23 "Lung cancer"    ,  place(e) size(3.75) color(gs10) just(left))

            text(8 7   "Kidney diseases"    ,  place(w) size(3.75) color(gs10) just(right))
            text(10 23 "Kidney diseases"    ,  place(e) size(3.75) color(gs10) just(left))

            text(9 7   "IPV"    ,  place(w) size(3.75) color(gs10) just(right))
            text(3 23  "IPV"    ,  place(e) size(3.75) color(gs10) just(left))

            text(10 7   "HHD"    ,  place(w) size(3.75) color(gs10) just(right))

            text(11 7   "Road injury"    ,  place(w) size(3.75) color(gs10) just(right))
            text(6 23   "Road injury"    ,  place(e) size(3.75) color(gs10) just(left))

            text(12 7   "Liver cirrhosis"    ,  place(w) size(3.75) color(gs10) just(right))
            text(20 23  "Liver cirrhosis"    ,  place(e) size(3.75) color(gs10) just(left))

            text(13 7   "Colorectal cancer"    ,  place(w) size(3.75) color(gs10) just(right))

            text(14 7   "Breast cancer"    ,  place(w) size(3.75) color(gs10) just(right))

            text(15 7   "Prostate cancer"    ,  place(w) size(3.75) color(gs10) just(right))

            text(16 7    "Self harm"    ,  place(w) size(3.75) color(gs10) just(right))
            text(19 23   "Self harm"    ,  place(e) size(3.75) color(gs10) just(left))

            text(17 7   "Neonatal conditions"    ,  place(w) size(3.75) color(gs10) just(right))
            text(5 23   "Neonatal conditions"    ,  place(e) size(3.75) color(gs10) just(left))

            text(18 7   "Drug use disorders"    ,  place(w) size(3.75) color(gs10) just(right))
            text(9 23   "Drug use disorders"    ,  place(e) size(3.75) color(gs10) just(left))

            text(19 7   "Pancreas cancer"    ,  place(w) size(3.75) color(gs10) just(right))

            text(20 7   "Falls"    ,  place(w) size(3.75) color(gs10) just(right))
            text(18 23  "Falls"    ,  place(e) size(3.75) color(gs10) just(left))

            text(8 23    "Back and neck pain"    ,  place(e) size(3.75) color(gs10) just(left))
            text(17 23   "Congenital anomolies"    ,  place(e) size(3.75) color(gs10) just(left))
            text(15 23   "Anxiety disorders"    ,  place(e) size(3.75) color(gs10) just(left))
            text(11 23   "Depressive disorders"    ,  place(e) size(3.75) color(gs10) just(left))
            text(14 23   "Other hearing loss"    ,  place(e) size(3.75) color(gs10) just(left))

			legend(off)
			name(slopechart1)
			;
#delimit cr	

** Export to Vector Graphic
** DEC 22nd, 2022
graph export "`outputpath'\reports\2024-edits\graphics\box4.svg", replace
graph export "`outputpath'\reports\2024-edits\graphics\box4.pdf", replace


/*
#delimit ;
	gr twoway 

		/// Header line
        (function y = 0, range(4 26) lc("`gry'")) 

        /// THE CONNECTING LINES
        (pcspike morder circle1 dorder circle2 if q1==1 , lw(1) lc("gs0%20")) 
        (pcspike morder circle1 dorder circle2 if q1==2 , lw(1) lc("gs0%20")) 
        (pcspike morder circle1 dorder circle2 if q1==3 , lw(1) lc("gs0%20")) 
        (pcspike morder circle1 dorder circle2 if q1==4 , lw(1) lc("gs0%20")) 
        (pcspike morder circle1 dorder circle2 if q1==5 , lw(1) lc("gs0%20")) 

		/// IHD. 1-(2000) 1-(2019)
        (sc morder circle1 if q1==1 & twice==0, msize(5) m(o) mlc("`q1'*0.7") mfc("gs0") mlw(2))
        (sc morder circle1 if q1==2 & twice==0, msize(5) m(o) mlc("`q2'*0.7") mfc("gs0") mlw(2))
        (sc morder circle1 if q1==3 & twice==0, msize(5) m(o) mlc("`q3'*0.7") mfc("gs0") mlw(2))
        (sc morder circle1 if q1==4 & twice==0, msize(5) m(o) mlc("`q4'*0.7") mfc("gs0") mlw(2))
        (sc morder circle1 if q1==5 & twice==0, msize(5) m(o) mlc("`q5'*0.7") mfc("gs0") mlw(2))

        (sc dorder circle2 if q1==1 & twice==0, msize(5) m(o) mlc("`q1'*0.7") mfc("gs0") mlw(2))
        (sc dorder circle2 if q1==2 & twice==0, msize(5) m(o) mlc("`q2'*0.7") mfc("gs0") mlw(2))
        (sc dorder circle2 if q1==3 & twice==0, msize(5) m(o) mlc("`q3'*0.7") mfc("gs0") mlw(2))
        (sc dorder circle2 if q1==4 & twice==0, msize(5) m(o) mlc("`q4'*0.7") mfc("gs0") mlw(2))
        (sc dorder circle2 if q1==5 & twice==0, msize(5) m(o) mlc("`q5'*0.7") mfc("gs0") mlw(2))

        (sc morder circle1 if q1==1 & twice==1, msize(8) m(o) mlc("gs0") mfc("`q1'*0.7") mlw(0.2))
        (sc morder circle1 if q1==2 & twice==1, msize(8) m(o) mlc("gs0") mfc("`q2'*0.7") mlw(0.2))
        (sc morder circle1 if q1==3 & twice==1, msize(8) m(o) mlc("gs0") mfc("`q3'*0.7") mlw(0.2))
        (sc morder circle1 if q1==4 & twice==1, msize(8) m(o) mlc("gs0") mfc("`q4'*0.7") mlw(0.2))
        (sc morder circle1 if q1==5 & twice==1, msize(8) m(o) mlc("gs0") mfc("`q5'*0.7") mlw(0.2))
        
        (sc dorder circle2 if q1==1 & twice==1, msize(8) m(o) mlc("gs0") mfc("`q1'*0.7") mlw(0.2))
        (sc dorder circle2 if q1==2 & twice==1, msize(8) m(o) mlc("gs0") mfc("`q2'*0.7") mlw(0.2))
        (sc dorder circle2 if q1==3 & twice==1, msize(8) m(o) mlc("gs0") mfc("`q3'*0.7") mlw(0.2))
        (sc dorder circle2 if q1==4 & twice==1, msize(8) m(o) mlc("gs0") mfc("`q4'*0.7") mlw(0.2))
        (sc dorder circle2 if q1==5 & twice==1, msize(8) m(o) mlc("gs0") mfc("`q5'*0.7") mlw(0.2))
        		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			ysize(12) xsize(7)

			xlab(none, 
            notick tlc(gs0) labc(gs0) notick nogrid glc(gs16))
			xscale(noline range(-12(1)42)) 
			xtitle(" ", size(5) color(gs0) margin(l=0 r=0 t=0 b=0)) 
			
			ylab(none,
			valuelabel labc(gs0) labs(6) tstyle(major_notick) nogrid glc(gs16) angle(0) format(%9.0f))
			yscale(reverse noline lw(vthin) range(22(-1)-2)) 
			ytitle("", size(5) margin(l=0 r=0 t=0 b=0)) 

            /// title("Disease burden", size(7) color(gs0) position(11))

            /// Header
            text(-1 5 "Disease" "Deaths"         ,  place(c) size(4.5) color(gs5))
            text(-1 25 "Disease" "Burden"  ,  place(c) size(4.5) color(gs5))

            /// Circle numbering 
            /// text(1 1 "1",  place(c) size(5) color(gs0))
            /// text(1 10 "1",  place(c) size(5) color(gs0))

            /// Disease coding 
            text(1 7  "Ischemic heart disease"  ,  place(w) size(3.75) color(gs10) just(right))
            text(1 23 "Ischemic heart disease"  ,  place(e) size(3.75) color(gs10) just(left))

            text(2 7  "Stroke"  ,  place(w) size(3.75) color(gs10) just(right))
            text(4 23 "Stroke"  ,  place(e) size(3.75) color(gs10) just(left))

            text(3 7   "Alzeimers/dementias"  ,  place(w) size(3.75) color(gs10) just(right))
            text(13 23 "Alzeimers/dementias"  ,  place(e) size(3.75) color(gs10) just(left))

            text(4 7  "COPD"    ,  place(w) size(3.75) color(gs10) just(right))
            text(7 23 "COPD"    ,  place(e) size(3.75) color(gs10) just(left))

            text(5 7   "Lower Resp.Inf"    ,  place(w) size(3.75) color(gs10) just(right))
            text(12 23 "Lower Resp.Inf"    ,  place(e) size(3.75) color(gs10) just(left))

            text(6 7  "Diabetes"    ,  place(w) size(3.75) color(gs10) just(right))
            text(2 23 "Diabetes"    ,  place(e) size(3.75) color(gs10) just(left))

            text(7 7   "Lung cancer"    ,  place(w) size(3.75) color(gs10) just(right))
            text(16 23 "Lung cancer"    ,  place(e) size(3.75) color(gs10) just(left))

            text(8 7   "Kidney diseases"    ,  place(w) size(3.75) color(gs10) just(right))
            text(10 23 "Kidney diseases"    ,  place(e) size(3.75) color(gs10) just(left))

            text(9 7   "IPV"    ,  place(w) size(3.75) color(gs10) just(right))
            text(3 23  "IPV"    ,  place(e) size(3.75) color(gs10) just(left))

            text(10 7   "HHD"    ,  place(w) size(3.75) color(gs10) just(right))

            text(11 7   "Road injury"    ,  place(w) size(3.75) color(gs10) just(right))
            text(6 23   "Road injury"    ,  place(e) size(3.75) color(gs10) just(left))

            text(12 7   "Liver cirrhosis"    ,  place(w) size(3.75) color(gs10) just(right))
            text(20 23  "Liver cirrhosis"    ,  place(e) size(3.75) color(gs10) just(left))

            text(13 7   "Colorectal cancer"    ,  place(w) size(3.75) color(gs10) just(right))

            text(14 7   "Breast cancer"    ,  place(w) size(3.75) color(gs10) just(right))

            text(15 7   "Prostate cancer"    ,  place(w) size(3.75) color(gs10) just(right))

            text(16 7    "Self harm"    ,  place(w) size(3.75) color(gs10) just(right))
            text(19 23   "Self harm"    ,  place(e) size(3.75) color(gs10) just(left))

            text(17 7   "Neonatal conditions"    ,  place(w) size(3.75) color(gs10) just(right))
            text(5 23   "Neonatal conditions"    ,  place(e) size(3.75) color(gs10) just(left))

            text(18 7   "Drug use disorders"    ,  place(w) size(3.75) color(gs10) just(right))
            text(9 23   "Drug use disorders"    ,  place(e) size(3.75) color(gs10) just(left))

            text(19 7   "Pancreas cancer"    ,  place(w) size(3.75) color(gs10) just(right))

            text(20 7   "Falls"    ,  place(w) size(3.75) color(gs10) just(right))
            text(18 23  "Falls"    ,  place(e) size(3.75) color(gs10) just(left))

            text(8 23    "Back and neck pain"    ,  place(e) size(3.75) color(gs10) just(left))
            text(17 23   "Congenital anomolies"    ,  place(e) size(3.75) color(gs10) just(left))
            text(15 23   "Anxiety disorders"    ,  place(e) size(3.75) color(gs10) just(left))
            text(11 23   "Depressive disorders"    ,  place(e) size(3.75) color(gs10) just(left))
            text(14 23   "Other hearing loss"    ,  place(e) size(3.75) color(gs10) just(left))

			legend(off)
			name(slopechart2)
			;
#delimit cr	


/*
** Export to Vector Graphic
** DEC 22nd, 2022
graph export "`outputpath'\reports\2024-edits\graphics\fig12.svg", replace
graph export "`outputpath'\reports\2024-edits\graphics\fig12.pdf", replace
