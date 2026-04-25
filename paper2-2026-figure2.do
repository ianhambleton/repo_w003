** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    paper2-2026-figure2.do
    //  project:				    WHO Global Health Estimates
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	16-Apr-2021
    //  algorithm task			    Panel graphic - proportion of deaths by AGE group

    ** General algorithm set-up
    version 18
    clear all
    macro drop _all
    set more 1
    set linesize 80

    ** Set working directories: this is for DATASET and LOGFILE import and export

    ** DATASETS to encrypted SharePoint folder
    local datapath "C:\yoshimi-hot\output\analyse-write\w003\data\2025"

    ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    local logpath "C:\yoshimi-hot\output\analyse-write\w003\tech-docs\2025"

    ** REPORTS and Other outputs
    local outputpath "C:\yoshimi-hot\output\analyse-write\w003\outputs\2025"

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\paper2-2026-figure2", replace
** HEADER -----------------------------------------------------

** SUPPLEMENT TABLE 11
** DALY numbers for women+men combined, for 2021, by 5 broad age groups

** Load population file from: 
**      paper2-100-datasets.do 
use "`datapath'/dataset02a", clear
drop dths

** Women and Men combined
keep if sex==3
drop sex
 
** Nubers of DALYs by Broad age group
table ghecause agroup if year==2021 & (ghecause==4), stat(sum daly)
table ghecause agroup if year==2021 & (ghecause==5 | ghecause==6), stat(sum daly)
table ghecause agroup if year==2021 & (ghecause>=7 & ghecause<=16), stat(sum daly)

keep if year==2021
keep if ghecause>=4 
keep ghecause daly agroup
reshape wide daly , i(ghecause) j(agroup) 
egen rtot = rowtotal(daly1 daly2 daly3 daly4 daly5)
format daly1 daly2 daly3 daly4 daly5 rtot %15.0fc


** ----------------------------------------------------
** SUPPLEMENT TABLE 11
** ----------------------------------------------------

** IPV, Road, Salf harm, Falls, Poisonings, Fire and Heat, Drowning, Mech Forces, Natural Dis, Collective,  Unint, Int, All
gen ghecause2 = ghecause 
recode ghecause2 (15=1) (7=2) (14=3) (9=4) (8=5) (10=6) (11=7) (12=8) (13=9) (16=10) (5=11) (6=12) (4=13)
#delimit ; 
label define ghecause2  1 "Interpersonal violence" 
                        2 "Road injuries"
                        3 "Self harm"
                        4 "Falls"
                        5 "Poisonings"
                        6 "Fire and heat"
                        7 "Drowning"
                        8 "Mechanical Forces"
                        9 "Natural Disasters"
                        10 "Collective violence"
                        11 "Unintentional injury"
                        12 "Intentional injury"
                        13 "All injury", modify;
#delimit cr 
label values ghecause2 ghecause2
sort ghecause2 


	** Begin Table 
	putdocx begin , landscape font(calibri light, 10)
	putdocx paragraph 
		putdocx text ("(SUPPLEMENT TABLE 11). "), bold
		putdocx text ("Numbers of years of injury disability (DALYs) in 2021 in 5 broad age groups (Early Childhood, School-aged and Adolescent, Young Adults, Middle Adulthood, Older Adults."), 
		putdocx table t2 = data("ghecause2 daly1 daly2 daly3 daly4 daly5 rtot"), varnames 
		putdocx table t2(2/10,.), border(bottom, single, "e6e6e6")
		putdocx table t2(12/13,.), border(bottom, single, "e6e6e6")
		putdocx table t2(1,.),  shading("e6e6e6")
        
		putdocx table t2(1,2) = ("<5 years"),  font(calibri light,10, "000000")
		putdocx table t2(1,3) = ("5-19 years"),  font(calibri light,10, "000000")
		putdocx table t2(1,4) = ("20-39 years"),  font(calibri light,10, "000000")
		putdocx table t2(1,5) = ("40-64 years"),  font(calibri light,10, "000000")
		putdocx table t2(1,6) = ("65 years and older"),  font(calibri light,10, "000000")
		putdocx table t2(1,7) = (""),  font(calibri light,10, "000000")

		putdocx table t2(1,1) = (" "),  font(calibri light,10, "000000")
		putdocx table t2(2,1) = ("Interpersonal violence"),  font(calibri light,10, "000000")
		putdocx table t2(3,1) = ("Road injury"),  font(calibri light,10, "000000")
		putdocx table t2(4,1) = ("Self harm"),  font(calibri light,10, "000000")
		putdocx table t2(5,1) = ("Falls"),  font(calibri light,10, "000000")
		putdocx table t2(6,1) = ("Poisonings"),  font(calibri light,10, "000000")
		putdocx table t2(7,1) = ("Fire and Heat"),  font(calibri light,10, "000000")
		putdocx table t2(8,1) = ("Drowning"),  font(calibri light,10, "000000")
		putdocx table t2(9,1) = ("Mechanical Forces"),  font(calibri light,10, "000000")
		putdocx table t2(10,1) = ("Natural Forces"),  font(calibri light,10, "000000")
		putdocx table t2(11,1) = ("Collective Violence"),  font(calibri light,10, "000000")
		putdocx table t2(12,1) = ("Unintentional Injuries"), bold font(calibri light,10, "000000")
		putdocx table t2(13,1) = ("Intentional injuries"), bold font(calibri light,10, "000000")
		putdocx table t2(14,1) = ("All injuries"), bold font(calibri light,10, "000000")

        putdocx table t2(.,1)  , width(22%)
        putdocx table t2(.,2)  , width(13%)
        putdocx table t2(.,3)  , width(13%)
        putdocx table t2(.,4)  , width(13%)
        putdocx table t2(.,5)  , width(13%)
        putdocx table t2(.,6)  , width(13%)
        putdocx table t2(.,7)  , width(13%)

        putdocx table t2(1,.), addrows(1, before)
		putdocx table t2(1,.),  shading("e6e6e6")
		putdocx table t2(1,.), border(bottom, single, "e6e6e6")
		putdocx table t2(1,2) = ("Early Childhood"),  font(calibri light,10, "000000")
		putdocx table t2(1,3) = ("School-aged and Adolescent"),  font(calibri light,10, "000000")
		putdocx table t2(1,4) = ("Young Adults"),  font(calibri light,10, "000000")
		putdocx table t2(1,5) = ("Middle Adulthood"),  font(calibri light,10, "000000")
		putdocx table t2(1,6) = ("Older Adults"),  font(calibri light,10, "000000")
		putdocx table t2(1,7) = ("All ages"),  font(calibri light,10, "000000")

        ///putdocx table t2(1,1) , rowspan(2)        
        putdocx table t2(1,1) = ("Injury Cause"),  font(calibri light,10, "000000")

	** Save the Table
    putdocx save "`outputpath'/inj_supplement_table_11", replace




** --------------------------------------------------------------
** FIGURE. MEN
** --------------------------------------------------------------

** Load population file from: 
**      paper2-100-datasets.do 
use "`datapath'/dataset02", clear
drop dths

** Keep Injury components (ie. drop ALL / Unintentional / Intentional injuries)
keep if ghecause>6

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
 
** Nubers of DALYs by Broad age group
tabstat daly if year==2021, by(agroup) stat(sum) format(%12.0fc)
** Individual causes 
tabstat daly if year==2021, by(agroup) stat(sum) format(%12.0fc)
table ghecause agroup if year==2021, stat(sum daly)


** ------------------------------------------------------------
** GRAPHIC
** ------------------------------------------------------------

** GRAPHIC ordered by umber of deaths
** low to high
** 8 subregions
gen yr1 = . 
replace yr1 = year if       agroup==1
replace yr1 = year + 22 if  agroup==2
replace yr1 = year + 44 if  agroup==3
replace yr1 = year + 66 if  agroup==4
replace yr1 = year + 88 if  agroup==5
order year yr1 
drop daly pop td 
reshape wide pd , i(agroup yr1 year) j(ghecause) 

** (ghecause  7. road injury)
** (ghecause  8. poisonings)
** (ghecause  9. falls)
** (ghecause 10. fire and heat)
** (ghecause 11. drowning)
** (ghecause 12. mechanical forces)
** (ghecause 13. natural disasters)
** (ghecause 14. self harm)
** (ghecause 15. interpersonal violence)
** (ghecause 16. collective violence)
**
** Cumulative Percentages 
** 13/c7 Natural Disasters
**  7/c1 Road injuries
**  9/c3 Falls
** 15/c9 Interpersonal violence
** 14/c8 Self harm
** 11/c5 Drowning
**  8/c2 Poisonings
** 10/c4 Fire and Heat
** 12/c6 Mechanical forces
** 16/c10 Collective violence
gen zero    = 0 
gen c1      = pd13
gen c2      = pd7 + c1 
gen c3      = pd9 + c2
gen c4      = pd15 + c3 
gen c5      = pd14 + c4 
gen c6      = pd11 + c5 
gen c7      = pd8 + c6 
gen c8      = pd10 + c7 
gen c9      = pd12 + c8 
gen c10     = pd16 + c9

** generate a local for the ColorBrewer color scheme
colorpalette ptol rainbow , n(10)  nograph
local list r(p) 
** c1 - c11
forval x = 1(1)10 {
    local a`x' `r(p`x')'
}

** FOR ARTICLE - COLORBLIND FRIENDLY
** Paul Tol’s Bright Palette (12 colors)
colorpalette tol muted, nograph 
local list r(p) 
local a1 `r(p1)'
local a2 `r(p2)'
local a3 `r(p3)'
local a4 `r(p4)'
local a5 `r(p5)'
local a6 `r(p6)'
local a7 `r(p7)'
local a8 `r(p8)'
local a9 `r(p9)'
local a10 `gs5'

** Legend outer limits for graphing 
local outer1 90 2001 95 2001 95 2006 90 2006 90 2001 
local outer2 81 2001 86 2001 86 2006 81 2006 81 2001 
local outer3 72 2001 77 2001 77 2006 72 2006 72 2001 

#delimit ;
	gr twoway 
		/// Young children (0-4)
        (rarea zero c1 yr1 if  agroup==1 , lw(0.1) fc("`a1'%50") lc("`a1'"))
        (rarea c1 c2 yr1  if   agroup==1 , lw(0.1) fc("`a2'%50") lc("`a2'"))
        (rarea c2 c3 yr1  if   agroup==1 , lw(0.1) fc("`a3'%50") lc("`a3'"))
        (rarea c3 c4 yr1  if   agroup==1 , lw(0.1) fc("`a4'%50") lc("`a4'"))
        (rarea c4 c5 yr1  if   agroup==1 , lw(0.1) fc("`a5'%50") lc("`a5'"))
        (rarea c5 c6 yr1  if   agroup==1 , lw(0.1) fc("`a6'%50") lc("`a6'"))
        (rarea c6 c7 yr1  if   agroup==1 , lw(0.1) fc("`a7'%50") lc("`a7'"))
        (rarea c7 c8 yr1  if   agroup==1 , lw(0.1) fc("`a8'%50") lc("`a8'"))
        (rarea c8 c9 yr1  if   agroup==1 , lw(0.1) fc("`a9'%50") lc("`a9'"))
        (rarea c9 c10 yr1  if  agroup==1 , lw(0.1) fc("`a10'%50") lc("`a10'"))
		/// Youth (5-19)
        (rarea zero c1 yr1 if  agroup==2 , lw(0.1) fc("`a1'%50") lc("`a1'"))
        (rarea c1 c2 yr1  if   agroup==2 , lw(0.1) fc("`a2'%50") lc("`a2'"))
        (rarea c2 c3 yr1  if   agroup==2 , lw(0.1) fc("`a3'%50") lc("`a3'"))
        (rarea c3 c4 yr1  if   agroup==2 , lw(0.1) fc("`a4'%50") lc("`a4'"))
        (rarea c4 c5 yr1  if   agroup==2 , lw(0.1) fc("`a5'%50") lc("`a5'"))
        (rarea c5 c6 yr1  if   agroup==2 , lw(0.1) fc("`a6'%50") lc("`a6'"))
        (rarea c6 c7 yr1  if   agroup==2 , lw(0.1) fc("`a7'%50") lc("`a7'"))
        (rarea c7 c8 yr1  if   agroup==2 , lw(0.1) fc("`a8'%50") lc("`a8'"))
        (rarea c8 c9 yr1  if   agroup==2 , lw(0.1) fc("`a9'%50") lc("`a9'"))
        (rarea c9 c10 yr1  if  agroup==2 , lw(0.1) fc("`a10'%50") lc("`a10'"))
		/// Young Adults (20-39)
        (rarea zero c1 yr1 if  agroup==3 , lw(0.1) fc("`a1'%50") lc("`a1'"))
        (rarea c1 c2 yr1  if   agroup==3 , lw(0.1) fc("`a2'%50") lc("`a2'"))
        (rarea c2 c3 yr1  if   agroup==3 , lw(0.1) fc("`a3'%50") lc("`a3'"))
        (rarea c3 c4 yr1  if   agroup==3 , lw(0.1) fc("`a4'%50") lc("`a4'"))
        (rarea c4 c5 yr1  if   agroup==3 , lw(0.1) fc("`a5'%50") lc("`a5'"))
        (rarea c5 c6 yr1  if   agroup==3 , lw(0.1) fc("`a6'%50") lc("`a6'"))
        (rarea c6 c7 yr1  if   agroup==3 , lw(0.1) fc("`a7'%50") lc("`a7'"))
        (rarea c7 c8 yr1  if   agroup==3 , lw(0.1) fc("`a8'%50") lc("`a8'"))
        (rarea c8 c9 yr1  if   agroup==3 , lw(0.1) fc("`a9'%50") lc("`a9'"))
        (rarea c9 c10 yr1  if  agroup==3 , lw(0.1) fc("`a10'%25") lc("`a10'%85"))
		/// Older Adults (40-64)
        (rarea zero c1 yr1 if  agroup==4 , lw(0.1) fc("`a1'%50") lc("`a1'"))
        (rarea c1 c2 yr1  if   agroup==4 , lw(0.1) fc("`a2'%50") lc("`a2'"))
        (rarea c2 c3 yr1  if   agroup==4 , lw(0.1) fc("`a3'%50") lc("`a3'"))
        (rarea c3 c4 yr1  if   agroup==4 , lw(0.1) fc("`a4'%50") lc("`a4'"))
        (rarea c4 c5 yr1  if   agroup==4 , lw(0.1) fc("`a5'%50") lc("`a5'"))
        (rarea c5 c6 yr1  if   agroup==4 , lw(0.1) fc("`a6'%50") lc("`a6'"))
        (rarea c6 c7 yr1  if   agroup==4 , lw(0.1) fc("`a7'%50") lc("`a7'"))
        (rarea c7 c8 yr1  if   agroup==4 , lw(0.1) fc("`a8'%50") lc("`a8'"))
        (rarea c8 c9 yr1  if   agroup==4 , lw(0.1) fc("`a9'%50") lc("`a9'"))
        (rarea c9 c10 yr1  if  agroup==4 , lw(0.1) fc("`a10'%25") lc("`a10'%85"))
        /// Older adults (65+)
        (rarea zero c1 yr1 if  agroup==5 , lw(0.1) fc("`a1'%50") lc("`a1'"))
        (rarea c1 c2 yr1  if   agroup==5 , lw(0.1) fc("`a2'%50") lc("`a2'"))
        (rarea c2 c3 yr1  if   agroup==5 , lw(0.1) fc("`a3'%50") lc("`a3'"))
        (rarea c3 c4 yr1  if   agroup==5 , lw(0.1) fc("`a4'%50") lc("`a4'"))
        (rarea c4 c5 yr1  if   agroup==5 , lw(0.1) fc("`a5'%50") lc("`a5'"))
        (rarea c5 c6 yr1  if   agroup==5 , lw(0.1) fc("`a6'%50") lc("`a6'"))
        (rarea c6 c7 yr1  if   agroup==5 , lw(0.1) fc("`a7'%50") lc("`a7'"))
        (rarea c7 c8 yr1  if   agroup==5 , lw(0.1) fc("`a8'%50") lc("`a8'"))
        (rarea c8 c9 yr1  if   agroup==5 , lw(0.1) fc("`a9'%50") lc("`a9'"))
        (rarea c9 c10 yr1  if  agroup==5 , lw(0.1) fc("`a10'%25") lc("`a10'%85"))


        (function y=101, range(2000 2110) lc(gs12) dropline(2021.5 2043.5 2065.5 2087.5 2109.5))

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
            text(105 2011 "Under 5s",  place(c) size(5) color(gs5))
            text(105 2032 "5-19 yrs",  place(c) size(5) color(gs5))
            text(105 2054 "20-39 yrs",  place(c) size(5) color(gs5))   
            text(105 2076 "40-64 yrs",  place(c) size(5) color(gs5))
            text(105 2098 "65 and older",  place(c) size(5) color(gs5))   

			/// X-Axis text
            text(-3.5 2001 "2000",  place(e) size(4) color(gs8))
            text(-3.5 2020 "2021",  place(w) size(4) color(gs8))

            text(-3.5 2023 "2000",  place(e) size(4) color(gs8))
            text(-3.5 2042 "2021",  place(w) size(4) color(gs8))
            
            text(-3.5 2045 "2000",  place(e) size(4) color(gs8))
            text(-3.5 2064 "2021",  place(w) size(4) color(gs8))
            
            text(-3.5 2067 "2000",  place(e) size(4) color(gs8))
            text(-3.5 2086 "2021",  place(w) size(4) color(gs8))
            
            text(-3.5 2089 "2000",  place(e) size(4) color(gs8))
            text(-3.5 2108 "2021",  place(w) size(4) color(gs8))

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
			graph export "`outputpath'/figure2a.png", replace width(4000);
#delimit cr	


** --------------------------------------------------------------
** WOMEN
** --------------------------------------------------------------

** Load population file from: 
**      paper2-100-datasets.do 
use "`datapath'/dataset02", clear
drop dths

** Keep Injury components
keep if ghecause>6

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
tabstat daly if year==2021, by(agroup) stat(sum) format(%12.0fc)

tabstat pd if year==2021 & agroup==1, by(ghecause) stat(sum) format(%12.0fc)
tabstat pd if year==2021 & agroup==2, by(ghecause) stat(sum) format(%12.0fc)
tabstat pd if year==2021 & agroup==3, by(ghecause) stat(sum) format(%12.0fc)
tabstat pd if year==2021 & agroup==4, by(ghecause) stat(sum) format(%12.0fc)
tabstat pd if year==2021 & agroup==5, by(ghecause) stat(sum) format(%12.0fc)

** ------------------------------------------------------------
** GRAPHIC
** ------------------------------------------------------------

** GRAPHIC ordered by umber of deaths
** low to high
** 8 subregions
gen yr1 = . 
replace yr1 = year if       agroup==1
replace yr1 = year + 22 if  agroup==2
replace yr1 = year + 44 if  agroup==3
replace yr1 = year + 66 if  agroup==4
replace yr1 = year + 88 if  agroup==5
order year yr1 
drop daly pop td 
reshape wide pd , i(agroup yr1 year) j(ghecause) 


** (ghecause  7. road injury)
** (ghecause  8. poisonings)
** (ghecause  9. falls)
** (ghecause 10. fire and heat)
** (ghecause 11. drowning)
** (ghecause 12. mechanical forces)
** (ghecause 13. natural disasters)
** (ghecause 14. self harm)
** (ghecause 15. interpersonal violence)
** (ghecause 16. collective violence)
**
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
gen c1      = pd13
gen c2      = pd7 + c1 
gen c3      = pd9 + c2
gen c4      = pd15 + c3 
gen c5      = pd14 + c4 
gen c6      = pd11 + c5 
gen c7      = pd8 + c6 
gen c8      = pd10 + c7 
gen c9      = pd12 + c8 
gen c10     = pd16 + c9

** generate a local for the ColorBrewer color scheme
colorpalette ptol rainbow , n(10)  nograph
local list r(p) 
** c1 - c11
forval x = 1(1)10 {
    local a`x' `r(p`x')'
}

** FOR ARTICLE - COLORBLIND FRIENDLY
** Paul Tol’s Bright Palette (12 colors)
colorpalette tol muted, nograph 
local list r(p) 
local a1 `r(p1)'
local a2 `r(p2)'
local a3 `r(p3)'
local a4 `r(p4)'
local a5 `r(p5)'
local a6 `r(p6)'
local a7 `r(p7)'
local a8 `r(p8)'
local a9 `r(p9)'
local a10 `gs5'

** Legend outer limits for graphing 
local outer1 90 2001 95 2001 95 2006 90 2006 90 2001 
local outer2 81 2001 86 2001 86 2006 81 2006 81 2001 
local outer3 72 2001 77 2001 77 2006 72 2006 72 2001 

#delimit ;
	gr twoway 
		/// Young children (0-4)
        (rarea zero c1 yr1 if  agroup==1 , lw(0.1) fc("`a1'%50") lc("`a1'"))
        (rarea c1 c2 yr1  if   agroup==1 , lw(0.1) fc("`a2'%50") lc("`a2'"))
        (rarea c2 c3 yr1  if   agroup==1 , lw(0.1) fc("`a3'%50") lc("`a3'"))
        (rarea c3 c4 yr1  if   agroup==1 , lw(0.1) fc("`a4'%50") lc("`a4'"))
        (rarea c4 c5 yr1  if   agroup==1 , lw(0.1) fc("`a5'%50") lc("`a5'"))
        (rarea c5 c6 yr1  if   agroup==1 , lw(0.1) fc("`a6'%50") lc("`a6'"))
        (rarea c6 c7 yr1  if   agroup==1 , lw(0.1) fc("`a7'%50") lc("`a7'"))
        (rarea c7 c8 yr1  if   agroup==1 , lw(0.1) fc("`a8'%50") lc("`a8'"))
        (rarea c8 c9 yr1  if   agroup==1 , lw(0.1) fc("`a9'%50") lc("`a9'"))
        (rarea c9 c10 yr1  if  agroup==1 , lw(0.1) fc("`a10'%50") lc("`a10'"))
		/// Youth (5-19)
        (rarea zero c1 yr1 if  agroup==2 , lw(0.1) fc("`a1'%50") lc("`a1'"))
        (rarea c1 c2 yr1  if   agroup==2 , lw(0.1) fc("`a2'%50") lc("`a2'"))
        (rarea c2 c3 yr1  if   agroup==2 , lw(0.1) fc("`a3'%50") lc("`a3'"))
        (rarea c3 c4 yr1  if   agroup==2 , lw(0.1) fc("`a4'%50") lc("`a4'"))
        (rarea c4 c5 yr1  if   agroup==2 , lw(0.1) fc("`a5'%50") lc("`a5'"))
        (rarea c5 c6 yr1  if   agroup==2 , lw(0.1) fc("`a6'%50") lc("`a6'"))
        (rarea c6 c7 yr1  if   agroup==2 , lw(0.1) fc("`a7'%50") lc("`a7'"))
        (rarea c7 c8 yr1  if   agroup==2 , lw(0.1) fc("`a8'%50") lc("`a8'"))
        (rarea c8 c9 yr1  if   agroup==2 , lw(0.1) fc("`a9'%50") lc("`a9'"))
        (rarea c9 c10 yr1  if  agroup==2 , lw(0.1) fc("`a10'%50") lc("`a10'"))
		/// Young Adults (20-39)
        (rarea zero c1 yr1 if  agroup==3 , lw(0.1) fc("`a1'%50") lc("`a1'"))
        (rarea c1 c2 yr1  if   agroup==3 , lw(0.1) fc("`a2'%50") lc("`a2'"))
        (rarea c2 c3 yr1  if   agroup==3 , lw(0.1) fc("`a3'%50") lc("`a3'"))
        (rarea c3 c4 yr1  if   agroup==3 , lw(0.1) fc("`a4'%50") lc("`a4'"))
        (rarea c4 c5 yr1  if   agroup==3 , lw(0.1) fc("`a5'%50") lc("`a5'"))
        (rarea c5 c6 yr1  if   agroup==3 , lw(0.1) fc("`a6'%50") lc("`a6'"))
        (rarea c6 c7 yr1  if   agroup==3 , lw(0.1) fc("`a7'%50") lc("`a7'"))
        (rarea c7 c8 yr1  if   agroup==3 , lw(0.1) fc("`a8'%50") lc("`a8'"))
        (rarea c8 c9 yr1  if   agroup==3 , lw(0.1) fc("`a9'%50") lc("`a9'"))
        (rarea c9 c10 yr1  if  agroup==3 , lw(0.1) fc("`a10'%50") lc("`a10'"))
		/// Older Adults (40-64)
        (rarea zero c1 yr1 if  agroup==4 , lw(0.1) fc("`a1'%50") lc("`a1'"))
        (rarea c1 c2 yr1  if   agroup==4 , lw(0.1) fc("`a2'%50") lc("`a2'"))
        (rarea c2 c3 yr1  if   agroup==4 , lw(0.1) fc("`a3'%50") lc("`a3'"))
        (rarea c3 c4 yr1  if   agroup==4 , lw(0.1) fc("`a4'%50") lc("`a4'"))
        (rarea c4 c5 yr1  if   agroup==4 , lw(0.1) fc("`a5'%50") lc("`a5'"))
        (rarea c5 c6 yr1  if   agroup==4 , lw(0.1) fc("`a6'%50") lc("`a6'"))
        (rarea c6 c7 yr1  if   agroup==4 , lw(0.1) fc("`a7'%50") lc("`a7'"))
        (rarea c7 c8 yr1  if   agroup==4 , lw(0.1) fc("`a8'%50") lc("`a8'"))
        (rarea c8 c9 yr1  if   agroup==4 , lw(0.1) fc("`a9'%50") lc("`a9'"))
        (rarea c9 c10 yr1  if  agroup==4 , lw(0.1) fc("`a10'%50") lc("`a10'"))
        /// Older adults (65+)
        (rarea zero c1 yr1 if  agroup==5 , lw(0.1) fc("`a1'%50") lc("`a1'"))
        (rarea c1 c2 yr1  if   agroup==5 , lw(0.1) fc("`a2'%50") lc("`a2'"))
        (rarea c2 c3 yr1  if   agroup==5 , lw(0.1) fc("`a3'%50") lc("`a3'"))
        (rarea c3 c4 yr1  if   agroup==5 , lw(0.1) fc("`a4'%50") lc("`a4'"))
        (rarea c4 c5 yr1  if   agroup==5 , lw(0.1) fc("`a5'%50") lc("`a5'"))
        (rarea c5 c6 yr1  if   agroup==5 , lw(0.1) fc("`a6'%50") lc("`a6'"))
        (rarea c6 c7 yr1  if   agroup==5 , lw(0.1) fc("`a7'%50") lc("`a7'"))
        (rarea c7 c8 yr1  if   agroup==5 , lw(0.1) fc("`a8'%50") lc("`a8'"))
        (rarea c8 c9 yr1  if   agroup==5 , lw(0.1) fc("`a9'%50") lc("`a9'"))
        (rarea c9 c10 yr1  if  agroup==5 , lw(0.1) fc("`a10'%50") lc("`a10'"))


        (function y=101, range(2000 2110) lc(gs12) dropline(2021.5 2043.5 2065.5 2087.5 2109.5))

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
            text(105 2011 "Under 5s",  place(c) size(5) color(gs5))
            text(105 2032 "5-19 yrs",  place(c) size(5) color(gs5))
            text(105 2054 "20-39 yrs",  place(c) size(5) color(gs5))   
            text(105 2076 "40-64 yrs",  place(c) size(5) color(gs5))
            text(105 2098 "65 and older",  place(c) size(5) color(gs5))   

			/// X-Axis text
            text(-3.5 2001 "2000",  place(e) size(4) color(gs8))
            text(-3.5 2020 "2021",  place(w) size(4) color(gs8))

            text(-3.5 2023 "2000",  place(e) size(4) color(gs8))
            text(-3.5 2042 "2021",  place(w) size(4) color(gs8))

            text(-3.5 2045 "2000",  place(e) size(4) color(gs8))
            text(-3.5 2064 "2021",  place(w) size(4) color(gs8))

            text(-3.5 2067 "2000",  place(e) size(4) color(gs8))
            text(-3.5 2086 "2021",  place(w) size(4) color(gs8))

            text(-3.5 2089 "2000",  place(e) size(4) color(gs8))
            text(-3.5 2108 "2021",  place(w) size(4) color(gs8))

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
			graph export "`outputpath'/figure2b.png", replace width(4000);
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
    putpdf text ("Age-specific burden of injuries between 2000 and 2021 in The Americas, measured using Disability Adjusted life Years (DALY) rate per 100,000. ")

** FIGURE OF DAILY COVID-19 COUNT
    putpdf table f2 = (6,1), width(90%) border(all,nil) halign(center)
    putpdf table f2(1,1)=("(A) Men")
    putpdf table f2(3,1)=("(B) Women")
    putpdf table f2(2,1)=image("`outputpath'/figure2a.png")
    putpdf table f2(4,1)=image("`outputpath'/figure2b.png")

** FOOTNOTE
///    putpdf paragraph ,  font("Calibri Light", 9)
///    putpdf text ("Note: ") , italic linebreak
///    putpdf text ("Haitian earthquake in 2010 raised the injury burden (DALY rate per 100,000) to 168 thousand among men and 103 thousand among women") , italic

** Save the PDF
    local c_date = c(current_date)
    local date_string = subinstr("`c_date'", " ", "", .)
    ** putpdf save "`outputpath'/Figure_One_SS_`date_string'_grayscale", replace
    putpdf save "`outputpath'/Figure_2_`date_string'_color", replace
