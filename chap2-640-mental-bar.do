** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap2-640-mental-bar.do
    //  project:				    WHO Global Health Estimates
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	19-August-2021
    //  algorithm task			    Leading causes of mental health/neurological death: by-country bar charts

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
    log using "`logpath'\chap2-640-mental-bar", replace
** HEADER -----------------------------------------------------

tempfile t1

** Mortality rate 
use "`datapath'\from-who\chap2_000_mr_adjusted", clear
keep year sex ghecause region mortr 
save `t1', replace 

** DALY rate 
use "`datapath'\from-who\chap2_000_daly_adjusted", clear
keep year sex ghecause region dalyr 
merge 1:1 year sex ghecause region using `t1' 
drop _merge

** Restrict
keep if sex==3
keep if year==2019
drop year sex 

**------------------------------------------------
** Ordered version of ghecause 
** MENTAL HEALTH
** (36)  1   "Drug use disorders" 
** (32)  2   "Depressive disorders" 
** (37)  3   "Anxiety disorders" 
** (35)  4   "Alcohol use disorders" 
** (34)  5   "Schizophrenia" 
** NEUROLOGICAL
** (42)  6   "Alzheimer/dementias"
** (46)  7   "Migraine"
** (44)  8   "Epilepsy"
** (47)  9   "Non-migraine headache"
** (43)  10  "Parkinson disease"
** (800)  11  "all mental"
** (900)  12  "all neurological"
** (100)  13  "all cause"  
** -----------------------------------------------
gen cod = .
replace cod = 1 if ghecause==36
replace cod = 2 if ghecause==32
replace cod = 3 if ghecause==37
replace cod = 4 if ghecause==35
replace cod = 5 if ghecause==34
replace cod = 6 if ghecause==800

replace cod = 7 if ghecause==42
replace cod = 8 if ghecause==46
replace cod = 9 if ghecause==44
replace cod = 10 if ghecause==47
replace cod = 11 if ghecause==43
replace cod = 12 if ghecause==900
#delimit ;
label define cod_   1   "Drug use disorders" 
                    2   "Depressive disorders" 
                    3   "Anxiety disorders" 
                    4   "Alcohol use disorders" 
                    5   "Schizophrenia" 
                    6  "all mental"
                    7   "Alzheimer/dementias"
                    8   "Migraine"
                    9   "Epilepsy"
                    10   "Non-migraine headache"
                    11  "Parkinson disease"
                    12  "all neurological", modify;
#delimit cr
label values cod cod_    
keep if cod<=12
sort cod

** Restrict region to countries + Americas 
keep if region < 100 | region==2000

** ---------------------------------------------------
** Statistics for the text to accompany this graphic
** Simple relative measure of inequality : Rate (R)
** Simple absolute measure of inequality : Difference (D)
** Simple relative measure of inequality : Index of Disparity (ID) 
** ---------------------------------------------------
drop mortr 

** BASED ON ADJUSTED MORTALITY RATE 
** (R) Simple - relative
    bysort cod : egen m_min = min(dalyr)
    bysort cod : egen m_max = max(dalyr)
    gen rel_sim = m_max / m_min
    label var rel_sim "Relative inequality: WHO simple measure"

** (D) Simple - absolute
    gen abs_sim = m_max - m_min
    label var abs_sim "Absolute inequality: WHO simple measure"
    drop m_min m_max 

** (ID) Complex - relative
    * --> Index of Disparity (Each country compared to Americas average rate)
    * --> number of countries in group 
    bysort cod : gen J = _N - 1
    gen americas1 = dalyr if region==2000
    bysort cod : egen daly_am = min(americas1) 
    drop americas1 
    order daly_am, after(dalyr)
    gen id1 = abs(dalyr - daly_am)
    bysort cod : egen id2 = sum(id1) 
    gen id3 = id2 / daly_am
    gen id = (1/J) * id3 * 100
    drop daly_am id1 id2 id3 J
    order abs_sim rel_sim id , after(dalyr)

    bysort cod: gen touse = 1 if _n==1 
    tabdisp cod, c(abs_sim rel_sim) format(%9.1f)
    tabdisp cod, c(id) format(%9.1f)

** ID to local macros
forval x = 1(1)11 {
    preserve
        keep if cod==`x' & touse==1
        local id`x' : dis %5.0f id
    restore
}

** Unicode markers for graphic
/// †  	U+2020 (alt-08224)	DAGGER = obelisk, obelus, long cross
/// ‡  	U+2021 (alt-08225)	DOUBLE DAGGER = diesis, double obelisk
/// •  	U+2022 (alt-08226)	BULLET = black small circle
local dagger = uchar(8224)
local ddagger = uchar(8225)
local section = uchar(0167) 
local teardrop = uchar(10045) 


** --------------------------------------------------------
** GRAPHIC
** --------------------------------------------------------

** COLORS - ORANGES for Mental health / neurological
    colorpalette hcl, oranges nograph n(14)
    local list r(p) 
    ** Age groups
    local child `r(p2)'    
    local youth `r(p5)'    
    local young `r(p8)'    
    local older `r(p11)'    
    local elderly `r(p14)'   

** COLORS - REDS
    colorpalette hcl, reds nograph n(14)
    local list r(p) 
    ** Age groups
    local americas1 `r(p2)'    
    local americas2 `r(p5)'    
    local americas3 `r(p8)'    
    local americas4 `r(p11)'    
    local americas5 `r(p14)' 

** Outer boxes
local outer1   62 -10   -26 -10   -26 110   62 110   62 -10 

local outer2a  62 110   62 230  
local outer2b  62 230   -26 230  
local outer2c  -26 110   -26 230 

local outer3a  62 230    62 350  
local outer3b  62 350   -26 350 
local outer3c -26 230   -26 350 

local outer4a  62 350    62 470  
local outer4b  62 470   -26 470  
local outer4c -26 350   -26 470 

local outer5a  62 470    62 590  
local outer5b  62 590   -26 590  
local outer5c -26 470   -26 590

local outer6a  62 590    62 710  
local outer6b  62 710   -26 710  
local outer6c -26 590   -26 710 

** Countries ordered by size for COD (1-6)
gsort cod dalyr
gen region_new = region
label values region_new region_
#delimit ; 
    label define region_    28 "St.Vincent & Gren"
                            1 "Antigua & Barbuda"
                            30 "Trinidad & Tobago"
                            13 "Dominican Rep"
                            2000 "Americas", modify;
#delimit cr

decode region_new , gen(region_lab)
bysort cod : gen regiono = _n
forval x = 1(1)11 {
    gen region`x' = regiono if cod==`x'
    labmask region`x' if cod==`x', values(region_lab)
}

** Scale all rates to 100 - keeps shape of all bar charts, and allows us to more easily create a panel of 6 charts
bysort cod : egen maxr = max(dalyr)
gen scaler = (dalyr/maxr) * 100
order maxr scaler , after(dalyr) 
forval x = 1(1)11 {
    gen scaler`x' = scaler if cod==`x'
}
gen origin1 = 0
gen origin2 = 120 
replace scaler2 = scaler2 + 120
gen origin3 = 240
replace scaler3 = scaler3 + 240
gen origin4 = 360 
replace scaler4 = scaler4 + 360
gen origin5 = 480 
replace scaler5 = scaler5 + 480
gen origin6 = 600 
replace scaler6 = scaler6 + 600

** St Vincent and the Grenadines -- Too Long - Abbreviate
replace region_lab = "St.Vincent & Gren" if region_lab == "Saint Vincent and the Grenadines"
replace region_lab = "Antigua & Barbuda" if region_lab == "Antigua and Barbuda"


** COUNTRIES with High and Low Mortality Rates
preserve
    drop if region==2000
    sort cod dalyr
    bysort cod: gen include = _n
    mark keepme if include<=5 | include>=29
    keep if keepme==1
    bysort cod : gen regiono2 = _n
    order include regiono2, after(dalyr)
    ** Drug use disorders
    forval x = 1(1)10 {
        local cid1_`x' = region_lab[`x'] 
    }
    ** depressive disorders
    forval x = 11(1)20 {
        local cid2_`x' = region_lab[`x'] 
    }
    ** anxiety disorders
    forval x = 21(1)30 {
        local cid3_`x' = region_lab[`x'] 
    }
    ** alcohol use disorders
    forval x = 31(1)40 {
        local cid4_`x' = region_lab[`x'] 
    }
    ** schizophrenia
    forval x = 41(1)50 {
        local cid5_`x' = region_lab[`x'] 
    }
    ** All mental health
    forval x = 51(1)60 {
        local cid6_`x' = region_lab[`x'] 
    }
restore

#delimit ;
	gr twoway 
		/// outer boxes 
        (scatteri `outer1'  , recast(area) lw(0.2) lc(gs10) fc(none) lp("l"))
        (scatteri `outer2a' , recast(line) lw(0.2) lc(gs10) fc(none) lp("l"))
        (scatteri `outer2b' , recast(line) lw(0.2) lc(gs10) fc(none) lp("l"))
        (scatteri `outer2c' , recast(line) lw(0.2) lc(gs10) fc(none) lp("l"))
        (scatteri `outer3a' , recast(line) lw(0.2) lc(gs10) fc(none) lp("l"))
        (scatteri `outer3b' , recast(line) lw(0.2) lc(gs10) fc(none) lp("l"))
        (scatteri `outer3c' , recast(line) lw(0.2) lc(gs10) fc(none) lp("l"))
        (scatteri `outer4a' , recast(line) lw(0.2) lc(gs10) fc(none) lp("l"))
        (scatteri `outer4b' , recast(line) lw(0.2) lc(gs10) fc(none) lp("l"))
        (scatteri `outer4c' , recast(line) lw(0.2) lc(gs10) fc(none) lp("l"))
        (scatteri `outer5a' , recast(line) lw(0.2) lc(gs10) fc(none) lp("l"))
        (scatteri `outer5b' , recast(line) lw(0.2) lc(gs10) fc(none) lp("l"))
        (scatteri `outer5c' , recast(line) lw(0.2) lc(gs10) fc(none) lp("l"))
        (scatteri `outer6a' , recast(line) lw(0.2) lc(gs10) fc(none) lp("l"))
        (scatteri `outer6b' , recast(line) lw(0.2) lc(gs10) fc(none) lp("l"))
        (scatteri `outer6c' , recast(line) lw(0.2) lc(gs10) fc(none) lp("l"))

		/// country values
        (rbar origin1 scaler1 region1 if cod==1 & region!=2000, horizontal barw(0.6) fcol("`youth'") lcol("`youth'") lw(0.1))       
        (rbar origin2 scaler2 region2 if cod==2 & region!=2000, horizontal barw(0.6) fcol("`youth'") lcol("`youth'") lw(0.1))           
        (rbar origin3 scaler3 region3 if cod==3 & region!=2000, horizontal barw(0.6) fcol("`youth'") lcol("`youth'") lw(0.1))           
        (rbar origin4 scaler4 region4 if cod==4 & region!=2000, horizontal barw(0.6) fcol("`youth'") lcol("`youth'") lw(0.1))           
        (rbar origin5 scaler5 region5 if cod==5 & region!=2000, horizontal barw(0.6) fcol("`youth'") lcol("`youth'") lw(0.1))           
        (rbar origin6 scaler6 region6 if cod==6 & region!=2000, horizontal barw(0.6) fcol("`youth'") lcol("`youth'") lw(0.1))           

        (rbar origin1 scaler1 region1 if cod==1 & region==2000, horizontal barw(0.6) fcol("gs0") lcol("gs0") lw(0.1))       
        (rbar origin2 scaler2 region2 if cod==2 & region==2000, horizontal barw(0.6) fcol("gs0") lcol("gs0") lw(0.1))           
        (rbar origin3 scaler3 region3 if cod==3 & region==2000, horizontal barw(0.6) fcol("gs0") lcol("gs0") lw(0.1))           
        (rbar origin4 scaler4 region4 if cod==4 & region==2000, horizontal barw(0.6) fcol("gs0") lcol("gs0") lw(0.1))           
        (rbar origin5 scaler5 region5 if cod==5 & region==2000, horizontal barw(0.6) fcol("gs0") lcol("gs0") lw(0.1))           
        (rbar origin6 scaler6 region6 if cod==6 & region==2000, horizontal barw(0.6) fcol("gs0") lcol("gs0") lw(0.1))           
                		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			ysize(9) xsize(18)

			xlab(none, notick labs(7) tlc(gs0) labc(gs0) notick nogrid glc(gs16))
			xscale(noline ) 
			xtitle("", size(5) color(gs0) margin(l=2 r=2 t=5 b=2)) 
			
			ylab(none,
			labc(gs0) labs(3) tstyle(major_notick) nogrid glc(gs16) angle(0) format(%9.0f))
			yscale(noline lw(vthin) range(-36(2)67)) 
			ytitle("", size(5) margin(l=2 r=5 t=2 b=2)) 

           /// Region Titles 
           text(67 50 "Drug use" "disorders"          ,  place(c) size(3.5) color(gs8) just(center))
           text(67 170 "Depressive" "disorders"       ,  place(c) size(3.5) color(gs8) just(center))
           text(67 290 "Anxiety" "disorders"          ,  place(c) size(3.5) color(gs8) just(center))
           text(67 410 "Alcohol use" "disorders"      ,  place(c) size(3.5) color(gs8) just(center))
           text(67 530 "Schizophrenia"                ,  place(c) size(3.5) color(gs8) just(center))
           text(67 650 "All" "mental health"          ,  place(c) size(3.5) color(gs8) just(center))

            /// INDEX OF DISPARITY VALUES
           /// text(-4.4 0.3 "ID{superscript:`ddagger'}" ,  place(c) size(7) color("`child'*0.5") just(center))
           text(16 65 "IoD"                        ,  place(c) size(6) color("`child'*0.5") just(center))
           text(18.5 84 "`teardrop'"               ,  place(c) size(2.5) color("`child'*0.5") just(center))
           text(10 60 "`id1'"                     ,  place(c) size(7) color("`child'*0.5") just(center))
           text(10 195 "`id2'"                     ,  place(c) size(7) color("`child'*0.5") just(center))
           text(10 315 "`id3'"                     ,  place(c) size(7) color("`child'*0.5") just(center))
           text(10 420 "`id4'"                     ,  place(c) size(7) color("`child'*0.5") just(center))
           text(10 555 "`id5'"                     ,  place(c) size(7) color("`child'*0.5") just(center))
           text(10 670 "`id6'"                     ,  place(c) size(7) color("`child'*0.5") just(center))

           /// Y-Axis text 
           text(-29.5 340 "Age-standardized DALY rate (per 100,000)" ,  
                                    place(c) size(3.5) color("gs8") just(center))

           /// High Rate Countries
           /// Drug use disorders
           text(59 0 "Highest Rates:",  place(e) size(3.5) color("`child'*0.80") just(right))
           text(55 105 "`cid1_10' (1)",  place(w) size(3) color("`child'*0.5") just(right))
           text(51 105 "`cid1_9' (2)",  place(w) size(3) color("`child'*0.5") just(right))
           text(47 105 "`cid1_8' (3)",  place(w) size(3) color("`child'*0.5") just(right))
           text(43 105 "`cid1_7' (4)",  place(w) size(3) color("`child'*0.5") just(right))
           text(39 105 "`cid1_6' (5)",  place(w) size(3) color("`child'*0.5") just(right))
           text(-3 0 "Lowest Rates:",  place(e) size(3.5) color("`child'*0.80") just(right))
           text(-7 105 "`cid1_5' (5)",  place(w) size(3) color("`child'*0.5") just(right))
           text(-11 105 "`cid1_4' (4)",  place(w) size(3) color("`child'*0.5") just(right))
           text(-15 105 "`cid1_3' (3)",  place(w) size(3) color("`child'*0.5") just(right))
           text(-19 105 "`cid1_2' (2)",  place(w) size(3) color("`child'*0.5") just(right))
           text(-23 105 "`cid1_1' (1)",  place(w) size(3) color("`child'*0.5") just(right))

           /// /// Depressive disorders
           /// ///text(48 0 "Highest Rates:",  place(e) size(3.5) color("`child'*0.80") just(right))
           text(55 225 "`cid2_20'",  place(w) size(3) color("`child'*0.5") just(right))
           text(51 225 "`cid2_19'",  place(w) size(3) color("`child'*0.5") just(right))
           text(47 225 "`cid2_18'",  place(w) size(3) color("`child'*0.5") just(right))
           text(43 225 "`cid2_17'",  place(w) size(3) color("`child'*0.5") just(right))
           text(39 225 "`cid2_16'",  place(w) size(3) color("`child'*0.5") just(right))
           /// ///text(-3 0 "Lowest Rates:",  place(e) size(3.5) color("`child'*0.80") just(right))
           text(-7 225 "`cid2_15'",  place(w) size(3) color("`child'*0.5") just(right))
           text(-11 225 "`cid2_14'",  place(w) size(3) color("`child'*0.5") just(right))
           text(-15 225 "`cid2_13'",  place(w) size(3) color("`child'*0.5") just(right))
           text(-19 225 "`cid2_12'",  place(w) size(3) color("`child'*0.5") just(right))
           text(-23 225 "`cid2_11'",  place(w) size(3) color("`child'*0.5") just(right))
           
           /// Anxiety disorders
           /// ///text(48 0 "Highest Rates:",  place(e) size(3.5) color("`child'*0.80") just(right))
           text(55 345 "`cid3_30'",  place(w) size(3) color("`child'*0.5") just(right))
           text(51 345 "`cid3_29'",  place(w) size(3) color("`child'*0.5") just(right))
           text(47 345 "`cid3_28'",  place(w) size(3) color("`child'*0.5") just(right))
           text(43 345 "`cid3_27'",  place(w) size(3) color("`child'*0.5") just(right))
           text(39 345 "`cid3_26'",  place(w) size(3) color("`child'*0.5") just(right))
           /// ///text(-3 0 "Lowest Rates:",  place(e) size(3.5) color("`child'*0.80") just(right))
           text(-7 345 "`cid3_25'",  place(w) size(3) color("`child'*0.5") just(right))
           text(-11 345 "`cid3_24'",  place(w) size(3) color("`child'*0.5") just(right))
           text(-15 345 "`cid3_23'",  place(w) size(3) color("`child'*0.5") just(right))
           text(-19 345 "`cid3_22'",  place(w) size(3) color("`child'*0.5") just(right))
           text(-23 345 "`cid3_21'",  place(w) size(3) color("`child'*0.5") just(right))
 
           /// Alcohol use disorders
           text(55 465 "`cid4_40'",  place(w) size(3) color("`child'*0.5") just(right))
           text(51 465 "`cid4_39'",  place(w) size(3) color("`child'*0.5") just(right))
           text(47 465 "`cid4_38'",  place(w) size(3) color("`child'*0.5") just(right))
           text(43 465 "`cid4_37'",  place(w) size(3) color("`child'*0.5") just(right))
           text(39 465 "`cid4_36'",  place(w) size(3) color("`child'*0.5") just(right))
           /// ///text(-3 0 "Lowest Rates:",  place(e) size(3.5) color("`child'*0.80") just(right))
           text(-7 465 "`cid4_35'",  place(w) size(3) color("`child'*0.5") just(right))
           text(-11 465 "`cid4_34'",  place(w) size(3) color("`child'*0.5") just(right))
           text(-15 465 "`cid4_33'",  place(w) size(3) color("`child'*0.5") just(right))
           text(-19 465 "`cid4_32'",  place(w) size(3) color("`child'*0.5") just(right))
           text(-23 465 "`cid4_31'",  place(w) size(3) color("`child'*0.5") just(right))
 
           /// Schizophrenia
           /// ///text(48 0 "Highest Rates:",  place(e) size(3.5) color("`child'*0.80") just(right))
           text(55 585 "`cid5_50'",  place(w) size(3) color("`child'*0.5") just(right))
           text(51 585 "`cid5_49'",  place(w) size(3) color("`child'*0.5") just(right))
           text(47 585 "`cid5_48'",  place(w) size(3) color("`child'*0.5") just(right))
           text(43 585 "`cid5_47'",  place(w) size(3) color("`child'*0.5") just(right))
           text(39 585 "`cid5_46'",  place(w) size(3) color("`child'*0.5") just(right))
           /// ///text(-3 0 "Lowest Rates:",  place(e) size(3.5) color("`child'*0.80") just(right))
           text(-7 585 "`cid5_45'",  place(w) size(3) color("`child'*0.5") just(right))
           text(-11 585 "`cid5_44'",  place(w) size(3) color("`child'*0.5") just(right))
           text(-15 585 "`cid5_43'",  place(w) size(3) color("`child'*0.5") just(right))
           text(-19 585 "`cid5_42'",  place(w) size(3) color("`child'*0.5") just(right))
           text(-23 585 "`cid5_41'",  place(w) size(3) color("`child'*0.5") just(right))
 
           /// All mental health
           ///text(48 0 "Highest Rates:",  place(e) size(3.5) color("`child'*0.80") just(right))
           text(55 705 "`cid6_60'",  place(w) size(3) color("`child'*0.5") just(right))
           text(51 705 "`cid6_59'",  place(w) size(3) color("`child'*0.5") just(right))
           text(47 705 "`cid6_58'",  place(w) size(3) color("`child'*0.5") just(right))
           text(43 705 "`cid6_57'",  place(w) size(3) color("`child'*0.5") just(right))
           text(39 705 "`cid6_56'",  place(w) size(3) color("`child'*0.5") just(right))
           /// ///text(-3 0 "Lowest Rates:",  place(e) size(3.5) color("`child'*0.80") just(right))
           text(-7 705 "`cid6_55'",  place(w) size(3) color("`child'*0.5") just(right))
           text(-11 705 "`cid6_54'",  place(w) size(3) color("`child'*0.5") just(right))
           text(-15 705 "`cid6_53'",  place(w) size(3) color("`child'*0.5") just(right))
           text(-19 705 "`cid6_52'",  place(w) size(3) color("`child'*0.5") just(right))
           text(-23 705 "`cid6_51'",  place(w) size(3) color("`child'*0.5") just(right))

           /// NOTE
           text(-34.5 0.5 "`teardrop' IoD = Index of Disparity. Measures the average (mean) deviation of each country rate from the regional rate, as a percentage." , 
                                    place(e) size(2.25) color(gs10) just(left) )
           text(-38.5 0.5 "`dagger' BLACK BAR is the DALY rate for the Region of the Americas." ,  
                                    place(e) size(2.25) color(gs10)  just(left))
			legend(off)
			name(bar1)
			;
#delimit cr	



    ** generate a local for the D3 color scheme
    colorpalette d3, 20 n(20) nograph
    local list r(p) 
    ** CVD
    local cvd1 `r(p9)'
    local cvd2 `r(p10)'
    ** Cancer 
    local can1 `r(p1)'
    local can2 `r(p2)'
    ** CRD
    local crd1 `r(p5)'
    local crd2 `r(p6)'
    ** Diabetes
    local dia1 `r(p17)'
    local dia2 `r(p18)'
    ** Mental Health
    local men1 `r(p3)'
    local men2 `r(p4)'
    ** External causes
    local inj1 `r(p7)'
    local inj2 `r(p8)'


** --------------------------------------------------------------
** --------------------------------------------------------------
** REPEAT DISABILITY FOR YEAR 2000
** --------------------------------------------------------------
** --------------------------------------------------------------
tempfile t1

** Mortality rate 
use "`datapath'\from-who\chap2_000_mr_adjusted", clear
keep year sex ghecause region mortr 
save `t1', replace 

** DALY rate 
use "`datapath'\from-who\chap2_000_daly_adjusted", clear
keep year sex ghecause region dalyr 
merge 1:1 year sex ghecause region using `t1' 
drop _merge

** Restrict
keep if sex==3
keep if year==2000
drop year sex 

**------------------------------------------------
** Ordered version of ghecause 
** MENTAL HEALTH
** (36)  1   "Drug use disorders" 
** (32)  2   "Depressive disorders" 
** (37)  3   "Anxiety disorders" 
** (35)  4   "Alcohol use disorders" 
** (34)  5   "Schizophrenia" 
** NEUROLOGICAL
** (42)  6   "Alzheimer/dementias"
** (46)  7   "Migraine"
** (44)  8   "Epilepsy"
** (47)  9   "Non-migraine headache"
** (43)  10  "Parkinson disease"
** (800)  11  "all mental"
** (900)  12  "all neurological"
** (100)  13  "all cause"  
** -----------------------------------------------
gen cod = .
replace cod = 1 if ghecause==36
replace cod = 2 if ghecause==32
replace cod = 3 if ghecause==37
replace cod = 4 if ghecause==35
replace cod = 5 if ghecause==34
replace cod = 6 if ghecause==800

replace cod = 7 if ghecause==42
replace cod = 8 if ghecause==46
replace cod = 9 if ghecause==44
replace cod = 10 if ghecause==47
replace cod = 11 if ghecause==43
replace cod = 12 if ghecause==900
#delimit ;
label define cod_   1   "Drug use disorders" 
                    2   "Depressive disorders" 
                    3   "Anxiety disorders" 
                    4   "Alcohol use disorders" 
                    5   "Schizophrenia" 
                    6  "all mental"
                    7   "Alzheimer/dementias"
                    8   "Migraine"
                    9   "Epilepsy"
                    10   "Non-migraine headache"
                    11  "Parkinson disease"
                    12  "all neurological", modify;
#delimit cr
label values cod cod_    
keep if cod<=6
sort cod

** Restrict region to countries + Americas 
keep if region < 100 | region==2000

** ---------------------------------------------------
** Statistics for the text to accompany this graphic
** Simple relative measure of inequality : Rate (R)
** Simple absolute measure of inequality : Difference (D)
** Simple relative measure of inequality : Index of Disparity (ID) 
** ---------------------------------------------------
drop mortr 

** BASED ON ADJUSTED MORTALITY RATE 
** (R) Simple - relative
    bysort cod : egen m_min = min(dalyr)
    bysort cod : egen m_max = max(dalyr)
    gen rel_sim = m_max / m_min
    label var rel_sim "Relative inequality: WHO simple measure"

** (D) Simple - absolute
    gen abs_sim = m_max - m_min
    label var abs_sim "Absolute inequality: WHO simple measure"
    drop m_min m_max 

** (ID) Complex - relative
    * --> Index of Disparity (Each country compared to Americas average rate)
    * --> number of countries in group 
    bysort cod : gen J = _N - 1
    gen americas1 = dalyr if region==2000
    bysort cod : egen daly_am = min(americas1) 
    drop americas1 
    order daly_am, after(dalyr)
    gen id1 = abs(dalyr - daly_am)
    bysort cod : egen id2 = sum(id1) 
    gen id3 = id2 / daly_am
    gen id = (1/J) * id3 * 100
    drop daly_am id1 id2 id3 J
    order abs_sim rel_sim id , after(dalyr)

    bysort cod: gen touse = 1 if _n==1 
    tabdisp cod, c(abs_sim rel_sim) format(%9.1f)
    tabdisp cod, c(id) format(%9.1f)

** ID to local macros
forval x = 1(1)6 {
    preserve
        keep if cod==`x' & touse==1
        local id`x' : dis %5.0f id
    restore
}

** Unicode markers for graphic
/// †  	U+2020 (alt-08224)	DAGGER = obelisk, obelus, long cross
/// ‡  	U+2021 (alt-08225)	DOUBLE DAGGER = diesis, double obelisk
/// •  	U+2022 (alt-08226)	BULLET = black small circle
local dagger = uchar(8224)
local ddagger = uchar(8225)
local section = uchar(0167) 
local teardrop = uchar(10045) 


** --------------------------------------------------------
** GRAPHIC
** --------------------------------------------------------
** Countries ordered by size for COD (1-6)
gsort cod dalyr
gen region_new = region
label values region_new region_
#delimit ; 
    label define region_    28 "St.Vincent & Gren"
                            1 "Antigua & Barbuda"
                            30 "Trinidad & Tobago"
                            13 "Dominican Rep"
                            2000 "Americas", modify;
#delimit cr

decode region_new , gen(region_lab)
bysort cod : gen regiono = _n
forval x = 1(1)6 {
    gen region`x' = regiono if cod==`x'
    labmask region`x' if cod==`x', values(region_lab)
}

** Scale all rates to 100 - keeps shape of all bar charts, and allows us to more easily create a panel of 6 charts
bysort cod : egen maxr = max(dalyr)
gen scaler = (dalyr/maxr) * 100
order maxr scaler , after(dalyr) 
forval x = 1(1)6 {
    gen scaler`x' = scaler if cod==`x'
}
gen origin1 = 0
gen origin2 = 120 
replace scaler2 = scaler2 + 120
gen origin3 = 240
replace scaler3 = scaler3 + 240
gen origin4 = 360 
replace scaler4 = scaler4 + 360
gen origin5 = 480 
replace scaler5 = scaler5 + 480
gen origin6 = 600 
replace scaler6 = scaler6 + 600

** --------------------------------------------------------------
** APPENDIX: BAR CHART ORDERED by COUNTRY (ALL CVDs)
** Change year on LINE 47 of DO FILE to repeat for 2000 and 2019
** --------------------------------------------------------------

gsort -cod -dalyr
order cod region dalyr region6 scaler6 

** Bring scalar 6 back to be from 0 x-axis
replace scaler6 = scaler6 - 600

** Mortality rates on graphic RHS - creating X and Y variables for graphic
gen value6 = region6
gen dalyr_int = round(dalyr,1) 
tostring dalyr_int, gen(dalyr_str) force
gen hun  = substr(dalyr_str,-3,.)
replace hun  = substr(dalyr_str,-2,.) if hun==""
replace hun  = substr(dalyr_str,-1,.) if hun==""
gen slen = length(dalyr_str)
gen thou  = substr(dalyr_str,1,2) if slen==5
replace thou  = substr(dalyr_str,1,1) if slen==4
gen num_str = thou + "," + hun if slen>=4
replace num_str = hun if slen<4
labmask value6, val(num_str)
gen x6 = -120
drop dalyr_int hun thou slen num_str
order cod region dalyr dalyr_str region6 scaler6 value6 

#delimit ;  
	gr twoway 
		/// country values
        (rbar origin1 scaler6 region6 if cod==6 & region!=2000, horizontal barw(0.6) fcol("`men2'") lcol("`men2'") lw(0.1))           
        (rbar origin1 scaler6 region6 if cod==6 & region==2000, horizontal barw(0.6) fcol(gs0) lcol(gs0) lw(0.1))           
        (sc value6 x6, msymbol(i) mlabel(value6) mlabsize(7) mlabcol(gs8) mlabp(0))
                		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			ysize(16) xsize(4)

			xlab(none, notick labs(7) tlc(gs0) labc(gs0) notick nogrid glc(gs16))
			xscale(noline range(1(1)100)) 
			xtitle("", size(7) color(gs0) margin(l=2 r=2 t=5 b=2)) 
			
			ylab(1(1)34, valuelabel
			labc(gs0) labs(7) tstyle(major_notick) nogrid glc(gs16) angle(0) format(%9.0f) labgap(10))
			yscale(noline lw(vthin) range(-2.5(0.5)36)) 
			ytitle("", size(7) margin(l=2 r=2 t=2 b=2)) 

           /// Region Titles 
           text(37 200 "All CVD" ,  place(c) size(7.5) color(gs8) just(center))

            /// INDEX OF DISPARITY VALUES
           text(35.5  -200 "IoD:"                       ,  place(c) size(11) color("`men1'") just(center))
           text(35.75 -350 "`teardrop'"                ,  place(c) size(5) color("`men1'") just(center))
           text(35.5  -20 "`id6'"                     ,  place(c) size(11) color("`men1'") just(center))

           /// Y-Axis text 
           text(-0.5 -200 "Disability (DALY) rate" "(per 100,000)" ,  
                                    place(c) size(6) color(gs8) just(center) linegap(1.25))
           /// NOTES
           text(-2 -250 "`teardrop' IoD = Index of Disparity." , 
                                    place(c) size(5) color(gs10) just(left) linegap(1.25))

            legend(off)
			name(bar_daly2000)
			;
#delimit cr	









** --------------------------------------------------------------
** --------------------------------------------------------------
** REPEAT DISABILITY FOR YEAR 2019
** --------------------------------------------------------------
** --------------------------------------------------------------
tempfile t1

** Mortality rate 
use "`datapath'\from-who\chap2_000_mr_adjusted", clear
keep year sex ghecause region mortr 
save `t1', replace 

** DALY rate 
use "`datapath'\from-who\chap2_000_daly_adjusted", clear
keep year sex ghecause region dalyr 
merge 1:1 year sex ghecause region using `t1' 
drop _merge

** Restrict
keep if sex==3
keep if year==2019
drop year sex 

**------------------------------------------------
** Ordered version of ghecause 
** MENTAL HEALTH
** (36)  1   "Drug use disorders" 
** (32)  2   "Depressive disorders" 
** (37)  3   "Anxiety disorders" 
** (35)  4   "Alcohol use disorders" 
** (34)  5   "Schizophrenia" 
** NEUROLOGICAL
** (42)  6   "Alzheimer/dementias"
** (46)  7   "Migraine"
** (44)  8   "Epilepsy"
** (47)  9   "Non-migraine headache"
** (43)  10  "Parkinson disease"
** (800)  11  "all mental"
** (900)  12  "all neurological"
** (100)  13  "all cause"  
** -----------------------------------------------
gen cod = .
replace cod = 1 if ghecause==36
replace cod = 2 if ghecause==32
replace cod = 3 if ghecause==37
replace cod = 4 if ghecause==35
replace cod = 5 if ghecause==34
replace cod = 6 if ghecause==800

replace cod = 7 if ghecause==42
replace cod = 8 if ghecause==46
replace cod = 9 if ghecause==44
replace cod = 10 if ghecause==47
replace cod = 11 if ghecause==43
replace cod = 12 if ghecause==900
#delimit ;
label define cod_   1   "Drug use disorders" 
                    2   "Depressive disorders" 
                    3   "Anxiety disorders" 
                    4   "Alcohol use disorders" 
                    5   "Schizophrenia" 
                    6  "all mental"
                    7   "Alzheimer/dementias"
                    8   "Migraine"
                    9   "Epilepsy"
                    10   "Non-migraine headache"
                    11  "Parkinson disease"
                    12  "all neurological", modify;
#delimit cr
label values cod cod_    
keep if cod<=6
sort cod

** Restrict region to countries + Americas 
keep if region < 100 | region==2000

** ---------------------------------------------------
** Statistics for the text to accompany this graphic
** Simple relative measure of inequality : Rate (R)
** Simple absolute measure of inequality : Difference (D)
** Simple relative measure of inequality : Index of Disparity (ID) 
** ---------------------------------------------------
drop mortr 

** BASED ON ADJUSTED MORTALITY RATE 
** (R) Simple - relative
    bysort cod : egen m_min = min(dalyr)
    bysort cod : egen m_max = max(dalyr)
    gen rel_sim = m_max / m_min
    label var rel_sim "Relative inequality: WHO simple measure"

** (D) Simple - absolute
    gen abs_sim = m_max - m_min
    label var abs_sim "Absolute inequality: WHO simple measure"
    drop m_min m_max 

** (ID) Complex - relative
    * --> Index of Disparity (Each country compared to Americas average rate)
    * --> number of countries in group 
    bysort cod : gen J = _N - 1
    gen americas1 = dalyr if region==2000
    bysort cod : egen daly_am = min(americas1) 
    drop americas1 
    order daly_am, after(dalyr)
    gen id1 = abs(dalyr - daly_am)
    bysort cod : egen id2 = sum(id1) 
    gen id3 = id2 / daly_am
    gen id = (1/J) * id3 * 100
    drop daly_am id1 id2 id3 J
    order abs_sim rel_sim id , after(dalyr)

    bysort cod: gen touse = 1 if _n==1 
    tabdisp cod, c(abs_sim rel_sim) format(%9.1f)
    tabdisp cod, c(id) format(%9.1f)

** ID to local macros
forval x = 1(1)6 {
    preserve
        keep if cod==`x' & touse==1
        local id`x' : dis %5.0f id
    restore
}

** Unicode markers for graphic
/// †  	U+2020 (alt-08224)	DAGGER = obelisk, obelus, long cross
/// ‡  	U+2021 (alt-08225)	DOUBLE DAGGER = diesis, double obelisk
/// •  	U+2022 (alt-08226)	BULLET = black small circle
local dagger = uchar(8224)
local ddagger = uchar(8225)
local section = uchar(0167) 
local teardrop = uchar(10045) 


** --------------------------------------------------------
** GRAPHIC
** --------------------------------------------------------

** Countries ordered by size for COD (1-6)
gsort cod dalyr
gen region_new = region
label values region_new region_
#delimit ; 
    label define region_    28 "St.Vincent & Gren"
                            1 "Antigua & Barbuda"
                            30 "Trinidad & Tobago"
                            13 "Dominican Rep"
                            2000 "Americas", modify;
#delimit cr

decode region_new , gen(region_lab)
bysort cod : gen regiono = _n
forval x = 1(1)6 {
    gen region`x' = regiono if cod==`x'
    labmask region`x' if cod==`x', values(region_lab)
}

** Scale all rates to 100 - keeps shape of all bar charts, and allows us to more easily create a panel of 6 charts
bysort cod : egen maxr = max(dalyr)
gen scaler = (dalyr/maxr) * 100
order maxr scaler , after(dalyr) 
forval x = 1(1)6 {
    gen scaler`x' = scaler if cod==`x'
}
gen origin1 = 0
gen origin2 = 120 
replace scaler2 = scaler2 + 120
gen origin3 = 240
replace scaler3 = scaler3 + 240
gen origin4 = 360 
replace scaler4 = scaler4 + 360
gen origin5 = 480 
replace scaler5 = scaler5 + 480
gen origin6 = 600 
replace scaler6 = scaler6 + 600


** --------------------------------------------------------------
** APPENDIX: BAR CHART ORDERED by COUNTRY (ALL CVDs)
** Change year on LINE 47 of DO FILE to repeat for 2000 and 2019
** --------------------------------------------------------------

gsort -cod -dalyr
order cod region dalyr region6 scaler6 

** Bring scalar 6 back to be from 0 x-axis
replace scaler6 = scaler6 - 600

** Mortality rates on graphic RHS - creating X and Y variables for graphic
gen value6 = region6
gen dalyr_int = round(dalyr,1) 
tostring dalyr_int, gen(dalyr_str) force
gen hun  = substr(dalyr_str,-3,.)
replace hun  = substr(dalyr_str,-2,.) if hun==""
replace hun  = substr(dalyr_str,-1,.) if hun==""
gen slen = length(dalyr_str)
gen thou  = substr(dalyr_str,1,2) if slen==5
replace thou  = substr(dalyr_str,1,1) if slen==4
gen num_str = thou + "," + hun if slen>=4
replace num_str = hun if slen<4
labmask value6, val(num_str)
gen x6 = -120
drop dalyr_int hun thou slen num_str
order cod region dalyr dalyr_str region6 scaler6 value6 

#delimit ;  
	gr twoway 
		/// country values
        (rbar origin1 scaler6 region6 if cod==6 & region!=2000, horizontal barw(0.6) fcol("`men2'") lcol("`men2'") lw(0.1))           
        (rbar origin1 scaler6 region6 if cod==6 & region==2000, horizontal barw(0.6) fcol(gs0) lcol(gs0) lw(0.1))           
        (sc value6 x6, msymbol(i) mlabel(value6) mlabsize(7) mlabcol(gs8) mlabp(0))
                		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			ysize(16) xsize(4)

			xlab(none, notick labs(7) tlc(gs0) labc(gs0) notick nogrid glc(gs16))
			xscale(noline range(1(1)100)) 
			xtitle("", size(7) color(gs0) margin(l=2 r=2 t=5 b=2)) 
			
			ylab(1(1)34, valuelabel
			labc(gs0) labs(7) tstyle(major_notick) nogrid glc(gs16) angle(0) format(%9.0f) labgap(10))
			yscale(noline lw(vthin) range(-2.5(0.5)36)) 
			ytitle("", size(7) margin(l=2 r=2 t=2 b=2)) 

           /// Region Titles 
           text(37 200 "All CVD" ,  place(c) size(7.5) color(gs8) just(center))

            /// INDEX OF DISPARITY VALUES
           text(35.5  -200 "IoD:"                       ,  place(c) size(11) color("`men1'") just(center))
           text(35.75 -350 "`teardrop'"                ,  place(c) size(5) color("`men1'") just(center))
           text(35.5  -20 "`id6'"                     ,  place(c) size(11) color("`men1'") just(center))

           /// Y-Axis text 
           text(-0.5 -200 "Disability (DALY) rate" "(per 100,000)" ,  
                                    place(c) size(6) color(gs8) just(center) linegap(1.25))
           /// NOTES
           text(-2 -250 "`teardrop' IoD = Index of Disparity." , 
                                    place(c) size(5) color(gs10) just(left) linegap(1.25))

            legend(off)
			name(bar_daly2019)
			;
#delimit cr	




** --------------------------------------------------------------
** --------------------------------------------------------------
** REPEAT MORTALITY FOR YEAR 2000
** --------------------------------------------------------------
** --------------------------------------------------------------

tempfile t1

** Mortality rate 
use "`datapath'\from-who\chap2_000_mr_adjusted", clear
keep year sex ghecause region mortr 
save `t1', replace 

** DALY rate 
use "`datapath'\from-who\chap2_000_daly_adjusted", clear
keep year sex ghecause region dalyr 
merge 1:1 year sex ghecause region using `t1' 
drop _merge

** Restrict
keep if sex==3
keep if year==2000
drop year sex 

**------------------------------------------------
** Ordered version of ghecause 
** MENTAL HEALTH
** (36)  1   "Drug use disorders" 
** (32)  2   "Depressive disorders" 
** (37)  3   "Anxiety disorders" 
** (35)  4   "Alcohol use disorders" 
** (34)  5   "Schizophrenia" 
** NEUROLOGICAL
** (42)  6   "Alzheimer/dementias"
** (46)  7   "Migraine"
** (44)  8   "Epilepsy"
** (47)  9   "Non-migraine headache"
** (43)  10  "Parkinson disease"
** (800)  11  "all mental"
** (900)  12  "all neurological"
** (100)  13  "all cause"  
** -----------------------------------------------
gen cod = .
replace cod = 1 if ghecause==36
replace cod = 2 if ghecause==32
replace cod = 3 if ghecause==37
replace cod = 4 if ghecause==35
replace cod = 5 if ghecause==34
replace cod = 6 if ghecause==800

replace cod = 7 if ghecause==42
replace cod = 8 if ghecause==46
replace cod = 9 if ghecause==44
replace cod = 10 if ghecause==47
replace cod = 11 if ghecause==43
replace cod = 12 if ghecause==900
#delimit ;
label define cod_   1   "Drug use disorders" 
                    2   "Depressive disorders" 
                    3   "Anxiety disorders" 
                    4   "Alcohol use disorders" 
                    5   "Schizophrenia" 
                    6  "all mental"
                    7   "Alzheimer/dementias"
                    8   "Migraine"
                    9   "Epilepsy"
                    10   "Non-migraine headache"
                    11  "Parkinson disease"
                    12  "all neurological", modify;
#delimit cr
label values cod cod_    
keep if cod<=6
sort cod


** Restrict region to countries + Americas 
keep if region < 100 | region==2000

** ---------------------------------------------------
** Statistics for the text to accompany this graphic
** Simple relative measure of inequality : Rate (R)
** Simple absolute measure of inequality : Difference (D)
** Simple relative measure of inequality : Index of Disparity (ID) 
** ---------------------------------------------------
drop dalyr 

** BASED ON ADJUSTED MORTALITY RATE 
** (R) Simple - relative
    bysort cod : egen m_min = min(mortr)
    bysort cod : egen m_max = max(mortr)
    gen rel_sim = m_max / m_min
    label var rel_sim "Relative inequality: WHO simple measure"

** (D) Simple - absolute
    gen abs_sim = m_max - m_min
    label var abs_sim "Absolute inequality: WHO simple measure"
    drop m_min m_max 

** (ID) Complex - relative (compared to Average of Americas)
    * --> Index of Disparity (Each country compared to Americas average rate)
    * --> number of countries in group 
    bysort cod : gen J = _N - 1
    gen americas1 = mortr if region==2000
    bysort cod : egen mort_am = min(americas1) 
    drop americas1 
    order mort_am, after(mortr)
    gen id1 = abs(mortr - mort_am)
    bysort cod : egen id2 = sum(id1) 
    gen id3 = id2 / mort_am
    gen id = (1/J) * id3 * 100
    drop mort_am id1 id2 id3 J
    order abs_sim rel_sim id , after(mortr)

    bysort cod: gen touse = 1 if _n==1 
    tabdisp cod, c(abs_sim rel_sim) format(%9.1f)
    tabdisp cod, c(id) format(%9.1f)

** ID to local macros
forval x = 1(1)6 {
    preserve
        keep if cod==`x' & touse==1
        local id`x' : dis %5.0f id
    restore
}

** Unicode markers for graphic
/// †  	U+2020 (alt-08224)	DAGGER = obelisk, obelus, long cross
/// ‡  	U+2021 (alt-08225)	DOUBLE DAGGER = diesis, double obelisk
/// •  	U+2022 (alt-08226)	BULLET = black small circle
local dagger = uchar(8224)
local ddagger = uchar(8225)
local section = uchar(0167) 
local teardrop = uchar(10045) 

** --------------------------------------------------------
** GRAPHIC
** --------------------------------------------------------

** Countries ordered by size for COD (1-6)
gsort cod mortr
gen region_new = region
label values region_new region_
#delimit ; 
    label define region_    28 "St.Vincent & Gren"
                            1 "Antigua & Barbuda"
                            30 "Trinidad & Tobago"
                            13 "Dominican Rep"
                            2000 "Americas", modify;
#delimit cr

decode region_new , gen(region_lab)
bysort cod : gen regiono = _n
forval x = 1(1)6 {
    gen region`x' = regiono if cod==`x'
    labmask region`x' if cod==`x', values(region_lab)
}

** Scale all rates to 100 - keeps shape of all bar charts, and allows us to more easily create a panel of 6 charts
bysort cod : egen maxr = max(mortr)
gen scaler = (mortr/maxr) * 100
order maxr scaler , after(mortr) 
forval x = 1(1)6 {
    gen scaler`x' = scaler if cod==`x'
}
gen origin1 = 0
gen origin2 = 120 
replace scaler2 = scaler2 + 120
gen origin3 = 240
replace scaler3 = scaler3 + 240
gen origin4 = 360 
replace scaler4 = scaler4 + 360
gen origin5 = 480 
replace scaler5 = scaler5 + 480
gen origin6 = 600 
replace scaler6 = scaler6 + 600

** --------------------------------------------------------------
** APPENDIX: BAR CHART ORDERED by COUNTRY (ALL CVDs)
** Change year on LINE 47 of DO FILE to repeat for 2000 and 2019
** --------------------------------------------------------------

gsort -cod mortr

** Bring scalar 6 back to be from 0 x-axis
replace scaler6 = scaler6 - 600

** Mortality rates on graphic RHS - creating X and Y variables for graphic
gen value6 = region6
gen mortr_int = round(mortr,1) 
tostring mortr_int, gen(mortr_str) force
labmask value6, val(mortr_str)
gen x6 = -50
drop mortr_int 
order cod region mortr mortr_str region6 scaler6 value6 

#delimit ;  
	gr twoway 
		/// country values
        (rbar origin1 scaler6 region6 if cod==6 & region!=2000, horizontal barw(0.6) fcol("`men1'") lcol("`men1'") lw(0.1))           
        (rbar origin1 scaler6 region6 if cod==6 & region==2000, horizontal barw(0.6) fcol(gs0) lcol(gs0) lw(0.1))           
        (sc value6 x6, msymbol(i) mlabel(value6) mlabsize(7) mlabcol(gs8) mlabp(0))
                		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			ysize(16) xsize(4)

			xlab(none, notick labs(7) tlc(gs0) labc(gs0) notick nogrid glc(gs16))
			xscale(noline range(1(1)100)) 
			xtitle("", size(7) color(gs0) margin(l=2 r=2 t=5 b=2)) 
			
			ylab(1(1)34, valuelabel
			labc(gs0) labs(7) tstyle(major_notick) nogrid glc(gs16) angle(0) format(%9.0f) labgap(5))
			yscale(noline lw(vthin) range(-2.5(0.5)36)) 
			ytitle("", size(7) margin(l=2 r=2 t=2 b=2)) 

           /// Region Titles 
           text(37 200 "All CVD" ,  place(c) size(7.5) color(gs8) just(center))

            /// INDEX OF DISPARITY VALUES
           text(35.5  -100 "IoD:"                       ,  place(c) size(11) color("`men1'") just(center))
           text(35.75 -175 "`teardrop'"                ,  place(c) size(5) color("`men1'") just(center))
           text(35.5  -20 "`id6'"                     ,  place(c) size(11) color("`men1'") just(center))

           /// Y-Axis text 
           text(-0.5 -50 "Mortality rate" "(per 100,000)" ,  
                                    place(c) size(6) color(gs8) just(center) linegap(1.25))
           /// NOTES
           text(-2 -100 "`teardrop' IoD = Index of Disparity." , 
                                    place(c) size(5) color(gs10) just(left) linegap(1.25))

            legend(off)
			name(bar_mort2000)
			;
#delimit cr	




** --------------------------------------------------------------
** --------------------------------------------------------------
** REPEAT MORTALITY FOR YEAR 2019
** --------------------------------------------------------------
** --------------------------------------------------------------

tempfile t1

** Mortality rate 
use "`datapath'\from-who\chap2_000_mr_adjusted", clear
keep year sex ghecause region mortr 
save `t1', replace 

** DALY rate 
use "`datapath'\from-who\chap2_000_daly_adjusted", clear
keep year sex ghecause region dalyr 
merge 1:1 year sex ghecause region using `t1' 
drop _merge

** Restrict
keep if sex==3
keep if year==2019
drop year sex 

**------------------------------------------------
** Ordered version of ghecause 
** MENTAL HEALTH
** (36)  1   "Drug use disorders" 
** (32)  2   "Depressive disorders" 
** (37)  3   "Anxiety disorders" 
** (35)  4   "Alcohol use disorders" 
** (34)  5   "Schizophrenia" 
** NEUROLOGICAL
** (42)  6   "Alzheimer/dementias"
** (46)  7   "Migraine"
** (44)  8   "Epilepsy"
** (47)  9   "Non-migraine headache"
** (43)  10  "Parkinson disease"
** (800)  11  "all mental"
** (900)  12  "all neurological"
** (100)  13  "all cause"  
** -----------------------------------------------
gen cod = .
replace cod = 1 if ghecause==36
replace cod = 2 if ghecause==32
replace cod = 3 if ghecause==37
replace cod = 4 if ghecause==35
replace cod = 5 if ghecause==34
replace cod = 6 if ghecause==800

replace cod = 7 if ghecause==42
replace cod = 8 if ghecause==46
replace cod = 9 if ghecause==44
replace cod = 10 if ghecause==47
replace cod = 11 if ghecause==43
replace cod = 12 if ghecause==900
#delimit ;
label define cod_   1   "Drug use disorders" 
                    2   "Depressive disorders" 
                    3   "Anxiety disorders" 
                    4   "Alcohol use disorders" 
                    5   "Schizophrenia" 
                    6  "all mental"
                    7   "Alzheimer/dementias"
                    8   "Migraine"
                    9   "Epilepsy"
                    10   "Non-migraine headache"
                    11  "Parkinson disease"
                    12  "all neurological", modify;
#delimit cr
label values cod cod_    
keep if cod<=6
sort cod


** Restrict region to countries + Americas 
keep if region < 100 | region==2000

** ---------------------------------------------------
** Statistics for the text to accompany this graphic
** Simple relative measure of inequality : Rate (R)
** Simple absolute measure of inequality : Difference (D)
** Simple relative measure of inequality : Index of Disparity (ID) 
** ---------------------------------------------------
drop dalyr 

** BASED ON ADJUSTED MORTALITY RATE 
** (R) Simple - relative
    bysort cod : egen m_min = min(mortr)
    bysort cod : egen m_max = max(mortr)
    gen rel_sim = m_max / m_min
    label var rel_sim "Relative inequality: WHO simple measure"

** (D) Simple - absolute
    gen abs_sim = m_max - m_min
    label var abs_sim "Absolute inequality: WHO simple measure"
    drop m_min m_max 

** (ID) Complex - relative (compared to Average of Americas)
    * --> Index of Disparity (Each country compared to Americas average rate)
    * --> number of countries in group 
    bysort cod : gen J = _N - 1
    gen americas1 = mortr if region==2000
    bysort cod : egen mort_am = min(americas1) 
    drop americas1 
    order mort_am, after(mortr)
    gen id1 = abs(mortr - mort_am)
    bysort cod : egen id2 = sum(id1) 
    gen id3 = id2 / mort_am
    gen id = (1/J) * id3 * 100
    drop mort_am id1 id2 id3 J
    order abs_sim rel_sim id , after(mortr)

    bysort cod: gen touse = 1 if _n==1 
    tabdisp cod, c(abs_sim rel_sim) format(%9.1f)
    tabdisp cod, c(id) format(%9.1f)

** ID to local macros
forval x = 1(1)6 {
    preserve
        keep if cod==`x' & touse==1
        local id`x' : dis %5.0f id
    restore
}

** Unicode markers for graphic
/// †  	U+2020 (alt-08224)	DAGGER = obelisk, obelus, long cross
/// ‡  	U+2021 (alt-08225)	DOUBLE DAGGER = diesis, double obelisk
/// •  	U+2022 (alt-08226)	BULLET = black small circle
local dagger = uchar(8224)
local ddagger = uchar(8225)
local section = uchar(0167) 
local teardrop = uchar(10045) 

** --------------------------------------------------------
** GRAPHIC
** --------------------------------------------------------

** Countries ordered by size for COD (1-6)
gsort cod mortr
gen region_new = region
label values region_new region_
#delimit ; 
    label define region_    28 "St.Vincent & Gren"
                            1 "Antigua & Barbuda"
                            30 "Trinidad & Tobago"
                            13 "Dominican Rep"
                            2000 "Americas", modify;
#delimit cr

decode region_new , gen(region_lab)
bysort cod : gen regiono = _n
forval x = 1(1)6 {
    gen region`x' = regiono if cod==`x'
    labmask region`x' if cod==`x', values(region_lab)
}

** Scale all rates to 100 - keeps shape of all bar charts, and allows us to more easily create a panel of 6 charts
bysort cod : egen maxr = max(mortr)
gen scaler = (mortr/maxr) * 100
order maxr scaler , after(mortr) 
forval x = 1(1)6 {
    gen scaler`x' = scaler if cod==`x'
}
gen origin1 = 0
gen origin2 = 120 
replace scaler2 = scaler2 + 120
gen origin3 = 240
replace scaler3 = scaler3 + 240
gen origin4 = 360 
replace scaler4 = scaler4 + 360
gen origin5 = 480 
replace scaler5 = scaler5 + 480
gen origin6 = 600 
replace scaler6 = scaler6 + 600

** --------------------------------------------------------------
** APPENDIX: BAR CHART ORDERED by COUNTRY (ALL CVDs)
** Change year on LINE 47 of DO FILE to repeat for 2000 and 2019
** --------------------------------------------------------------

gsort -cod mortr

** Bring scalar 6 back to be from 0 x-axis
replace scaler6 = scaler6 - 600

** Mortality rates on graphic RHS - creating X and Y variables for graphic
gen value6 = region6
gen mortr_int = round(mortr,1) 
tostring mortr_int, gen(mortr_str) force
labmask value6, val(mortr_str)
gen x6 = -50
drop mortr_int 
order cod region mortr mortr_str region6 scaler6 value6 

#delimit ;  
	gr twoway 
		/// country values
        (rbar origin1 scaler6 region6 if cod==6 & region!=2000, horizontal barw(0.6) fcol("`men1'") lcol("`men1'") lw(0.1))           
        (rbar origin1 scaler6 region6 if cod==6 & region==2000, horizontal barw(0.6) fcol(gs0) lcol(gs0) lw(0.1))           
        (sc value6 x6, msymbol(i) mlabel(value6) mlabsize(7) mlabcol(gs8) mlabp(0))
                		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			ysize(16) xsize(4)

			xlab(none, notick labs(7) tlc(gs0) labc(gs0) notick nogrid glc(gs16))
			xscale(noline range(1(1)100)) 
			xtitle("", size(7) color(gs0) margin(l=2 r=2 t=5 b=2)) 
			
			ylab(1(1)34, valuelabel
			labc(gs0) labs(7) tstyle(major_notick) nogrid glc(gs16) angle(0) format(%9.0f) labgap(5))
			yscale(noline lw(vthin) range(-2.5(0.5)36)) 
			ytitle("", size(7) margin(l=2 r=2 t=2 b=2)) 

           /// Region Titles 
           text(37 200 "All CVD" ,  place(c) size(7.5) color(gs8) just(center))

            /// INDEX OF DISPARITY VALUES
           text(35.5  -100 "IoD:"                       ,  place(c) size(11) color("`men1'") just(center))
           text(35.75 -175 "`teardrop'"                ,  place(c) size(5) color("`men1'") just(center))
           text(35.5  -20 "`id6'"                     ,  place(c) size(11) color("`men1'") just(center))

           /// Y-Axis text 
           text(-0.5 -50 "Mortality rate" "(per 100,000)" ,  
                                    place(c) size(6) color(gs8) just(center) linegap(1.25))
           /// NOTES
           text(-2 -100 "`teardrop' IoD = Index of Disparity." , 
                                    place(c) size(5) color(gs10) just(left) linegap(1.25))

            legend(off)
			name(bar_mort2019)
			;
#delimit cr	
