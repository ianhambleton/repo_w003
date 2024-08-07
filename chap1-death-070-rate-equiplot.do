** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap1-death-070-rate-equiplot.do
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
    log using "`logpath'\chap1-death-070-rate-equiplot", replace
** HEADER -----------------------------------------------------



use "`datapath'\from-who\chap2_000_adjusted", clear
** Keep sub-regional level (this will keep the 8 PAHO subregions of the Americas)
keep if region>=100 & region <1000
** Interested only in the THREE major disease groups
** 200	communicable
** 300	NCD
** 1000 Injuries
keep if ghecause==200 | ghecause==300 | ghecause==1000
rename ghecause ghecause_orig 
gen ghecause = . 
replace ghecause = 10 if ghecause_orig==200
replace ghecause = 20 if ghecause_orig==300
replace ghecause = 30 if ghecause_orig==1000
label define ghecause_ 10 "Communicable" 20 "NCDs" 30 "Injuries",modify
label values ghecause ghecause_ 

** DROP DALYs
drop daly dalyr pop_dalyr dths
rename mortr arate
rename pop_mortr pop

** Inequality in 2019 
keep if year==2019
sort sex ghecause
order sex ghecause region 
format pop %15.1fc 


** Identify minimum rate for each chart block --> sex (at 2 levels) x disease group (at 3 levels)
sort sex ghecause arate 
bysort sex ghecause : egen mrate = min(arate)
gen drate = arate - mrate
replace drate = 0 if drate<0.001
** Ordered y-axis
bysort sex ghecause : gen oregion = _n
decode region, gen(tregion)
sort ghecause sex arate

** SAVE THE DATASET FOR GRAPHIC
tempfile graphic
save `graphic', replace


** Associated stats for text
** COM/NCDs/INJ in 2000 and 2019, women and men separately, and women+men combined
list ghecause year sex region arate drate , sep(8) linesize(150)





** -------------------------------------------------------------------
** GRAPHIC
** -------------------------------------------------------------------

** Legend outer limits for graphing 
local outer1 -2 -15 28 -15 28 230 -2 230 -2 -15 
local outer2 -2 240 28 240 28 465 -2 465 -2 240 

** Shifting NCDs and Injures further down screen
gen zero = 0
replace oregion = oregion + 9 if ghecause==20
replace oregion = oregion + 18 if ghecause==30

** Rates among females to allow reverse graphic from RHS
gen zerof = 450
gen dratef = 450 - drate

** generate a local for the ColorBrewer color scheme
colorpalette ptol, rainbow n(9)  nograph
local list r(p) 
** (COM --> ghecause = 10)
local com `r(p3)'
** (NCD --> ghecause = 600)
local ncd `r(p6)'
** (INJ --> ghecause = 1510)
local inj `r(p9)'

sort sex ghecause drate 

#delimit ;
	gr twoway 
        (function y=27, yaxis(1) range(0 0) lc(gs13) lp("-") dropline(0))
        (function y=27, yaxis(2) range(450 450) lc(gs13) lp("-") dropline(450))

        /// COM vertical lines
		(function y=8, yaxis(1) range(100 115) lc("`com'%25") lp("-") )
        (function y=8, yaxis(2) range(342 357) lc("`com'%25") lp("-") )
		(function y=115, range(6 8) hor lc("`com'%25") lp("-") )
		(function y=342, range(6 8) hor lc("`com'%25") lp("-") )

        /// NCD vertical lines
		(function y=17, yaxis(1) range(199 214) lc("`ncd'%25") lp("-") )
        (function y=17, yaxis(2) range(272 287) lc("`ncd'%25") lp("-") )
		(function y=214, range(15 17) hor lc("`ncd'%25") lp("-") )
		(function y=272, range(15 17) hor lc("`ncd'%25") lp("-") )

        /// INJ vertical lines
		(function y=26, yaxis(1) range(75 90) lc("`inj'%25") lp("-") )
        (function y=26, yaxis(2) range(411 426) lc("`inj'%25") lp("-") )
		(function y=90, range(24 26) hor lc("`inj'%25") lp("-") )
		(function y=411, range(24 26) hor lc("`inj'%25") lp("-") )

        (scatteri `outer1' , yaxis(1) recast(area) lw(0.2) lc(gs10) fc(none)  )
        (scatteri `outer2' , yaxis(2) recast(area) lw(0.2) lc(gs10) fc(none)  )

		/// COM. MALE
        (rbar zero drate oregion if sex==1 & ghecause==10 , yaxis(1) horizontal fc("`com'%50") barw(0.05) lw(none))
        (sc oregion drate        if sex==1 & ghecause==10 , yaxis(1) msize(3) m(o) mlc("`com'") mfc("`com'") mlw(0.1))

		/// NCD. MALE
        (rbar zero drate oregion if sex==1 & ghecause==20 , yaxis(1) horizontal fc("`ncd'%50") barw(0.05) lw(none))
        (sc oregion drate        if sex==1 & ghecause==20 , yaxis(1) msize(3) m(o) mlc("`ncd'") mfc("`ncd'") mlw(0.1))

		/// INJ. MALE
        (rbar zero drate oregion if sex==1 & ghecause==30 , yaxis(1) horizontal fc("`inj'%50") barw(0.05) lw(none))
        (sc oregion drate        if sex==1 & ghecause==30 , yaxis(1) msize(3) m(o) mlc("`inj'") mfc("`inj'") mlw(0.1))

		/// COM. FEMALE
        (rbar zerof dratef oregion if sex==2 & ghecause==10 , yaxis(2) horizontal fc("`com'%50") barw(0.05) lw(none))
        (sc oregion dratef         if sex==2 & ghecause==10 , yaxis(2) msize(3) m(o) mlc("`com'") mfc("`com'") mlw(0.1))	

		/// NCD. FEMALE
        (rbar zerof dratef oregion if sex==2 & ghecause==20 , yaxis(2) horizontal fc("`ncd'%50") barw(0.05) lw(none))
        (sc oregion dratef         if sex==2 & ghecause==20 , yaxis(2) msize(3) m(o) mlc("`ncd'") mfc("`ncd'") mlw(0.1))

		/// INJ. FEMALE
        (rbar zerof dratef oregion if sex==2 & ghecause==30 , yaxis(2) horizontal fc("`inj'%50") barw(0.05) lw(none))
        (sc oregion dratef         if sex==2 & ghecause==30 , yaxis(2) msize(3) m(o) mlc("`inj'") mfc("`inj'") mlw(0.1))			
		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 
			ysize(11) xsize(15)

			/// TOP
			xlab(none, 
			axis(1) labc(gs8) labs(2.5) notick grid glc(gs16) angle(0) format(%9.0f))
			xscale(axis(1) noline range(0(10)430) lw(vthin)) 
			xtitle("", axis(1)  size(2.5) color(gs8) margin(l=1 r=1 t=0 b=0)) 

			/// men
			ylab(	1 	"North America"
					2 	"Mexico"
					3 	"Andean"
					4 	"Non-Latin Caribbean"
					5 	"Southern Cone"
					6 	"Brazil"
					7 	"Central America"
					8 	"Latin Caribbean"
					10 	"Andean"
					11 	"North America"
					12 	"Southern Cone"
					13 	"Central America"
					14 	"Brazil"
					15 	"Mexico"
					16 	"Non-Latin Caribbean"
					17 	"Latin Caribbean"
					19 	"North America"
					20 	"Southern Cone"
					21 	"Mexico"
					22 	"Andean"
					23 	"Brazil"
					24 	"Non-Latin Caribbean"
					25 	"Latin Caribbean"
					26 	"Central America"
					,
			axis(1) labc(gs8) labs(2.25) tlc(gs8) nogrid notick glc(blue) angle(0) format(%9.0f) labgap(0))
			yscale(axis(1) noline reverse range(-6(0.5)29) noextend) 
			ytitle(" ", axis(1) color(gs8) size(3) margin(l=1 r=1 t=1 b=1)) 

			/// women
			ylab(	
					1	"North America"
					2	"Mexico"
					3	"Non-Latin Caribbean"
					4	"Southern Cone"
					5	"Andean"
					6	"Brazil"
					7	"Central America"
					8	"Latin Caribbean"
					10	"Andean"
					11	"Southern Cone"
					12	"North America"
					13	"Brazil"
					14	"Mexico"
					15	"Central America"
					16	"Non-Latin Caribbean"
					17	"Latin Caribbean"
					19	"Southern Cone"
					20	"Mexico"
					21	"Andean"
					22	"Brazil"
					23	"North America"
					24	"Non-Latin Caribbean"
					25	"Central America"
					26	"Latin Caribbean"
					,
			axis(2) labc(gs8) labs(2.25) tlc(gs8) nogrid notick glc(red) angle(0) format(%9.0f) labgap(0))
			yscale(axis(2) noline reverse range(-6(0.5)29) noextend) 
			ytitle(" ", axis(2) color(gs8) size(3) margin(l=1 r=1 t=1 b=1)) 

            /// Legend Text
            text(27 170 "Men",  place(c) size(3) color(gs8))   
            text(27 300 "Women",  place(c) size(3) color(gs8))   
            text(-3 225 "Excess mortality rate (per 100 000 people)",  place(c) size(3) color(gs8))   
            text(-1 0 "0",  place(c) size(3) color(gs8))   
            text(-1 450 "0",  place(c) size(3) color(gs8))   
			/// Values
			text(5.4 115 "101",  place(c) size(2.5) color("`com'"))   
			text(5.4 342 "92",  place(c) size(2.5) color("`com'"))   
			
			text(14.4 214 "199",  place(c) size(2.5) color("`ncd'"))   
			text(14.4 272 "163",  place(c) size(2.5) color("`ncd'"))   			
			
			text(23.4 90 "75",  place(c) size(2.5) color("`inj'"))   
			text(23.4 411 "24",  place(c) size(2.5) color("`inj'"))   

			legend(size(3) position(12) nobox ring(0) bm(t=0 b=0 l=0 r=0) colf cols(3)
			region(fcolor(gs16)  lw(none) margin(t=0 b=1 l=0 r=0)) 
			order(24 26 28) 
			lab(24 "CMPN") 
			lab(26 "NCDs") 		
			lab(28 "Injuries") 		
            )
			name(excess_death)
			;
#delimit cr	
** Export to Vector Graphic
** DEC 22nd, 2022
graph export "`outputpath'\reports\2024-edits\graphics\fig8.svg", replace
graph export "`outputpath'\reports\2024-edits\graphics\fig8.pdf", replace

** Export data for Figure 8
** WOMEN 2. MEN 1.
drop if sex==3
drop year ghecause_orig paho_subregion *yll* *yld* tregion zero zerof dratef oregion pop arate mrate
sort sex ghecause drate
order sex ghecause region drate 
rename drate excess_rate
export excel "`outputpath'\reports\2024-edits\graphics\chap1_data.xlsx", sheet("figure-8", replace) first(var)






** REPEAT, BY WORLD BANK INCOME GROUPS
** 27-AUG-2021

use "`datapath'\from-who\chap2_000_adjusted", clear
use "`datapath'\from-who\chap2_000_mr_wb", clear
drop crate arate_new pop_new paho_subregion cases pop
** We're using an earlier MR file - which hasn't been multiplied to 100,000 persons
replace arate = arate * 100000 

** Keep World Bank income groups
keep if region>=10000 

** Interested only in the THREE major disease groups
** 200	communicable
** 300	NCD
** 1000 Injuries
keep if ghecause==200 | ghecause==300 | ghecause==1000
rename ghecause ghecause_orig 
gen ghecause = . 
replace ghecause = 10 if ghecause_orig==200
replace ghecause = 20 if ghecause_orig==300
replace ghecause = 30 if ghecause_orig==1000
label define ghecause_ 10 "Communicable" 20 "NCDs" 30 "Injuries",modify
label values ghecause ghecause_ 

** Inequality in 2019 
keep if year==2019
sort sex ghecause
order sex ghecause region 

** Identify minimum rate for each chart block --> sex (at 2 levels) x disease group (at 3 levels)
sort sex ghecause arate 
bysort sex ghecause : egen mrate = min(arate)
gen drate = arate - mrate
replace drate = 0 if drate<0.001

** Ordered y-axis
label define region_ 11000 "low income" 12000 "low-middle income" 13000 "high-middle income" 14000 "high income", modify
label values region region_
bysort sex ghecause : gen oregion = _n
decode region, gen(tregion)
sort ghecause sex arate

** SAVE THE DATASET FOR GRAPHIC
tempfile graphic
save `graphic', replace

** Associated stats for text
** COM/NCDs/INJ in 2000 and 2019, women and men separately, and women+men combined
sort  ghecause sex drate 
list ghecause year sex region arate mrate drate , sep(8) linesize(150)

** -------------------------------------------------------------------
** GRAPHIC
** -------------------------------------------------------------------

** Legend outer limits for graphing 
local outer1 -2 -40 16 -40 16 550 -2 550 -2 -40 
local outer2 -2 570 16 570 16 1200 -2 1200 -2 570 

** Shifting NCDs and Injures further down screen
** FOUR income groups - so we shift by 5 to allow for spacing
gen zero = 0
replace oregion = oregion + 5 if ghecause==20
replace oregion = oregion + 10 if ghecause==30

** Rates among females to allow reverse graphic from RHS
gen zerof = 1160
gen dratef = 1160 - drate

** generate a local for the ColorBrewer color scheme
colorpalette ptol, rainbow n(9)  nograph
local list r(p) 
** (COM --> ghecause = 10)
local com `r(p3)'
** (NCD --> ghecause = 600)
local ncd `r(p6)'
** (INJ --> ghecause = 1510)
local inj `r(p9)'

sort sex ghecause drate 

#delimit ;
	gr twoway 
        (function y=15, yaxis(1) range(0 0) lc(gs13) lp("-") dropline(0))
        (function y=15, yaxis(2) range(1160 1160) lc(gs13) lp("-") dropline(1160))

        /// COM vertical lines
		(function y=4, yaxis(1) range(190 250) lc("`com'%25") lp("-") )
        (function y=4, yaxis(2) range(900 940) lc("`com'%25") lp("-") )
		(function y=250, range(3 4) hor lc("`com'%25") lp("-") )
		(function y=900, range(3 4) hor lc("`com'%25") lp("-") )

        /// NCD vertical lines
		(function y=9, yaxis(1) range(400 425) lc("`ncd'%25") lp("-") )
        (function y=9, yaxis(2) range(650 650) lc("`ncd'%25") lp("-") )
		(function y=425, range(8 9) hor lc("`ncd'%25") lp("-") )
		(function y=650, range(8 9) hor lc("`ncd'%25") lp("-") )

        /// INJ vertical lines
		(function y=14, yaxis(1) range(90 160) lc("`inj'%25") lp("-") )
        (function y=14, yaxis(2) range(1020 1100) lc("`inj'%25") lp("-") )
		(function y=160, range(13 14) hor lc("`inj'%25") lp("-") )
		(function y=1020, range(13 14) hor lc("`inj'%25") lp("-") )

        (scatteri `outer1' , yaxis(1) recast(area) lw(0.2) lc(gs10) fc(none)  )
        (scatteri `outer2' , yaxis(2) recast(area) lw(0.2) lc(gs10) fc(none)  )

		/// COM. MALE
        (rbar zero drate oregion if sex==1 & ghecause==10 , yaxis(1) horizontal fc("`com'%50") barw(0.05) lw(none))
        (sc oregion drate        if sex==1 & ghecause==10 , yaxis(1) msize(3) m(o) mlc("`com'") mfc("`com'") mlw(0.1))

		/// NCD. MALE
        (rbar zero drate oregion if sex==1 & ghecause==20 , yaxis(1) horizontal fc("`ncd'%50") barw(0.05) lw(none))
        (sc oregion drate        if sex==1 & ghecause==20 , yaxis(1) msize(3) m(o) mlc("`ncd'") mfc("`ncd'") mlw(0.1))

		/// INJ. MALE
        (rbar zero drate oregion if sex==1 & ghecause==30 , yaxis(1) horizontal fc("`inj'%50") barw(0.05) lw(none))
        (sc oregion drate        if sex==1 & ghecause==30 , yaxis(1) msize(3) m(o) mlc("`inj'") mfc("`inj'") mlw(0.1))

		/// COM. FEMALE
        (rbar zerof dratef oregion if sex==2 & ghecause==10 , yaxis(2) horizontal fc("`com'%50") barw(0.05) lw(none))
        (sc oregion dratef         if sex==2 & ghecause==10 , yaxis(2) msize(3) m(o) mlc("`com'") mfc("`com'") mlw(0.1))	

		/// NCD. FEMALE
        (rbar zerof dratef oregion if sex==2 & ghecause==20 , yaxis(2) horizontal fc("`ncd'%50") barw(0.05) lw(none))
        (sc oregion dratef         if sex==2 & ghecause==20 , yaxis(2) msize(3) m(o) mlc("`ncd'") mfc("`ncd'") mlw(0.1))

		/// INJ. FEMALE
        (rbar zerof dratef oregion if sex==2 & ghecause==30 , yaxis(2) horizontal fc("`inj'%50") barw(0.05) lw(none))
        (sc oregion dratef         if sex==2 & ghecause==30 , yaxis(2) msize(3) m(o) mlc("`inj'") mfc("`inj'") mlw(0.1))			
		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 
			ysize(11) xsize(15)

			/// TOP
			xlab(none, 
			axis(1) labc(gs8) labs(2.5) notick grid glc(gs16) angle(0) format(%9.0f))
			xscale(axis(1) noline range(0(10)950) lw(vthin)) 
			xtitle("", axis(1)  size(2.5) color(gs8) margin(l=1 r=1 t=0 b=0)) 

			/// men
			ylab(	1 	"High income"
					2 	"Upper-middle income"
					3 	"Lower-middle income"
					4 	"Low income"
					6 	"High income"
					7 	"Upper-middle income"
					8 	"Lower-middle income"
					9 	"Low income"
					11 	"High income"
					12 	"Upper-middle income"
					13 	"Lower-middle income"
					14 	"Low income"
					,
			axis(1) labc(gs8) labs(2.75) tlc(gs8) nogrid notick glc(blue) angle(0) format(%9.0f) labgap(0))
			yscale(axis(1) noline reverse range(-5(0.5)16) noextend) 
			ytitle(" ", axis(1) color(gs8) size(3) margin(l=1 r=1 t=1 b=1)) 

			/// women
			ylab(	1 	"High income"
					2 	"Upper-middle income"
					3 	"Lower-middle income"
					4 	"Low income"
					6 	"High income"
					7 	"Upper-middle income"
					8 	"Lower-middle income"
					9 	"Low income"
					11 	"Upper-middle income"
					12 	"High income"
					13 	"Lower-middle income"
					14 	"Low income"
					,
			axis(2) labc(gs8) labs(2.75) tlc(gs8) nogrid notick glc(red) angle(0) format(%9.0f) labgap(0))
			yscale(axis(2) noline reverse range(-5(0.5)16) noextend) 
			ytitle(" ", axis(2) color(gs8) size(3) margin(l=1 r=1 t=1 b=1)) 

            /// Legend Text
            text(15.3 380 "Men",  place(c) size(3) color(gs8))   
            text(15.3 750 "Women",  place(c) size(3) color(gs8))   
            text(-3 550 "Excess mortality rate (per 100 000 people)",  place(c) size(3) color(gs8))   
            text(-1 0 "0",  place(c) size(3) color(gs8))   
            text(-1 1160 "0",  place(c) size(3) color(gs8))   

			/// COM
			text(2.7 250 "191",  place(c) size(2.5) color("`com'"))   
			text(2.7 900 "190",  place(c) size(2.5) color("`com'"))   
			
			/// NCD
			text(7.5 425 "368",  place(c) size(2.5) color("`ncd'"))   
			text(7.5 650 "513",  place(c) size(2.5) color("`ncd'"))   			
			
			/// INJ
			text(12.6 160 "77",  place(c) size(2.5) color("`inj'"))   
			text(12.6 1020 "33",  place(c) size(2.5) color("`inj'"))   

			legend(size(3) position(12) nobox ring(0) bm(t=0 b=0 l=0 r=0) colf cols(3)
			region(fcolor(gs16)  lw(none) margin(t=0 b=1 l=0 r=0)) 
			order(24 26 28) 
			lab(24 "CMPN") 
			lab(26 "NCDs") 		
			lab(28 "Injuries") 		
            )
			name(excess_death2)
			;
#delimit cr	
** Export to Vector Graphic
** DEC 22nd, 2022
graph export "`outputpath'\reports\2024-edits\graphics\fig9.svg", replace
graph export "`outputpath'\reports\2024-edits\graphics\fig9.pdf", replace


** Export data for Figure 9
** WOMEN 2. MEN 1.
drop if sex==3
drop year ghecause_orig tregion zero zerof dratef oregion arate mrate
sort sex ghecause drate
order sex ghecause region drate 
rename drate excess_rate
export excel "`outputpath'\reports\2024-edits\graphics\chap1_data.xlsx", sheet("figure-9", replace) first(var)
