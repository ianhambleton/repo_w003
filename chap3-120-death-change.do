** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap3-120-death-change.do
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
    log using "`logpath'\chap3-120-death-change", replace
** HEADER -----------------------------------------------------

** Load the country-level death and population data
** This comes from:
**	--> C:\Sync\OneDrive - The University of the West Indies\repo_ianhambleton\repo_w003\chap2-000c-mr-country-groups.do
use "`datapath'\from-who\chap3_byage_country_groups_both", clear
	append using "`datapath'\from-who\chap3_byage_groups_both"
	keep if who_region==. | who_region==2
	replace iso3c = "LAC" if who_region==2
	replace iso3n = 2000 if who_region==2

	rename age18 age
	rename dths death
	
	** keep if ghecause==100
	keep if ghecause==300 | ghecause==1000
	keep if year==2000 | year==2019
	drop paho_subregion agroup deaths
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
gen xloc2 = 180
gen xloc3 = 260
gen pd = round(ch_d) 
gen ad = int(death2019 - death2000)
format ad %10.0fc

** Boxes around metrics
local box1 0.5 160 33.5 160 33.5 200 0.5 200
local box2 0.5 230 33.5 230 33.5 290 0.5 290

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
		(scatter y1 , msymbol(O) mlcolor(gs10) mfcolor(gs16%80) msize(2))

		/// Percentage change in deaths
		(sc y1 xloc2, msymbol(i) mlabel(pd) mlabsize(2.5) mlabcol(gs8) mlabp(0))
		/// Actual change in numbers of deaths
		(sc y1 xloc3, msymbol(i) mlabel(ad) mlabsize(2.5) mlabcol(gs8) mlabp(0))

		,
		plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
		graphregion(c(gs16) ic(gs16) ilw(thin) lw(thin))
		ysize(15) xsize(10)
	
		xlabel(-50(50)150, labsize(2.5) nogrid labcolor(gs8))
		xscale(noextend) 
		xtitle(" ", margin(top) color(gs0) size(2.5)) 

		ylabel(
			33	"Trinidad & Tobago"
			32	"Uruguay"
			31	"Argentina"
			30	"St.Vincent & Gren"
			29	"United States"
			28	"Jamaica"
			27	"Canada"
			26	"Colombia"
			25	"Grenada"
			24	"Barbados"
			23	"Haiti"
			22	"El Salvador"
			21	"Cuba"
			20	"Chile"
			19	"St.Lucia"
			18	"Brazil"
			17	"Guyana"
			16	"Peru"
			15	"Ecuador"
			14	"Antigua & Barbuda"
			13	"Belize"
			12	"Venezuela"
			11	"Costa Rica"
			10	"Suriname"
			9	"Bolivia"
			8	"Mexico"
			7	"Panama"
			6	"Guatemala"
			5	"Bahamas"
			4	"Paraguay"
			3	"Nicaragua"
			2	"Honduras"
			1	"Dominican Rep"
		, notick grid valuelabel angle(0) labsize(2.5) labcolor(gs10)) 
		ytitle(" ", axis(1)) 
		yscale(noline range(1(1)35))

        text(-2.5 50 "Percent Change in Deaths" "2000-2019", place(c) size(2.5) color("gs8") just(center) margin(l=2 r=2 t=4 b=2))
        text(35 180 "Percent" "Change", place(c) size(2.5) color("gs8") just(center) margin(l=2 r=2 t=4 b=2))
        text(35 260 "Extra" "Deaths", place(c) size(2.5) color("gs8") just(center) margin(l=2 r=2 t=4 b=2))

		legend(order(7 3 4 5) keygap(2) rowgap(2) linegap(0.75)
		label(3 "Change due to age-" "specific mortality rates")  
		label(4 "Change due to" "population aging") 
		label(5 "Change due to" "population growth") 
		label(7 "Change in deaths") 
		cols(2) position(6) size(2.5) symysize(3) color(gs8)
		) 
	;
#delimit cr
