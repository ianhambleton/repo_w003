** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			        ap120-slopechart.do
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
    log using "`logpath'\ap120-slopechart", replace
** HEADER -----------------------------------------------------

** UN deaths equiplot example
use "`datapath'\from-who\who-ghe-daly-002-who2", replace
keep if year==2000 | year==2019 
drop if age < 0 
drop daly_low daly_up un_region who_region
collapse (sum) daly pop, by(year ghecause)
** Take All cause into new total column
gen dalyt = daly if ghecause == 0
bysort year: egen daly_tot = min(dalyt)
drop dalyt 
** Variable formatting 
format daly %15.0fc
format pop %15.0fc
format daly_tot %15.0fc

** Drop all the grouped causes 
#delimit ; 
drop if ghecause == 0   |         /* All causes */
        ghecause == 10  |         /* Communicable */
        ghecause == 20  |         /* Infectious */
        ghecause == 40  |         /* STDs */
        ghecause == 120  |        /* Childhood-cluster */
        ghecause == 185  |        /* Hepatitis */
        ghecause == 210 |        /* Parasitic */
        ghecause == 380 |        /* Respiratory */
        ghecause == 490 |        /* Neonatal */
        ghecause == 540 |        /* Nutritional */
        ghecause == 600 |        /* NCDs */
        ghecause == 610 |        /* Cancers */
        ghecause == 810 |        /* Endocrine / blood */
        ghecause == 820 |        /* Mental */
        ghecause == 870 |        /* Drug Abuse */
        ghecause == 910 |        /* Child behavioural */
        ghecause == 940 |        /* neurological */
        ghecause == 1020 |        /* sense organ */
        ghecause == 1100 |        /* CVD */
        ghecause == 1170 |        /* Chronic respiratory */
        ghecause == 1210 |        /* Digestive diseases */
        ghecause == 1260 |        /* GU diseases */
        ghecause == 1270 |        /* Kidney diseases */
        ghecause == 1340 |        /* Musculoskeletal */
        ghecause == 1400 |        /* Congenital */
        ghecause == 1470 |        /* Oral conditions */
        ghecause == 1510 |        /* Injuries */
        ghecause == 1520 |        /* Unintentional Injuries */
        ghecause == 1600;         /* intentional Injuries */
#delimit cr 


** Reshape to wide for each year
reshape wide daly pop daly_tot, i(ghecause) j(year)
gsort -daly2000 

** Change between 2000 and 2019
egen tot2000 = sum(daly2000) 
order tot2000, after(daly2000)
egen tot2019 = sum(daly2019) 
order tot2019, after(daly2019)
format tot2000 %14.0fc 
format tot2019 %14.0fc 
format pop2000 %14.0fc 
format pop2019 %14.0fc 
** ABSOLUTE CHANGE
gen perc2000 = (daly2000/daly_tot2000)*100
gen perc2019 = (daly2019/daly_tot2019)*100
** RELATIVE CHANGE
gen pindex = (perc2000/perc2000)*100
gen p2019 = (perc2019/perc2000)*100

** Y-axis order based on 2019 percentage size 
gsort -perc2019 
gen yorder = _n
keep if yorder<=20

** Extract COD labels
tempvar str1
decode ghecause, gen(`str1')
gen codlab = `str1'
labmask yorder, values(codlab)
#delimit ;
label define yorder_
                1   "Ischaemic heart disease"
                2   "Diabetes mellitus"
                3   "Interpersonal violence"
                4   "Stroke"
                5   "Musculoskeletal"
                6   "Road injury"
                7   "COPD"
                8   "Back / neck pain"
                9   "Depressive disorders"
                10  "LRIs"
                11  "Opioid use"
                12  "Major depression"
                13  "Alzheimer / dementias"
                14  "Hearing loss"
                15  "Anxiety disorders"
                16  "Lung cancers"
                17  "Haemorrhagic stroke"
                18  "Other circulatory"
                19  "Preterm birth"
                20  "Falls";
#delimit cr 
label values yorder yorder_ 

** Outer box
local outer1 0 0 21 0 21 275 0 275 0 0 
local outer2 0 0 21 0 21 8 0 8 0 0 


** *******************************************************
** Color palette (-colorpalette-)
** Categorical D3 
** *******************************************************
** Purple --> 148 103 189 (darker) 197 176 213 (lighter)
** Blue --> 31 119 180 (darker) 174 199 232 (lighter)
** Orange --> 255 127 14 (darker)  255 187 120 (lighter)
** Gray --> 127 127 127 (darker)  199 199 199 (lighter)
** *******************************************************
#delimit ;
	gr twoway 
		/// OUTER BOX
        (scatteri `outer1' , recast(area) lw(0.2) lc(gs10) fc(none))		
        /// RELATIVE CHANGE
		(rbar pindex p2019 yorder if p2019<pindex  , hor fc("174 199 232") lw(none) barwidth(0.75))
		(rbar pindex p2019 yorder if p2019>=pindex , hor fc("255 187 120") lw(none) barwidth(0.75))
		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			ysize(12) xsize(9)

			xlab(50 100 150 200 250, 
            notick tlc(gs0) labc(gs0) notick nogrid glc(gs16))
			xscale(noline range(0(1)10)) 
			xtitle(" ", size(5) color(gs0) margin(l=2 r=2 t=5 b=2)) 
			
			ylab(
                1   "Ischaemic heart disease"
                2   "Diabetes mellitus"
                3   "Interpersonal violence"
                4   "Stroke"
                5   "Musculoskeletal"
                6   "Road injury"
                7   "COPD"
                8   "Back / neck pain"
                9   "Depressive disorders"
                10  "LRIs"
                11  "Opioid use"
                12  "Major depression"
                13  "Alzheimer / dementias"
                14  "Hearing loss"
                15  "Anxiety disorders"
                16  "Lung cancers"
                17  "Haemorrhagic stroke"
                18  "Other circulatory"
                19  "Preterm birth"
                20  "Falls"
			,
            valuelabel labc(gs0) labs(3) tstyle(major_notick) nogrid glc(gs16) angle(0) format(%9.0f))
			yscale(reverse noline lw(vthin) ) 
			ytitle("", size(5) margin(l=2 r=5 t=2 b=2)) 

            /// title("DALYs in the Americas", size(7) color(gs0) position(11))

			legend(off)
			name(linechart1)
			;
#delimit cr	

#delimit ;
	gr twoway 
		/// OUTER BOX
        (scatteri `outer2' , recast(area) lw(0.2) lc(gs10) fc(none))		
		/// ABSOLUTE CHANGE
		(sc yorder perc2000 if p2019<pindex , msize(3) mlw(none) mfc("174 199 232"))
		(sc yorder perc2019 if p2019<pindex , msize(3) mlw(none) mfc("174 199 232"))
		(rspike perc2000 perc2019 yorder if p2019<pindex , hor lw(0.5) lc("174 199 232")) 
        (sc yorder perc2000 if p2019>=pindex , msize(3) mlw(none) mfc("255 187 120"))
		(sc yorder perc2019 if p2019>=pindex , msize(3) mlw(none) mfc("255 187 120"))
    	(rspike perc2000 perc2019 yorder if p2019>=pindex , hor lw(0.5) lc("255 187 120")) 

        ,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			ysize(12) xsize(9)

			xlab(
            ,
            notick tlc(gs0) labc(gs0) notick nogrid glc(gs16))
			xscale(noline range(0(1)8)) 
			xtitle(" ", size(5) color(gs0) margin(l=2 r=2 t=5 b=2)) 
			
			ylab(
                1   "Ischaemic heart disease"
                2   "Diabetes mellitus"
                3   "Interpersonal violence"
                4   "Stroke"
                5   "Musculoskeletal"
                6   "Road injury"
                7   "COPD"
                8   "Back / neck pain"
                9   "Depressive disorders"
                10  "LRIs"
                11  "Opioid use"
                12  "Major depression"
                13  "Alzheimer / dementias"
                14  "Hearing loss"
                15  "Anxiety disorders"
                16  "Lung cancers"
                17  "Haemorrhagic stroke"
                18  "Other circulatory"
                19  "Preterm birth"
                20  "Falls"
			,
            valuelabel labc(gs16) labs(3) tstyle(major_notick) nogrid glc(gs16) angle(0) format(%9.0f))
			yscale(fill reverse noline lw(vthin) ) 
			ytitle("", size(5) margin(l=2 r=5 t=2 b=2)) 

			legend(off)
			name(linechart2)
			;
#delimit cr	
