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
    local datapath "X:\OneDrive - The University of the West Indies\Writing\w003\data"

    ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    local logpath "X:\OneDrive - The University of the West Indies\Writing\w003\tech-docs"

    ** REPORTS and Other outputs
    local outputpath "X:\OneDrive - The University of the West Indies\Writing\w003\outputs"

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\chap2-008-initial-slopechart-who", replace
** HEADER -----------------------------------------------------

input type order str50 cod cnum
1  1	"IHD"	1091 
1  2	"Stroke"	478 
1  3	"Dementias"	390 
1  4	"COPD"	378 
1  5	"Lower respiratory infections"	317 
1  6	"Diabetes"	284 
1  7	"Lung cancers"	256 
1  8	"Kidney diseases"	254 
1  9	"Interpersonal violence"	194 
1  10	"HHD"	157 
1  11	"Road injury"	155 
1  12	"Cirrhosis of the liver"	143 
1  13	"Colorectal cancers"	134 
1  14	"Breast cancer"	109 
1  15	"Prostate cancer"	98 
1  16	"Self-harm"	97 
1   17  "Neonatal conditions"  86
1  18	"Drug use disorders"	86 
1  19	"Pancreas cancer"	82 
1  20	"Falls"	81 
2  1	"IHD"	 19943 
2  2	"Diabetes"	 13430 
2  3	"Interpersonal violence"	 11157 
2  4	"Stroke"	 10330 
2  5	"Neonatal conditions"	 10076 
2  6	"Road injury"	 8756 
2  7	"COPD"	 8675 
2  8	"Back and neck pain" 8218 
2  9	"Drug use disorders"	 7990 
2  10	"Kidney diseases"	 6929 
2  11	"Depressive disorders"	 6904 
2  12	"Lower respiratory infections"	 6847 
2  13	"Dementias"	 5854 
2  14	"Other hearing loss"	 5531 
2  15	"Anxiety disorders"	 5530 
2  16	"Lung cancers"	 5471 
2  17	"Congenital anomalies"	 5417 
2  18	"Falls"	 4961 
2  19	"Self-harm"	 4527 
2  20	"Cirrhosis of the liver"	 4368 
end
label define type_ 1 "mortality" 2 "daly",modify
label values type type_
reshape wide cod cnum, i(order) j(type)

gen position1 = .
gen position2 = .

** We want 1 row per COD - mortality

** IHD
replace position1 = 1  if  cod1=="IHD"	
replace position2 = 1  if  cod2=="IHD"	

** Stroke
replace position1 = 2  if  cod1=="Stroke"	
replace position2 = 4  if  cod2=="Stroke"	

** Dementias
replace position1 = 3  if  cod1=="Dementias"
replace position2 = 13  if  cod2=="Dementias"

** COPD
replace position1 = 4  if  cod1=="COPD"	 
replace position2 = 7  if  cod2=="COPD"	 

** LRI
replace position1 = 5  if  cod1=="Lower respiratory infections"	 
replace position2 = 12  if  cod2=="Lower respiratory infections"	 

** Diabetes
replace position1 = 6  if  cod1=="Diabetes"	 
replace position2 = 2  if  cod2=="Diabetes"	 

** Lung cancers
replace position1 = 7  if  cod1=="Lung cancers"	 
replace position2 = 16  if  cod2=="Lung cancers"	 

** Kidney diseases
replace position1 = 8  if  cod1=="Kidney diseases"	 
replace position2 = 10  if  cod2=="Kidney diseases"	 

** IPV
replace position1 = 9  if  cod1=="Interpersonal violence"	 
replace position2 = 3  if  cod2=="Interpersonal violence"	 

** HHD
replace position1 = 10 if  cod1=="HHD"	 

** Road injury
replace position1 = 11 if  cod1=="Road injury"	 
replace position2 = 6 if  cod2=="Road injury"	 

** Liver cirrhosis
replace position1 = 12 if  cod1=="Cirrhosis of the liver"	 
replace position2 = 20 if  cod2=="Cirrhosis of the liver"	 

** Colorectal cancer
replace position1 = 13 if  cod1=="Colorectal cancers"	 

** breast cancer
replace position1 = 14 if  cod1=="Breast cancer"	 

** prostate cancer
replace position1 = 15 if  cod1=="Prostate cancer"	 

** self harm
replace position1 = 16 if  cod1=="Self-harm"	 
replace position2 = 19 if  cod2=="Self-harm"	 

** neonatal conditions
replace position1 = 17 if  cod1=="Neonatal conditions"  
replace position2 = 5 if  cod2=="Neonatal conditions"  

** drug use disorders
replace position1 = 18 if  cod1=="Drug use disorders"	 
replace position2 = 9 if  cod2=="Drug use disorders"	 

** pancreas cancer
replace position1 = 19 if  cod1=="Pancreas cancer"	 

** Falls
replace position1 = 20 if  cod1=="Falls"	 
replace position2 = 18 if  cod2=="Falls"	 


** Back pain
replace position2 = 8  if  cod2=="Back and neck pain"	 

** depressive disorders
replace position2 = 11  if  cod2=="Depressive disorders"	 

** hearing loss
replace position2 = 14 if  cod2=="Other hearing loss"

** anxiety disorders
replace position2 = 15  if  cod2=="Anxiety disorders"	 

** congenital anomalies
replace position2 = 17  if  cod2=="Congenital anomalies"	 

/*
** COLOR palette (GRAY, RED, BLUE)
colorpalette d3, 10 nograph
local list r(p) 
** (RED)
local red `r(p4)'
** (Blue)
local blu `r(p1)'
** (Grey)
local gry `r(p8)'

/// local outer1    25 -4     -5 -4     -5 45      25 45      25 -4 

gen circle1 = 10
gen circle2 = 20





/*
#delimit ;
	gr twoway 

		/// outer boxes 
        /// (scatteri `outer1' , recast(area) lw(0.2) lc(gs10) fc(none)  )

		/// Header line
        (function y = 0.5, range(-2 24) lc("`gry'")) 
        /// (function y = -5, horizontal range(0 23) lc("`gry'")) 

        /// THE LINES
        (pcspike order1 circle1 order2 circle2    if metric==2 & order2019==1 , lw(1.5) lc("`gry'%50")) 

		/// IHD. 1-(2000) 1-(2019)
        (sc order2000 ycode2000                             if metric==2 & order2000==1 , msize(10) m(o) mlc("`gry'*0.75") mfc("`gry'*0.5") mlw(0.2))
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
            text(1 13 "Ischemic heart disease",  place(e) size(5) color(gs0))
            text(2 13 "Interpersonal violence",  place(e) size(5) color(gs0))
            text(3 13 "Diabetes",  place(e) size(5) color(gs0))

            text(4 13 "Road injury",  place(e) size(5) color(gs0))
            text(5 13 "Stroke",  place(e) size(5) color(gs0))
            text(6 13 "Drug use disorders",  place(e) size(5) color(gs0))

            text(7 13 "Depressive disorders",  place(e) size(5) color(gs0))
            text(8 13 "COPD",  place(e) size(5) color(gs0))
            text(9 13 "Anxiety disorders",  place(e) size(5) color(gs0))

            text(10 13 "Breast cancer",  place(e) size(5) color(gs0))
            text(11 13 "Self-harm",  place(e) size(5) color(gs0))
            text(12 13 "Lung cancer", place(e) size(5) color(gs0))

            text(13 13 "Falls",  place(e) size(5) color(gs0))
            text(14 13 "Alzeimers/dementias",  place(e) size(5) color(gs0))
            text(15 13 "Alcohol use disorders",  place(e) size(5) color(gs0))

            text(16 13 "Migraine",  place(e) size(5) color(gs0))
            text(17 13 "Prostate cancer",  place(e) size(5) color(gs0))
            text(18 13 "Asthma",  place(e) size(5) color(gs0))

            text(19 13 "Colorectal cancer",  place(e) size(5) color(gs0))
            text(20 13 "Hypertensive heart disease",  place(e) size(5) color(gs0))
            text(22 13 "Cervical cancer",  place(e) size(5) color(gs0))

			legend(off)
			name(slopechart_daly)
			;
#delimit cr	

