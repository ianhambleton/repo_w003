** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap1-death-030-perc-panel.do
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
    local datapath "C:\yasuki\Sync\output\analyse-write\w003\data"

    ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    local logpath "C:\yasuki\Sync\output\analyse-write\w003\tech-docs"

    ** REPORTS and Other outputs
    local outputpath "C:\yasuki\Sync\output\analyse-write\w003\outputs"

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\chap1-death-030-perc-panel", replace
** HEADER -----------------------------------------------------

** Loading COD dataset for world regions
** Limit to just the wide COD groups and save - as preparation for analytics

** ------------------------------------------------------------
** 10 Communicable, maternal, perinatal and nutritional conditions
** 600 Noncommunicable diseases
** 1510 Injuries
** ------------------------------------------------------------
tempfile amr 

** Americas (AMR)
use "`datapath'\from-who\who-ghe-deaths-001-who2", replace
    keep if ghecause==10 | ghecause==600 | ghecause==1510
    keep if who_region==2
    drop if age<0 
    drop dths_low dths_up
    ** Collapse AGE ut of dataset 
    collapse (sum) dths , by(ghecause year paho_subregion age)
    save `amr' , replace
    save "`datapath'\from-who\chap1_deaths_001", replace

** BROAD age groups
** 1 Young children --> under-5s
** 2 Youth          --> 5-19
** 3 Young Adults   --> 20-39
** 4 Older Adults   --> 40-64
** 5 The Elderly    --> 65+
gen agroup = 1 if age==0 | age==1 
replace agroup = 2 if age==5 | age==10 | age==15 
replace agroup = 3 if age==20 | age==25 | age==30 | age==35 
replace agroup = 4 if age==40 | age==45 | age==50 | age==55 | age==60  
replace agroup = 5 if age==65 | age==70 | age==75 | age==80 | age==85  
label define agroup_ 1 "young children" 2 "youth" 3 "young adults" 4 "older adults" 5 "elderly" , modify
label values agroup agroup_ 
collapse (sum) dths , by(agroup year ghecause )

** Total deaths by GHECAUSE and sub-region and year 
** Percentage of each major COD
sort agroup year ghecause  
order agroup year ghecause
by agroup year : egen td = sum(dths)
gen pd = (dths/td)*100
sort agroup ghecause year  
order agroup ghecause year
 
** Nubers of deaths by Broad age group
tabstat dths if year==2019, by(agroup) stat(sum) format(%12.0fc)

tabstat pd if year==2019 & agroup==1, by(ghecause) stat(sum) format(%12.0fc)
tabstat pd if year==2019 & agroup==2, by(ghecause) stat(sum) format(%12.0fc)
tabstat pd if year==2019 & agroup==3, by(ghecause) stat(sum) format(%12.0fc)
tabstat pd if year==2019 & agroup==4, by(ghecause) stat(sum) format(%12.0fc)
tabstat pd if year==2019 & agroup==5, by(ghecause) stat(sum) format(%12.0fc)

** ------------------------------------------------------------
** GRAPHIC
** ------------------------------------------------------------

** GRAPHIC ordered by umber of deaths
** low to high
** 8 subregions
gen yr1 = . 
replace yr1 = year if       agroup==1
replace yr1 = year + 20 if  agroup==2
replace yr1 = year + 40 if  agroup==3
replace yr1 = year + 60 if  agroup==4
replace yr1 = year + 80 if  agroup==5
order year yr1 
drop dths td 
reshape wide pd , i(agroup yr1 year) j(ghecause) 
** Cumulative Percentages 
gen zero = 0 
gen inj = pd1510 
gen ncd = pd600 + inj 
gen com = pd10 + ncd

** generate a local for the ColorBrewer color scheme
colorpalette ptol, rainbow n(9)  nograph
local list r(p) 
** (COM --> ghecause = 10)
local com `r(p3)'
** (NCD --> ghecause = 600)
local ncd `r(p6)'
** (INJ --> ghecause = 1510)
local inj `r(p9)'

** Legend outer limits for graphing 
local outer1 90 2001 95 2001 95 2006 90 2006 90 2001 
local outer2 81 2001 86 2001 86 2006 81 2006 81 2001 
local outer3 72 2001 77 2001 77 2006 72 2006 72 2001 

#delimit ;
	gr twoway 
		/// Young children
        (rarea zero inj yr1 if agroup==1 , lw(none) color("`inj'%25"))
        (rarea inj ncd yr1 if  agroup==1 , lw(none) color("`ncd'%25"))
        (rarea ncd com yr1 if  agroup==1 , lw(none) color("`com'%25"))
		/// youth
        (rarea zero inj yr1 if agroup==2 , lw(none) color("`inj'%25"))
        (rarea inj ncd yr1 if  agroup==2 , lw(none) color("`ncd'%25"))
        (rarea ncd com yr1 if  agroup==2 , lw(none) color("`com'%25"))
		/// Young adults
        (rarea zero inj yr1 if agroup==3 , lw(none) color("`inj'%25"))
        (rarea inj ncd yr1 if  agroup==3 , lw(none) color("`ncd'%25"))
        (rarea ncd com yr1 if  agroup==3 , lw(none) color("`com'%25"))
		/// Older adults
        (rarea zero inj yr1 if agroup==4 , lw(none) color("`inj'%25"))
        (rarea inj ncd yr1 if  agroup==4 , lw(none) color("`ncd'%25"))
        (rarea ncd com yr1 if  agroup==4 , lw(none) color("`com'%25"))
		/// Elderly
        (rarea zero inj yr1 if agroup==5 , lw(none) color("`inj'%25"))
        (rarea inj ncd yr1 if  agroup==5 , lw(none) color("`ncd'%25"))
        (rarea ncd com yr1 if  agroup==5 , lw(none) color("`com'%25"))

        /// droplines
        (function y=101, range(2000 2100) lc(gs12) dropline(2019.5 2039.5 2059.5 2079.5 2099.5))

        /// Legend
        (scatteri `outer1' , recast(area) lw(none) lc("`com'%25") fc("`com'%25")  )
        (scatteri `outer2' , recast(area) lw(none) lc("`ncd'%25") fc("`ncd'%25")  )
        (scatteri `outer3' , recast(area) lw(none) lc("`inj'%25") fc("`inj'%25")  )
		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 
			ysize(8) xsize(18)

			xlab(none, 
			valuelabel labc(gs0) labs(2.5) notick nogrid glc(gs16) angle(45) format(%9.0f))
			xscale(noline lw(vthin)) 
			xtitle(" ", size(3) color(gs0) margin(l=1 r=1 t=1 b=1)) 
	
			ylab(0(20)100,
			valuelabel labc(gs8) labs(3) tlc(gs8) nogrid glc(gs16) angle(0) format(%9.0f))
			yscale(lw(vthin) lc(gs8) range(0(10)115) noextend) 
			ytitle("Percentage of all deaths", color(gs8) size(3) margin(l=1 r=1 t=1 b=1)) 

            /// Region Titles 
            text(105 2010 "Under 5s",  place(c) size(4) color(gs5))
            text(105 2030 "5-19 yrs",  place(c) size(4) color(gs5))
            text(105 2050 "20-39 yrs",  place(c) size(4) color(gs5))   
            text(105 2070 "40-64 yrs",  place(c) size(4) color(gs5))
            text(105 2090 "65 and older",  place(c) size(4) color(gs5))

            /// Legend Text
            text(92.5   2007 "CMPN",  place(e) size(3) color(gs4))   
            text(83.5   2007 "NCDs",  place(e) size(3) color(gs4))   
            text(74.5   2007 "Injuries",  place(e) size(3) color(gs4))   

			/// X-Axis text
            text(-3 2001 "2000",  place(e) size(3) color(gs8))
            text(-3 2018 "2019",  place(w) size(3) color(gs8))
            text(-3 2021 "2000",  place(e) size(3) color(gs8))
            text(-3 2038 "2019",  place(w) size(3) color(gs8))
            text(-3 2041 "2000",  place(e) size(3) color(gs8))
            text(-3 2058 "2019",  place(w) size(3) color(gs8))
            text(-3 2061 "2000",  place(e) size(3) color(gs8))
            text(-3 2078 "2019",  place(w) size(3) color(gs8))
            text(-3 2081 "2000",  place(e) size(3) color(gs8))
            text(-3 2098 "2019",  place(w) size(3) color(gs8))

			legend(off size(2.5) position(9) nobox ring(0) bm(t=1 b=4 l=5 r=0) colf cols(1)
			region(fcolor(gs16)  lw(none) margin(zero)) 
			order(2 1) 
			lab(1 "xx") 
			lab(2 "xx") 		
            )
			name(deaths_age_panel)
			;
#delimit cr	


** Version 2 - legend outside


** Legend outer limits for graphing 
local outer1 112 2030 117 2030 117 2034 112 2034 112 2030 
local outer2 112 2045 117 2045 117 2049 112 2049 112 2045 
local outer3 112 2060 117 2060 117 2064 112 2064 112 2060 

#delimit ;
	gr twoway 
		/// Young children
        (rarea zero inj yr1 if agroup==1 , lw(none) color("`inj'%25"))
        (rarea inj ncd yr1 if  agroup==1 , lw(none) color("`ncd'%25"))
        (rarea ncd com yr1 if  agroup==1 , lw(none) color("`com'%25"))
		/// youth
        (rarea zero inj yr1 if agroup==2 , lw(none) color("`inj'%25"))
        (rarea inj ncd yr1 if  agroup==2 , lw(none) color("`ncd'%25"))
        (rarea ncd com yr1 if  agroup==2 , lw(none) color("`com'%25"))
		/// Young adults
        (rarea zero inj yr1 if agroup==3 , lw(none) color("`inj'%25"))
        (rarea inj ncd yr1 if  agroup==3 , lw(none) color("`ncd'%25"))
        (rarea ncd com yr1 if  agroup==3 , lw(none) color("`com'%25"))
		/// Older adults
        (rarea zero inj yr1 if agroup==4 , lw(none) color("`inj'%25"))
        (rarea inj ncd yr1 if  agroup==4 , lw(none) color("`ncd'%25"))
        (rarea ncd com yr1 if  agroup==4 , lw(none) color("`com'%25"))
		/// Elderly
        (rarea zero inj yr1 if agroup==5 , lw(none) color("`inj'%25"))
        (rarea inj ncd yr1 if  agroup==5 , lw(none) color("`ncd'%25"))
        (rarea ncd com yr1 if  agroup==5 , lw(none) color("`com'%25"))

        /// droplines
        (function y=101, range(2000 2100) lc(gs12) dropline(2019.5 2039.5 2059.5 2079.5 2099.5))

        /// Legend
        (scatteri `outer1' , recast(area) lw(none) lc("`com'%25") fc("`com'%25")  )
        (scatteri `outer2' , recast(area) lw(none) lc("`ncd'%25") fc("`ncd'%25")  )
        (scatteri `outer3' , recast(area) lw(none) lc("`inj'%25") fc("`inj'%25")  )
        (function y=110, range(2030 2070) lp("l") lc(gs14) lw(0.4))

		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 
			ysize(8) xsize(18)

			xlab(none, 
			valuelabel labc(gs0) labs(2.5) notick nogrid glc(gs16) angle(45) format(%9.0f))
			xscale(noline lw(vthin)) 
			xtitle(" ", size(3) color(gs0) margin(l=1 r=1 t=1 b=1)) 
	
			ylab(0(20)100,
			valuelabel labc(gs8) labs(3) tlc(gs8) nogrid glc(gs16) angle(0) format(%9.0f))
			yscale(lw(vthin) lc(gs8) range(0(10)120) noextend) 
			ytitle("Percentage of all deaths", color(gs8) size(3) margin(l=1 r=1 t=1 b=1)) 

            /// Region Titles 
            text(105 2010 "Under 5s",  place(c) size(3.5) color(gs5))
            text(105 2030 "5-19 yrs",  place(c) size(3.5) color(gs5))
            text(105 2050 "20-39 yrs",  place(c) size(3.5) color(gs5))   
            text(105 2070 "40-64 yrs",  place(c) size(3.5) color(gs5))
            text(105 2090 "65 and older",  place(c) size(3.5) color(gs5))

            /// Legend Text
            text(115   2035 "CMPN",  place(e) size(3) color(gs4))   
            text(115   2050 "NCDs",  place(e) size(3) color(gs4))   
            text(115   2065 "Injuries",  place(e) size(3) color(gs4))   

			/// X-Axis text
            text(-3 2001 "2000",  place(e) size(3) color(gs8))
            text(-3 2018 "2019",  place(w) size(3) color(gs8))
            text(-3 2021 "2000",  place(e) size(3) color(gs8))
            text(-3 2038 "2019",  place(w) size(3) color(gs8))
            text(-3 2041 "2000",  place(e) size(3) color(gs8))
            text(-3 2058 "2019",  place(w) size(3) color(gs8))
            text(-3 2061 "2000",  place(e) size(3) color(gs8))
            text(-3 2078 "2019",  place(w) size(3) color(gs8))
            text(-3 2081 "2000",  place(e) size(3) color(gs8))
            text(-3 2098 "2019",  place(w) size(3) color(gs8))

			legend(off size(2.5) position(9) nobox ring(0) bm(t=1 b=4 l=5 r=0) colf cols(1)
			region(fcolor(gs16)  lw(none) margin(zero)) 
			order(2 1) 
			lab(1 "xx") 
			lab(2 "xx") 		
            )
			name(deaths_age_panel2)
			;
#delimit cr	
** Export to Vector Graphic
** DEC 22nd, 2022
graph export "`outputpath'\reports\2024-edits\graphics\fig6.svg", replace
graph export "`outputpath'\reports\2024-edits\graphics\fig6.pdf", replace


** Export data for Figure 6
drop zero 
rename inj inj_cumulative
rename ncd ncd_cumulative
rename com com_cumulative
rename pd10 com
rename pd600 ncd 
rename pd1510 inj
rename agroup age_group 
rename yr1 graph_order
order year graph_order age_group inj ncd com inj_* ncd_* com_*  
sort graph_order
export excel "`outputpath'\reports\2024-edits\graphics\chap1_data.xlsx", sheet("figure-6", replace) first(var)

