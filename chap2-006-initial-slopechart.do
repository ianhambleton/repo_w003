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
    local datapath "C:\yasuki\Sync\output\analyse-write\w003\data"

    ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    local logpath "C:\yasuki\Sync\output\analyse-write\w003\tech-docs"

    ** REPORTS and Other outputs
    local outputpath "C:\yasuki\Sync\output\analyse-write\w003\outputs"

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\chap2-006-initial-slopechart", replace
** HEADER -----------------------------------------------------

tempfile metric1

** ---------------------------------------------------------
** Combine MR and DALY rates for women and men combined.
** ---------------------------------------------------------
use "`datapath'\from-who\chap2_000_mr", clear
keep if region==2000 & sex==3
gen metric = 1
drop sex 
save `metric1', replace

use "`datapath'\from-who\chap2_000_daly", clear
keep if region==2000 & sex==3
gen metric = 2
drop sex
append using `metric1'
label define metric_ 1 "mr" 2 "daly", modify 
label values metric metric_ 

** Rate per 100,000 in 2000 and 2019
keep if year==2000 | year==2019 
drop crate region paho_subregion
format pop_new %15.0fc
replace arate = arate * 100000 
replace arate_new = arate_new * 100000 
gen arate_final = arate
replace arate_final = arate_new if arate_new<. 


** ---------------------------------------------------------
** PREPARE DATA FOR SLOPECHART GRAPHIC
** ---------------------------------------------------------

** Drop grouped causes
drop if ghecause>=100

** Reshape to wide for each year
** Order CoDs by metric size 
drop arate arate_new pop_new cases pop
rename arate_final arate

reshape wide arate, i(metric ghecause) j(year)
gsort metric -arate2000 
by metric : gen order2000 = _n 
gsort metric -arate2019 
by metric : gen order2019 = _n 

** Keep top 20 in  either 2000 or 2019 
keep if order2000<=20 | order2019<=20
sort metric order2000 


** Fix CoDs out of top 20 to drop to values 22 and lower

** Mortality Rates
** 19 in 2000 --> 22 in 2019  --> 28. Leukemia
** 20 in 2000 --> 23 in 2019  --> 17. Ovary cancer
** 24 in 2000 --> 18 in 2019  --> 50. Falls
** 27 in 2000 --> 14 in 2019  --> 36. Drug Use Disorders
replace order2019 = 22 if metric==1 & order2000==19 & order2019==22 & ghecause==50
replace order2019 = 23 if metric==1 & order2000==20 & order2019==22 & ghecause==17
replace order2000 = 22 if metric==1 & order2000==24 & order2019==18 & ghecause==50
replace order2000 = 23 if metric==1 & order2000==27 & order2019==14 & ghecause==36

** DALYs
** 19 in 2000 --> 22 in 2019  --> 15. Cervix uteri cancer
** 23 in 2000 --> 20 in 2019  --> 2. HHD
replace order2019 = 22 if metric==2 & order2000==19 & order2019==22 & ghecause==15
replace order2000 = 22 if metric==2 & order2000==23 & order2019==20 & ghecause==2

** Generate the X-axis 
gen ycode2000 = 1 
gen ycode2019 = 10

** COLOR palette (GRAY, RED, BLUE)
colorpalette d3, 10 nograph
local list r(p) 
** (RED)
local red `r(p4)'
** (Blue)
local blu `r(p1)'
** (Grey)
local gry `r(p8)'



local outer1    25 -4     -5 -4     -5 45      25 45      25 -4 

** DALY RATE

#delimit ;
	gr twoway 

		/// outer boxes 
        /// (scatteri `outer1' , recast(area) lw(0.2) lc(gs10) fc(none)  )

		/// Header line
        (function y = 0.5, range(-2 24) lc("`gry'")) 
        /// (function y = -5, horizontal range(0 23) lc("`gry'")) 

        /// THE LINES
        (pcspike order2000 ycode2000 order2019 ycode2019    if metric==2 & order2019==1 , lw(1.5) lc("`gry'%50")) 
        (pcspike order2000 ycode2000 order2019 ycode2019    if metric==2 & order2019==2 , lw(1.5) lc("`red'%50")) 
        (pcspike order2000 ycode2000 order2019 ycode2019    if metric==2 & order2019==3 , lw(1.5) lc("`red'%50")) 

        (pcspike order2000 ycode2000 order2019 ycode2019    if metric==2 & order2019==4 , lw(1.5) lc("`gry'%50")) 
        (pcspike order2000 ycode2000 order2019 ycode2019    if metric==2 & order2019==5 , lw(1.5) lc("`blu'%50")) 
        (pcspike order2000 ycode2000 order2019 ycode2019    if metric==2 & order2019==6 , lw(1.5) lc("`red'%50")) 
        
        (pcspike order2000 ycode2000 order2019 ycode2019    if metric==2 & order2019==7 , lw(1.5) lc("`gry'%50")) 
        (pcspike order2000 ycode2000 order2019 ycode2019    if metric==2 & order2019==8 , lw(1.5) lc("`blu'%50")) 
        (pcspike order2000 ycode2000 order2019 ycode2019    if metric==2 & order2019==9 , lw(1.5) lc("`red'%50")) 
        
        (pcspike order2000 ycode2000 order2019 ycode2019    if metric==2 & order2019==10 , lw(1.5) lc("`blu'%50")) 
        (pcspike order2000 ycode2000 order2019 ycode2019    if metric==2 & order2019==11 , lw(1.5) lc("`red'%50")) 
        (pcspike order2000 ycode2000 order2019 ycode2019    if metric==2 & order2019==12 , lw(1.5) lc("`blu'%50")) 
        
        (pcspike order2000 ycode2000 order2019 ycode2019    if metric==2 & order2019==13 , lw(1.5) lc("`red'%50")) 
        (pcspike order2000 ycode2000 order2019 ycode2019    if metric==2 & order2019==14 , lw(1.5) lc("`blu'%50")) 
        (pcspike order2000 ycode2000 order2019 ycode2019    if metric==2 & order2019==15 , lw(1.5) lc("`gry'%50")) 
        
        (pcspike order2000 ycode2000 order2019 ycode2019    if metric==2 & order2019==16 , lw(1.5) lc("`red'%50")) 
        (pcspike order2000 ycode2000 order2019 ycode2019    if metric==2 & order2019==17 , lw(1.5) lc("`blu'%50")) 
        (pcspike order2000 ycode2000 order2019 ycode2019    if metric==2 & order2019==18 , lw(1.5) lc("`gry'%50")) 
        
        (pcspike order2000 ycode2000 order2019 ycode2019    if metric==2 & order2019==19 , lw(1.5) lc("`blu'%50")) 
        (pcspike order2000 ycode2000 order2019 ycode2019    if metric==2 & order2019==20 , lw(1.5) lc("`red'%15")) 
        (pcspike order2000 ycode2000 order2019 ycode2019    if metric==2 & order2019==22 , lw(1.5) lc("`blu'%15")) 

		/// IHD. 1-(2000) 1-(2019)
        (sc order2000 ycode2000                             if metric==2 & order2000==1 , msize(10) m(o) mlc("`gry'*0.75") mfc("`gry'*0.5") mlw(0.2))
        (sc order2019 ycode2019                             if metric==2 & order2019==1 , msize(10) m(o) mlc("`gry'*0.75") mfc("`gry'*0.5") mlw(0.2))

		/// IPV. 3-(2000) 2-(2019)
        (sc order2000 ycode2000                             if metric==2 & order2000==3 , msize(10) m(o) mlc("`red'*0.75") mfc("`red'*0.5") mlw(0.2))
        (sc order2019 ycode2019                             if metric==2 & order2019==2 , msize(10) m(o) mlc("`red'*0.75") mfc("`red'*0.5") mlw(0.2))

		/// DIABETES. 5-(2000) 3-(2019)
        (sc order2000 ycode2000                             if metric==2 & order2000==5 , msize(10) m(o) mlc("`red'*0.75") mfc("`red'*0.5") mlw(0.2))
        (sc order2019 ycode2019                             if metric==2 & order2019==3 , msize(10) m(o) mlc("`red'*0.75") mfc("`red'*0.5") mlw(0.2))
        
		/// ROAD INJURY. 4-(2000) 4-(2019)
        (sc order2000 ycode2000                             if metric==2 & order2000==4 , msize(10) m(o) mlc("`gry'*0.75") mfc("`gry'*0.5") mlw(0.2))
        (sc order2019 ycode2019                             if metric==2 & order2019==4 , msize(10) m(o) mlc("`gry'*0.75") mfc("`gry'*0.5") mlw(0.2))
        
		/// STROKE. 2-(2000) 5-(2019)
        (sc order2000 ycode2000                             if metric==2 & order2000==2 , msize(10) m(o) mlc("`blu'*0.75") mfc("`blu'*0.5") mlw(0.2))
        (sc order2019 ycode2019                             if metric==2 & order2019==5 , msize(10) m(o) mlc("`blu'*0.75") mfc("`blu'*0.5") mlw(0.2))        
        
		/// DRUG USE. 12-(2000) 6-(2019)
        (sc order2000 ycode2000                             if metric==2 & order2000==12 , msize(10) m(o) mlc("`red'*0.75") mfc("`red'*0.5") mlw(0.2))
        (sc order2019 ycode2019                             if metric==2 & order2019==6 , msize(10) m(o) mlc("`red'*0.75") mfc("`red'*0.5") mlw(0.2))        
        
		/// DEPRESSIVE. 7-(2000) 7-(2019)
        (sc order2000 ycode2000                             if metric==2 & order2000==7 , msize(10) m(o) mlc("`gry'*0.75") mfc("`gry'*0.5") mlw(0.2))
        (sc order2019 ycode2019                             if metric==2 & order2019==7 , msize(10) m(o) mlc("`gry'*0.75") mfc("`gry'*0.5") mlw(0.2))
        
		/// COPD. 6-(2000) 8-(2019)
        (sc order2000 ycode2000                             if metric==2 & order2000==6 , msize(10) m(o) mlc("`blu'*0.75") mfc("`blu'*0.5") mlw(0.2))
        (sc order2019 ycode2019                             if metric==2 & order2019==8 , msize(10) m(o) mlc("`blu'*0.75") mfc("`blu'*0.5") mlw(0.2))

		/// ANXIETY. 10-(2000) 9-(2019)
        (sc order2000 ycode2000                             if metric==2 & order2000==10 , msize(10) m(o) mlc("`red'*0.75") mfc("`red'*0.5") mlw(0.2))
        (sc order2019 ycode2019                             if metric==2 & order2019==9 , msize(10) m(o) mlc("`red'*0.75") mfc("`red'*0.5") mlw(0.2))

		/// BREAST CANCER. 10-(2000) 12-(2019)
        (sc order2000 ycode2000                             if metric==2 & order2000==9 , msize(10) m(o) mlc("`blu'*0.75") mfc("`blu'*0.5") mlw(0.2))
        (sc order2019 ycode2019                             if metric==2 & order2019==10 , msize(10) m(o) mlc("`blu'*0.75") mfc("`blu'*0.5") mlw(0.2))

		/// SELF HARM. 16-(2000) 11-(2019)
        (sc order2000 ycode2000                             if metric==2 & order2000==16 , msize(10) m(o) mlc("`red'*0.75") mfc("`red'*0.5") mlw(0.2))
        (sc order2019 ycode2019                             if metric==2 & order2019==11 , msize(10) m(o) mlc("`red'*0.75") mfc("`red'*0.5") mlw(0.2))

		/// LUNG CANCER. 8-(2000) 12-(2019)
        (sc order2000 ycode2000                             if metric==2 & order2000==8 , msize(10) m(o) mlc("`blu'*0.75") mfc("`blu'*0.5") mlw(0.2))
        (sc order2019 ycode2019                             if metric==2 & order2019==12 , msize(10) m(o) mlc("`blu'*0.75") mfc("`blu'*0.5") mlw(0.2))

		/// FALLS. 14-(2000) 13-(2019)
        (sc order2000 ycode2000                             if metric==2 & order2000==14 , msize(10) m(o) mlc("`red'*0.75") mfc("`red'*0.5") mlw(0.2))
        (sc order2019 ycode2019                             if metric==2 & order2019==13 , msize(10) m(o) mlc("`red'*0.75") mfc("`red'*0.5") mlw(0.2))

		/// ALCOHOL USE. 14-(2000) 11-(2019)
        (sc order2000 ycode2000                             if metric==2 & order2000==11 , msize(10) m(o) mlc("`blu'*0.75") mfc("`blu'*0.5") mlw(0.2))
        (sc order2019 ycode2019                             if metric==2 & order2019==14 , msize(10) m(o) mlc("`blu'*0.75") mfc("`blu'*0.5") mlw(0.2))

		/// MIGRAINE. 15-(2000) 15-(2019)
        (sc order2000 ycode2000                             if metric==2 & order2000==15 , msize(10) m(o) mlc("`gry'*0.75") mfc("`gry'*0.5") mlw(0.2))
        (sc order2019 ycode2019                             if metric==2 & order2019==15 , msize(10) m(o) mlc("`gry'*0.75") mfc("`gry'*0.5") mlw(0.2))

		/// ALZHEIMER 20-(2000) 16-(2019)
        (sc order2000 ycode2000                             if metric==2 & order2000==20 , msize(10) m(o) mlc("`red'*0.75") mfc("`red'*0.5") mlw(0.2))
        (sc order2019 ycode2019                             if metric==2 & order2019==16 , msize(10) m(o) mlc("`red'*0.75") mfc("`red'*0.5") mlw(0.2))

		/// PROSTATE CANCER. 13-(2000) 17-(2019)
        (sc order2000 ycode2000                             if metric==2 & order2000==13 , msize(10) m(o) mlc("`blu'*0.75") mfc("`blu'*0.5") mlw(0.2))
        (sc order2019 ycode2019                             if metric==2 & order2019==17 , msize(10) m(o) mlc("`blu'*0.75") mfc("`blu'*0.5") mlw(0.2))

		/// ASTHMA. 18-(2000) 18-(2019)
        (sc order2000 ycode2000                             if metric==2 & order2000==18 , msize(10) m(o) mlc("`gry'*0.75") mfc("`gry'*0.5") mlw(0.2))
        (sc order2019 ycode2019                             if metric==2 & order2019==18 , msize(10) m(o) mlc("`gry'*0.75") mfc("`gry'*0.5") mlw(0.2))

		/// COLON CANCER. 17-(2000) 19-(2019)
        (sc order2000 ycode2000                             if metric==2 & order2000==17 , msize(10) m(o) mlc("`blu'*0.75") mfc("`blu'*0.5") mlw(0.2))
        (sc order2019 ycode2019                             if metric==2 & order2019==19 , msize(10) m(o) mlc("`blu'*0.75") mfc("`blu'*0.5") mlw(0.2))

		/// HHD. 22-(2000) 20-(2019)
        (sc order2000 ycode2000                             if metric==2 & order2000==22 , mlc("`red'*0.75") msize(10) m(o) mfc("`red'*0.15") mlw(0.2))
        (sc order2019 ycode2019                             if metric==2 & order2019==20 , mlc("`red'*0.75") msize(10) m(o) mfc("`red'*0.5") mlw(0.2))

		/// CERVICAL. 19-(2000) 22-(2019)
        (sc order2000 ycode2000                             if metric==2 & order2000==19 , msize(10) m(o) mlc("`blu'*0.75") mfc("`blu'*0.5") mlw(0.2))
        (sc order2019 ycode2019                             if metric==2 & order2019==22 , msize(10) m(o) mlc("`blu'*0.75") mfc("`blu'*0.15") mlw(0.2))

        		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			ysize(12) xsize(4.75)

			xlab(none, 
            notick tlc(gs0) labc(gs0) notick nogrid glc(gs16))
			xscale(noline range(-7(1)40)) 
			xtitle(" ", size(5) color(gs0) margin(l=0 r=0 t=0 b=0)) 
			
			ylab(none,
			valuelabel labc(gs0) labs(6) tstyle(major_notick) nogrid glc(gs16) angle(0) format(%9.0f))
			yscale(reverse noline lw(vthin) range(0(0.5)23)) 
			ytitle("", size(5) margin(l=0 r=0 t=0 b=0)) 

            title("Disease burden", size(7) color(gs0) position(11))

            /// Header
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
            text(11 1 "11",  place(c) size(5) color(gs0))
            text(11 10 "11",  place(c) size(5) color(gs0))
            text(12 1 "12",  place(c) size(5) color(gs0))
            text(12 10 "12",  place(c) size(5) color(gs0))
            text(13 1 "13",  place(c) size(5) color(gs0))
            text(13 10 "13",  place(c) size(5) color(gs0))
            text(14 1 "14",  place(c) size(5) color(gs0))
            text(14 10 "14",  place(c) size(5) color(gs0))
            text(15 1 "15",  place(c) size(5) color(gs0))
            text(15 10 "15",  place(c) size(5) color(gs0))
            text(16 1 "16",  place(c) size(5) color(gs0))
            text(16 10 "16",  place(c) size(5) color(gs0))
            text(17 1 "17",  place(c) size(5) color(gs0))
            text(17 10 "17",  place(c) size(5) color(gs0))
            text(18 1 "18",  place(c) size(5) color(gs0))
            text(18 10 "18",  place(c) size(5) color(gs0))
            text(19 1 "19",  place(c) size(5) color(gs0))
            text(19 10 "19",  place(c) size(5) color(gs0))
            text(20 1 "20",  place(c) size(5) color(gs0))
            text(20 10 "20",  place(c) size(5) color(gs0))
            text(22 1 "23",  place(c) size(5) color(gs0))
            text(22 10 "22",  place(c) size(5) color(gs0))


            /// Disease coding 
            text(1 13 "Ischemic heart disease",  place(e) size(4.25) color(gs0))
            text(2 13 "Interpersonal violence",  place(e) size(4.25) color(gs0))
            text(3 13 "Diabetes",  place(e) size(4.25) color(gs0))

            text(4 13 "Road injury",  place(e) size(4.25) color(gs0))
            text(5 13 "Stroke",  place(e) size(4.25) color(gs0))
            text(6 13 "Drug use disorders",  place(e) size(4.25) color(gs0))

            text(7 13 "Depressive disorders",  place(e) size(4.25) color(gs0))
            text(8 13 "COPD",  place(e) size(4.25) color(gs0))
            text(9 13 "Anxiety disorders",  place(e) size(4.25) color(gs0))

            text(10 13 "Breast cancer",  place(e) size(4.25) color(gs0))
            text(11 13 "Self-harm",  place(e) size(4.25) color(gs0))
            text(12 13 "Lung cancer", place(e) size(4.25) color(gs0))

            text(13 13 "Falls",  place(e) size(4.25) color(gs0))
            text(14 13 "Alcohol use disorders",  place(e) size(4.25) color(gs0))
            text(15 13 "Migraine",  place(e) size(4.25) color(gs0))

            text(16 13 "Alzeimer/dementias",  place(e) size(4.25) color(gs0))
            text(17 13 "Prostate cancer",  place(e) size(4.25) color(gs0))
            text(18 13 "Asthma",  place(e) size(4.25) color(gs0))

            text(19 13 "Colorectal cancer",  place(e) size(4.25) color(gs0))
            text(20 13 "Hypertensive heart disease",  place(e) size(4.25) color(gs0))
            text(22 13 "Cervical cancer",  place(e) size(4.25) color(gs0))

			legend(off)
			name(slopechart_daly)
            saving("`outputpath'\reports\graphics\fig3-2-daly.pdf", replace)
			;
#delimit cr	


*** MORTALITY RATE
#delimit ;
	gr twoway 
		/// outer boxes 
        /// (scatteri `outer1' , recast(area) lw(0.2) lc(gs10) fc(none)  )

		/// Header line
        (function y = 0.5, range(-2 24) lc("`gry'")) 

        /// THE LINES
        (pcspike order2000 ycode2000 order2019 ycode2019    if metric==1 & order2000==1 , lw(1.5) lc("`gry'%50")) 
        (pcspike order2000 ycode2000 order2019 ycode2019    if metric==1 & order2000==2 , lw(1.5) lc("`gry'%50")) 
        (pcspike order2000 ycode2000 order2019 ycode2019    if metric==1 & order2000==3 , lw(1.5) lc("`gry'%50"))

        (pcspike order2000 ycode2000 order2019 ycode2019    if metric==1 & order2000==4 , lw(1.5) lc("`blu'%50")) 
        (pcspike order2000 ycode2000 order2019 ycode2019    if metric==1 & order2000==5 , lw(1.5) lc("`gry'%50")) 
        (pcspike order2000 ycode2000 order2019 ycode2019    if metric==1 & order2000==6 , lw(1.5) lc("`blu'%50")) 
        
        (pcspike order2000 ycode2000 order2019 ycode2019    if metric==1 & order2000==7 , lw(1.5) lc("`red'%50")) 
        (pcspike order2000 ycode2000 order2019 ycode2019    if metric==1 & order2000==8 , lw(1.5) lc("`gry'%50")) 
        (pcspike order2000 ycode2000 order2019 ycode2019    if metric==1 & order2000==9 , lw(1.5) lc("`blu'%50")) 
        
        (pcspike order2000 ycode2000 order2019 ycode2019    if metric==1 & order2000==10 , lw(1.5) lc("`blu'%50")) 
        (pcspike order2000 ycode2000 order2019 ycode2019    if metric==1 & order2000==11 , lw(1.5) lc("`red'%50")) 
        (pcspike order2000 ycode2000 order2019 ycode2019    if metric==1 & order2000==12 , lw(1.5) lc("`red'%50")) 
        
        (pcspike order2000 ycode2000 order2019 ycode2019    if metric==1 & order2000==13 , lw(1.5) lc("`blu'%50")) 
        (pcspike order2000 ycode2000 order2019 ycode2019    if metric==1 & order2000==14 , lw(1.5) lc("`blu'%50")) 
        (pcspike order2000 ycode2000 order2019 ycode2019    if metric==1 & order2000==15 , lw(1.5) lc("`red'%50")) 
        
        (pcspike order2000 ycode2000 order2019 ycode2019    if metric==1 & order2000==16 , lw(1.5) lc("`blu'%50")) 
        (pcspike order2000 ycode2000 order2019 ycode2019    if metric==1 & order2000==17 , lw(1.5) lc("`gry'%50")) 
        (pcspike order2000 ycode2000 order2019 ycode2019    if metric==1 & order2000==18 , lw(1.5) lc("`red'%50")) 
        
        (pcspike order2000 ycode2000 order2019 ycode2019    if metric==1 & order2000==19 , lw(1.5) lc("`blu'%15")) 
        (pcspike order2000 ycode2000 order2019 ycode2019    if metric==1 & order2000==20 , lw(1.5) lc("`blu'%15")) 
        (pcspike order2000 ycode2000 order2019 ycode2019    if metric==1 & order2000==22 , lw(1.5) lc("`red'%15")) 
        (pcspike order2000 ycode2000 order2019 ycode2019    if metric==1 & order2000==23 , lw(1.5) lc("`red'%15")) 

		/// IHD. 1-(2000) 1-(2019)
        (sc order2000 ycode2000                             if metric==1 & order2000==1 , msize(10) m(o) mlc("`gry'*0.75") mfc("`gry'*0.5") mlw(0.2))
        (sc order2019 ycode2019                             if metric==1 & order2019==1 , msize(10) m(o) mlc("`gry'*0.75") mfc("`gry'*0.5") mlw(0.2))

		/// STROKE. 2-(2000) 2-(2019)
        (sc order2000 ycode2000                             if metric==1 & order2000==2 , msize(10) m(o) mlc("`gry'*0.75") mfc("`gry'*0.5") mlw(0.2))
        (sc order2019 ycode2019                             if metric==1 & order2019==2 , msize(10) m(o) mlc("`gry'*0.75") mfc("`gry'*0.5") mlw(0.2))

		/// COPD. 3-(2000) 3-(2019)
        (sc order2000 ycode2000                             if metric==1 & order2000==3 , msize(10) m(o) mlc("`gry'*0.75") mfc("`gry'*0.5") mlw(0.2))
        (sc order2019 ycode2019                             if metric==1 & order2019==3 , msize(10) m(o) mlc("`gry'*0.75") mfc("`gry'*0.5") mlw(0.2))
        
		/// LUNG CANCER. 4-(2000) 7-(2019)
        (sc order2000 ycode2000                             if metric==1 & order2000==4 , msize(10) mlc("`blu'*0.75") m(o) mfc("`blu'*0.5") mlw(0.2))
        (sc order2019 ycode2019                             if metric==1 & order2019==7 , msize(10) mlc("`blu'*0.75") m(o) mfc("`blu'*0.5") mlw(0.2))
        
		/// DIABETES. 5-(2000) 5-(2019)
        (sc order2000 ycode2000                             if metric==1 & order2000==5 , msize(10) m(o) mlc("`gry'*0.75") mfc("`gry'*0.5") mlw(0.2))
        (sc order2019 ycode2019                             if metric==1 & order2019==5 , msize(10) m(o) mlc("`gry'*0.75") mfc("`gry'*0.5") mlw(0.2))        
        
		/// PROSTATE. 6-(2000) 9-(2019)
        (sc order2000 ycode2000                             if metric==1 & order2000==6 , msize(10) m(o) mlc("`blu'*0.75") mfc("`blu'*0.5") mlw(0.2))
        (sc order2019 ycode2019                             if metric==1 & order2019==9 , msize(10) m(o) mlc("`blu'*0.75") mfc("`blu'*0.5") mlw(0.2))        
        
		/// IPV. 7-(2000) 6-(2019)
        (sc order2000 ycode2000                             if metric==1 & order2000==7 , msize(10) m(o) mlc("`red'*0.75") mfc("`red'*0.5") mlw(0.2))
        (sc order2019 ycode2019                             if metric==1 & order2019==6 , msize(10) m(o) mlc("`red'*0.75") mfc("`red'*0.5") mlw(0.2))
        
		/// BREAST CANCER. 8-(2000) 8-(2019)
        (sc order2000 ycode2000                             if metric==1 & order2000==8 , msize(10) m(o) mlc("`gry'*0.75") mfc("`gry'*0.5") mlw(0.2))
        (sc order2019 ycode2019                             if metric==1 & order2019==8 , msize(10) m(o) mlc("`gry'*0.75") mfc("`gry'*0.5") mlw(0.2))

		/// ROAD INJURY. 9-(2000) 10-(2019)
        (sc order2000 ycode2000                             if metric==1 & order2000==9 , msize(10) m(o) mlc("`blu'*0.75") mfc("`blu'*0.5") mlw(0.2))
        (sc order2019 ycode2019                             if metric==1 & order2019==10 , msize(10) m(o) mlc("`blu'*0.75") mfc("`blu'*0.5") mlw(0.2))

		/// COLON CANCER. 10-(2000) 12-(2019)
        (sc order2000 ycode2000                             if metric==1 & order2000==10 , msize(10) m(o) mlc("`blu'*0.75") mfc("`blu'*0.5") mlw(0.2))
        (sc order2019 ycode2019                             if metric==1 & order2019==12 , msize(10) m(o) mlc("`blu'*0.75") mfc("`blu'*0.5") mlw(0.2))

		/// ALXHEIMERS. 11-(2000) 4-(2019)
        (sc order2000 ycode2000                             if metric==1 & order2000==11 , msize(10) m(o) mlc("`red'*0.75") mfc("`red'*0.5") mlw(0.2))
        (sc order2019 ycode2019                             if metric==1 & order2019==4 , msize(10) m(o) mlc("`red'*0.75") mfc("`red'*0.5") mlw(0.2))

		/// HHD. 12-(2000) 1-(2019)
        (sc order2000 ycode2000                             if metric==1 & order2000==12 , msize(10) m(o) mlc("`red'*0.75") mfc("`red'*0.5") mlw(0.2))
        (sc order2019 ycode2019                             if metric==1 & order2019==11 , msize(10) m(o) mlc("`red'*0.75") mfc("`red'*0.5") mlw(0.2))

		/// CERVICAL CANCER etc. 13-(2000) 15-(2019)
        (sc order2000 ycode2000                             if metric==1 & order2000==13 , msize(10) m(o) mlc("`blu'*0.75") mfc("`blu'*0.5") mlw(0.2))
        (sc order2019 ycode2019                             if metric==1 & order2019==15 , msize(10) m(o) mlc("`blu'*0.75") mfc("`blu'*0.5") mlw(0.2))

		/// CARDIOMYOPATHY. 14-(2000) 20-(2019)
        (sc order2000 ycode2000                             if metric==1 & order2000==14 , msize(10) m(o) mlc("`blu'*0.75") mfc("`blu'*0.5") mlw(0.2))
        (sc order2019 ycode2019                             if metric==1 & order2019==20 , msize(10) m(o) mlc("`blu'*0.75") mfc("`blu'*0.5") mlw(0.2))

		/// SELF HARM. 15-(2000) 13-(2019)
        (sc order2000 ycode2000                             if metric==1 & order2000==15 , msize(10) m(o) mlc("`red'*0.75") mfc("`red'*0.5") mlw(0.2))
        (sc order2019 ycode2019                             if metric==1 & order2019==13 , msize(10) m(o) mlc("`red'*0.75") mfc("`red'*0.5") mlw(0.2))

		/// STOMACH CANCER. 16-(2000) 19-(2019)
        (sc order2000 ycode2000                             if metric==1 & order2000==16 , msize(10) m(o) mlc("`blu'*0.75") mfc("`blu'*0.5") mlw(0.2))
        (sc order2019 ycode2019                             if metric==1 & order2019==19 , msize(10) m(o) mlc("`blu'*0.75") mfc("`blu'*0.5") mlw(0.2))

		/// LYMPHOMA. 17-(2000) 17-(2019)
        (sc order2000 ycode2000                             if metric==1 & order2000==17 , msize(10) m(o) mlc("`gry'*0.75") mfc("`gry'*0.5") mlw(0.2))
        (sc order2019 ycode2019                             if metric==1 & order2019==17 , msize(10) m(o) mlc("`gry'*0.75") mfc("`gry'*0.5") mlw(0.2))

		/// PANCREAS CANCER. 18-(2000) 16-(2019)
        (sc order2000 ycode2000                             if metric==1 & order2000==18 , msize(10) m(o) mlc("`red'*0.75") mfc("`red'*0.5") mlw(0.2))
        (sc order2019 ycode2019                             if metric==1 & order2019==16 , msize(10) m(o) mlc("`red'*0.75") mfc("`red'*0.5") mlw(0.2))

		/// LEUKEMIA. 19-(2000) 22-(2019)
        (sc order2000 ycode2000                             if metric==1 & order2000==19 , msize(10) m(o) mlc("`blu'*0.75") mfc("`blu'*0.5") mlw(0.2))
        (sc order2019 ycode2019                             if metric==1 & order2019==22 , msize(10) m(o) mlc("`blu'*0.75") mfc("`blu'*0.15") mlw(0.2))

		/// OVARY CANCER. 20-(2000) 23-(2019)
        (sc order2000 ycode2000                             if metric==1 & order2000==20 , msize(10) m(o) mlc("`blu'*0.75") mfc("`blu'*0.5") mlw(0.2))
        (sc order2019 ycode2019                             if metric==1 & order2019==23 , msize(10) m(o) mlc("`blu'*0.75") mfc("`blu'*0.15") mlw(0.2))

		/// FALLS. 22-(2000) 18-(2019)
        (sc order2000 ycode2000                             if metric==1 & order2000==22 , msize(10) m(o) mlc("`red'*0.75") mfc("`red'*0.15") mlw(0.2))
        (sc order2019 ycode2019                             if metric==1 & order2019==18 , msize(10) m(o) mlc("`red'*0.75") mfc("`red'*0.5") mlw(0.2))
        
		/// DRUG USE DISORDERS. 23-(2000) 14-(2019)
        (sc order2000 ycode2000                             if metric==1 & order2000==23 , msize(10) m(o) mlc("`red'*0.75") mfc("`red'*0.15") mlw(0.2))
        (sc order2019 ycode2019                             if metric==1 & order2019==14 , msize(10) m(o) mlc("`red'*0.75") mfc("`red'*0.5") mlw(0.2))

        		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			ysize(12) xsize(4.75)

			xlab(none, 
            notick tlc(gs0) labc(gs0) notick nogrid glc(gs16))
			xscale(noline range(-7(1)40)) 
			xtitle(" ", size(5) color(gs0) margin(l=0 r=0 t=0 b=0)) 
			
			ylab(none,
			valuelabel labc(gs0) labs(6) tstyle(major_notick) nogrid glc(gs16) angle(0) format(%9.0f))
			yscale(reverse noline lw(vthin) range(0(0.5)23)) 
			ytitle("", size(5) margin(l=0 r=0 t=0 b=0)) 

            title("Disease deaths", size(7) color(gs0) position(11))

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
            text(11 1 "11",  place(c) size(5) color(gs0))
            text(11 10 "11",  place(c) size(5) color(gs0))
            text(12 1 "12",  place(c) size(5) color(gs0))
            text(12 10 "12",  place(c) size(5) color(gs0))
            text(13 1 "13",  place(c) size(5) color(gs0))
            text(13 10 "13",  place(c) size(5) color(gs0))
            text(14 1 "14",  place(c) size(5) color(gs0))
            text(14 10 "14",  place(c) size(5) color(gs0))
            text(15 1 "15",  place(c) size(5) color(gs0))
            text(15 10 "15",  place(c) size(5) color(gs0))
            text(16 1 "16",  place(c) size(5) color(gs0))
            text(16 10 "16",  place(c) size(5) color(gs0))
            text(17 1 "17",  place(c) size(5) color(gs0))
            text(17 10 "17",  place(c) size(5) color(gs0))
            text(18 1 "18",  place(c) size(5) color(gs0))
            text(18 10 "18",  place(c) size(5) color(gs0))
            text(19 1 "19",  place(c) size(5) color(gs0))
            text(19 10 "19",  place(c) size(5) color(gs0))
            text(20 1 "20",  place(c) size(5) color(gs0))
            text(20 10 "20",  place(c) size(5) color(gs0))
            text(22 1 "23",  place(c) size(5) color(gs0))
            text(22 10 "21",  place(c) size(5) color(gs0))
            text(23 1 "27",  place(c) size(5) color(gs0))
            text(23 10 "24",  place(c) size(5) color(gs0))


            /// Disease coding 
            text(1 13 "Ischemic heart disease",  place(e) size(4.25) color(gs0))
            text(2 13 "Stroke",  place(e) size(4.25) color(gs0))
            text(3 13 "COPD",  place(e) size(4.25) color(gs0))
            text(4 13 "Alzeimer/dementias",  place(e) size(4.25) color(gs0))
            text(5 13 "Diabetes",  place(e) size(4.25) color(gs0))
            text(6 13 "Interpersonal violence",  place(e) size(4.25) color(gs0))
            text(7 13 "Lung cancers", place(e) size(4.25) color(gs0))
            text(8 13 "Breast cancer",  place(e) size(4.25) color(gs0))
            text(9 13 "Prostate cancer",  place(e) size(4.25) color(gs0))
            text(10 13 "Road injury",  place(e) size(4.25) color(gs0))
            text(11 13 "Hypertensive heart disease",  place(e) size(4.25) color(gs0))
            text(12 13 "Colorectal cancer",  place(e) size(4.25) color(gs0))
            text(13 13 "Self-harm",  place(e) size(4.25) color(gs0))
            text(14 13 "Drug use disorders",  place(e) size(4.25) color(gs0))
            text(15 13 "Cervical cancer",  place(e) size(4.25) color(gs0))
            text(16 13 "Pancreas cancer",  place(e) size(4.25) color(gs0))
            text(17 13 "Lymphomas, myeloma",  place(e) size(4.25) color(gs0))
            text(18 13 "Falls",  place(e) size(4.25) color(gs0))
            text(19 13 "Stomach cancer",  place(e) size(4.25) color(gs0))
            text(20 13 "Cardiomyopathy etc.",  place(e) size(4.25) color(gs0))
            text(22 13 "Leukemia",  place(e) size(4.25) color(gs0))
            text(23 13 "Ovarian cancer",  place(e) size(4.25) color(gs0))

			legend(off)
			name(slopechart_mr)
            saving("`outputpath'\reports\graphics\fig3-2-mortality.pdf", replace)
			;
#delimit cr	

** Figure 3.2
#delimit ;
gr combine  "`outputpath'\reports\graphics\fig3-2-mortality.pdf" 
            "`outputpath'\reports\graphics\fig3-2-daly.pdf"
            ,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 
			ysize(12) xsize(8)

            rows(1) cols(2)
            iscale(*0.7)
            ///ycommon
            ;
#delimit cr

** Export to Vector Graphic
** DEC 22nd, 2022
graph export "`outputpath'\reports\2024-edits\graphics\fig11.svg", replace
graph export "`outputpath'\reports\2024-edits\graphics\fig11.pdf", replace


    ** Export data for Figure 11
    sort metric order2019 
    keep ghecause metric arate2000 arate2019 order2000 order2019   
    rename ghecause disease_group 
    rename arate2000 rate2000
    rename arate2019 rate2019
    order disease_group metric rate2000 rate2019 order2000 order2019 
    export excel "`outputpath'\reports\2024-edits\graphics\chap2_data.xlsx", sheet("figure-11", replace) first(var) keepcellfmt
