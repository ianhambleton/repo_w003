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

** Join subregional and regional files to country files
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

    ** Colorblind friendly palette (Bischof, 2017b)
    ** Bischof, D. 2017b. New graphic schemes for Stata: plotplain and plottig.  The Stata Journal 17(3): 748–759
    #delimit ;
    colorpalette cblind, select(1 2 4 5 9 8 7 3 6) nograph;
    local list r(p);    local blk `r(p1)'; local gry `r(p2)'; local bl1 `r(p3)';  local gre `r(p4)'; local pur `r(p5)'; 
                        local red `r(p6)'; local bl2 `r(p7)'; local ora `r(p8)'; local yel `r(p9)';
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


** Recode to have 70+ age group at bottom of chart
keep paho_subregion year group1 group2 group3 pg1 pg2 pg3 perc1 perc2 perc3 group* total pg*  
** reshape long group pg , i(paho_subregion year) j(agroup) 
** label define agroup_ 1 "0-19" 2 "20-69" 3 "70+",modify
** label values agroup agroup_
** recode agroup 3=1 1=3

* Version 2 - legend outside
** Legend outer limits for graphing 
local a3 -10 15    -5 15    -5 25    -10 25    -10 15 
local a2 -10 30    -5 30    -5 40    -10 40    -10 30 
local a1 -10 45    -5 45    -5 55    -10 55    -10 45 

///         
///        


#delimit ;
gr hbar perc1 perc2 perc3
, 
	plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 		
	graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 
	ysize(16) xsize(12)
    
    stack 

    over(year, axis(off) gap(15) lab(labs(2)) )
    over(paho_subregion, axis(off) gap(120) reverse relabel(1 " " 2 " " 3 " " 4 " " 5 " " 6 " " 7 " " 8 " "))
    
	ylab(
        ,
	valuelabel labc(gs0) labs(3) tlc(gs0) notick nogrid glc(gs16) angle(0) format(%9.0f))
	yscale(lw(none) lc(gs16) noextend range(-50(10)150)) 
	ytitle("", color(gs8) size(3) margin(l=1 r=1 t=1 b=1)) 

    bar(1, col("`bl2'*0.80"))
    bar(2, col("`ora'*0.80"))
    bar(3, col("`gre'*0.80"))

    text(130 -9  "Aged 70+ (%)" ,  place(c) size(3) color(gs0) just(right))
    text(120 -5  "Women" ,  place(c) size(2.5) color(gs4) just(right))
    text(142 -5  "Men" ,  place(c) size(2.5) color(gs4) just(right))

    /// WOMEN
    text(115 98    "$a70_2_1_1980" ,    place(e) size(2.5) color(gs8) just(right))
    text(115 95    "$a70_2_1_2020 " ,   place(e) size(2.5) color(gs8) just(right))
    text(115 92    "$a70_2_1_2060 " ,   place(e) size(2.5) color(gs8) just(right))
    text(115 85    "$a70_2_2_1980" ,    place(e) size(2.5) color(gs8) just(right))
    text(115 82    "$a70_2_2_2020 " ,   place(e) size(2.5) color(gs8) just(right))
    text(115 79    "$a70_2_2_2060 " ,   place(e) size(2.5) color(gs8) just(right))
    text(115 72    "$a70_2_3_1980" ,    place(e) size(2.5) color(gs8) just(right))
    text(115 69    "$a70_2_3_2020 " ,   place(e) size(2.5) color(gs8) just(right))
    text(115 66    "$a70_2_3_2060 " ,   place(e) size(2.5) color(gs8) just(right))
    text(115 59.3  "$a70_2_4_1980" ,    place(e) size(2.5) color(gs8) just(right))
    text(115 56.3  "$a70_2_4_2020 " ,   place(e) size(2.5) color(gs8) just(right))
    text(115 53.3  "$a70_2_4_2060 " ,   place(e) size(2.5) color(gs8) just(right))
    text(115 46.5  "$a70_2_5_1980" ,    place(e) size(2.5) color(gs8) just(right))
    text(115 43.5  "$a70_2_5_2020 " ,   place(e) size(2.5) color(gs8) just(right))
    text(115 40.5  "$a70_2_5_2060 " ,   place(e) size(2.5) color(gs8) just(right))
    text(115 33.7  "$a70_2_6_1980" ,    place(e) size(2.5) color(gs8) just(right))
    text(115 30.7  "$a70_2_6_2020 " ,   place(e) size(2.5) color(gs8) just(right))
    text(115 27.7  "$a70_2_6_2060 " ,   place(e) size(2.5) color(gs8) just(right))
    text(115 20.9  "$a70_2_7_1980" ,    place(e) size(2.5) color(gs8) just(right))
    text(115 17.9  "$a70_2_7_2020 " ,   place(e) size(2.5) color(gs8) just(right))
    text(115 14.9  "$a70_2_7_2060 " ,   place(e) size(2.5) color(gs8) just(right))
    text(115 8     "$a70_2_8_1980" ,    place(e) size(2.5) color(gs8) just(right))
    text(115 5     "$a70_2_8_2020 " ,   place(e) size(2.5) color(gs8) just(right))
    text(115 2     "$a70_2_8_2060 " ,   place(e) size(2.5) color(gs8) just(right))

    /// MEN
    text(135 98   "$a70_1_1_1980" ,    place(e) size(2.5) color(gs8) just(right))
    text(135 95   "$a70_1_1_2020 " ,   place(e) size(2.5) color(gs8) just(right))
    text(135 92   "$a70_1_1_2060 " ,   place(e) size(2.5) color(gs8) just(right))
    text(135 85   "$a70_1_2_1980" ,    place(e) size(2.5) color(gs8) just(right))
    text(135 82   "$a70_1_2_2020 " ,   place(e) size(2.5) color(gs8) just(right))
    text(135 79   "$a70_1_2_2060 " ,   place(e) size(2.5) color(gs8) just(right))
    text(135 72   "$a70_1_3_1980" ,    place(e) size(2.5) color(gs8) just(right))
    text(135 69   "$a70_1_3_2020 " ,   place(e) size(2.5) color(gs8) just(right))
    text(135 66   "$a70_1_3_2060 " ,   place(e) size(2.5) color(gs8) just(right))
    text(135 59.3 "$a70_1_4_1980" ,    place(e) size(2.5) color(gs8) just(right))
    text(135 56.3 "$a70_1_4_2020 " ,   place(e) size(2.5) color(gs8) just(right))
    text(135 53.3 "$a70_1_4_2060 " ,   place(e) size(2.5) color(gs8) just(right))
    text(135 46.5 "$a70_1_5_1980" ,    place(e) size(2.5) color(gs8) just(right))
    text(135 43.5 "$a70_1_5_2020 " ,   place(e) size(2.5) color(gs8) just(right))
    text(135 40.5 "$a70_1_5_2060 " ,   place(e) size(2.5) color(gs8) just(right))
    text(135 33.7 "$a70_1_6_1980" ,    place(e) size(2.5) color(gs8) just(right))
    text(135 30.7 "$a70_1_6_2020 " ,   place(e) size(2.5) color(gs8) just(right))
    text(135 27.7 "$a70_1_6_2060 " ,   place(e) size(2.5) color(gs8) just(right))
    text(135 20.9 "$a70_1_7_1980" ,    place(e) size(2.5) color(gs8) just(right))
    text(135 17.9 "$a70_1_7_2020 " ,   place(e) size(2.5) color(gs8) just(right))
    text(135 14.9 "$a70_1_7_2060 " ,   place(e) size(2.5) color(gs8) just(right))
    text(135 8    "$a70_1_8_1980" ,    place(e) size(2.5) color(gs8) just(right))
    text(135 5    "$a70_1_8_2020 " ,   place(e) size(2.5) color(gs8) just(right))
    text(135 2    "$a70_1_8_2060 " ,   place(e) size(2.5) color(gs8) just(right))

    /// YEARS
    text(-4 98 "1980" ,     place(w) size(2.5) color(gs8) just(right))
    text(-4 95 "2020" ,     place(w) size(2.5) color(gs8) just(right))
    text(-4 92 "2060" ,     place(w) size(2.5) color(gs8) just(right))
    text(-4 85 "1980 " ,    place(w) size(2.5) color(gs8) just(right))
    text(-4 82 "2020" ,     place(w) size(2.5) color(gs8) just(right))
    text(-4 79 "2060" ,     place(w) size(2.5) color(gs8) just(right))
    text(-4 72 "1980" ,     place(w) size(2.5) color(gs8) just(right))
    text(-4 69 "2020" ,     place(w) size(2.5) color(gs8) just(right))
    text(-4 66 "2060" ,     place(w) size(2.5) color(gs8) just(right))
    text(-4 59.3 "1980" ,   place(w) size(2.5) color(gs8) just(right))
    text(-4 56.3 "2020" ,   place(w) size(2.5) color(gs8) just(right))
    text(-4 53.3 "2060" ,   place(w) size(2.5) color(gs8) just(right))
    text(-4 46.5 "1980" ,   place(w) size(2.5) color(gs8) just(right))
    text(-4 43.5 "2020" ,   place(w) size(2.5) color(gs8) just(right))
    text(-4 40.5 "2060" ,   place(w) size(2.5) color(gs8) just(right))
    text(-4 33.7 "1980" ,   place(w) size(2.5) color(gs8) just(right))
    text(-4 30.7 "2020" ,   place(w) size(2.5) color(gs8) just(right))
    text(-4 27.7 "2060" ,   place(w) size(2.5) color(gs8) just(right))
    text(-4 20.9 "1980" ,   place(w) size(2.5) color(gs8) just(right))
    text(-4 17.9 "2020" ,   place(w) size(2.5) color(gs8) just(right))
    text(-4 14.9 "2060" ,   place(w) size(2.5) color(gs8) just(right))
    text(-4 8 "1980" ,      place(w) size(2.5) color(gs8) just(right))
    text(-4 5 "2020" ,      place(w) size(2.5) color(gs8) just(right))
    text(-4 2 "2060" ,      place(w) size(2.5) color(gs8) just(right))

    text(-20 5 "Mexico" ,     place(w) size(2.5) color(gs0) just(right))
    text(-20 18 "Brazil" ,     place(w) size(2.5) color(gs0) just(right))
    text(-20 29.2 "non-Latin" ,     place(w) size(2.5) color(gs0) just(right))
    text(-20 31.8 "Caribbean" ,     place(w) size(2.5) color(gs0) just(right))
    text(-20 42.2 "Latin" ,     place(w) size(2.5) color(gs0) just(right))
    text(-20 44.8 "Caribbean" ,     place(w) size(2.5) color(gs0) just(right))
    text(-20 55.2 "Southern" ,     place(w) size(2.5) color(gs0) just(right))
    text(-20 57.8 "cone" ,     place(w) size(2.5) color(gs0) just(right))
    text(-20 66.2 "Andean" ,     place(w) size(2.5) color(gs0) just(right))
    text(-20 68.8 "area" ,     place(w) size(2.5) color(gs0) just(right))
    text(-20 79.2 "Central" ,     place(w) size(2.5) color(gs0) just(right))
    text(-20 81.8 "America" ,     place(w) size(2.5) color(gs0) just(right))
    text(-20 92.2 "North" ,     place(w) size(2.5) color(gs0) just(right))
    text(-20 94.8 "America" ,     place(w) size(2.5) color(gs0) just(right))

	legend(size(3) color(gs8) position(12) nobox ring(1) bm(t=0 b=5 l=0 r=0) colf cols(3)
	region(fcolor(gs16) lw(none) margin(t=5 b=0 l=0 r=0)) keygap(1) symp(center)
	order(1 2 3) notextfirst stack
    symy(3) symx(6)
	lab(1 "0-19 yrs") 
	lab(2 "20-69 yrs") 
	lab(3 "70+ yrs") 
    )

    ytitle("% of population in 3 age groups" , size(2.5) color(gs0))
    note("Data from: UN DESA, Population Division (2019). World Population Prospects (Ref. 20)",   place(e) size(2.5) color(gs10) just(left))
    name(figure1)    
;
#delimit cr
graph export "`outputpath'/figure1.png", replace width(4000)



** ------------------------------------------
** PDF of Figure 1
** DEATHS
** ------------------------------------------
putpdf begin, pagesize(letter) font("Calibri Light", 10) margin(top,0.5cm) margin(bottom,0.25cm) margin(left,0.5cm) margin(right,0.25cm)

** FIGURES
    putpdf paragraph ,  font("Calibri Light", 10)
    putpdf text ("Figure 1"), bold font("Calibri Light", 12)
    putpdf table t2 = (1,1), width(85%) halign(center) border(all,nil) 
    putpdf table t2(1,1)=image("`outputpath'/figure1.png")

** Save the PDF
    local c_date = c(current_date)
    local date_string = subinstr("`c_date'", " ", "", .)
    putpdf save "`outputpath'/figure1-revised", replace


