** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap2-540-diabetes-bar.do
    //  project:				    WHO Global Health Estimates
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	19-August-2021
    //  algorithm task			    Leading causes of diabetes death: by-country bar chart

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
    log using "`logpath'\chap2-540-diabetes-bar", replace
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
** Create new GHE CoD order 
** 31 - Diabetes
** -----------------------------------------------
gen     cod = 1 if ghecause==31 
#delimit ; 
label define cod_   1 "diabetes" , modify ;
#delimit cr
label values cod cod_ 
sort cod 
drop ghecause 
order cod region mortr dalyr 
keep if cod<=1

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

** (ID) Complex - relative
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
    preserve
        keep if cod==1 & touse==1
        local id1 : dis %5.0f id
    restore

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

** COLORS - PURPLES for CVD
    colorpalette #6c6c13 #adad1f #dddd3c #e8e87d #f4f4be, nograph
    local list r(p) 
    ** Age groups
    local child `r(p1)'    
    local youth `r(p2)'    
    local young `r(p3)'    
    local older `r(p4)'    
    local elderly `r(p5)'   

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

** Outer boxes (CANCER CAUSES 7-11)
local touter1   52 -10   9 -10   9 110   52 110   52 -10 

local touter2a  52 110   52 230  
local touter2b  52 230   9 230  
local touter2c  9 110   9 230 


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
    gen region1 = regiono if cod==1
    labmask region1 if cod==1, values(region_lab)

** Scale all rates to 100 - keeps shape of all bar charts, and allows us to more easily create a panel of 6 charts
bysort cod : egen maxr = max(mortr)
gen scaler = (mortr/maxr) * 100
order maxr scaler , after(mortr) 
    gen scaler1 = scaler if cod==1
gen origin1 = 0


** COUNTRIES with High and Low Mortality Rates
preserve
    drop if region==2000
    sort cod mortr
    bysort cod: gen include = _n
    mark keepme if include<=5 | include>=29
    keep if keepme==1
    bysort cod : gen regiono2 = _n
    order include regiono2, after(mortr)
    ** Diabetes
    forval x = 1(1)10 {
        local cid1_`x' = region_lab[`x'] 
    }
restore

#delimit ;
	gr twoway 
		/// outer boxes 
        (scatteri `outer1'  , recast(area) lw(0.2) lc(gs10) fc(none) )
        ///(scatteri `outer2a' , recast(line) lw(0.2) lc(gs10) fc(none) )
        ///(scatteri `outer2b' , recast(line) lw(0.2) lc(gs10) fc(none) )
        ///(scatteri `outer2c' , recast(line) lw(0.2) lc(gs10) fc(none) )
        ///(scatteri `outer3a' , recast(line) lw(0.2) lc(gs10) fc(none) )
        ///(scatteri `outer3b' , recast(line) lw(0.2) lc(gs10) fc(none) )
        ///(scatteri `outer3c' , recast(line) lw(0.2) lc(gs10) fc(none) )

		/// country values
        (rbar origin1 scaler1 region1 if cod==1 & region!=2000, horizontal barw(0.6) fcol("`youth'") lcol("`youth'") lw(0.1))                   

        (rbar origin1 scaler1 region1 if cod==1 & region==2000, horizontal barw(0.6) fcol(gs0) lcol(gs0) lw(0.1))              
                		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			ysize(15) xsize(11)

			xlab(none, notick labs(7) tlc(gs0) labc(gs0) notick nogrid glc(gs16))
			xscale(noline ) 
			xtitle("", size(5) color(gs0) margin(l=2 r=2 t=5 b=2)) 
			
			ylab(none,
			labc(gs0) labs(3) tstyle(major_notick) nogrid glc(gs16) angle(0) format(%9.0f))
			yscale(noline lw(vthin) range(-44(2)65)) 
			ytitle("", size(5) margin(l=2 r=5 t=2 b=2)) 

           /// Region Titles 
           text(66 50 "Diabetes"       ,  place(c) size(6) color(gs8) just(center))

            /// INDEX OF DISPARITY VALUES
           /// text(-4.4 0.3 "ID{superscript:`ddagger'}" ,  place(c) size(7) color("`child'*0.5") just(center))
           text(15 60 "IoD"                       ,  place(c) size(9) color("`child'*0.5") just(center))
           text(17 75 "`teardrop'"                ,  place(c) size(4) color("`child'*0.5") just(center))
           ///text(14 60 "Index"                     ,  place(c) size(6) color("`child'*0.75") just(center))
           text(7 60 "`id1'"                     ,  place(c) size(9) color("`child'*0.5") just(center))

           /// Y-Axis text 
           text(-31 40 "Age-standardized" "mortality rate (per 100,000)" ,  
                                    place(c) size(5) color(gs8) just(center))

           /// High Rate Countries
           /// COPD
           text(59 0 "Highest Rates:",  place(e) size(5.5) color("`child'*0.80") just(right))
           text(55 105 "`cid1_10' (1)",  place(w) size(4.5) color("`child'*0.5") just(right))
           text(51 105 "`cid1_9' (2)",  place(w) size(4.5) color("`child'*0.5") just(right))
           text(47 105 "`cid1_8' (3)",  place(w) size(4.5) color("`child'*0.5") just(right))
           text(43 105 "`cid1_7' (4)",  place(w) size(4.5) color("`child'*0.5") just(right))
           text(39 105 "`cid1_6' (5)",  place(w) size(4.5) color("`child'*0.5") just(right))
           text(-3 0 "Lowest Rates:",  place(e) size(5.5) color("`child'*0.80") just(right))
           text(-7 105 "`cid1_5' (5)" ,  place(w) size(4.5) color("`child'*0.5") just(right))
           text(-11 105 "`cid1_4' (4)",  place(w) size(4.5) color("`child'*0.5") just(right))
           text(-15 105 "`cid1_3' (3)",  place(w) size(4.5) color("`child'*0.5") just(right))
           text(-19 105 "`cid1_2' (2)",  place(w) size(4.5) color("`child'*0.5") just(right))
           text(-23 105 "`cid1_1' (1)",  place(w) size(4.5) color("`child'*0.5") just(right))
 
           /// NOTE
           text(-38 0.5 "`teardrop' IoD = Index of Disparity. Measures the average (mean) deviation of each " ,  
                                    place(e) size(2.5) color(gs8)  just(left)) 
           text(-40.2 0.75 "             country rate from the regional rate, as a percentage." ,  
                                    place(e) size(2.5) color(gs8)  just(left))
           text(-43.7 0 "`ddagger' BLACK BAR, mortality rate for the Region of the Americas." ,  
                                    place(e) size(2.5) color(gs8)  just(left))
			legend(off)
			name(bar1)
			;
#delimit cr	


** Export to Vector Graphic
** DEC 22nd, 2022
graph export "`outputpath'\reports\graphics\fig2-12.svg", replace
graph export "`outputpath'\reports\graphics\fig2-12.pdf", replace




/*
** ----------------------------------------
** ----------------------------------------
** APPENDIX CHARTS ADDED
** 29-SEP-2021
** ----------------------------------------
** ----------------------------------------

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
** APPENDIX: BAR CHART ORDERED by COUNTRY (ALL CVDs)
** Change year on LINE 47 of DO FILE to repeat for 2000 and 2019
** --------------------------------------------------------------

gsort -cod mortr

** Bring scalar 6 back to be from 0 x-axis
/// replace scaler1 = scaler1 - 240

** Mortality rates on graphic RHS - creating X and Y variables for graphic
gen value1 = region1
gen mortr_int = round(mortr,1) 
tostring mortr_int, gen(mortr_str) force
labmask value1, val(mortr_str)
gen x1 = -50
drop mortr_int 
order cod region mortr mortr_str region1 scaler1 value1 

#delimit ;  
	gr twoway 
		/// country values
        (rbar origin1 scaler1 region1 if cod==1 & region!=2000, horizontal barw(0.6) fcol("`dia1'") lcol("`dia1'") lw(0.1))           
        (rbar origin1 scaler1 region1 if cod==1 & region==2000, horizontal barw(0.6) fcol(gs0) lcol(gs0) lw(0.1))           
        (sc value1 x1, msymbol(i) mlabel(value1) mlabsize(7) mlabcol(gs8) mlabp(0))
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
           text(35.5  -125 "IoD:"                       ,  place(c) size(11) color("`dia1'") just(center))
           text(35.75 -200 "`teardrop'"                ,  place(c) size(5) color("`dia1'") just(center))
           text(35.5  -20 "`id1'"                     ,  place(c) size(11) color("`dia1'") just(center))

           /// Y-Axis text 
           text(-0.5 -125 "Mortality rate" "(per 100,000)" ,  
                                    place(c) size(6) color(gs8) just(center) linegap(1.25))
           /// NOTES
           text(-2 -175 "`teardrop' IoD = Index of Disparity." , 
                                    place(c) size(5) color(gs10) just(left) linegap(1.25))

            legend(off)
			name(bar_mort2019)
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
** Create new GHE CoD order 
** 31 - Diabetes
** -----------------------------------------------
gen     cod = 1 if ghecause==31 
#delimit ; 
label define cod_   1 "diabetes" , modify ;
#delimit cr
label values cod cod_ 
sort cod 
drop ghecause 
order cod region mortr dalyr 
keep if cod<=1


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
    preserve
         keep if cod==1 & touse==1
         local id1 : dis %5.0f id
    restore

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
    gen region1 = regiono if cod==1
    labmask region1 if cod==1, values(region_lab)

** Scale all rates to 100 - keeps shape of all bar charts, and allows us to more easily create a panel of 6 charts
bysort cod : egen maxr = max(mortr)
gen scaler = (mortr/maxr) * 100
order maxr scaler , after(mortr) 
gen scaler1 = scaler if cod==1
gen origin1 = 0



** --------------------------------------------------------------
** APPENDIX: BAR CHART ORDERED by COUNTRY (ALL CVDs)
** Change year on LINE 47 of DO FILE to repeat for 2000 and 2019
** --------------------------------------------------------------

gsort -cod mortr

** Bring scalar 6 back to be from 0 x-axis
///replace scaler1 = scaler1 - 240

** Mortality rates on graphic RHS - creating X and Y variables for graphic
gen value1 = region1
gen mortr_int = round(mortr,1) 
tostring mortr_int, gen(mortr_str) force
labmask value1, val(mortr_str)
gen x1 = -50
drop mortr_int 
order cod region mortr mortr_str region1 scaler1 value1 

#delimit ;  
	gr twoway 
		/// country values
        (rbar origin1 scaler1 region1 if cod==1 & region!=2000, horizontal barw(0.6) fcol("`dia1'") lcol("`dia1'") lw(0.1))           
        (rbar origin1 scaler1 region1 if cod==1 & region==2000, horizontal barw(0.6) fcol(gs0) lcol(gs0) lw(0.1))           
        (sc value1 x1, msymbol(i) mlabel(value1) mlabsize(7) mlabcol(gs8) mlabp(0))
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
           text(35.5  -125 "IoD:"                       ,  place(c) size(11) color("`dia1'") just(center))
           text(35.75 -200 "`teardrop'"                ,  place(c) size(5) color("`dia1'") just(center))
           text(35.5  -20 "`id1'"                     ,  place(c) size(11) color("`dia1'") just(center))

           /// Y-Axis text 
           text(-0.5 -125 "Mortality rate" "(per 100,000)" ,  
                                    place(c) size(6) color(gs8) just(center) linegap(1.25))
           /// NOTES
           text(-2 -175 "`teardrop' IoD = Index of Disparity." , 
                                    place(c) size(5) color(gs10) just(left) linegap(1.25))

            legend(off)
			name(bar_mort2000)
			;
#delimit cr	






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
** Create new GHE CoD order 
** 31 - Diabetes
** -----------------------------------------------
gen     cod = 1 if ghecause==31 
#delimit ; 
label define cod_   1 "diabetes" , modify ;
#delimit cr
label values cod cod_ 
sort cod 
drop ghecause 
order cod region mortr dalyr 
keep if cod<=1


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
    preserve
        keep if cod==1 & touse==1
        local id1 : dis %5.0f id
    restore

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
    gen region1 = regiono if cod==1
    labmask region1 if cod==1, values(region_lab)

** Scale all rates to 100 - keeps shape of all bar charts, and allows us to more easily create a panel of 6 charts
bysort cod : egen maxr = max(dalyr)
gen scaler = (dalyr/maxr) * 100
order maxr scaler , after(dalyr) 
    gen scaler1 = scaler if cod==1
gen origin1 = 0


** --------------------------------------------------------------
** APPENDIX: BAR CHART ORDERED by COUNTRY (ALL CVDs)
** Change year on LINE 47 of DO FILE to repeat for 2000 and 2019
** --------------------------------------------------------------

gsort -cod -dalyr
order cod region dalyr region1 scaler1 

** Bring scalar 1 back to be from 0 x-axis
/// replace scaler1 = scaler1 - 240

** Mortality rates on graphic RHS - creating X and Y variables for graphic
gen value1 = region1
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
labmask value1, val(num_str)
gen x1 = -120
drop dalyr_int hun thou slen num_str
order cod region dalyr dalyr_str region1 scaler1 value1 

#delimit ;  
	gr twoway 
		/// country values
        (rbar origin1 scaler1 region1 if cod==1 & region!=2000, horizontal barw(0.6) fcol("`dia2'") lcol("`dia2'") lw(0.1))           
        (rbar origin1 scaler1 region1 if cod==1 & region==2000, horizontal barw(0.6) fcol(gs0) lcol(gs0) lw(0.1))           
        (sc value1 x1, msymbol(i) mlabel(value1) mlabsize(7) mlabcol(gs8) mlabp(0))
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
           text(35.5  -200 "IoD:"                       ,  place(c) size(11) color("`dia1'") just(center))
           text(35.75 -350 "`teardrop'"                ,  place(c) size(5) color("`dia1'") just(center))
           text(35.5  -20 "`id1'"                     ,  place(c) size(11) color("`dia1'") just(center))

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
** Create new GHE CoD order 
** 31 - Diabetes
** -----------------------------------------------
gen     cod = 1 if ghecause==31 
#delimit ; 
label define cod_   1 "diabetes" , modify ;
#delimit cr
label values cod cod_ 
sort cod 
drop ghecause 
order cod region mortr dalyr 
keep if cod<=1

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
    preserve
        keep if cod==1 & touse==1
        local id1 : dis %5.0f id
    restore

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
    gen region1 = regiono if cod==1
    labmask region1 if cod==1, values(region_lab)


** Scale all rates to 100 - keeps shape of all bar charts, and allows us to more easily create a panel of 6 charts
bysort cod : egen maxr = max(dalyr)
gen scaler = (dalyr/maxr) * 100
order maxr scaler , after(dalyr) 
    gen scaler1 = scaler if cod==1
gen origin1 = 0


** --------------------------------------------------------------
** APPENDIX: BAR CHART ORDERED by COUNTRY (ALL CVDs)
** Change year on LINE 47 of DO FILE to repeat for 2000 and 2019
** --------------------------------------------------------------

gsort -cod -dalyr
order cod region dalyr region1 scaler1 

** Bring scalar 3 back to be from 0 x-axis
///replace scaler3 = scaler3 - 240

** Mortality rates on graphic RHS - creating X and Y variables for graphic
gen value1 = region1
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
labmask value1, val(num_str)
gen x1 = -120
drop dalyr_int hun thou slen num_str
order cod region dalyr dalyr_str region1 scaler1 value1 

#delimit ;  
	gr twoway 
		/// country values
        (rbar origin1 scaler1 region1 if cod==1 & region!=2000, horizontal barw(0.6) fcol("`dia2'") lcol("`dia2'") lw(0.1))           
        (rbar origin1 scaler1 region1 if cod==1 & region==2000, horizontal barw(0.6) fcol(gs0) lcol(gs0) lw(0.1))           
        (sc value1 x1, msymbol(i) mlabel(value1) mlabsize(7) mlabcol(gs8) mlabp(0))
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
           text(35.5  -200 "IoD:"                       ,  place(c) size(11) color("`dia1'") just(center))
           text(35.75 -350 "`teardrop'"                ,  place(c) size(5) color("`dia1'") just(center))
           text(35.5  -20 "`id1'"                     ,  place(c) size(11) color("`dia1'") just(center))

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
