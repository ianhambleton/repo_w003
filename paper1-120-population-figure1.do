** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    paper1-120-population-figure1.do
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
    log using "`logpath'\paper1-120-population-figure1", replace
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
    keep if paho_subregion<.
    collapse (sum) a0 a5 a10 a15 a20 a25 a30 a35 a40 a45 a50 a55 a60 a65 a70 a75 a80 a85 a90 a95 a100, by(paho_subregion year sex)
    gen iso3n = 20000
    save `sr_totals', replace
restore

** Collapse into AMERICAS region
preserve
    tempfile r_totals
    keep if paho_subregion<.
    collapse (sum) a0 a5 a10 a15 a20 a25 a30 a35 a40 a45 a50 a55 a60 a65 a70 a75 a80 a85 a90 a95 a100, by(region year sex)
    gen iso3n = 10000
    save `r_totals', replace
restore

** Join sbregional and regional files to country files
append using `sr_totals'
append using `r_totals'

** Keep region and subregions
drop if iso3n<900
** keep if iso3n==.
replace paho_subregion = 10 if region==1
label define paho_subregion_ 10 "americas" , modify 
label values paho_subregion paho_subregion_
drop region un_subregion

** Calculate age-group percentages
egen group1 = rowtotal(a0 a5 a10 a15) 
egen group2 = rowtotal(a20 a25 a30 a35 a40 a45 a50 a55 a60 a65) 
egen group3 = rowtotal(a70 a75 a80 a85 a90 a95 a100) 
egen total = rowtotal(a0 a5 a10 a15 a20 a25 a30 a35 a40 a45 a50 a55 a60 a65 a70 a75 a80 a85 a90 a95 a100) 
label var group1 "Ages 0-19"
label var group2 "Ages 20-69"
label var group3 "Ages 70+"
label var total "Total across all ages"
format group1 group2 group3 total %15.1fc
gen pg1 = (group1/total) 
gen pg2 = (group2/total) 
gen pg3 = (group3/total) 
label var pg1 "Proportion 0-19"
label var pg2 "Proportion 20-69"
label var pg3 "Proportion 70+"
keep iso3n paho_subregion sex year group1 group2 group3 total pg1 pg2 pg3
sort paho_subregion sex year

** STATS to ACCOMPANY GRAPHIC
** keep if sex==3 
sort iso3n paho_subregion sex year
gen perc1 = pg1 * 100
gen perc2 = pg2 * 100
gen perc3 = pg3 * 100
gen arise1 = perc1[_n] - perc1[_n-1] if iso3n[_n]==iso3n[_n-1] & sex[_n]==sex[_n-1] 
gen arise3 = perc3[_n] - perc3[_n-1] if iso3n[_n]==iso3n[_n-1] & sex[_n]==sex[_n-1]
format perc1 perc2 perc3 arise1 arise3 %9.1f

** STATS FOR RESULTS SECTION
** Mostly on women and men combined
preserve
    * Results-Para2. Americas overall
    keep if sex==3 & iso3n==904
    sort year
    list iso3n year perc1 arise1 perc2 perc3 arise3, sep(3) line(120)
restore
preserve
    * Results-Para2. Global
    keep if sex==3 & iso3n==900
    sort year
    list iso3n year perc1 arise1 perc2 perc3 arise3, sep(3) line(120)
restore
preserve
    * Results-Para2. The 8 PAHO subregions. Absolute change 1980 to 2020
    keep if sex==3 & paho_subregion<10
    sort arise3
    list paho_subregion year perc1 arise1 perc2 perc3 arise3 if year==2020, sep(3) line(120)
restore
preserve
    * Results-Para2. The 8 PAHO subregions. Absolute change 2020 to 2060
    keep if sex==3 & paho_subregion<10
    sort arise3
    list paho_subregion year perc1 arise1 perc2 perc3 arise3 if year==2060, sep(3) line(120)
restore
preserve
    * Results-Para2. Baseline proportions 70+ in 1980
    keep if sex==3 & paho_subregion<10
    sort perc3
    list paho_subregion year perc1 arise1 perc2 perc3 arise3 if year==1980, sep(3) line(120)
restore
preserve
    * Results-Para2. Baseline proportions 70+ in 2060
    keep if sex==3 & paho_subregion<10
    sort perc3
    list paho_subregion year perc1 arise1 perc2 perc3 arise3 if year==2060, sep(3) line(120)
restore


** -------------------------------------------------------
** GRAPHIC
** ONLY using PAHO-SUBREGIONS
** -------------------------------------------------------
drop if paho_subregion==10
** Metrics on RHS of chart
** (a) % change 70+ between 1980 and 2020
** (b) % change 70+ between 2020 and 2060
gen pc1 = ( group3[_n] - group3[_n-1] ) / total[_n-1] if paho_subregion[_n] == paho_subregion[_n-1] 
forval w = 1(1)2 {
    forval x = 1(1)8 {
        forval y = 1980(40)2060 {
        preserve
            keep if sex==`w' & paho_subregion==`x' & year==`y'
            local a70_`w'_`x'_`y' = pg3 * 100      
            global a70_`w'_`x'_`y' : dis %5.1f `a70_`w'_`x'_`y''
        restore
        }
    }
}

** GRAPH of women and men combined
keep if sex==3

** Matrix of 400 dots
** agroup is the defining age grouping
gen d1 = round(pg1 * 400, 1)
gen d3 = round(pg3 * 400, 1)
gen d2 = 400 - d1 - d3 
keep paho_subregion year d1 d2 d3 group* total pg*  
reshape long d, i(paho_subregion year) j(agroup) 
label define agroup_ 1 "0-19" 2 "20-69" 3 "70+",modify
label values agroup agroup_ 

* define the dots
expand d
sort paho_subregion year agroup 
// define the dots
local rows =  20   // row dots
local cols  = 20   // col dots

* generate the dots
bysort paho_subregion year: egen y = seq() , b(`cols')
egen x = seq() , t(`rows')
bysort paho_subregion year: egen y1 = seq() , f(`cols') t(1) b(`cols')
egen x1 = seq() , f(`rows') t(1)

** Shift Subregion vertically
replace y1 = y1 + 25 if paho_subregion==2
replace y1 = y1 + 50 if paho_subregion==3
replace y1 = y1 + 75 if paho_subregion==4
replace y1 = y1 + 100 if paho_subregion==5
replace y1 = y1 + 125 if paho_subregion==6
replace y1 = y1 + 150 if paho_subregion==7
replace y1 = y1 + 175 if paho_subregion==8
replace y1 = y1 + 200 if paho_subregion==10

** Shift Years horizontally
replace x1 = x1 + 25 if year==2020
replace x1 = x1 + 50 if year==2060

** generate -locals- from the d3 qualitative-paired color scheme
colorpalette sfso , blue nograph
local list r(p) 
** Darkest to lightest
local blu1 `r(p1)'
local blu2 `r(p2)'
local blu3 `r(p3)'
local blu4 `r(p4)'
local blu5 `r(p5)'
local blu6 `r(p6)'
local blu7 `r(p7)'

** Recode to have 70+ age group at bottom of chart
recode agroup 3=1 1=3

* Version 2 - legend outside
** Legend outer limits for graphing 
local a3 -10 15    -5 15    -5 25    -10 25    -10 15 
local a2 -10 30    -5 30    -5 40    -10 40    -10 30 
local a1 -10 45    -5 45    -5 55    -10 55    -10 45 

#delimit ; 
twoway 
     /// (1) North America
     /// (2) Central America 
     /// (3) Andean area
     /// (4) Southern Cone
     /// (5) Latin Caribbean
     /// (6) non-Latin Caribbean
     /// (7) Brazil
     /// (8) Mexico   
     (scatter y1 x1 if paho_subregion==1 & year==1980 & agroup==1, msize(0.15) mc("`blu2'") m(O))
     (scatter y1 x1 if paho_subregion==1 & year==1980 & agroup==2, msize(0.15) mc("`blu6'") m(O))
     (scatter y1 x1 if paho_subregion==1 & year==1980 & agroup==3, msize(0.15) mc("`blu4'") m(O))
     (scatter y1 x1 if paho_subregion==1 & year==2020 & agroup==1, msize(0.15) mc("`blu2'") m(O))
     (scatter y1 x1 if paho_subregion==1 & year==2020 & agroup==2, msize(0.15) mc("`blu6'") m(O))
     (scatter y1 x1 if paho_subregion==1 & year==2020 & agroup==3, msize(0.15) mc("`blu4'") m(O))
     (scatter y1 x1 if paho_subregion==1 & year==2060 & agroup==1, msize(0.15) mc("`blu2'") m(O))
     (scatter y1 x1 if paho_subregion==1 & year==2060 & agroup==2, msize(0.15) mc("`blu6'") m(O))
     (scatter y1 x1 if paho_subregion==1 & year==2060 & agroup==3, msize(0.15) mc("`blu4'") m(O))
     (scatter y1 x1 if paho_subregion==2 & year==1980 & agroup==1, msize(0.15) mc("`blu2'") m(O))
     (scatter y1 x1 if paho_subregion==2 & year==1980 & agroup==2, msize(0.15) mc("`blu6'") m(O))
     (scatter y1 x1 if paho_subregion==2 & year==1980 & agroup==3, msize(0.15) mc("`blu4'") m(O))
     (scatter y1 x1 if paho_subregion==2 & year==2020 & agroup==1, msize(0.15) mc("`blu2'") m(O))
     (scatter y1 x1 if paho_subregion==2 & year==2020 & agroup==2, msize(0.15) mc("`blu6'") m(O))
     (scatter y1 x1 if paho_subregion==2 & year==2020 & agroup==3, msize(0.15) mc("`blu4'") m(O))    
     (scatter y1 x1 if paho_subregion==2 & year==2060 & agroup==1, msize(0.15) mc("`blu2'") m(O))
     (scatter y1 x1 if paho_subregion==2 & year==2060 & agroup==2, msize(0.15) mc("`blu6'") m(O))
     (scatter y1 x1 if paho_subregion==2 & year==2060 & agroup==3, msize(0.15) mc("`blu4'") m(O))  
     (scatter y1 x1 if paho_subregion==3 & year==1980 & agroup==1, msize(0.15) mc("`blu2'") m(O))
     (scatter y1 x1 if paho_subregion==3 & year==1980 & agroup==2, msize(0.15) mc("`blu6'") m(O))
     (scatter y1 x1 if paho_subregion==3 & year==1980 & agroup==3, msize(0.15) mc("`blu4'") m(O))
     (scatter y1 x1 if paho_subregion==3 & year==2020 & agroup==1, msize(0.15) mc("`blu2'") m(O))
     (scatter y1 x1 if paho_subregion==3 & year==2020 & agroup==2, msize(0.15) mc("`blu6'") m(O))
     (scatter y1 x1 if paho_subregion==3 & year==2020 & agroup==3, msize(0.15) mc("`blu4'") m(O))  
     (scatter y1 x1 if paho_subregion==3 & year==2060 & agroup==1, msize(0.15) mc("`blu2'") m(O))
     (scatter y1 x1 if paho_subregion==3 & year==2060 & agroup==2, msize(0.15) mc("`blu6'") m(O))
     (scatter y1 x1 if paho_subregion==3 & year==2060 & agroup==3, msize(0.15) mc("`blu4'") m(O))  
     (scatter y1 x1 if paho_subregion==4 & year==1980 & agroup==1, msize(0.15) mc("`blu2'") m(O))
     (scatter y1 x1 if paho_subregion==4 & year==1980 & agroup==2, msize(0.15) mc("`blu6'") m(O))
     (scatter y1 x1 if paho_subregion==4 & year==1980 & agroup==3, msize(0.15) mc("`blu4'") m(O))
     (scatter y1 x1 if paho_subregion==4 & year==2020 & agroup==1, msize(0.15) mc("`blu2'") m(O))
     (scatter y1 x1 if paho_subregion==4 & year==2020 & agroup==2, msize(0.15) mc("`blu6'") m(O))
     (scatter y1 x1 if paho_subregion==4 & year==2020 & agroup==3, msize(0.15) mc("`blu4'") m(O))  
     (scatter y1 x1 if paho_subregion==4 & year==2060 & agroup==1, msize(0.15) mc("`blu2'") m(O))
     (scatter y1 x1 if paho_subregion==4 & year==2060 & agroup==2, msize(0.15) mc("`blu6'") m(O))
     (scatter y1 x1 if paho_subregion==4 & year==2060 & agroup==3, msize(0.15) mc("`blu4'") m(O))  
     (scatter y1 x1 if paho_subregion==5 & year==1980 & agroup==1, msize(0.15) mc("`blu2'") m(O))
     (scatter y1 x1 if paho_subregion==5 & year==1980 & agroup==2, msize(0.15) mc("`blu6'") m(O))
     (scatter y1 x1 if paho_subregion==5 & year==1980 & agroup==3, msize(0.15) mc("`blu4'") m(O))
     (scatter y1 x1 if paho_subregion==5 & year==2020 & agroup==1, msize(0.15) mc("`blu2'") m(O))
     (scatter y1 x1 if paho_subregion==5 & year==2020 & agroup==2, msize(0.15) mc("`blu6'") m(O))
     (scatter y1 x1 if paho_subregion==5 & year==2020 & agroup==3, msize(0.15) mc("`blu4'") m(O))  
     (scatter y1 x1 if paho_subregion==5 & year==2060 & agroup==1, msize(0.15) mc("`blu2'") m(O))
     (scatter y1 x1 if paho_subregion==5 & year==2060 & agroup==2, msize(0.15) mc("`blu6'") m(O))
     (scatter y1 x1 if paho_subregion==5 & year==2060 & agroup==3, msize(0.15) mc("`blu4'") m(O))  
     (scatter y1 x1 if paho_subregion==6 & year==1980 & agroup==1, msize(0.15) mc("`blu2'") m(O))
     (scatter y1 x1 if paho_subregion==6 & year==1980 & agroup==2, msize(0.15) mc("`blu6'") m(O))
     (scatter y1 x1 if paho_subregion==6 & year==1980 & agroup==3, msize(0.15) mc("`blu4'") m(O))
     (scatter y1 x1 if paho_subregion==6 & year==2020 & agroup==1, msize(0.15) mc("`blu2'") m(O))
     (scatter y1 x1 if paho_subregion==6 & year==2020 & agroup==2, msize(0.15) mc("`blu6'") m(O))
     (scatter y1 x1 if paho_subregion==6 & year==2020 & agroup==3, msize(0.15) mc("`blu4'") m(O))  
     (scatter y1 x1 if paho_subregion==6 & year==2060 & agroup==1, msize(0.15) mc("`blu2'") m(O))
     (scatter y1 x1 if paho_subregion==6 & year==2060 & agroup==2, msize(0.15) mc("`blu6'") m(O))
     (scatter y1 x1 if paho_subregion==6 & year==2060 & agroup==3, msize(0.15) mc("`blu4'") m(O))  
     (scatter y1 x1 if paho_subregion==7 & year==1980 & agroup==1, msize(0.15) mc("`blu2'") m(O))
     (scatter y1 x1 if paho_subregion==7 & year==1980 & agroup==2, msize(0.15) mc("`blu6'") m(O))
     (scatter y1 x1 if paho_subregion==7 & year==1980 & agroup==3, msize(0.15) mc("`blu4'") m(O))
     (scatter y1 x1 if paho_subregion==7 & year==2020 & agroup==1, msize(0.15) mc("`blu2'") m(O))
     (scatter y1 x1 if paho_subregion==7 & year==2020 & agroup==2, msize(0.15) mc("`blu6'") m(O))
     (scatter y1 x1 if paho_subregion==7 & year==2020 & agroup==3, msize(0.15) mc("`blu4'") m(O))  
     (scatter y1 x1 if paho_subregion==7 & year==2060 & agroup==1, msize(0.15) mc("`blu2'") m(O))
     (scatter y1 x1 if paho_subregion==7 & year==2060 & agroup==2, msize(0.15) mc("`blu6'") m(O))
     (scatter y1 x1 if paho_subregion==7 & year==2060 & agroup==3, msize(0.15) mc("`blu4'") m(O))  
     (scatter y1 x1 if paho_subregion==8 & year==1980 & agroup==1, msize(0.15) mc("`blu2'") m(O))
     (scatter y1 x1 if paho_subregion==8 & year==1980 & agroup==2, msize(0.15) mc("`blu6'") m(O))
     (scatter y1 x1 if paho_subregion==8 & year==1980 & agroup==3, msize(0.15) mc("`blu4'") m(O))
     (scatter y1 x1 if paho_subregion==8 & year==2020 & agroup==1, msize(0.15) mc("`blu2'") m(O))
     (scatter y1 x1 if paho_subregion==8 & year==2020 & agroup==2, msize(0.15) mc("`blu6'") m(O))
     (scatter y1 x1 if paho_subregion==8 & year==2020 & agroup==3, msize(0.15) mc("`blu4'") m(O))  
     (scatter y1 x1 if paho_subregion==8 & year==2060 & agroup==1, msize(0.15) mc("`blu2'") m(O))
     (scatter y1 x1 if paho_subregion==8 & year==2060 & agroup==2, msize(0.15) mc("`blu6'") m(O))
     (scatter y1 x1 if paho_subregion==8 & year==2060 & agroup==3, msize(0.15) mc("`blu4'") m(O))  

    /// Legend 
     (scatteri `a1' , recast(area) lw(none) lc("`blu2'") fc("`blu2'")  )
     (scatteri `a2' , recast(area) lw(none) lc("`blu6'") fc("`blu6'")  )
     (scatteri `a3' , recast(area) lw(none) lc("`blu4'") fc("`blu4'")  )

         , 

	plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 		
	graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 
	ysize(16) xsize(12)

	ylab(
        12 "North" 
        7 "America" 
        37 "Central" 
        32 "America"
        62 "Andean"
        57 "area"
        87 "Southern"
        82 "cone"
        112 "Latin"
        107 "Caribbean"
        137 "non-Latin"
        132 "Caribbean"
        162 "Brazil"
        187 "Mexico"
        ,
	valuelabel labc(gs0) labs(3) tlc(gs0) notick nogrid glc(gs16) angle(0) format(%9.0f))
	yscale(noline lw(none) lc(gs16) noextend range(-20(10)210)) 
	ytitle("", color(gs8) size(3) margin(l=1 r=1 t=1 b=1)) 

	xlab(none , 
	valuelabel labc(gs0) labs(3) notick nogrid glc(gs16) angle(0) format(%9.0f))
	xscale(noline lw(vthin) range(0(10)130) ) 
	xtitle(" ", size(3) color(gs0) margin(l=0 r=0 t=0 b=0)) 

    xtitle("") xscale(noline) xlabel(, nogrid)

    /// Column headings
    text(203 11 "1980" ,  place(c) size(3) color(gs0) just(right))
    text(203 36 "2020" ,  place(c) size(3) color(gs0) just(right))
    text(203 61 "2060" ,  place(c) size(3) color(gs0) just(right))
    text(205 90 "Aged 70+ (%)" ,  place(e) size(3) color(gs0) just(right))
    text(197 92 "Women" ,  place(e) size(2.5) color(gs4) just(right))
    text(197 110 "Men" ,  place(e) size(2.5) color(gs4) just(right))

    /// WOMEN
    text(191 83 "1980:   $a70_2_8_1980" ,    place(e) size(2.5) color(gs8) just(right))
    text(185 83 "2020:   $a70_2_8_2020 " ,   place(e) size(2.5) color(gs8) just(right))
    text(179 83 "2060:   $a70_2_8_2060 " ,   place(e) size(2.5) color(gs8) just(right))
    text(166 83 "1980:   $a70_2_7_1980" ,    place(e) size(2.5) color(gs8) just(right))
    text(160 83 "2020:   $a70_2_7_2020 " ,   place(e) size(2.5) color(gs8) just(right))
    text(154 83 "2060:   $a70_2_7_2060 " ,   place(e) size(2.5) color(gs8) just(right))
    text(141 83 "1980:   $a70_2_6_1980" ,    place(e) size(2.5) color(gs8) just(right))
    text(135 83 "2020:   $a70_2_6_2020 " ,   place(e) size(2.5) color(gs8) just(right))
    text(129 83 "2060:   $a70_2_6_2060 " ,   place(e) size(2.5) color(gs8) just(right))
    text(116 83 "1980:   $a70_2_5_1980" ,    place(e) size(2.5) color(gs8) just(right))
    text(110 83 "2020:   $a70_2_5_2020 " ,   place(e) size(2.5) color(gs8) just(right))
    text(104 83 "2060:   $a70_2_5_2060 " ,   place(e) size(2.5) color(gs8) just(right))
    text(91  83 "1980:   $a70_2_4_1980" ,    place(e) size(2.5) color(gs8) just(right))
    text(85  83 "2020:   $a70_2_4_2020 " ,   place(e) size(2.5) color(gs8) just(right))
    text(79  83 "2060:   $a70_2_4_2060 " ,   place(e) size(2.5) color(gs8) just(right))
    text(66  83 "1980:   $a70_2_3_1980" ,    place(e) size(2.5) color(gs8) just(right))
    text(60  83 "2020:   $a70_2_3_2020 " ,   place(e) size(2.5) color(gs8) just(right))
    text(54  83 "2060:   $a70_2_3_2060 " ,   place(e) size(2.5) color(gs8) just(right))
    text(41  83 "1980:   $a70_2_2_1980" ,    place(e) size(2.5) color(gs8) just(right))
    text(35  83 "2020:   $a70_2_2_2020 " ,   place(e) size(2.5) color(gs8) just(right))
    text(29  83 "2060:   $a70_2_2_2060 " ,   place(e) size(2.5) color(gs8) just(right))
    text(16  83 "1980:   $a70_2_1_1980" ,    place(e) size(2.5) color(gs8) just(right))
    text(10  83 "2020:   $a70_2_1_2020 " ,   place(e) size(2.5) color(gs8) just(right))
    text(4   83 "2060:   $a70_2_1_2060 " ,   place(e) size(2.5) color(gs8) just(right))

    /// MEN
    text(191 110 "$a70_1_8_1980" ,    place(e) size(2.5) color(gs8) just(right))
    text(185 110 "$a70_1_8_2020 " ,   place(e) size(2.5) color(gs8) just(right))
    text(179 110 "$a70_1_8_2060 " ,   place(e) size(2.5) color(gs8) just(right))
    text(166 110 "$a70_1_7_1980" ,    place(e) size(2.5) color(gs8) just(right))
    text(160 110 "$a70_1_7_2020 " ,   place(e) size(2.5) color(gs8) just(right))
    text(154 110 "$a70_1_7_2060 " ,   place(e) size(2.5) color(gs8) just(right))
    text(141 110 "$a70_1_6_1980" ,    place(e) size(2.5) color(gs8) just(right))
    text(135 110 "$a70_1_6_2020 " ,   place(e) size(2.5) color(gs8) just(right))
    text(129 110 "$a70_1_6_2060 " ,   place(e) size(2.5) color(gs8) just(right))
    text(116 110 "$a70_1_5_1980" ,    place(e) size(2.5) color(gs8) just(right))
    text(110 110 "$a70_1_5_2020 " ,   place(e) size(2.5) color(gs8) just(right))
    text(104 110 "$a70_1_5_2060 " ,   place(e) size(2.5) color(gs8) just(right))
    text(91  110 "$a70_1_4_1980" ,    place(e) size(2.5) color(gs8) just(right))
    text(85  110 "$a70_1_4_2020 " ,   place(e) size(2.5) color(gs8) just(right))
    text(79  110 "$a70_1_4_2060 " ,   place(e) size(2.5) color(gs8) just(right))
    text(66  110 "$a70_1_3_1980" ,    place(e) size(2.5) color(gs8) just(right))
    text(60  110 "$a70_1_3_2020 " ,   place(e) size(2.5) color(gs8) just(right))
    text(54  110 "$a70_1_3_2060 " ,   place(e) size(2.5) color(gs8) just(right))
    text(41  110 "$a70_1_2_1980" ,    place(e) size(2.5) color(gs8) just(right))
    text(35  110 "$a70_1_2_2020 " ,   place(e) size(2.5) color(gs8) just(right))
    text(29  110 "$a70_1_2_2060 " ,   place(e) size(2.5) color(gs8) just(right))
    text(16  110 "$a70_1_1_1980" ,    place(e) size(2.5) color(gs8) just(right))
    text(10  110 "$a70_1_1_2020 " ,   place(e) size(2.5) color(gs8) just(right))
    text(4   110 "$a70_1_1_2060 " ,   place(e) size(2.5) color(gs8) just(right))

    /// Legend Text
    text(-15 20  "0-19",  place(c) size(3) color(gs8))   
    text(-15 35 "20-69",  place(c) size(3) color(gs8))   
    text(-15 50   "70+",  place(c) size(3) color(gs8))   

    legend(off) 
    name(figure1)
    ;
#delimit cr 



