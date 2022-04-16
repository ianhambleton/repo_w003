** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    paper1-160-health-figure3.do
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
    log using "`logpath'\paper1-160-health-figure3", replace
** HEADER -----------------------------------------------------



** -----------------------------------------------
** 2. DEATHS
** -----------------------------------------------

** Load the country-level death and population data
** This comes from:
**	--> C:\Sync\OneDrive - The University of the West Indies\repo_ianhambleton\repo_w003\chap2-000c-mr-country-groups.do
use "`datapath'\from-who\paper1-chap3_byage_country_groups_both", clear
	append using "`datapath'\from-who\paper1-chap3_byage_groups_both"
	keep if who_region==. | who_region==2
	replace iso3c = "LAC" if who_region==2
	replace iso3n = 2000 if who_region==2

	rename age18 age
	rename dths death

	** keep if ghecause==100
	keep if ghecause==50
	keep if year==2000 | year==2019
	drop paho_subregion agroup 
	rename pop pop_orig
	collapse (sum) death (mean) pop = pop_orig , by(iso3c iso3n year age) 
	order iso3c iso3n year  
	bysort year iso3c : egen tpop = sum(pop)
	format tpop %15.0fc
	reshape wide death pop tpop , i(iso3c iso3n age) j(year)

** AS = age-structure
**  P = Population
**  R = Crude Rate 
**  D = Deaths

** METRIC 1. Population given the Age-Structure in 2000, rescaled for the population in 2019  
gen as2000_p2019 = (pop2000 / tpop2000) * tpop2019
format as2000_p2019 %15.1fc

** METRIC 2. Age-specific Mortality Rates in each year 
gen r2000 = death2000 / pop2000
gen r2019 = death2019 / pop2019

** METRIC 3. DEATHS, assuming:  
**	(a) age-stratified DEATHS assuming (POP in 2019 given AS in 2000) and (mortality rate in 2000)
gen d_p2019_as2000 = as2000_p2019 * (r2000)
**	(b) age-stratified DEATHS (POP in 2019 given AS in 2019) and (mortality rate in 2000)
gen d_p2019_as2019 = pop2019 * (r2000) 
format d_p2019_as2000 d_p2019_as2019 %15.1fc

** COLLAPSE OUT AGE - keeping 4 statistics
**		- d_p2019_as2000	Deaths | POP2019 and AS2000 and MR2000
**		- d_p2019_as2019	Deaths | POP2019 and AS2019 and MR2000
**		- deaths2000		Deaths | POP2000 and AS2000 and MR2000
**		- deaths2019		Deaths | POP2019 and AS2019 and MR2019
collapse (sum) d_* death2000 death2019, by(iso3c iso3n)
format d_* death2000 death2019 %15.1fc

** Percentage change in deaths between 2000 and 2019
gen ch_d = ((death2019 - death2000) / death2000) * 100


** Combined metrics of interest

** Percentage change due to population growth
gen ch_gr    = ((d_p2019_as2000 - death2000) / death2000) * 100
gen ch_as    = ((d_p2019_as2019 - d_p2019_as2000) / death2000) * 100
gen ch_epi   = (ch_d - ch_as - ch_gr) 
gen test_epi = ((death2019 - d_p2019_as2019) / death2000) * 100

** Further graph preparation
gen zero = 0 
gen realzero = 0

gen addage = ch_as  if ch_epi < 0  & ch_as > 0
gen basepop = 0 
replace basepop = ch_as if ch_as < 0
replace basepop = ch_epi + basepop if ch_epi > 0
replace addage = ch_as + ch_epi if ch_epi > 0 
replace addage = ch_epi if ch_epi > 0 & ch_as < 0
gen addpop = addage + ch_gr

format death* %15.0fc

** List the decompiosition by overall change in deaths
** IE same order as for graphic
		label define iso3n 2000 "THE AMERICAS", modify
		label values iso3n iso3n 
		gsort ch_d
		list iso3n ch_d ch_gr ch_as ch_epi, sep(5) line(120)


** Country names
drop if iso3c=="LAC"
gsort -ch_d
gen y1 = _n
decode iso3n, gen(cname)
labmask y1, val(cname)
#delimit ; 
label define y1         30 "St.Vincent & Gren"
                        14 "Antigua & Barbuda"
                        33 "Trinidad & Tobago"
                        1  "Dominican Rep", modify;
label values y1 y1; 
#delimit cr

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

** Column X-location for death metrics 
** Max of first panel = 144
gen xloc2 = 220
gen xloc3 = 310
gen pd = round(ch_d) 
gen ad = int(death2019 - death2000)
format ad %10.0fc

** Boxes around metrics
local box1 0.5 200 33.5 200 33.5 240 0.5 240
local box2 0.5 260 33.5 260 33.5 360 0.5 360

sort ch_d

#delimit ;
	graph twoway 
		/// Boxes around metrics
		(scatteri `box1'  , recast(area) lw(0.2) lc("gs13") fc("gs14") lp("l"))
		(scatteri `box2'  , recast(area) lw(0.2) lc("gs13") fc("gs14") lp("l"))

		///epi change
		(rbar zero ch_epi y1, horizontal barwidth(.75)  lc("`blu2'") lw(0.05) fc("`blu2'")) 
		/// Change in Population Size
		(rbar basepop addage y1 , horizontal barwidth(.75)  lc("`ora2'") lw(0.05) fc("`ora2'")) 
		/// Change in Population Age
		(rbar addage addpop y1 , horizontal barwidth(.75)  lc("`pur2'") lw(0.05) fc("`pur2'")) 
		/// Vertical Zero Line
		(line y1 realzero, lcolor(gs10) lp(l) lc(gs0%25)) 
		/// Overall Change point
		(scatter y1 ch_d, msymbol(O) mlcolor(gs10) mfcolor(gs16%80) msize(2))

		/// Percentage change in deaths
		(sc y1 xloc2, msymbol(i) mlabel(pd) mlabsize(2.5) mlabcol(gs8) mlabp(0))
		/// Actual change in numbers of deaths
		(sc y1 xloc3, msymbol(i) mlabel(ad) mlabsize(2.5) mlabcol(gs8) mlabp(0))

		,
		plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
		graphregion(c(gs16) ic(gs16) ilw(thin) lw(thin))
		ysize(15) xsize(10)
	
		xlabel(-50(50)200, labsize(2.5) nogrid labcolor(gs8))
		xscale(noextend) 
		xtitle(" ", margin(top) color(gs0) size(2.5)) 

		ylabel(
				33	"Trinidad & Tobago"
				32	"Uruguay"
				31	"Argentina"
				30	"St Vincent & Gren"
				29	"United States"
				28	"Canada"
				27	"Grenada"
				26	"Jamaica"
				25	"Barbados"
				24	"Saint Lucia"
				23	"Brazil"
				22	"Haiti"
				21	"Chile"
				20	"Cuba"
				19	"El Salvador"
				18	"Guyana"
				17	"Belize"
				16	"Costa Rica"
				15	"Colombia"
				14	"Antigua & Barbuda"
				13	"Venezuela"
				12	"Ecuador"
				11	"Peru"
				10	"Bahamas"
				9	"Suriname"
				8	"Mexico"
				7	"Guatemala"
				6	"Paraguay"
				5	"Bolivia"
				4	"Panama"
				3	"Nicaragua"
				2	"Honduras"
				1	"Dominican Rep"

		, notick grid valuelabel angle(0) labsize(2.5) labcolor(gs10)) 
		ytitle(" ", axis(1)) 
		yscale(noline range(1(1)35))

        text(-2.5 50 "Percent Change in Deaths" "2000-2019", place(c) size(2.5) color("gs8") just(center) margin(l=2 r=2 t=4 b=2))
        text(35 220 "Percent" "Change", place(c) size(2.5) color("gs8") just(center) margin(l=2 r=2 t=4 b=2))
        text(35 310 "Extra" "Deaths", place(c) size(2.5) color("gs8") just(center) margin(l=2 r=2 t=4 b=2))

		legend(order(7 3 4 5) keygap(2) rowgap(2) linegap(0.75)
		label(3 "Change due to age-" "specific mortality rates")  
		label(4 "Change due to" "population aging") 
		label(5 "Change due to" "population growth") 
		label(7 "Change in deaths") 
		cols(2) position(6) size(2.5) symysize(3) color(gs8)
		) 
		name(fig3_dth)
	;
#delimit cr






** -----------------------------------------------
** 2. DALY
** -----------------------------------------------

** Load the country-level daly and population data
** This comes from:
**	--> C:\Sync\OneDrive - The University of the West Indies\repo_ianhambleton\repo_w003\chap2-000g-daly-country-groups.do
use "`datapath'\from-who\paper1-chap3_byage_country_groups_both_daly", clear
	append using "`datapath'\from-who\paper1-chap3_byage_groups_both_daly"
	keep if who_region==. | who_region==2
	replace iso3c = "LAC" if who_region==2
	replace iso3n = 2000 if who_region==2

	rename age18 age

	** keep if ghecause==100
	keep if ghecause==50
	keep if year==2000 | year==2019
	drop paho_subregion agroup 
	rename pop pop_orig
	collapse (sum) daly (mean) pop = pop_orig , by(iso3c iso3n year age) 
	order iso3c iso3n year  
	bysort year iso3c : egen tpop = sum(pop)
	format tpop %15.0fc
	reshape wide daly pop tpop , i(iso3c iso3n age) j(year)

** AS = age-structure
**  P = Population
**  R = Crude Rate 
**  D = dalys

** METRIC 1. Population given the Age-Structure in 2000, rescaled for the population in 2019  
gen as2000_p2019 = (pop2000 / tpop2000) * tpop2019
format as2000_p2019 %15.1fc

** METRIC 2. Age-specific Mortality Rates in each year 
gen r2000 = daly2000 / pop2000
gen r2019 = daly2019 / pop2019

** METRIC 3. dalyS, assuming:  
**	(a) age-stratified dalyS assuming (POP in 2019 given AS in 2000) and (mortality rate in 2000)
gen d_p2019_as2000 = as2000_p2019 * (r2000)
**	(b) age-stratified dalyS (POP in 2019 given AS in 2019) and (mortality rate in 2000)
gen d_p2019_as2019 = pop2019 * (r2000) 
format d_p2019_as2000 d_p2019_as2019 %15.1fc

** COLLAPSE OUT AGE - keeping 4 statistics
**		- d_p2019_as2000	dalys | POP2019 and AS2000 and MR2000
**		- d_p2019_as2019	dalys | POP2019 and AS2019 and MR2000
**		- dalys2000		dalys | POP2000 and AS2000 and MR2000
**		- dalys2019		dalys | POP2019 and AS2019 and MR2019
collapse (sum) d_* daly2000 daly2019, by(iso3c iso3n)
format d_* daly2000 daly2019 %15.1fc

** Percentage change in dalys between 2000 and 2019
gen ch_d = ((daly2019 - daly2000) / daly2000) * 100


** Combined metrics of interest

** Percentage change due to population growth
gen ch_gr    = ((d_p2019_as2000 - daly2000) / daly2000) * 100
gen ch_as    = ((d_p2019_as2019 - d_p2019_as2000) / daly2000) * 100
gen ch_epi   = (ch_d - ch_as - ch_gr) 
gen test_epi = ((daly2019 - d_p2019_as2019) / daly2000) * 100

** Further graph preparation
gen zero = 0 
gen realzero = 0

gen addage = ch_as  if ch_epi < 0  & ch_as > 0
gen basepop = 0 
replace basepop = ch_as if ch_as < 0
replace basepop = ch_epi + basepop if ch_epi > 0
replace addage = ch_as + ch_epi if ch_epi > 0 
replace addage = ch_epi if ch_epi > 0 & ch_as < 0
gen addpop = addage + ch_gr

format daly* %15.0fc

** List the decompiosition by overall change in deaths
** IE same order as for graphic
		label define iso3n 2000 "THE AMERICAS", modify
		label values iso3n iso3n 
		gsort ch_d
		list iso3n ch_d ch_gr ch_as ch_epi, sep(5) line(120)

** Country names
drop if iso3c=="LAC"
gsort -ch_d
gen y1 = _n
decode iso3n, gen(cname)
labmask y1, val(cname)
#delimit ; 
label define y1         30 "St.Vincent & Gren"
                        14 "Antigua & Barbuda"
                        33 "Trinidad & Tobago"
                        1  "Dominican Rep", modify;
label values y1 y1; 
#delimit cr

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

** Column X-location for daly metrics 
** Max of first panel = 144
gen xloc2 = 220
gen xloc3 = 310
gen pd = round(ch_d) 
gen ad = int(daly2019 - daly2000)
format ad %10.0fc

** Boxes around metrics
local box1 0.5 200 33.5 200 33.5 240 0.5 240
local box2 0.5 260 33.5 260 33.5 360 0.5 360


#delimit ;
	graph twoway 
		/// Boxes around metrics
		(scatteri `box1'  , recast(area) lw(0.2) lc("gs13") fc("gs14") lp("l"))
		(scatteri `box2'  , recast(area) lw(0.2) lc("gs13") fc("gs14") lp("l"))

		///epi change
		(rbar zero ch_epi y1, horizontal barwidth(.75)  lc("`blu2'") lw(0.05) fc("`blu2'")) 
		/// Change in Population Size
		(rbar basepop addage y1 , horizontal barwidth(.75)  lc("`ora2'") lw(0.05) fc("`ora2'")) 
		/// Change in Population Age
		(rbar addage addpop y1 , horizontal barwidth(.75)  lc("`pur2'") lw(0.05) fc("`pur2'")) 
		/// Vertical Zero Line
		(line y1 realzero, lcolor(gs10) lp(l) lc(gs0%25)) 
		/// Overall Change point
		(scatter y1 ch_d, msymbol(O) mlcolor(gs10) mfcolor(gs16%80) msize(2))

		/// Percentage change in dalys
		(sc y1 xloc2, msymbol(i) mlabel(pd) mlabsize(2.5) mlabcol(gs8) mlabp(0))
		/// Actual change in numbers of dalys
		(sc y1 xloc3, msymbol(i) mlabel(ad) mlabsize(2.5) mlabcol(gs8) mlabp(0))

		,
		plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
		graphregion(c(gs16) ic(gs16) ilw(thin) lw(thin))
		ysize(15) xsize(10)
	
		xlabel(-50(50)200, labsize(2.5) nogrid labcolor(gs8))
		xscale(noextend) 
		xtitle(" ", margin(top) color(gs0) size(2.5)) 

		ylabel(
				33	"Uruguay"
				32	"Trinidad & Tobago"
				31	"Argentina"
				30	"Grenada"
				29	"Canada"
				28	"El Salvador"
				27	"United States"
				26	"St Vincent & Gren"
				25	"Barbados"
				24	"Cuba"
				23	"Brazil"
				22	"Jamaica"
				21	"Guyana"
				20	"Chile"
				19	"Colombia"
				18	"Haiti"
				17	"Peru"
				16	"Venezuela"
				15	"Saint Lucia"
				14	"Bolivia"
				13	"Costa Rica"
				12	"Ecuador"
				11	"Antigua & Barbuda"
				10	"Suriname"
				9	"Guatemala"
				8	"Nicaragua"
				7	"Paraguay"
				6	"Mexico"
				5	"Belize"
				4	"Panama"
				3	"Bahamas"
				2	"Honduras"
				1	"Dominican Rep"
		, notick grid valuelabel angle(0) labsize(2.5) labcolor(gs10)) 
		ytitle(" ", axis(1)) 
		yscale(noline range(1(1)35))

        text(-2.5 50 "Percent Change in DALYs" "2000-2019", place(c) size(2.5) color("gs8") just(center) margin(l=2 r=2 t=4 b=2))
        text(35 220 "Percent" "Change", place(c) size(2.5) color("gs8") just(center) margin(l=2 r=2 t=4 b=2))
        text(35 310 "Extra" "DALYs", place(c) size(2.5) color("gs8") just(center) margin(l=2 r=2 t=4 b=2))

		legend(order(7 3 4 5) keygap(2) rowgap(2) linegap(0.75)
		label(3 "Change due to age-" "specific DALY rates")  
		label(4 "Change due to" "population aging") 
		label(5 "Change due to" "population growth") 
		label(7 "Change in DALYs") 
		cols(2) position(6) size(2.5) symysize(3) color(gs8)
		) 
		name(fig3_daly)
	;
#delimit cr







** -----------------------------------------------
** 3. YLL
** -----------------------------------------------

** Load the country-level yll and population data
** This comes from:
**	--> C:\Sync\OneDrive - The University of the West Indies\repo_ianhambleton\repo_w003\chap2-000r-yll-country-groups.do
use "`datapath'\from-who\paper1-chap3_byage_country_groups_both_yll", clear
	append using "`datapath'\from-who\paper1-chap3_byage_groups_both_yll"
	keep if who_region==. | who_region==2
	replace iso3c = "LAC" if who_region==2
	replace iso3n = 2000 if who_region==2

	rename age18 age

	** keep if ghecause==100
	keep if ghecause==50
	keep if year==2000 | year==2019
	drop paho_subregion agroup 
	rename pop pop_orig
	collapse (sum) yll (mean) pop = pop_orig , by(iso3c iso3n year age) 
	order iso3c iso3n year  
	bysort year iso3c : egen tpop = sum(pop)
	format tpop %15.0fc
	reshape wide yll pop tpop , i(iso3c iso3n age) j(year)

** AS = age-structure
**  P = Population
**  R = Crude Rate 
**  D = ylls

** METRIC 1. Population given the Age-Structure in 2000, rescaled for the population in 2019  
gen as2000_p2019 = (pop2000 / tpop2000) * tpop2019
format as2000_p2019 %15.1fc

** METRIC 2. Age-specific Mortality Rates in each year 
gen r2000 = yll2000 / pop2000
gen r2019 = yll2019 / pop2019

** METRIC 3. yll, assuming:  
**	(a) age-stratified yllS assuming (POP in 2019 given AS in 2000) and (mortality rate in 2000)
gen d_p2019_as2000 = as2000_p2019 * (r2000)
**	(b) age-stratified yllS (POP in 2019 given AS in 2019) and (mortality rate in 2000)
gen d_p2019_as2019 = pop2019 * (r2000) 
format d_p2019_as2000 d_p2019_as2019 %15.1fc

** COLLAPSE OUT AGE - keeping 4 statistics
**		- d_p2019_as2000	ylls | POP2019 and AS2000 and MR2000
**		- d_p2019_as2019	ylls | POP2019 and AS2019 and MR2000
**		- ylls2000		ylls | POP2000 and AS2000 and MR2000
**		- ylls2019		ylls | POP2019 and AS2019 and MR2019
collapse (sum) d_* yll2000 yll2019, by(iso3c iso3n)
format d_* yll2000 yll2019 %15.1fc

** Percentage change in ylls between 2000 and 2019
gen ch_d = ((yll2019 - yll2000) / yll2000) * 100


** Combined metrics of interest

** Percentage change due to population growth
gen ch_gr    = ((d_p2019_as2000 - yll2000) / yll2000) * 100
gen ch_as    = ((d_p2019_as2019 - d_p2019_as2000) / yll2000) * 100
gen ch_epi   = (ch_d - ch_as - ch_gr) 
gen test_epi = ((yll2019 - d_p2019_as2019) / yll2000) * 100

** Further graph preparation
gen zero = 0 
gen realzero = 0

gen addage = ch_as  if ch_epi < 0  & ch_as > 0
gen basepop = 0 
replace basepop = ch_as if ch_as < 0
replace basepop = ch_epi + basepop if ch_epi > 0
replace addage = ch_as + ch_epi if ch_epi > 0 
replace addage = ch_epi if ch_epi > 0 & ch_as < 0
gen addpop = addage + ch_gr

format yll* %15.0fc

** List the decompiosition by overall change in deaths
** IE same order as for graphic
		label define iso3n 2000 "THE AMERICAS", modify
		label values iso3n iso3n 
		gsort ch_d
		list iso3n ch_d ch_gr ch_as ch_epi, sep(5) line(120)

** Country names
drop if iso3c=="LAC"
gsort -ch_d
gen y1 = _n
decode iso3n, gen(cname)
labmask y1, val(cname)
#delimit ; 
label define y1         30 "St.Vincent & Gren"
                        14 "Antigua & Barbuda"
                        33 "Trinidad & Tobago"
                        1  "Dominican Rep", modify;
label values y1 y1; 
#delimit cr

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

** Column X-location for yll metrics 
** Max of first panel = 144
gen xloc2 = 220
gen xloc3 = 310
gen pd = round(ch_d) 
gen ad = int(yll2019 - yll2000)
format ad %10.0fc

** Boxes around metrics
local box1 0.5 200 33.5 200 33.5 240 0.5 240
local box2 0.5 260 33.5 260 33.5 360 0.5 360


#delimit ;
	graph twoway 
		/// Boxes around metrics
		(scatteri `box1'  , recast(area) lw(0.2) lc("gs13") fc("gs14") lp("l"))
		(scatteri `box2'  , recast(area) lw(0.2) lc("gs13") fc("gs14") lp("l"))

		///epi change
		(rbar zero ch_epi y1, horizontal barwidth(.75)  lc("`blu2'") lw(0.05) fc("`blu2'")) 
		/// Change in Population Size
		(rbar basepop addage y1 , horizontal barwidth(.75)  lc("`ora2'") lw(0.05) fc("`ora2'")) 
		/// Change in Population Age
		(rbar addage addpop y1 , horizontal barwidth(.75)  lc("`pur2'") lw(0.05) fc("`pur2'")) 
		/// Vertical Zero Line
		(line y1 realzero, lcolor(gs10) lp(l) lc(gs0%25)) 
		/// Overall Change point
		(scatter y1 ch_d, msymbol(O) mlcolor(gs10) mfcolor(gs16%80) msize(2))

		/// Percentage change in ylls
		(sc y1 xloc2, msymbol(i) mlabel(pd) mlabsize(2.5) mlabcol(gs8) mlabp(0))
		/// Actual change in numbers of ylls
		(sc y1 xloc3, msymbol(i) mlabel(ad) mlabsize(2.5) mlabcol(gs8) mlabp(0))

		,
		plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
		graphregion(c(gs16) ic(gs16) ilw(thin) lw(thin))
		ysize(15) xsize(10)
	
		xlabel(-50(50)200, labsize(2.5) nogrid labcolor(gs8))
		xscale(noextend) 
		xtitle(" ", margin(top) color(gs0) size(2.5)) 

		ylabel(
				33	"Trinidad & Tobago"
				32	"Uruguay"
				31	"Argentina"
				30	"Canada"
				29	"United States"
				28	"Grenada"
				27	"El Salvador"
				26	"St Vincent & Gren"
				25	"Brazil"
				24	"Barbados"
				23	"Chile"
				22	"Jamaica"
				21	"Colombia"
				20	"Haiti"
				19	"Cuba"
				18	"Guyana"
				17	"Peru"
				16	"Venezuela"
				15	"St Lucia"
				14	"Bolivia"
				13	"Costa Rica"
				12	"Ecuador"
				11	"Guatemala"
				10	"Belize"
				9	"Antigua & Barbuda"
				8	"Suriname"
				7	"Mexico"
				6	"Paraguay"
				5	"Panama"
				4	"Nicaragua"
				3	"Honduras"
				2	"Bahamas"
				1	"Dominican Rep"
		, notick grid valuelabel angle(0) labsize(2.5) labcolor(gs10)) 
		ytitle(" ", axis(1)) 
		yscale(noline range(1(1)35))

        text(-2.5 50 "Percent Change in YLLs" "2000-2019", place(c) size(2.5) color("gs8") just(center) margin(l=2 r=2 t=4 b=2))
        text(35 220 "Percent" "Change", place(c) size(2.5) color("gs8") just(center) margin(l=2 r=2 t=4 b=2))
        text(35 310 "Extra" "YLLs", place(c) size(2.5) color("gs8") just(center) margin(l=2 r=2 t=4 b=2))

		legend(order(7 3 4 5) keygap(2) rowgap(2) linegap(0.75)
		label(3 "Change due to age-" "specific YLL rates")  
		label(4 "Change due to" "population aging") 
		label(5 "Change due to" "population growth") 
		label(7 "Change in YLLs") 
		cols(2) position(6) size(2.5) symysize(3) color(gs8)
		) 
		name(fig3_yll)
	;
#delimit cr





** -----------------------------------------------
** 4. YLD
** -----------------------------------------------

** Load the country-level yld and population data
** This comes from:
**	--> C:\Sync\OneDrive - The University of the West Indies\repo_ianhambleton\repo_w003\chap2-000m-yld-country-groups.do
use "`datapath'\from-who\paper1-chap3_byage_country_groups_both_yld", clear
	append using "`datapath'\from-who\paper1-chap3_byage_groups_both_yld"
	keep if who_region==. | who_region==2
	replace iso3c = "LAC" if who_region==2
	replace iso3n = 2000 if who_region==2

	rename age18 age

	** keep if ghecause==100
	keep if ghecause==50
	keep if year==2000 | year==2019
	drop paho_subregion agroup 
	rename pop pop_orig
	collapse (sum) yld (mean) pop = pop_orig , by(iso3c iso3n year age) 
	order iso3c iso3n year  
	bysort year iso3c : egen tpop = sum(pop)
	format tpop %15.0fc
	reshape wide yld pop tpop , i(iso3c iso3n age) j(year)

** AS = age-structure
**  P = Population
**  R = Crude Rate 
**  D = ylds

** METRIC 1. Population given the Age-Structure in 2000, rescaled for the population in 2019  
gen as2000_p2019 = (pop2000 / tpop2000) * tpop2019
format as2000_p2019 %15.1fc

** METRIC 2. Age-specific Mortality Rates in each year 
gen r2000 = yld2000 / pop2000
gen r2019 = yld2019 / pop2019

** METRIC 3. yld, assuming:  
**	(a) age-stratified yldS assuming (POP in 2019 given AS in 2000) and (mortality rate in 2000)
gen d_p2019_as2000 = as2000_p2019 * (r2000)
**	(b) age-stratified yldS (POP in 2019 given AS in 2019) and (mortality rate in 2000)
gen d_p2019_as2019 = pop2019 * (r2000) 
format d_p2019_as2000 d_p2019_as2019 %15.1fc

** COLLAPSE OUT AGE - keeping 4 statistics
**		- d_p2019_as2000	ylds | POP2019 and AS2000 and MR2000
**		- d_p2019_as2019	ylds | POP2019 and AS2019 and MR2000
**		- ylds2000		ylds | POP2000 and AS2000 and MR2000
**		- ylds2019		ylds | POP2019 and AS2019 and MR2019
collapse (sum) d_* yld2000 yld2019, by(iso3c iso3n)
format d_* yld2000 yld2019 %15.1fc

** Percentage change in ylds between 2000 and 2019
gen ch_d = ((yld2019 - yld2000) / yld2000) * 100


** Combined metrics of interest

** Percentage change due to population growth
gen ch_gr    = ((d_p2019_as2000 - yld2000) / yld2000) * 100
gen ch_as    = ((d_p2019_as2019 - d_p2019_as2000) / yld2000) * 100
gen ch_epi   = (ch_d - ch_as - ch_gr) 
gen test_epi = ((yld2019 - d_p2019_as2019) / yld2000) * 100

** Further graph preparation
gen zero = 0 
gen realzero = 0

gen addage = ch_as  if ch_epi < 0  & ch_as > 0
gen basepop = 0 
replace basepop = ch_as if ch_as < 0
replace basepop = ch_epi + basepop if ch_epi > 0
replace addage = ch_as + ch_epi if ch_epi > 0 
replace addage = ch_epi if ch_epi > 0 & ch_as < 0
gen addpop = addage + ch_gr

format yld* %15.0fc

** List the decompiosition by overall change in deaths
** IE same order as for graphic
		label define iso3n 2000 "THE AMERICAS", modify
		label values iso3n iso3n 
		gsort ch_d
		list iso3n ch_d ch_gr ch_as ch_epi, sep(5) line(120)

** Country names
drop if iso3c=="LAC"
gsort -ch_d
gen y1 = _n
decode iso3n, gen(cname)
labmask y1, val(cname)
#delimit ; 
label define y1         30 "St.Vincent & Gren"
                        14 "Antigua & Barbuda"
                        33 "Trinidad & Tobago"
                        1  "Dominican Rep", modify;
label values y1 y1; 
#delimit cr

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

** Column X-location for yld metrics 
** Max of first panel = 144
gen xloc2 = 220
gen xloc3 = 310
gen pd = round(ch_d) 
gen ad = int(yld2019 - yld2000)
format ad %10.0fc

** Boxes around metrics
local box1 0.5 200 33.5 200 33.5 240 0.5 240
local box2 0.5 260 33.5 260 33.5 360 0.5 360


#delimit ;
	graph twoway 
		/// Boxes around metrics
		(scatteri `box1'  , recast(area) lw(0.2) lc("gs13") fc("gs14") lp("l"))
		(scatteri `box2'  , recast(area) lw(0.2) lc("gs13") fc("gs14") lp("l"))

		///epi change
		(rbar zero ch_epi y1, horizontal barwidth(.75)  lc("`blu2'") lw(0.05) fc("`blu2'")) 
		/// Change in Population Size
		(rbar basepop addage y1 , horizontal barwidth(.75)  lc("`ora2'") lw(0.05) fc("`ora2'")) 
		/// Change in Population Age
		(rbar addage addpop y1 , horizontal barwidth(.75)  lc("`pur2'") lw(0.05) fc("`pur2'")) 
		/// Vertical Zero Line
		(line y1 realzero, lcolor(gs10) lp(l) lc(gs0%25)) 
		/// Overall Change point
		(scatter y1 ch_d, msymbol(O) mlcolor(gs10) mfcolor(gs16%80) msize(2))

		/// Percentage change in ylds
		(sc y1 xloc2, msymbol(i) mlabel(pd) mlabsize(2.5) mlabcol(gs8) mlabp(0))
		/// Actual change in numbers of ylds
		(sc y1 xloc3, msymbol(i) mlabel(ad) mlabsize(2.5) mlabcol(gs8) mlabp(0))

		,
		plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
		graphregion(c(gs16) ic(gs16) ilw(thin) lw(thin))
		ysize(15) xsize(10)
	
		xlabel(-50(50)200, labsize(2.5) nogrid labcolor(gs8))
		xscale(noextend) 
		xtitle(" ", margin(top) color(gs0) size(2.5)) 

		ylabel(
				33	"Cuba"
				32	"Uruguay"
				31	"Barbados"
				30	"Guyana"
				29	"El Salvador"
				28	"St Vincent & Gren"
				27	"Argentina"
				26	"Jamaica"
				25	"Grenada"
				24	"Trinidad & Tobago"
				23	"Brazil"
				22	"Peru"
				21	"United States"
				20	"Venezuela"
				19	"Chile"
				18	"Colombia"
				17	"Canada"
				16	"St Lucia"
				15	"Suriname"
				14	"Haiti"
				13	"Bolivia"
				12	"Antigua & Barbuda"
				11	"Nicaragua"
				10	"Dominican Rep"
				9	"Bahamas"
				8	"Ecuador"
				7	"Costa Rica"
				6	"Paraguay"
				5	"Mexico"
				4	"Panama"
				3	"Guatemala"
				2	"Honduras"
				1	"Belize"

		, notick grid valuelabel angle(0) labsize(2.5) labcolor(gs10)) 
		ytitle(" ", axis(1)) 
		yscale(noline range(1(1)35))

        text(-2.5 50 "Percent Change in ylds" "2000-2019", place(c) size(2.5) color("gs8") just(center) margin(l=2 r=2 t=4 b=2))
        text(35 220 "Percent" "Change", place(c) size(2.5) color("gs8") just(center) margin(l=2 r=2 t=4 b=2))
        text(35 310 "Extra" "ylds", place(c) size(2.5) color("gs8") just(center) margin(l=2 r=2 t=4 b=2))

		legend(order(7 3 4 5) keygap(2) rowgap(2) linegap(0.75)
		label(3 "Change due to age-" "specific yld rates")  
		label(4 "Change due to" "population aging") 
		label(5 "Change due to" "population growth") 
		label(7 "Change in ylds") 
		cols(2) position(6) size(2.5) symysize(3) color(gs8)
		) 
		name(fig3_yld)
	;
#delimit cr

