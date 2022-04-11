** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    paper1-130-population-figure2.do
    //  project:				    UN WPP (2019 edition)
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	24-Mar-2022
    //  algorithm task			    Importing the UN WPP data for the Americas

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
    log using "`logpath'\paper1-130-population-figure2", replace
** HEADER -----------------------------------------------------

** Load population file from: 
**      paper1-110-population.do 
use "`datapath'/paper1_population2", clear

** Keep required years:
keep if year==1980 | year==2020 | year==2060 
** UN region
gen region = 1
label define region_ 1 "Americas"
label values region region_ 
order region, after(iso3n)

** Collapse into PAHO sub-regions
preserve
    tempfile sr_totals
    collapse (sum) a0 a5 a10 a15 a20 a25 a30 a35 a40 a45 a50 a55 a60 a65 a70 a75 a80 a85 a90 a95 a100, by(paho_subregion year sex)
    save `sr_totals', replace
restore

** Collapse into AMERICAS region
preserve
    tempfile r_totals
    collapse (sum) a0 a5 a10 a15 a20 a25 a30 a35 a40 a45 a50 a55 a60 a65 a70 a75 a80 a85 a90 a95 a100, by(region year sex)
    save `r_totals', replace
restore

** Join sbregional and regional files to country files
append using `sr_totals'
append using `r_totals'

** Calculate age-group percentages
egen group1 = rowtotal(a0 a5 a10 a15) 
egen group2 = rowtotal(a20 a25 a30 a35 a40 a45 a50 a55 a60 a65) 
egen group3 = rowtotal(a70 a75 a80 a85 a90 a95 a100) 
egen total = rowtotal(a0 a5 a10 a15 a20 a25 a30 a35 a40 a45 a50 a55 a60 a65 a70 a75 a80 a85 a90 a95 a100) 
label var group1 "Ages 0-19"
label var group2 "Ages 20-69"
label var group3 "Ages 70+"
label var total "Total across all ages"
format group1 group2 group3 total %15.0fc
gen pg1 = (group1/total) 
gen pg2 = (group2/total) 
gen pg3 = (group3/total) 
label var pg1 "Proportion 0-19"
label var pg2 "Proportion 20-69"
label var pg3 "Proportion 70+"
keep iso3n region paho_subregion sex year group1 group2 group3 total pg1 pg2 pg3
sort paho_subregion sex year

** Keep women and men combined
keep if sex==3 

** Generate unique code by country - alphabetically
keep if iso3n<.
decode iso3n, gen(country)
order country, after(iso3n)
sort country year 
egen uid = group(country)
order uid
replace uid = 34 if paho_subregion==1 & iso3n==.
replace uid = 35 if paho_subregion==2 & iso3n==.
replace uid = 36 if paho_subregion==3 & iso3n==.
replace uid = 37 if paho_subregion==4 & iso3n==.
replace uid = 38 if paho_subregion==5 & iso3n==.
replace uid = 39 if paho_subregion==6 & iso3n==.
replace uid = 40 if paho_subregion==7 & iso3n==.
replace uid = 41 if paho_subregion==8 & iso3n==.
replace uid = 42 if region==1 & iso3n==.
labmask uid, values(iso3n) lblname(uid_) decode
#delimit ;
label define uid_   34 "NORTH AMERICA"
                    35 "CENTRAL AMERICA" 
                    36 "ANDEAN AREA"
                    37 "SOUTHERN CONE"
                    38 "LATIN CARIBBEAN"
                    39 "NON-LATIN CARIBBEAN"
                    40 "BRAZIL"
                    41 "MEXICO"
                    42 "AMERICAS", modify ;
#delimit cr
label values uid uid_

/// ** New code for looping through Regions, then subregions, then countries
/// gen uid1 = 1 if uid==42
/// ** North America (Canada, USA)
/// replace uid1 = 2 if uid==34
/// replace uid1 = 3 if uid==8
/// replace uid1 = 4 if uid==31
/// ** Central America (BLZ, CRI, SLV, GTM, HND, NIC PAN)
/// replace uid1 = 5 if uid==35
/// replace uid1 = 6 if uid==5
/// replace uid1 = 7 if uid==11
/// replace uid1 = 8 if uid==15
/// replace uid1 = 9 if uid==17
/// replace uid1 = 10 if uid==20
/// replace uid1 = 11 if uid==23
/// replace uid1 = 12 if uid==24
/// ** Andean Area (BOL, COL, ECU, PER, VEN)
/// replace uid1 = 13 if uid==36
/// replace uid1 = 14 if uid==6
/// replace uid1 = 15 if uid==10
/// replace uid1 = 16 if uid==14
/// replace uid1 = 17 if uid==26
/// replace uid1 = 18 if uid==33
/// ** Southern Cone (ARG, CHL, PRY, URY)
/// replace uid1 = 19 if uid==37
/// replace uid1 = 20 if uid==2
/// replace uid1 = 21 if uid==9
/// replace uid1 = 22 if uid==25
/// replace uid1 = 23 if uid==32
/// ** Latin Caribbean (CUB, DOM, HTI)
/// replace uid1 = 24 if uid==38
/// replace uid1 = 25 if uid==12
/// replace uid1 = 26 if uid==13
/// replace uid1 = 27 if uid==19
/// ** non-Latin Caribbean (ATG, BHS, BRB, GRD, GUY, JAM, LCA, VCT, SUR, TTO)
/// replace uid1 = 28 if uid==39
/// replace uid1 = 29 if uid==1
/// replace uid1 = 30 if uid==3
/// replace uid1 = 31 if uid==4
/// replace uid1 = 32 if uid==16
/// replace uid1 = 33 if uid==18
/// replace uid1 = 34 if uid==21
/// replace uid1 = 35 if uid==27
/// replace uid1 = 36 if uid==28
/// replace uid1 = 37 if uid==29
/// replace uid1 = 38 if uid==30
/// ** Brazil / Mexico
/// replace uid1 = 39 if uid==7
/// replace uid1 = 40 if uid==22
/// order uid1, after(uid) 
/// labmask uid1, values(uid) lblname(uid1_) decode
/// decode uid1, gen(country1)
/// order country1, after(country)

** Metrics for Table
** (1) Country
** (2) Population
** (3) Percent change 70+ between 2000 and 2019
** (4) Annual growth rate of Older adults
** (5) Dependency Ratio
gsort uid -year
gen pc1 = ( group3[_n] - group3[_n-1] ) / total[_n-1] if paho_subregion[_n] == paho_subregion[_n-1] 
** Growth rate all ages
gen gr = round( ( ( ln(total[_n-1] / total[_n]) ) / 19 ) * 100 , 0.01)  if uid[_n] == uid[_n-1] 
** Growth rate older adults (70+)
gen gr3 = round( ( ( ln(group3[_n-1] / group3[_n]) ) / 19 ) * 100 , 0.01)  if uid[_n] == uid[_n-1] 
** Old Age Dependency Ratio: Ratio of people aged 70+ per 100 people aged 20-69
gen dratio = (group3 / group2) * 100

** Keep dependency ratio and reshape to wide for graphic
keep uid iso3n country paho_subregion year dratio
reshape wide dratio , i(uid iso3n country paho_subregion) j(year)

** Only keep the 33 countries AND The Americas in total
keep if iso3n<900 | iso3n==904
drop uid

** Generate order based on size of dependency ratio
sort dratio2020
gen uid1 = _n
replace uid1 = uid1 + 1 if uid1>=7
replace uid1 = uid1 + 1 if uid1>=15 
replace uid1 = uid1 + 1 if uid1>=23 
replace uid1 = uid1 + 1 if uid1>=31 
sort dratio2020
replace country = "St Vincent & Gren" if country=="Saint Vincent and the Grenadines"
replace country = "Antigua & Barbuda" if country=="Antigua and Barbuda"
replace country = "Trinidad & Tobago" if country=="Trinidad and Tobago"
replace country = "Dominican Rep" if country=="Dominican Republic"
labmask uid1, values(country) lblname(uid1_)
label define uid1_ 26 "THE AMERICAS" , modify
label values uid1 uid1_ 

** Dependency ratio in 2060 as global macros for graphic
    forval c = 1(1)38 {   
            preserve
                keep if uid1==`c'
                ** (3) Percent 70+
                local dr_`c'_1980 = dratio1980
                local dr_`c'_2020 = dratio2020
                local dr_`c'_2060 = dratio2060
                global dr_`c'_1980 : dis %5.1f `dr_`c'_1980'
                global dr_`c'_2020 : dis %5.1f `dr_`c'_2020'
                global dr_`c'_2060 : dis %5.1f `dr_`c'_2060'

            restore
    }

** COLORS - PURPLES for CVD
    colorpalette hcl, purples nograph n(14)
    local list r(p) 
    ** Dependency ratio at three time points
    local dr2060 `r(p3)'    
    local dr2020 `r(p6)'    
    local dr1980 `r(p9)'     

    colorpalette hcl, reds nograph n(14)
    local list r(p) 
    ** Dependency ratio at three time points
    local red1 `r(p3)'    
    local red2 `r(p6)'    
    local red3 `r(p9)' 

colorpalette d3, 20c nograph
    local list r(p) 
    ** Dependency ratio at three time points
    local blu1 `r(p1)'    
    local blu2 `r(p2)'
    local blu3 `r(p3)'
    local blu4 `r(p4)'

    local ora1 `r(p5)'    
    local ora2 `r(p6)'    
    local ora3 `r(p7)'    
    local ora4 `r(p8)'    

    local pur1 `r(p13)'    
    local pur2 `r(p14)'    
    local pur3 `r(p15)'    
    local pur4 `r(p16)'    

    local gry1 `r(p17)'    
    local gry2 `r(p18)'    
    local gry3 `r(p19)'    
    local gry4 `r(p20)'    


** ASSOCIATED STATISTICS FOR RESULTS TEXT

    ** Dependency ratio at each time point (1980, 2020, 2060)
preserve
    keep if iso3n<900
        sort dratio1980
        format dratio1980 %9.1f
        list uid dratio1980 if uid<=33, sep(5) line(120)
        sort dratio2020
        format dratio2020 %9.1f
        list uid dratio2020 if uid<=33, sep(5) line(120)
        sort dratio2060
        format dratio2060 %9.1f
        list uid dratio2060 if uid<=33, sep(5) line(120)

        ** Annual change in dependency ratio

        ** Full period
        gsort uid
        gen dratio = round( ( ( ln(dratio2060 / dratio1980) ) / 80 ) * 100 , 0.01) 
        gen dratio_1st = round( ( ( ln(dratio2020 / dratio1980) ) / 40 ) * 100 , 0.01)  
        gen dratio_2nd = round( ( ( ln(dratio2060 / dratio2020) ) / 40 ) * 100 , 0.01)  
        sort dratio
        list uid dratio if uid<=33, sep(5) line(120)
        sort dratio_1st
        list uid dratio_1st if uid<=33, sep(5) line(120)
        sort dratio_2nd
        list uid dratio_2nd if uid<=33, sep(5) line(120)
restore



** --------------------------------------------------------------
** GRAPHIC - Equiplot, ordered by size of depenency ratio in 2060
** NOW SORT by 2020
** --------------------------------------------------------------

gen line_lo = dratio1980 + 2
gen line_hi = dratio2060 - 2

** The surrounding boxes
local outer1 -1 0     7 0    7 65     -1 65 
local outer2  7 0    15 0   15 65      7 65 
local outer3  15 0   23 0   23 65     15 65 
local outer4  23 0   31 0   31 65     23 65 
local outer5  31 0   39 0   39 65     31 65 

local inner1 -1 48     7 48    7 65     -1 65
local inner2  7 48    15 48   15 65      7 65 
local inner3  15 48   23 48   23 65     15 65 
local inner4  23 48   31 48   31 65     23 65 
local inner5  31 48   39 48   39 65     31 65 

local yax5 " 32 "Americas"  33 "Argentina" 34 "Cuba" 35 "Uruguay" 36 "United States" 37 "Barbados" 38 "Canada" "
local yax4 " 24 "El Salvador" 25 "Grenada" 26 "Saint Vincent & Gren" 27 "Saint Lucia" 28 "Costa Rica" 29 "Trinidad & Tobago" 30 "Chile" "
local yax3 " 16 "Peru" 17 "Colombia" 18 "Antigua & Barbuda" 19 "Bolivia" 20 "Brazil" 21 "Panama" 22 "Jamaica" "
local yax2 " 8 "Guyana" 9 "Paraguay" 10 "Suriname" 11 "Mexico" 12 "Dominican Rep" 13 "Ecuador" 14 "Venezuela" "
local yax1 " 1 "Belize" 2 "Honduras" 3 "Haiti" 4 "Nicaragua" 5 "Guatemala" 6 "Bahamas" "

#delimit ;
	gr twoway 
        (scatteri `inner1' , recast(area) lw(0.25) lc(gs10) fc(gs10) lp(l))
        (scatteri `inner2' , recast(area) lw(0.25) lc(gs10) fc(gs10) lp(l))
        (scatteri `inner3' , recast(area) lw(0.25) lc(gs10) fc(gs10) lp(l))
        (scatteri `inner4' , recast(area) lw(0.25) lc(gs10) fc(gs10) lp(l))
        (scatteri `inner5' , recast(area) lw(0.25) lc(gs10) fc(gs10) lp(l))

        (scatteri `outer1' , recast(area) lw(0.25) lc(gs7) fc(none) lp(l))
        (scatteri `outer2' , recast(line) lw(0.25) lc(gs7) fc(none) lp(l))
        (scatteri `outer3' , recast(line) lw(0.25) lc(gs7) fc(none) lp(l))
        (scatteri `outer4' , recast(line) lw(0.25) lc(gs7) fc(none) lp(l))
        (scatteri `outer5' , recast(line) lw(0.25) lc(gs7) fc(none) lp(l))

        /// Horizontal lines
        (rbar line_lo line_hi uid1, horizontal fc(gs13)   barw(0.1) lw(none))

		/// Dependency Ratio Points - 33 countries
        (sc uid1 dratio1980  , msize(4) m(o) mlc("`blu1'") mfc("`blu2'%50") mlw(0.1))
        (sc uid1 dratio2020  , msize(4) m(o) mlc("gs0") mfc("`gry2'") mlw(0.1))
        (sc uid1 dratio2060  , msize(4) m(o) mlc("`pur1'") mfc("`pur2'%50") mlw(0.1))

		/// Dependency Ratio Points - 33 countries
        /// (sc uid1 dratio1980 if uid1!=26 , msize(4) m(o) mlc("`blu1'") mfc("`blu3'") mlw(0.1))
        /// (sc uid1 dratio2020 if uid1!=26 , msize(4) m(o) mlc("gs0") mfc("`gry1'") mlw(0.1))
        /// (sc uid1 dratio2060 if uid1!=26 , msize(4) m(o) mlc("`pur1'") mfc("`pur3'") mlw(0.1))

		/// Dependency Ratio Points - The Americas
        /// (sc uid1 dratio1980 if uid1==26 , msize(4) m(o) mlc("gs10") mfc("`red3'") mlw(0.1))
        /// (sc uid1 dratio2020 if uid1==26 , msize(4) m(o) mlc("gs0") mfc("`red1'") mlw(0.1))
        /// (sc uid1 dratio2060 if uid1==26 , msize(4) m(o) mlc("gs10") mfc("`red3'") mlw(0.1))
		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 
			ysize(14) xsize(8)

			/// X-axis
			xlab(5(10)45, 
			labc(gs8) labs(4) notick grid glc(gs16) angle(0) format(%9.0f))
			xscale(noline range(0(5)60) lw(vthin)) 
			xtitle(" ", size(3) color(gs8) margin(l=0 r=0 t=0 b=0)) 
            xmtick(5(5)45, tlc(gs8))

			/// Y-axis
			ylab(   `yax1' `yax2' `yax3' `yax4' `yax5',
			valuelabels labc(gs8) labs(3) tlc(gs8) nogrid notick glc(blue) angle(0) format(%9.0f) labgap(2) )
			yscale(noline range(0(1)42) noextend   ) 
			ytitle("", color(gs8) size(3) margin(l=1 r=1 t=1 b=1)) 

            text( 41 55 "Dep Ratio" ,  place(c) size(3.5) color(gs8) just(right))
            text( 40 55 "2020"      ,  place(c) size(3.5) color(gs8) just(right))
            text( 1 55 "${dr_1_2020}"  ,  place(c) size(3) color(gs4) just(right))
            text( 2 55 "${dr_2_2020}"  ,  place(c) size(3) color(gs4) just(right))
            text( 3 55 "${dr_3_2020}"  ,  place(c) size(3) color(gs4) just(right))
            text( 4 55 "${dr_4_2020}"  ,  place(c) size(3) color(gs4) just(right))
            text( 5 55 "${dr_5_2020}"  ,  place(c) size(3) color(gs4) just(right))
            text( 6 55 "${dr_6_2020}"  ,  place(c) size(3) color(gs4) just(right))
            text( 8 55 "${dr_8_2020}"  ,  place(c) size(3) color(gs4) just(right))
            text( 9 55 "${dr_9_2020}"  ,  place(c) size(3) color(gs4) just(right))
            text(10 55 "${dr_10_2020}" ,  place(c) size(3) color(gs4) just(right))
            text(11 55 "${dr_11_2020}" ,  place(c) size(3) color(gs4) just(right))
            text(12 55 "${dr_12_2020}" ,  place(c) size(3) color(gs4) just(right))
            text(13 55 "${dr_13_2020}" ,  place(c) size(3) color(gs4) just(right))
            text(14 55 "${dr_14_2020}" ,  place(c) size(3) color(gs4) just(right))
            text(16 55 "${dr_16_2020}" ,  place(c) size(3) color(gs4) just(right))
            text(17 55 "${dr_17_2020}" ,  place(c) size(3) color(gs4) just(right))
            text(18 55 "${dr_18_2020}" ,  place(c) size(3) color(gs4) just(right))
            text(19 55 "${dr_19_2020}" ,  place(c) size(3) color(gs4) just(right))
            text(20 55 "${dr_20_2020}" ,  place(c) size(3) color(gs4) just(right))
            text(21 55 "${dr_21_2020}" ,  place(c) size(3) color(gs4) just(right))
            text(22 55 "${dr_22_2020}" ,  place(c) size(3) color(gs4) just(right))
            text(24 55 "${dr_24_2020}" ,  place(c) size(3) color(gs4) just(right))
            text(25 55 "${dr_25_2020}" ,  place(c) size(3) color(gs4) just(right))
            text(26 55 "${dr_26_2020}" ,  place(c) size(3) color(gs4) just(right))
            text(27 55 "${dr_27_2020}" ,  place(c) size(3) color(gs4) just(right))
            text(28 55 "${dr_28_2020}" ,  place(c) size(3) color(gs4) just(right))
            text(29 55 "${dr_29_2020}" ,  place(c) size(3) color(gs4) just(right))
            text(30 55 "${dr_30_2020}" ,  place(c) size(3) color(gs4) just(right))
            text(32 55 "${dr_32_2020}" ,  place(c) size(3) color(gs4) just(right))
            text(33 55 "${dr_33_2020}" ,  place(c) size(3) color(gs4) just(right))
            text(34 55 "${dr_34_2020}" ,  place(c) size(3) color(gs4) just(right))
            text(35 55 "${dr_35_2020}" ,  place(c) size(3) color(gs4) just(right))
            text(36 55 "${dr_36_2020}" ,  place(c) size(3) color(gs4) just(right))
            text(37 55 "${dr_37_2020}" ,  place(c) size(3) color(gs4) just(right))
            text(38 55 "${dr_38_2020}" ,  place(c) size(3) color(gs4) just(right))

			legend(size(4) color(gs8) position(12) nobox ring(1) bm(t=0 b=0 l=0 r=0) colf cols(13)
			region(fcolor(gs16) lw(none) margin(t=0 b=1 l=0 r=0)) 
			order(12 13 14) textfirst
			lab(12 "1980") 
			lab(13 "2020") 
			lab(14 "2060") 
            )
			name(equiplot_dratio_2020)
			;
#delimit cr	

