** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap2-640-neuro-bar.do
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
    log using "`logpath'\chap2-640-neuro-bar", replace
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
forval x = 1(1)12 {
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
decode region , gen(region_lab)
bysort cod : gen regiono = _n
forval x = 1(1)12 {
    gen region`x' = regiono if cod==`x'
    labmask region`x' if cod==`x', values(region_lab)
}

** Scale all rates to 100 - keeps shape of all bar charts, and allows us to more easily create a panel of 6 charts
bysort cod : egen maxr = max(dalyr)
gen scaler = (dalyr/maxr) * 100
order maxr scaler , after(dalyr) 
forval x = 1(1)12 {
    gen scaler`x' = scaler if cod==`x'
}
gen origin7 = 0
gen origin8 = 120 
replace scaler8 = scaler8 + 120
gen origin9 = 240
replace scaler9 = scaler9 + 240
gen origin10 = 360 
replace scaler10 = scaler10 + 360
gen origin11 = 480 
replace scaler11 = scaler11 + 480
gen origin12 = 600 
replace scaler12 = scaler12 + 600

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
    forval x = 61(1)70 {
        local cid7_`x' = region_lab[`x'] 
    }
    ** depressive disorders
    forval x = 71(1)80 {
        local cid8_`x' = region_lab[`x'] 
    }
    ** anxiety disorders
    forval x = 81(1)90 {
        local cid9_`x' = region_lab[`x'] 
    }
    ** alcohol use disorders
    forval x = 91(1)100 {
        local cid10_`x' = region_lab[`x'] 
    }
    ** schizophrenia
    forval x = 101(1)110 {
        local cid11_`x' = region_lab[`x'] 
    }
    ** All mental health
    forval x = 111(1)120 {
        local cid12_`x' = region_lab[`x'] 
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
        (rbar origin7  scaler7   region7  if cod==7  & region!=2000, horizontal barw(0.6) fcol("`youth'") lcol("`youth'") lw(0.1))       
        (rbar origin8  scaler8   region8  if cod==8  & region!=2000, horizontal barw(0.6) fcol("`youth'") lcol("`youth'") lw(0.1))           
        (rbar origin9  scaler9   region9  if cod==9  & region!=2000, horizontal barw(0.6) fcol("`youth'") lcol("`youth'") lw(0.1))           
        (rbar origin10 scaler10  region10 if cod==10 & region!=2000, horizontal barw(0.6) fcol("`youth'") lcol("`youth'") lw(0.1))           
        (rbar origin11 scaler11  region11 if cod==11 & region!=2000, horizontal barw(0.6) fcol("`youth'") lcol("`youth'") lw(0.1))           
        (rbar origin12 scaler12  region12 if cod==12 & region!=2000, horizontal barw(0.6) fcol("`youth'") lcol("`youth'") lw(0.1))           

        (rbar origin7  scaler7  region7  if cod==7  & region==2000, horizontal barw(0.6) fcol("gs0") lcol("gs0") lw(0.1))       
        (rbar origin8  scaler8  region8  if cod==8  & region==2000, horizontal barw(0.6) fcol("gs0") lcol("gs0") lw(0.1))           
        (rbar origin9  scaler9  region9  if cod==9  & region==2000, horizontal barw(0.6) fcol("gs0") lcol("gs0") lw(0.1))           
        (rbar origin10 scaler10 region10 if cod==10 & region==2000, horizontal barw(0.6) fcol("gs0") lcol("gs0") lw(0.1))           
        (rbar origin11 scaler11 region11 if cod==11 & region==2000, horizontal barw(0.6) fcol("gs0") lcol("gs0") lw(0.1))           
        (rbar origin12 scaler12 region12 if cod==12 & region==2000, horizontal barw(0.6) fcol("gs0") lcol("gs0") lw(0.1))           
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
           text(67 50 "Alzheimer /" "dementias"          ,  place(c) size(3.5) color(gs8) just(center))
           text(67 170 "Migraine"       ,  place(c) size(3.5) color(gs8) just(center))
           text(67 290 "Epilepsy"          ,  place(c) size(3.5) color(gs8) just(center))
           text(67 410 "Non-migraine" "headache"      ,  place(c) size(3.5) color(gs8) just(center))
           text(67 530 "Parkinson" "disease"                ,  place(c) size(3.5) color(gs8) just(center))
           text(67 650 "All" "neurological"          ,  place(c) size(3.5) color(gs8) just(center))

            /// INDEX OF DISPARITY VALUES
           /// text(-4.4 0.3 "ID{superscript:`ddagger'}" ,  place(c) size(7) color("`child'*0.5") just(center))
           text(16.5 70 "IoD"                        ,  place(c) size(6) color("`child'*0.5") just(center))
           text(19   89 "`teardrop'"               ,  place(c) size(2.5) color("`child'*0.5") just(center))
           text(10   75 "`id7'"                     ,  place(c) size(7) color("`child'*0.5") just(center))
           text(10   205 "`id8'"                     ,  place(c) size(7) color("`child'*0.5") just(center))
           text(10   320 "`id9'"                     ,  place(c) size(7) color("`child'*0.5") just(center))
           text(10   440 "`id10'"                     ,  place(c) size(7) color("`child'*0.5") just(center))
           text(10   555 "`id11'"                     ,  place(c) size(7) color("`child'*0.5") just(center))
           text(10   680 "`id12'"                     ,  place(c) size(7) color("`child'*0.5") just(center))

           /// Y-Axis text 
           text(-29.5 340 "Age-standardized DALY rate (per 100,000)" ,  
                                    place(c) size(3.5) color("gs8") just(center))

           /// High Rate Countries
           /// Alzheimer / dementias
           text(55 105  "`cid7_70' (1)",  place(w) size(3) color("`child'*0.5") just(right))
           text(51 105  "`cid7_69' (2)",  place(w) size(3) color("`child'*0.5") just(right))
           text(47 105  "`cid7_68' (3)",  place(w) size(3) color("`child'*0.5") just(right))
           text(43 105  "`cid7_67' (4)",  place(w) size(3) color("`child'*0.5") just(right))
           text(39 105  "`cid7_66' (5)",  place(w) size(3) color("`child'*0.5") just(right))
           text(-7 105  "`cid7_65' (5)",  place(w) size(3) color("`child'*0.5") just(right))
           text(-11 105 "`cid7_64' (4)",  place(w) size(3) color("`child'*0.5") just(right))
           text(-15 105 "`cid7_63' (3)",  place(w) size(3) color("`child'*0.5") just(right))
           text(-19 105 "`cid7_62' (2)",  place(w) size(3) color("`child'*0.5") just(right))
           text(-23 105 "`cid7_61' (1)",  place(w) size(3) color("`child'*0.5") just(right))

           /// Migraine
           text(55 225  "`cid8_80'",  place(w) size(3) color("`child'*0.5") just(right))
           text(51 225  "`cid8_79'",  place(w) size(3) color("`child'*0.5") just(right))
           text(47 225  "`cid8_78'",  place(w) size(3) color("`child'*0.5") just(right))
           text(43 225  "`cid8_77'",  place(w) size(3) color("`child'*0.5") just(right))
           text(39 225  "`cid8_76'",  place(w) size(3) color("`child'*0.5") just(right))
           text(-7 225  "`cid8_75'",  place(w) size(3) color("`child'*0.5") just(right))
           text(-11 225 "`cid8_74'",  place(w) size(3) color("`child'*0.5") just(right))
           text(-15 225 "`cid8_73'",  place(w) size(3) color("`child'*0.5") just(right))
           text(-19 225 "`cid8_72'",  place(w) size(3) color("`child'*0.5") just(right))
           text(-23 225 "`cid8_71'",  place(w) size(3) color("`child'*0.5") just(right))
           
           /// Epilepsy
           text(55 345  "`cid9_90'",  place(w) size(3) color("`child'*0.5") just(right))
           text(51 345  "`cid9_89'",  place(w) size(3) color("`child'*0.5") just(right))
           text(47 345  "`cid9_88'",  place(w) size(3) color("`child'*0.5") just(right))
           text(43 345  "`cid9_87'",  place(w) size(3) color("`child'*0.5") just(right))
           text(39 345  "`cid9_86'",  place(w) size(3) color("`child'*0.5") just(right))
           text(-7 345  "`cid9_85'",  place(w) size(3) color("`child'*0.5") just(right))
           text(-11 345 "`cid9_84'",  place(w) size(3) color("`child'*0.5") just(right))
           text(-15 345 "`cid9_83'",  place(w) size(3) color("`child'*0.5") just(right))
           text(-19 345 "`cid9_82'",  place(w) size(3) color("`child'*0.5") just(right))
           text(-23 345 "`cid9_81'",  place(w) size(3) color("`child'*0.5") just(right))
 
           /// Non-migraine headache
           text(55 465  "`cid10_100'",  place(w) size(3) color("`child'*0.5") just(right))
           text(51 465  "`cid10_99'",  place(w) size(3) color("`child'*0.5") just(right))
           text(47 465  "`cid10_98'",  place(w) size(3) color("`child'*0.5") just(right))
           text(43 465  "`cid10_97'",  place(w) size(3) color("`child'*0.5") just(right))
           text(39 465  "`cid10_96'",  place(w) size(3) color("`child'*0.5") just(right))
           text(-7 465  "`cid10_95'",  place(w) size(3) color("`child'*0.5") just(right))
           text(-11 465 "`cid10_94'",  place(w) size(3) color("`child'*0.5") just(right))
           text(-15 465 "`cid10_93'",  place(w) size(3) color("`child'*0.5") just(right))
           text(-19 465 "`cid10_92'",  place(w) size(3) color("`child'*0.5") just(right))
           text(-23 465 "`cid10_91'",  place(w) size(3) color("`child'*0.5") just(right))
 
           /// parkinson disease
           text(55 585  "`cid11_110'",  place(w) size(3) color("`child'*0.5") just(right))
           text(51 585  "`cid11_109'",  place(w) size(3) color("`child'*0.5") just(right))
           text(47 585  "`cid11_108'",  place(w) size(3) color("`child'*0.5") just(right))
           text(43 585  "`cid11_107'",  place(w) size(3) color("`child'*0.5") just(right))
           text(39 585  "`cid11_106'",  place(w) size(3) color("`child'*0.5") just(right))
           text(-7 585  "`cid11_105'",  place(w) size(3) color("`child'*0.5") just(right))
           text(-11 585 "`cid11_104'",  place(w) size(3) color("`child'*0.5") just(right))
           text(-15 585 "`cid11_103'",  place(w) size(3) color("`child'*0.5") just(right))
           text(-19 585 "`cid11_102'",  place(w) size(3) color("`child'*0.5") just(right))
           text(-23 585 "`cid11_101'",  place(w) size(3) color("`child'*0.5") just(right))
 
           /// All neurological
           text(55 705  "`cid12_120'",  place(w) size(3) color("`child'*0.5") just(right))
           text(51 705  "`cid12_119'",  place(w) size(3) color("`child'*0.5") just(right))
           text(47 705  "`cid12_118'",  place(w) size(3) color("`child'*0.5") just(right))
           text(43 705  "`cid12_117'",  place(w) size(3) color("`child'*0.5") just(right))
           text(39 705  "`cid12_116'",  place(w) size(3) color("`child'*0.5") just(right))
           text(-7 705  "`cid12_115'",  place(w) size(3) color("`child'*0.5") just(right))
           text(-11 705 "`cid12_114'",  place(w) size(3) color("`child'*0.5") just(right))
           text(-15 705 "`cid12_113'",  place(w) size(3) color("`child'*0.5") just(right))
           text(-19 705 "`cid12_112'",  place(w) size(3) color("`child'*0.5") just(right))
           text(-23 705 "`cid12_111'",  place(w) size(3) color("`child'*0.5") just(right))

           /// NOTE
           text(-34.5 0.5 "`teardrop' IoD = Index of Disparity. Measures the average (mean) deviation of each country rate from the regional rate, as a percentage." , 
                                    place(e) size(2.25) color(gs10) just(left) )
           text(-38.5 0.5 "`dagger' BLACK BAR is the DALY rate for the Region of the Americas." ,  
                                    place(e) size(2.25) color(gs10)  just(left))
			legend(off)
			name(bar1)
			;
#delimit cr	


/*



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
replace cod = 1 if ghecause==42
replace cod = 2 if ghecause==46
replace cod = 3 if ghecause==44
replace cod = 4 if ghecause==47
replace cod = 5 if ghecause==43
replace cod = 6 if ghecause==900

#delimit ;
label define cod_  
                    1   "Alzheimer/dementias"
                    2   "Migraine"
                    3   "Epilepsy"
                    4   "Non-migraine headache"
                    5  "Parkinson disease"
                    6  "all neurological", modify;
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
replace cod = 1 if ghecause==42
replace cod = 2 if ghecause==46
replace cod = 3 if ghecause==44
replace cod = 4 if ghecause==47
replace cod = 5 if ghecause==43
replace cod = 6 if ghecause==900

#delimit ;
label define cod_  
                    1   "Alzheimer/dementias"
                    2   "Migraine"
                    3   "Epilepsy"
                    4   "Non-migraine headache"
                    5  "Parkinson disease"
                    6  "all neurological", modify;
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
replace cod = 1 if ghecause==42
replace cod = 2 if ghecause==46
replace cod = 3 if ghecause==44
replace cod = 4 if ghecause==47
replace cod = 5 if ghecause==43
replace cod = 6 if ghecause==900

#delimit ;
label define cod_  
                    1   "Alzheimer/dementias"
                    2   "Migraine"
                    3   "Epilepsy"
                    4   "Non-migraine headache"
                    5  "Parkinson disease"
                    6  "all neurological", modify;
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
replace cod = 1 if ghecause==42
replace cod = 2 if ghecause==46
replace cod = 3 if ghecause==44
replace cod = 4 if ghecause==47
replace cod = 5 if ghecause==43
replace cod = 6 if ghecause==900

#delimit ;
label define cod_  
                    1   "Alzheimer/dementias"
                    2   "Migraine"
                    3   "Epilepsy"
                    4   "Non-migraine headache"
                    5  "Parkinson disease"
                    6  "all neurological", modify;
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
