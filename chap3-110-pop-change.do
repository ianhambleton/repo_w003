** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap3-110-pop-change.do
    //  project:				    WHO Global Health Estimates
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	26-OCT-2021
    //  algorithm task			    Summary graphic of POP change between 2000 and 2019

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
    log using "`logpath'\chap3-110-pop-change", replace
** HEADER -----------------------------------------------------


** -----------------------------------------------------
** PART ONE 
** -----------------------------------------------------

** Load age-specific datasets
** These come from: 
**      - chap2-000a-mr-region-groups.do
**      - chap2-000a-mr-region.do
tempfile a1 a2 a3 a4 
use "`datapath'\from-who\chap3_byage_groups_both", clear
gen sex = 3
save `a4' , replace
use "`datapath'\from-who\chap3_byage_groups_malefemale", clear
save `a3' , replace
use "`datapath'\from-who\chap3_byage_both", clear
gen sex = 3
save `a2' , replace
use "`datapath'\from-who\chap3_byage_malefemale", clear
save `a1' , replace

** Combine the datasets
use `a1', clear
append using `a2'
append using `a3'
append using `a4'

** Label the broad causes
#delimit ; 
label define ghecause_  
                    100  "all causes"
                    200  "communicable"
                    300  "NCD"
                    400  "CVD"
                    500  "cancer"
                    600  "respiratory"
                    700  "diabetes"
                    800  "mental"
                    900 "neurological"
                    1000  "injuries", modify
                    ;
#delimit cr
label values ghecause ghecause_ 

** Limit the dataset - we only need one instance of the population count
** All-cause deaths
keep if ghecause==100 & who_region==2
drop dths ghecause who_region agroup
rename age18 age

** Reshape to wide by sex
reshape wide pop deaths, i(year age) j(sex)
rename age age_start1
rename pop1 popmale
rename pop2 popfemale
rename pop3 popboth

** VALUES OF OUT 100 - turn into percentage of population
bysort year : egen totmale = sum(popmale)
bysort year : egen totfemale = sum(popfemale)
format totmale %15.0fc
format totfemale %15.0fc
gen pmale = (popmale/totmale) * 100
gen pfemale = (popfemale/totfemale) * 100
gen zero = 0

*! From here - % Change - third panel
** Proportion change at each age between 2000 and 2019 
gen t1 = popboth
gen t2 = popboth
replace t1 = . if year!=2000
replace t2 = . if year!=2019
bysort age_start1 : egen popboth2000 = min(t1)
bysort age_start1 : egen popboth2019 = min(t2)
bysort year : egen popyear2000 = sum(popboth2000)
bysort year : egen popyear2019 = sum(popboth2019)
gen pyear2000 = (popboth2000/popyear2000) * 100
gen pyear2019 = (popboth2019/popyear2019) * 100
format popboth2000 popboth2019 popyear2000 popyear2019 %15.0fc
gen pchange = pyear2019 - pyear2000
order pyear2000 pyear2019 pchange, after(popboth)
drop t1 t2 popboth2000 popboth2019 popyear2000 popyear2019 
sort year age_start1


** Negative values for men to push bar to left
replace pmale = pmale*-1
keep if year==2000 | year==2005 | year==2010 | year==2015 | year==2019 

** YEAR - further restriction
keep if year==2000 | year==2019


** ---------------------------------------------------
** GRAPHICS
** ---------------------------------------------------

** Proportion >=65 overall and by sex for graphics text	
gen sixtyfive = 0
replace sixtyfive = 1 if age_start1 >=14
bysort year sixtyfive: egen totf65 = sum(pfemale)
bysort year sixtyfive: egen totm65 = sum(pmale)
sort year age_start1

** Blues
colorpalette hcl blues, nograph 
local list r(p) 
    local blu1 `r(p4)'
    local blu2 `r(p8)'
    local blu3 `r(p12)'
** Purple
colorpalette hcl purples, nograph 
local list r(p) 
    local pur1 `r(p4)'
    local pur2 `r(p8)'
    local pur3 `r(p12)'
** Red
colorpalette hcl reds, nograph 
local list r(p) 
    local red1 `r(p4)'
    local red2 `r(p8)'
    local red3 `r(p12)'

** YEAR - further restriction
keep if year==2000 | year==2019

** 2019 values
replace pmale = pmale + 21 if year==2019
replace pfemale = pfemale + 21 if year==2019
** Percentage change values
gen pchange2 = pchange + 36.5 
order pchange2 , after(pchange)

** Origins for each panel
gen origin1a = -0.1
gen origin1b = 0.1
gen origin2a = 20.9
gen origin2b = 21.1
gen origin3 = 36.5
** Shift positive and negative values for percentage change
gen  origin3a = origin3  - 0.3
gen pchange3a = pchange2 - 0.3
gen origin3b  = origin3  + 0.3
gen pchange3b = pchange2 + 0.3
order origin3a pchange3a origin3b pchange3b , after(pchange2)

** Outer lines
local line1 18 36.5 1 36.5
local outer1   19 -11   0 -11   0 10   19 10   19 -11 
local outer2   19 10.5   0 10.5   0 31   19 31   19 10.5


** FIGURE 1
** To have different panels we need to convert from -bar- to -rbar-
	#delimit ;
		graph twoway 
        /// Outer Lines
        (scatteri `line1' , recast(line) lw(0.2) lc("gs8") fc("gs8") lp("-") )
        (scatteri `outer1'  , recast(area) lw(0.2) lc(gs10) fc(none) lp("l"))
        (scatteri `outer2'  , recast(area) lw(0.2) lc(gs10) fc(none) lp("l"))

		/// 2000
		/// Men 65 years and younger
        (rbar origin1a pmale age_start1 if age_start<=13 & year==2000, horizontal barw(0.8) fcol("`blu1'") lcol("`blu1'") lw(0.1))           
		/// Men 70 years and older
        (rbar origin1a pmale age_start1 if age_start>=14 & year==2000, horizontal barw(0.8) fcol("`blu2'") lcol("`blu2'") lw(0.1))           
		/// Women 65 years and younger
        (rbar origin1b pfemale age_start1 if age_start<=13 & year==2000, horizontal barw(0.8) fcol("`pur1'") lcol("`pur1'") lw(0.1))           
		/// Women 70 years and older
        (rbar origin1b pfemale age_start1 if age_start>=14 & year==2000, horizontal barw(0.8) fcol("`pur2'") lcol("`pur2'") lw(0.1))           

		/// 2019
		/// Men 65 years and younger
        (rbar origin2a pmale age_start1 if age_start<=13 & year==2019, horizontal barw(0.8) fcol("`blu1'") lcol("`blu1'") lw(0.1))           
		/// Men 70 years and older
        (rbar origin2a pmale age_start1 if age_start>=14 & year==2019, horizontal barw(0.8) fcol("`blu2'") lcol("`blu2'") lw(0.1))           
		/// Women 65 years and younger
        (rbar origin2b pfemale age_start1 if age_start<=13 & year==2019, horizontal barw(0.8) fcol("`pur1'") lcol("`pur1'") lw(0.1))           
		/// Women 70 years and older
        (rbar origin2b pfemale age_start1 if age_start>=14 & year==2019, horizontal barw(0.8) fcol("`pur2'") lcol("`pur2'") lw(0.1))           

        /// PERCENTAGE POINT CHANGE
        (rbar origin3a pchange3a age_start1 if pchange<=0 & age_start<=13 & year==2019, horizontal barw(0.8) fcol("gs10") lcol("gs10") lw(0.1))           
        (rbar origin3b pchange3b age_start1 if pchange> 0 & age_start<=13 & year==2019 , horizontal barw(0.8) fcol("gs10") lcol("gs10") lw(0.1))           
        (rbar origin3b pchange3b age_start1 if pchange> 0 & age_start>=14 & year==2019 , horizontal barw(0.8) fcol("`red2'") lcol("`red2'") lw(0.1))           

                ,

		subtitle(, nobox size(4))
		///text(80  -1500 "percent 70+" , place(e)) 
		ysize(6) xsize(14)
		
		ytitle("Age in 5-year groups", size(3.5)) 
		yscale(noline) 			
		ylabel(none, angle(0) nogrid labsize(3.5)) 

		xtitle("Population size", size(3.5)) 
		xscale(noline) 
		xlabel(-8 "8%" -4 "4%" 4 "5%" 8 "8%" 13 "8%" 17 "4%" 25 "4%" 29 "8%" , noticks nogrid labsize(3.5))
		
		legend(off size(2.5) colf cols(2) colgap(8)
		region(fcolor(gs16) lw(none) margin(l=2 r=2 t=4 b=2)) order(2 1 4 3)
		label(1 "Males 64 and younger") 
		label(2 "Males 65 and older")
		label(3 "Females 64 and younger") 
		label(4 "Females 65 and older")
		) 
		name(pyramid2000)
		;
#delimit cr		
