** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    paper2-130-figure2-version1.do
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
    local datapath "X:\OneDrive - The University of the West Indies\Writing\w003\data"

    ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    local logpath "X:\OneDrive - The University of the West Indies\Writing\w003\tech-docs"

    ** REPORTS and Other outputs
    local outputpath "X:\OneDrive - The University of the West Indies\Writing\w003\outputs"

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\paper2-130-figure2-version1", replace
** HEADER -----------------------------------------------------




** --------------------------------------------------------------
** MEN
** --------------------------------------------------------------


** Load population file from: 
**      paper2-100-datasets.do 
use "`datapath'/paper2-inj/dataset02", clear
drop dths

** Keep Injury components
keep if ghecause<1000

** Men
keep if sex==1
drop sex

** Total deaths by GHECAUSE and sub-region and year 
** Percentage of each major COD
sort agroup year ghecause  
order agroup year ghecause
by agroup year : egen td = sum(daly)
gen pd = (daly/td)*100
sort agroup ghecause year  
order agroup ghecause year
 
** Nubers of deaths by Broad age group
tabstat daly if year==2019, by(agroup) stat(sum) format(%12.0fc)

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
drop daly pop td 
reshape wide pd , i(agroup yr1 year) j(ghecause) 


** Cumulative Percentages 
** 54/c7 Natural Disasters
** 48/c1 Road injuries
** 50/c3 Falls
** 56/c9 Interpersonal violence
** 55/c8 Self harm
** 52/c5 Drowning
** 49/c2 Poisonings
** 51/c4 Fire and Heat
** 53/c6 Mechanical forces
** 57/c10 Collective violence
gen zero    = 0 
gen c1      = pd54
gen c2      = pd48 + c1 
gen c3      = pd50 + c2
gen c4      = pd56 + c3 
gen c5      = pd55 + c4 
gen c6      = pd52 + c5 
gen c7      = pd49 + c6 
gen c8      = pd51 + c7 
gen c9      = pd53 + c8 
gen c10     = pd57 + c9

** generate a local for the ColorBrewer color scheme
colorpalette ptol, rainbow n(10)  nograph
local list r(p) 
** c1 - c11
forval x = 1(1)10 {
    local a`x' `r(p`x')'
}

** Legend outer limits for graphing 
local outer1 90 2001 95 2001 95 2006 90 2006 90 2001 
local outer2 81 2001 86 2001 86 2006 81 2006 81 2001 
local outer3 72 2001 77 2001 77 2006 72 2006 72 2001 

#delimit ;
	gr twoway 
		/// Young children (0-4)
        (rarea zero c1 yr1 if  agroup==1 , lw(0.1) fc("`a1'%25") lc("`a1'%85"))
        (rarea c1 c2 yr1  if   agroup==1 , lw(0.1) fc("`a2'%25") lc("`a2'%85"))
        (rarea c2 c3 yr1  if   agroup==1 , lw(0.1) fc("`a3'%25") lc("`a3'%85"))
        (rarea c3 c4 yr1  if   agroup==1 , lw(0.1) fc("`a4'%25") lc("`a4'%85"))
        (rarea c4 c5 yr1  if   agroup==1 , lw(0.1) fc("`a5'%25") lc("`a5'%85"))
        (rarea c5 c6 yr1  if   agroup==1 , lw(0.1) fc("`a6'%25") lc("`a6'%85"))
        (rarea c6 c7 yr1  if   agroup==1 , lw(0.1) fc("`a7'%25") lc("`a7'%85"))
        (rarea c7 c8 yr1  if   agroup==1 , lw(0.1) fc("`a8'%25") lc("`a8'%85"))
        (rarea c8 c9 yr1  if   agroup==1 , lw(0.1) fc("`a9'%25") lc("`a9'%85"))
        (rarea c9 c10 yr1  if  agroup==1 , lw(0.1) fc("`a10'%25") lc("`a10'%85"))
		/// Youth (5-19)
        (rarea zero c1 yr1 if  agroup==2 , lw(0.1) fc("`a1'%25") lc("`a1'%85"))
        (rarea c1 c2 yr1  if   agroup==2 , lw(0.1) fc("`a2'%25") lc("`a2'%85"))
        (rarea c2 c3 yr1  if   agroup==2 , lw(0.1) fc("`a3'%25") lc("`a3'%85"))
        (rarea c3 c4 yr1  if   agroup==2 , lw(0.1) fc("`a4'%25") lc("`a4'%85"))
        (rarea c4 c5 yr1  if   agroup==2 , lw(0.1) fc("`a5'%25") lc("`a5'%85"))
        (rarea c5 c6 yr1  if   agroup==2 , lw(0.1) fc("`a6'%25") lc("`a6'%85"))
        (rarea c6 c7 yr1  if   agroup==2 , lw(0.1) fc("`a7'%25") lc("`a7'%85"))
        (rarea c7 c8 yr1  if   agroup==2 , lw(0.1) fc("`a8'%25") lc("`a8'%85"))
        (rarea c8 c9 yr1  if   agroup==2 , lw(0.1) fc("`a9'%25") lc("`a9'%85"))
        (rarea c9 c10 yr1  if  agroup==2 , lw(0.1) fc("`a10'%25") lc("`a10'%85"))
		/// Young Adults (20-39)
        (rarea zero c1 yr1 if  agroup==3 , lw(0.1) fc("`a1'%25") lc("`a1'%85"))
        (rarea c1 c2 yr1  if   agroup==3 , lw(0.1) fc("`a2'%25") lc("`a2'%85"))
        (rarea c2 c3 yr1  if   agroup==3 , lw(0.1) fc("`a3'%25") lc("`a3'%85"))
        (rarea c3 c4 yr1  if   agroup==3 , lw(0.1) fc("`a4'%25") lc("`a4'%85"))
        (rarea c4 c5 yr1  if   agroup==3 , lw(0.1) fc("`a5'%25") lc("`a5'%85"))
        (rarea c5 c6 yr1  if   agroup==3 , lw(0.1) fc("`a6'%25") lc("`a6'%85"))
        (rarea c6 c7 yr1  if   agroup==3 , lw(0.1) fc("`a7'%25") lc("`a7'%85"))
        (rarea c7 c8 yr1  if   agroup==3 , lw(0.1) fc("`a8'%25") lc("`a8'%85"))
        (rarea c8 c9 yr1  if   agroup==3 , lw(0.1) fc("`a9'%25") lc("`a9'%85"))
        (rarea c9 c10 yr1  if  agroup==3 , lw(0.1) fc("`a10'%25") lc("`a10'%85"))
		/// Older Adults (40-64)
        (rarea zero c1 yr1 if  agroup==4 , lw(0.1) fc("`a1'%25") lc("`a1'%85"))
        (rarea c1 c2 yr1  if   agroup==4 , lw(0.1) fc("`a2'%25") lc("`a2'%85"))
        (rarea c2 c3 yr1  if   agroup==4 , lw(0.1) fc("`a3'%25") lc("`a3'%85"))
        (rarea c3 c4 yr1  if   agroup==4 , lw(0.1) fc("`a4'%25") lc("`a4'%85"))
        (rarea c4 c5 yr1  if   agroup==4 , lw(0.1) fc("`a5'%25") lc("`a5'%85"))
        (rarea c5 c6 yr1  if   agroup==4 , lw(0.1) fc("`a6'%25") lc("`a6'%85"))
        (rarea c6 c7 yr1  if   agroup==4 , lw(0.1) fc("`a7'%25") lc("`a7'%85"))
        (rarea c7 c8 yr1  if   agroup==4 , lw(0.1) fc("`a8'%25") lc("`a8'%85"))
        (rarea c8 c9 yr1  if   agroup==4 , lw(0.1) fc("`a9'%25") lc("`a9'%85"))
        (rarea c9 c10 yr1  if  agroup==4 , lw(0.1) fc("`a10'%25") lc("`a10'%85"))
        /// Older adults (65+)
        (rarea zero c1 yr1 if  agroup==5 , lw(0.1) fc("`a1'%25") lc("`a1'%85"))
        (rarea c1 c2 yr1  if   agroup==5 , lw(0.1) fc("`a2'%25") lc("`a2'%85"))
        (rarea c2 c3 yr1  if   agroup==5 , lw(0.1) fc("`a3'%25") lc("`a3'%85"))
        (rarea c3 c4 yr1  if   agroup==5 , lw(0.1) fc("`a4'%25") lc("`a4'%85"))
        (rarea c4 c5 yr1  if   agroup==5 , lw(0.1) fc("`a5'%25") lc("`a5'%85"))
        (rarea c5 c6 yr1  if   agroup==5 , lw(0.1) fc("`a6'%25") lc("`a6'%85"))
        (rarea c6 c7 yr1  if   agroup==5 , lw(0.1) fc("`a7'%25") lc("`a7'%85"))
        (rarea c7 c8 yr1  if   agroup==5 , lw(0.1) fc("`a8'%25") lc("`a8'%85"))
        (rarea c8 c9 yr1  if   agroup==5 , lw(0.1) fc("`a9'%25") lc("`a9'%85"))
        (rarea c9 c10 yr1  if  agroup==5 , lw(0.1) fc("`a10'%25") lc("`a10'%85"))


        (function y=101, range(2000 2100) lc(gs12) dropline(2019.5 2039.5 2059.5 2079.5 2099.5))

		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 
			ysize(6) xsize(18)

			xlab(none, 
			valuelabel labc(gs0) labs(4) notick nogrid glc(gs16) angle(45) format(%9.0f))
			xscale(noline lw(vthin)) 
			xtitle(" ", size(3) color(gs0) margin(l=1 r=1 t=1 b=1)) 
	
			ylab(0(20)100,
			valuelabel labc(gs8) labs(4) tlc(gs8) nogrid glc(gs16) angle(0) format(%9.0f))
			yscale(lw(vthin) lc(gs8) range(0(2)115) noextend) 
			ytitle("Percentage of age-specific" "disease burden (DALYs)", color(gs8) size(4) margin(l=1 r=1 t=1 b=1)) 

            /// Region Titles 
            text(105 2010 "Under 5s",  place(c) size(5) color(gs5))
            text(105 2030 "5-19 yrs",  place(c) size(5) color(gs5))
            text(105 2050 "20-39 yrs",  place(c) size(5) color(gs5))   
            text(105 2070 "40-64 yrs",  place(c) size(5) color(gs5))
            text(105 2090 "65 and older",  place(c) size(5) color(gs5))   

			/// X-Axis text
            text(-3 2001 "2000",  place(e) size(4) color(gs8))
            text(-3 2018 "2019",  place(w) size(4) color(gs8))
            text(-3 2021 "2000",  place(e) size(4) color(gs8))
            text(-3 2038 "2019",  place(w) size(4) color(gs8))
            text(-3 2041 "2000",  place(e) size(4) color(gs8))
            text(-3 2058 "2019",  place(w) size(4) color(gs8))
            text(-3 2061 "2000",  place(e) size(4) color(gs8))
            text(-3 2078 "2019",  place(w) size(4) color(gs8))
            text(-3 2081 "2000",  place(e) size(4) color(gs8))
            text(-3 2098 "2019",  place(w) size(4) color(gs8))

			legend( size(4.25) position(6) nobox ring(1) bm(t=1 b=4 l=5 r=0) colf cols(5)
			region(fcolor(gs16)  lw(none) margin(zero)) 
			order(1 2 3 4 5 6 7 8 9 10) 
			lab(1 "Natural disasters") 
			lab(2 "Road injuries") 		
			lab(3 "Falls") 		
			lab(4 "Interpersonal violence") 		
			lab(5 "Self harm") 		
			lab(6 "Drowning") 		
			lab(7 "Poisonings") 		
			lab(8 "Fire & heat") 		
			lab(9 "Mechanical forces") 	
            lab(10 "Collective violence")	
            )
			name(figure2a)
			;
			graph export "`outputpath'/articles/paper-injury/figure2a.png", replace width(4000);
#delimit cr	





** --------------------------------------------------------------
** WOMEN
** --------------------------------------------------------------

** Load population file from: 
**      paper2-100-datasets.do 
use "`datapath'/paper2-inj/dataset02", clear
drop dths

** Keep Injury components
keep if ghecause<1000

** Women 
keep if sex==2
drop sex

** Total deaths by GHECAUSE and sub-region and year 
** Percentage of each major COD
sort agroup year ghecause  
order agroup year ghecause
by agroup year : egen td = sum(daly)
gen pd = (daly/td)*100
sort agroup ghecause year  
order agroup ghecause year
 
** Nubers of deaths by Broad age group
tabstat daly if year==2019, by(agroup) stat(sum) format(%12.0fc)

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
drop daly pop td 
reshape wide pd , i(agroup yr1 year) j(ghecause) 


** Cumulative Percentages 
** 54/c7 Natural Disasters
** 48/c1 Road injuries
** 50/c3 Falls
** 56/c9 Interpersonal violence
** 55/c8 Self harm
** 52/c5 Drowning
** 49/c2 Poisonings
** 51/c4 Fire and Heat
** 53/c6 Mechanical forces
** 57/c10 Collective violence
gen zero    = 0 
gen c1      = pd54
gen c2      = pd48 + c1 
gen c3      = pd50 + c2
gen c4      = pd56 + c3 
gen c5      = pd55 + c4 
gen c6      = pd52 + c5 
gen c7      = pd49 + c6 
gen c8      = pd51 + c7 
gen c9      = pd53 + c8 
gen c10     = pd57 + c9

** generate a local for the ColorBrewer color scheme
colorpalette ptol, rainbow n(10)  nograph
local list r(p) 
** c1 - c11
forval x = 1(1)10 {
    local a`x' `r(p`x')'
}

** Legend outer limits for graphing 
local outer1 90 2001 95 2001 95 2006 90 2006 90 2001 
local outer2 81 2001 86 2001 86 2006 81 2006 81 2001 
local outer3 72 2001 77 2001 77 2006 72 2006 72 2001 

#delimit ;
	gr twoway 
		/// Young children (0-4)
        (rarea zero c1 yr1 if  agroup==1 , lw(0.1) fc("`a1'%25") lc("`a1'%85"))
        (rarea c1 c2 yr1  if   agroup==1 , lw(0.1) fc("`a2'%25") lc("`a2'%85"))
        (rarea c2 c3 yr1  if   agroup==1 , lw(0.1) fc("`a3'%25") lc("`a3'%85"))
        (rarea c3 c4 yr1  if   agroup==1 , lw(0.1) fc("`a4'%25") lc("`a4'%85"))
        (rarea c4 c5 yr1  if   agroup==1 , lw(0.1) fc("`a5'%25") lc("`a5'%85"))
        (rarea c5 c6 yr1  if   agroup==1 , lw(0.1) fc("`a6'%25") lc("`a6'%85"))
        (rarea c6 c7 yr1  if   agroup==1 , lw(0.1) fc("`a7'%25") lc("`a7'%85"))
        (rarea c7 c8 yr1  if   agroup==1 , lw(0.1) fc("`a8'%25") lc("`a8'%85"))
        (rarea c8 c9 yr1  if   agroup==1 , lw(0.1) fc("`a9'%25") lc("`a9'%85"))
        (rarea c9 c10 yr1  if  agroup==1 , lw(0.1) fc("`a10'%25") lc("`a10'%85"))
		/// Youth (5-19)
        (rarea zero c1 yr1 if  agroup==2 , lw(0.1) fc("`a1'%25") lc("`a1'%85"))
        (rarea c1 c2 yr1  if   agroup==2 , lw(0.1) fc("`a2'%25") lc("`a2'%85"))
        (rarea c2 c3 yr1  if   agroup==2 , lw(0.1) fc("`a3'%25") lc("`a3'%85"))
        (rarea c3 c4 yr1  if   agroup==2 , lw(0.1) fc("`a4'%25") lc("`a4'%85"))
        (rarea c4 c5 yr1  if   agroup==2 , lw(0.1) fc("`a5'%25") lc("`a5'%85"))
        (rarea c5 c6 yr1  if   agroup==2 , lw(0.1) fc("`a6'%25") lc("`a6'%85"))
        (rarea c6 c7 yr1  if   agroup==2 , lw(0.1) fc("`a7'%25") lc("`a7'%85"))
        (rarea c7 c8 yr1  if   agroup==2 , lw(0.1) fc("`a8'%25") lc("`a8'%85"))
        (rarea c8 c9 yr1  if   agroup==2 , lw(0.1) fc("`a9'%25") lc("`a9'%85"))
        (rarea c9 c10 yr1  if  agroup==2 , lw(0.1) fc("`a10'%25") lc("`a10'%85"))
		/// Young Adults (20-39)
        (rarea zero c1 yr1 if  agroup==3 , lw(0.1) fc("`a1'%25") lc("`a1'%85"))
        (rarea c1 c2 yr1  if   agroup==3 , lw(0.1) fc("`a2'%25") lc("`a2'%85"))
        (rarea c2 c3 yr1  if   agroup==3 , lw(0.1) fc("`a3'%25") lc("`a3'%85"))
        (rarea c3 c4 yr1  if   agroup==3 , lw(0.1) fc("`a4'%25") lc("`a4'%85"))
        (rarea c4 c5 yr1  if   agroup==3 , lw(0.1) fc("`a5'%25") lc("`a5'%85"))
        (rarea c5 c6 yr1  if   agroup==3 , lw(0.1) fc("`a6'%25") lc("`a6'%85"))
        (rarea c6 c7 yr1  if   agroup==3 , lw(0.1) fc("`a7'%25") lc("`a7'%85"))
        (rarea c7 c8 yr1  if   agroup==3 , lw(0.1) fc("`a8'%25") lc("`a8'%85"))
        (rarea c8 c9 yr1  if   agroup==3 , lw(0.1) fc("`a9'%25") lc("`a9'%85"))
        (rarea c9 c10 yr1  if  agroup==3 , lw(0.1) fc("`a10'%25") lc("`a10'%85"))
		/// Older Adults (40-64)
        (rarea zero c1 yr1 if  agroup==4 , lw(0.1) fc("`a1'%25") lc("`a1'%85"))
        (rarea c1 c2 yr1  if   agroup==4 , lw(0.1) fc("`a2'%25") lc("`a2'%85"))
        (rarea c2 c3 yr1  if   agroup==4 , lw(0.1) fc("`a3'%25") lc("`a3'%85"))
        (rarea c3 c4 yr1  if   agroup==4 , lw(0.1) fc("`a4'%25") lc("`a4'%85"))
        (rarea c4 c5 yr1  if   agroup==4 , lw(0.1) fc("`a5'%25") lc("`a5'%85"))
        (rarea c5 c6 yr1  if   agroup==4 , lw(0.1) fc("`a6'%25") lc("`a6'%85"))
        (rarea c6 c7 yr1  if   agroup==4 , lw(0.1) fc("`a7'%25") lc("`a7'%85"))
        (rarea c7 c8 yr1  if   agroup==4 , lw(0.1) fc("`a8'%25") lc("`a8'%85"))
        (rarea c8 c9 yr1  if   agroup==4 , lw(0.1) fc("`a9'%25") lc("`a9'%85"))
        (rarea c9 c10 yr1  if  agroup==4 , lw(0.1) fc("`a10'%25") lc("`a10'%85"))
        /// Older adults (65+)
        (rarea zero c1 yr1 if  agroup==5 , lw(0.1) fc("`a1'%25") lc("`a1'%85"))
        (rarea c1 c2 yr1  if   agroup==5 , lw(0.1) fc("`a2'%25") lc("`a2'%85"))
        (rarea c2 c3 yr1  if   agroup==5 , lw(0.1) fc("`a3'%25") lc("`a3'%85"))
        (rarea c3 c4 yr1  if   agroup==5 , lw(0.1) fc("`a4'%25") lc("`a4'%85"))
        (rarea c4 c5 yr1  if   agroup==5 , lw(0.1) fc("`a5'%25") lc("`a5'%85"))
        (rarea c5 c6 yr1  if   agroup==5 , lw(0.1) fc("`a6'%25") lc("`a6'%85"))
        (rarea c6 c7 yr1  if   agroup==5 , lw(0.1) fc("`a7'%25") lc("`a7'%85"))
        (rarea c7 c8 yr1  if   agroup==5 , lw(0.1) fc("`a8'%25") lc("`a8'%85"))
        (rarea c8 c9 yr1  if   agroup==5 , lw(0.1) fc("`a9'%25") lc("`a9'%85"))
        (rarea c9 c10 yr1  if  agroup==5 , lw(0.1) fc("`a10'%25") lc("`a10'%85"))


        (function y=101, range(2000 2100) lc(gs12) dropline(2019.5 2039.5 2059.5 2079.5 2099.5))

		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 
			ysize(6) xsize(18)

			xlab(none, 
			valuelabel labc(gs0) labs(2.5) notick nogrid glc(gs16) angle(45) format(%9.0f))
			xscale(noline lw(vthin)) 
			xtitle(" ", size(3) color(gs0) margin(l=1 r=1 t=1 b=1)) 
	
			ylab(0(20)100,
			valuelabel labc(gs8) labs(4) tlc(gs8) nogrid glc(gs16) angle(0) format(%9.0f))
			yscale(lw(vthin) lc(gs8) range(-21(2)115) noextend) 
			ytitle("Percentage of age-specific" "disease burden (DALYs)", color(gs8) size(4) margin(l=1 r=1 t=1 b=1)) 

            /// Region Titles 
            text(105 2010 "Under 5s",  place(c) size(5) color(gs5))
            text(105 2030 "5-19 yrs",  place(c) size(5) color(gs5))
            text(105 2050 "20-39 yrs",  place(c) size(5) color(gs5))   
            text(105 2070 "40-64 yrs",  place(c) size(5) color(gs5))
            text(105 2090 "65 and older",  place(c) size(5) color(gs5))   

			/// X-Axis text
            text(-3 2001 "2000",  place(e) size(4) color(gs8))
            text(-3 2018 "2019",  place(w) size(4) color(gs8))
            text(-3 2021 "2000",  place(e) size(4) color(gs8))
            text(-3 2038 "2019",  place(w) size(4) color(gs8))
            text(-3 2041 "2000",  place(e) size(4) color(gs8))
            text(-3 2058 "2019",  place(w) size(4) color(gs8))
            text(-3 2061 "2000",  place(e) size(4) color(gs8))
            text(-3 2078 "2019",  place(w) size(4) color(gs8))
            text(-3 2081 "2000",  place(e) size(4) color(gs8))
            text(-3 2098 "2019",  place(w) size(4) color(gs8))

			legend(off size(5) position(12) nobox ring(1) bm(t=1 b=4 l=5 r=0) colf cols(5)
			region(fcolor(gs16)  lw(none) margin(zero)) 
			order(1 2 3 4 5 6 7 8 9 10) 
			lab(1 "Natural disasters") 
			lab(2 "Road injuries") 		
			lab(3 "Falls") 		
			lab(4 "Interpersonal violence") 		
			lab(5 "Self harm") 		
			lab(6 "Drowning") 		
			lab(7 "Poisonings") 		
			lab(8 "Fire & heat") 		
			lab(9 "Mechanical forces") 	
            lab(10 "Collective violence")	
            )
			name(figure2b)
			;
			graph export "`outputpath'/articles/paper-injury/figure2b.png", replace width(4000);
#delimit cr	



** ------------------------------------------------------
** FIGURE 2: PDF
** ------------------------------------------------------
** CONSTRUCT SINGLE GRAPHIC FROM PANELS
** ------------------------------------------------------
    putpdf begin, pagesize(letter) landscape font("Calibri Light", 10) margin(top,0.5cm) margin(bottom,0.5cm) margin(left,0.5cm) margin(right,0.5cm)
** PAGE 1. INTRODUCTION
    putpdf paragraph ,  font("Calibri Light", 10)
    putpdf text ("Figure 2. ") , bold
    putpdf text ("Age-specific burden of injuries between 2000 and 2019 in The Americas, measured using Disability Adjusted life Years (DALY) rate per 100,000. ")

** FIGURE OF DAILY COVID-19 COUNT
    putpdf table f2 = (6,1), width(90%) border(all,nil) halign(center)
    putpdf table f2(1,1)=("(A) Men")
    putpdf table f2(3,1)=("(B) Women")
    putpdf table f2(2,1)=image("`outputpath'/articles/paper-injury/figure2a.png")
    putpdf table f2(4,1)=image("`outputpath'/articles/paper-injury/figure2b.png")

** FOOTNOTE
///    putpdf paragraph ,  font("Calibri Light", 9)
///    putpdf text ("Note: ") , italic linebreak
///    putpdf text ("Haitian earthquake in 2010 raised the injury burden (DALY rate per 100,000) to 168 thousand among men and 103 thousand among women") , italic

** Save the PDF
    local c_date = c(current_date)
    local date_string = subinstr("`c_date'", " ", "", .)
    ** putpdf save "`outputpath'/Figure_One_SS_`date_string'_grayscale", replace
    putpdf save "`outputpath'/articles/paper-injury/article-draft/Figure_2_`date_string'_color", replace
