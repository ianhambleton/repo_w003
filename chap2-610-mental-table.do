** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap2-610-mental-table.do
    //  project:				    WHO Global Health Estimates
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	26-Apr-2021
    //  algorithm task			    Preparing Data for a summary CVD table

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
    log using "`logpath'\chap2-610-mental-table", replace
** HEADER -----------------------------------------------------


** -----------------------------------------------------
** GRAPHICS COLOR SCHEME
** -----------------------------------------------------
    colorpalette ptol, rainbow n(12)  nograph
    local list r(p) 
    ** Mortality Rate
    local mrate `r(p1)'
    ** DALY
    local daly `r(p4)'
    ** Improve and worsen
    local improve `r(p7)'
    local worsen `r(p12)'

    ** generate a local for the ColorBrewer color scheme
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



** -----------------------------------------------------
** TABLE PART ONE 
** DEATHS METRICS
** -----------------------------------------------------

tempfile kcancer region_mr12 region_mr3 region_daly12 region_daly3

** Use the dataset saved from (chap2-600-mental-stats) DO file
use "`datapath'\from-who\chap2_000_adjusted_mentalhealthonly", replace
rename mortr arate

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
replace cod = 1 if type==1 & top5==1
replace cod = 2 if type==1 & top5==2
replace cod = 3 if type==1 & top5==3
replace cod = 4 if type==1 & top5==4
replace cod = 5 if type==1 & top5==5
replace cod = 6 if type==2 & top5==1
replace cod = 7 if type==2 & top5==2
replace cod = 8 if type==2 & top5==3
replace cod = 9 if type==2 & top5==4
replace cod = 10 if type==2 & top5==5
replace cod = 11 if ghecause==800
replace cod = 12 if ghecause==900
replace cod = 13 if ghecause==100
#delimit ;
label define cod_   1   "Drug use disorders" 
                    2   "Depressive disorders" 
                    3   "Anxiety disorders" 
                    4   "Alcohol use disorders" 
                    5   "Schizophrenia" 
                    6   "Migraine"
                    7   "Alzheimer/dementias"
                    8   "Epilepsy"
                    9  "Non-migraine headache"
                    10 "Parkinson disease"
                    11   "All mental"
                    12  "All neurological", modify;
#delimit cr
label values cod cod_    
keep if cod<=12



** -----------------------------------------------------
** COLUMN 1
** Outputs: Total Deaths
** deaths1 to deaths6 (1-6 are the GHE causes)
** -----------------------------------------------------
** Number of deaths in the Americas in 2019 by GHE CoD 
** Women and men combined 
preserve 
    keep if region==2000 & year==2019 & sex==3
    ** collapse (sum) dths, by(cod)
    tabdisp cod  , cell(dths) format(%10.0fc)
    sort cod 

    gen dths_int = round(dths)
    mkmat cod dths_int , matrix(col1)
    matrix list col1
    forval x = 1(1)12 {
        global deaths`x' = col1[`x',2]
    }
restore


** -----------------------------------------------------
** COLUMN 2
** Outputs: Mortality Rate 2019
** arate1 to arate6 (1-6 are the GHE causes)
** -----------------------------------------------------
** Mortality Rate in 2019
preserve
    sort sex cod 
    ** replace arate = arate_new if arate_new<. 
    keep if region==2000 & year==2019 & sex==3
    ** Women and Men combined  
    tabdisp cod , cell(arate) format(%6.4fc) 
    sort cod 
    gen arate_int = round(arate, 0.1)
    mkmat cod arate_int , matrix(col2)
    matrix list col2
    forval x = 1(1)12 {
        global arate`x' = col2[`x',2]
    }
restore 



** -----------------------------------------------------
** COLUMN 3 
** Outputs: Mortality Rate change over time 
** spike1.png to spike6.png (1-6 are the GHE causes)
** -----------------------------------------------------
** Sparkline of Mortality Rate change over time
preserve
    keep if region==2000

    ** Lower Boundary (0.55 for cancers) for shading boundary 
    gen y = 0.55 

    ** Relative Rate 
    gen ar1 = arate if year==2000
    bysort sex cod : egen ar2 = min(ar1)
    drop ar1 
    gen rel_arate = arate/ar2

    ** Women and Men combined
    forval a = 1(1)12 { 
        #delimit ;
            gr twoway 
                (rarea rel_arate y year if cod==`a' & sex==3 & region==2000 , sort lw(none) color("`men1'%85"))
                (line rel_arate year if cod==`a' & sex==3 & region==2000, sort lc("`men1'") fc("`men1'") lw(6) msize(2.5))
                ///(sc rel_arate year if cod==`a' & sex==3 & region==2000, sort m(O) mfc("gs16") mlw(1) mlc("`cvd1'") msize(3.5) )
                ,
                    plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
                    graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
                    ysize(15) xsize(20)
                    
                    xlab(, 
                    labs(medsmall) nogrid glc(gs14) angle(0) labgap(3))
                    xscale(off lw(vthin) range(1999.5(0.5)2019.5))  
                    xtitle("", margin(t=3) size(medsmall)) 
                    yscale(off lw(vthin) ) 
                    ylab(,nogrid)
                    legend(off)
                    name(spark_mr_`a')
                    ;
            #delimit cr
        graph export "`outputpath'\graphics\spike`a'.png" , replace
        graph export "`outputpath'\reports\graphics\table2-5\table2-5-col4-row`a'.pdf", replace
        graph export "`outputpath'\reports\graphics\table2-5\table2-5-col4-row`a'.svg", replace
    }
restore



** -----------------------------------------------------
** COLUMN 4 
** Outputs: Relative Change in Mortality Rate between 2000 and 2019 
** improve{1-6}.png or worsen{1-6}.png (1-6 are the GHE causes)
** -----------------------------------------------------
** Graphic of Absolute or Relative Change between 2000 and 2019
preserve
    keep if sex==3 & region==2000 & (year==2000 | year==2019)
    keep year cod arate 
    reshape wide arate, i(cod) j(year)

    ** Improving rate (green chart) or Worsening rate (so red chart) 
    gen change = . 
    replace change = 1 if arate2019 < arate2000
    replace change = 2 if arate2019 >= arate2000
    label define change_ 1 "improving" 2 "worsening", modify 
    label values change change_

    ** absolute change
    gen arate_ac = sqrt((arate2000 - arate2019)^2)
    ** percentage change
    gen arate_pc = ( (sqrt((arate2000 - arate2019)^2)) / arate2000 ) * 100

    sort cod 
    gen arate_pc_int = round(arate_pc)
    mkmat cod arate_pc_int , matrix(col4)
    matrix list col4
    forval x = 1(1)12 {
        global pc`x' = col4[`x',2]
    }

    ** GRAPHIC
    ** Different graphic according to improving or worsening mortality rate
    forval a = 1(1)12 { 
        sort cod

        if change[`a'] == 1 {
            #delimit ;
                gr twoway 
                (function y=0.9, range (1.05 1.35) lc(gs16))
                    ,
                        plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(r=2 l=2 t=2 b=2) ) 
                        graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(r=2 l=2 t=2 b=2) ) 
                        ysize(5) xsize(6)
                        
                        xlab(, 
                        labs(medsmall) nogrid glc(gs14) angle(0) labgap(0))
                        xscale(off ) 
                        xtitle("", margin(t=0 b=0 r=0 l=0) )  

                        yscale(off ) 
                        ylab(,nogrid)

                        text(1.4 1.17 "{&dArr}", place(w) size(75) color("`improve'%75") just(center) margin(l=2 r=2 t=2 b=2))
                        text(0.9 1.175 "${pc`a'}", place(e) size(40) color("`improve'%75") just(center) margin(l=2 r=2 t=2 b=2))
                        
                        legend(off)
                        name(improve`a')
                        ;
            #delimit cr
            graph export "`outputpath'\graphics\mrc`a'.png" , replace
        }

        else if change[`a'] == 2 {
            #delimit ;
                gr twoway 
                (function y=0.9, range (1.05 1.35) lc(gs16))
                    ,
                        plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(r=2 l=2 t=2 b=2) ) 
                        graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(r=2 l=2 t=2 b=2) ) 
                        ysize(5) xsize(6)
                        
                        xlab(, 
                        labs(medsmall) nogrid glc(gs14) angle(0) labgap(0))
                        xscale(off ) 
                        xtitle("", margin(t=0 b=0 r=0 l=0) )  

                        yscale(off ) 
                        ylab(,nogrid)

                        text(0.9 1.17 "{&uArr}", place(w) size(75) color("`worsen'%75") just(center) margin(l=2 r=2 t=2 b=2))
                        text(0.9 1.175 "${pc`a'}", place(e) size(40) color("`worsen'%75") just(center) margin(l=2 r=2 t=2 b=2))
                        
                        legend(off)
                        name(worsen`a')
                        ;
            #delimit cr
            graph export "`outputpath'\graphics\mrc`a'.png" , replace
        }
    }
restore

** -----------------------------------------------------
** COLUMN 5 
** Outputs: Mortality Rate Gender ratio
** sratio1 to sratio6 (1-6 are the GHE causes)
** -----------------------------------------------------
** Ratio of Men to Women in 2019
preserve
    keep if sex<3 & region==2000 & year==2019
    keep sex cod arate 
    reshape wide arate, i(cod) j(sex)

    gen arate_ratio = arate1 / arate2 
    tabdisp cod , cell(arate_ratio) format(%6.2fc)
    sort cod 
    gen arate_ratio_int = round(arate_ratio, 0.01)
    mkmat cod arate_ratio_int , matrix(col5)
    matrix list col5
    forval x = 1(1)12 {
        global sratio`x' = col5[`x',2]
    }
restore






** -----------------------------------------------------
** TABLE PART TWO 
** DALY METRICS
** -----------------------------------------------------

tempfile kcancer region_mr12 region_mr3 region_daly12 region_daly3

** Use the dataset saved from (chap2-600-mental-stats) DO file
use "`datapath'\from-who\chap2_000_adjusted_mentalhealthonly", replace
rename dalyr arate 

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
/// gen cod = .
/// replace cod = 1 if type==1 & top5==1
/// replace cod = 2 if type==1 & top5==2
/// replace cod = 3 if type==1 & top5==3
/// replace cod = 4 if type==1 & top5==4
/// replace cod = 5 if type==1 & top5==5
/// replace cod = 6 if type==2 & top5==1
/// replace cod = 7 if type==2 & top5==2
/// replace cod = 8 if type==2 & top5==3
/// replace cod = 9 if type==2 & top5==4
/// replace cod = 10 if type==2 & top5==5
/// replace cod = 11 if ghecause==800
/// replace cod = 12 if ghecause==900
/// replace cod = 13 if ghecause==100
/// #delimit ;
/// label define cod_   1   "Drug use disorders" 
///                     2   "Depressive disorders" 
///                     3   "Anxiety disorders" 
///                     4   "Alcohol use disorders" 
///                     5   "Schizophrenia" 
///                     6   "All mental"
///                     7   "Alzheimer/dementias"
///                     8   "Migraine"
///                     9   "Epilepsy"
///                     10  "Non-migraine headache"
///                     11  "Parkinson disease"
///                     12  "All neurological", modify;
/// #delimit cr
/// label values cod cod_    
/// keep if cod<=12

gen cod = .
replace cod = 1 if type==1 & top5==1
replace cod = 2 if type==1 & top5==2
replace cod = 3 if type==1 & top5==3
replace cod = 4 if type==1 & top5==4
replace cod = 5 if type==1 & top5==5
replace cod = 6 if type==2 & top5==1
replace cod = 7 if type==2 & top5==2
replace cod = 8 if type==2 & top5==3
replace cod = 9 if type==2 & top5==4
replace cod = 10 if type==2 & top5==5
replace cod = 11 if ghecause==800
replace cod = 12 if ghecause==900
replace cod = 13 if ghecause==100
#delimit ;
label define cod_   1   "Drug use disorders" 
                    2   "Depressive disorders" 
                    3   "Anxiety disorders" 
                    4   "Alcohol use disorders" 
                    5   "Schizophrenia" 
                    6   "Migraine"
                    7   "Alzheimer/dementias"
                    8   "Epilepsy"
                    9  "Non-migraine headache"
                    10 "Parkinson disease"
                    11   "All mental"
                    12  "All neurological", modify;
#delimit cr
label values cod cod_    
keep if cod<=12

** -----------------------------------------------------
** COLUMN 6
** Outputs: Total DALYs
** daly1 to daly6 (1-6 are the GHE causes)
** -----------------------------------------------------
** Number of deaths in the Americas in 2019 by GHE CoD 
** Women and men combined 
preserve 
    keep if region==2000 & year==2019 & sex==3
    ** collapse (sum) daly, by(cod)
    tabdisp cod  , cell(daly) format(%10.0fc)
    sort cod 
    gen daly_int = round(daly)
    mkmat cod daly_int , matrix(col1)
    matrix list col1
    forval x = 1(1)12 {
        global daly`x' = col1[`x',2]
    }
restore



** -----------------------------------------------------
** COL 7
** Outputs: DALY Rate 2019
** drate1 to drate6 (1-6 are the GHE causes)
** -----------------------------------------------------
preserve
    sort sex cod 
    rename arate drate
    keep if region==2000 & year==2019 & sex==3
    ** Women and Men combined  
    tabdisp cod , cell(drate) format(%6.1fc) 
    sort cod 
    gen drate_int = round(drate, 0.1)
    mkmat cod drate_int , matrix(col2)
    matrix list col2
    forval x = 1(1)12 {
        global drate`x' = col2[`x',2]
    }
restore 





** -----------------------------------------------------
** COLUMN 8 
** Outputs: DALY Rate change over time 
** spike_daly1.png to spike_daly6.png (1-6 are the GHE causes)
** -----------------------------------------------------
** Sparkline of Mortality Rate change over time

preserve
    keep if region==2000

    ** Zero line for shading boundary 
    gen y = 0.55 

    ** Relative Rate 
    rename arate drate 
    gen ar1 = drate if year==2000
    bysort sex cod : egen ar2 = min(ar1)
    drop ar1 
    gen rel_drate = drate/ar2

    ** Women and Men combined
    forval a = 1(1)12 { 
        #delimit ;
            gr twoway 
                (rarea rel_drate y year if cod==`a' & sex==3 & region==2000 , sort lw(none) color("`men2'%85"))
                (line rel_drate year if cod==`a' & sex==3 & region==2000, sort lc("`men2'") fc("`men2'") lw(6) msize(2.5))
                ///(sc rel_drate year if cod==`a' & sex==3 & region==2000, sort m(O) mfc("gs16") mlw(1) mlc("`cvd2'") msize(3.5) )
                ,
                    plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
                    graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
                    ysize(15) xsize(20)
                    
                    xlab(, 
                    labs(medsmall) nogrid glc(gs14) angle(0) labgap(3))
                    xscale(off lw(vthin) range(1999.5(0.5)2019.5))  
                    xtitle("", margin(t=3) size(medsmall)) 
                    yscale(off lw(vthin) ) 
                    ylab(,nogrid)
                    legend(off)
                    name(spark_daly_`a')
                    ;
            #delimit cr
        graph export "`outputpath'\graphics\spike_daly`a'.png" , replace
        graph export "`outputpath'\reports\graphics\table2-5\table2-5-col9-row`a'.pdf", replace
        graph export "`outputpath'\reports\graphics\table2-5\table2-5-col9-row`a'.svg", replace
    }
restore




** -----------------------------------------------------
** COLUMN 9 
** Outputs: Relative Change in DALY Rate between 2000 and 2019 
** improve{1-6}.png or worsen{1-6}.png (1-6 are the GHE causes)
** -----------------------------------------------------
** Graphic of Absolute or Relative Change between 2000 and 2019
** Graphic of Absolute or Relative Change between 2000 and 2019
preserve
    rename arate drate 
    keep if sex==3 & region==2000 & (year==2000 | year==2019)
    keep year cod drate 
    reshape wide drate, i(cod) j(year)

    ** Improving rate (green chart) or Worsening rate (so red chart) 
    gen change = . 
    replace change = 1 if drate2019 < drate2000
    replace change = 2 if drate2019 >= drate2000
    label define change_ 1 "improving" 2 "worsening", modify 
    label values change change_

    ** absolute change
    gen drate_ac = sqrt((drate2000 - drate2019)^2)
    ** percentage change
    gen drate_pc = ( (sqrt((drate2000 - drate2019)^2)) / drate2000 ) * 100

    sort cod 
    gen drate_pc_int = round(drate_pc)
    mkmat cod drate_pc_int , matrix(col4)
    matrix list col4
    forval x = 1(1)12 {
        global pc`x' = col4[`x',2]
    }

    ** GRAPHIC
    ** Different graphic according to improving or worsening mortality rate
    forval a = 1(1)12 { 
        sort cod

        if change[`a'] == 1 {
            #delimit ;
                gr twoway 
                (function y=0.9, range (1.05 1.35) lc(gs16))
                    ,
                        plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(r=2 l=2 t=2 b=2) ) 
                        graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(r=2 l=2 t=2 b=2) ) 
                        ysize(5) xsize(6)
                        
                        xlab(, 
                        labs(medsmall) nogrid glc(gs14) angle(0) labgap(0))
                        xscale(off ) 
                        xtitle("", margin(t=0 b=0 r=0 l=0) )  

                        yscale(off ) 
                        ylab(,nogrid)

                        text(1.4 1.17 "{&dArr}", place(w) size(75) color("`improve'%75") just(center) margin(l=2 r=2 t=2 b=2))
                        text(0.9 1.175 "${pc`a'}", place(e) size(40) color("`improve'%75") just(center) margin(l=2 r=2 t=2 b=2))
                        
                        legend(off)
                        name(dimprove`a')
                        ;
            #delimit cr
            graph export "`outputpath'\graphics\dalyc`a'.png" , replace
        }

        else if change[`a'] == 2 {
            #delimit ;
                gr twoway 
                (function y=0.9, range (1.05 1.35) lc(gs16))
                    ,
                        plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(r=2 l=2 t=2 b=2) ) 
                        graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(r=2 l=2 t=2 b=2) ) 
                        ysize(5) xsize(6)
                        
                        xlab(, 
                        labs(medsmall) nogrid glc(gs14) angle(0) labgap(0))
                        xscale(off ) 
                        xtitle("", margin(t=0 b=0 r=0 l=0) )  

                        yscale(off ) 
                        ylab(,nogrid)

                        text(0.9 1.17 "{&uArr}", place(w) size(75) color("`worsen'%75") just(center) margin(l=2 r=2 t=2 b=2))
                        text(0.9 1.175 "${pc`a'}", place(e) size(40) color("`worsen'%75") just(center) margin(l=2 r=2 t=2 b=2))
                        
                        legend(off)
                        name(dworsen`a')
                        ;
            #delimit cr
            graph export "`outputpath'\graphics\dalyc`a'.png" , replace
        }
    }
restore



** -----------------------------------------------------
** COLUMN 9 
** Outputs: DALY Gender ratio
** sratio1 to sratio6 (1-6 are the GHE causes)
** -----------------------------------------------------
** Ratio of Men to Women in 2019
preserve
    rename arate drate 
    keep if sex<3 & region==2000 & year==2019
    keep sex cod drate 
    reshape wide drate, i(cod) j(sex)

    gen drate_ratio = drate1 / drate2 
    tabdisp cod , cell(drate_ratio) format(%6.2fc)
    sort cod 
    gen drate_ratio_int = round(drate_ratio, 0.01)
    mkmat cod drate_ratio_int , matrix(col5)
    matrix list col5
    forval x = 1(1)12 {
        global sdaly`x' = col5[`x',2]
    }
restore




** -----------------------------------------------------
** AUTOMATED WORD TABLE FOR REPORT
** -----------------------------------------------------
putdocx begin , pagesize(A4) font(calibri light, 9)
** ROW / COL
putdocx table cvd = (17 , 11) 

** ----------------------
** Formatting
** ----------------------
** All cells - vertical centering
putdocx table cvd(.,.), valign(center) 

** ROW3 - remove left and right borders
putdocx table cvd(3,.), border(left, single, "FFFFFF") 
putdocx table cvd(3,.), border(right, single, "FFFFFF") 
** ROW10 - remove left and right borders
putdocx table cvd(10,.), border(left, single, "FFFFFF") 
putdocx table cvd(10,.), border(right, single, "FFFFFF") 

** COL1 - no formatting
putdocx table cvd(1/2,1), bold border(all, single, "FFFFFF") 
putdocx table cvd(4/9,1), bold border(all, single, "FFFFFF") 
putdocx table cvd(11/16,1), bold border(all, single, "FFFFFF") 

** COL2 - Add back left hand side border
putdocx table cvd(1/2,2), border(left, single, "000000") 
putdocx table cvd(4/9,2), border(left, single, "000000") 
putdocx table cvd(11/16,2), border(left, single, "000000") 

** ROWS 1 and 2 - shading
putdocx table cvd(1/2,2/6), bold border(all, single, "000000") shading("`men1'")
putdocx table cvd(1/2,7/11), bold border(all, single, "000000") shading("`men2'")

** Merge FOUR top rows for headers
putdocx table cvd(1,2),colspan(5)
putdocx table cvd(1,3),colspan(5)

** Merge COL1 and COL2 rows 1 and 2
putdocx table cvd(1,1),rowspan(2)

** ROW 15 as single cell for comments
putdocx table cvd(17,2),colspan(10)
putdocx table cvd(17,.),halign(left) font(calibri light, 8)
putdocx table cvd(17,.),border(left, single, "FFFFFF")
putdocx table cvd(17,.),border(right, single, "FFFFFF")
putdocx table cvd(17,.),border(bottom, single, "FFFFFF")

** ----------------------
** Row and Column Titles
** ----------------------
putdocx table cvd(1,2) = ("Mortality "), bold font(calibri light,9, "FFFFFF")
putdocx table cvd(1,2) = ("1"), bold halign(right) font(calibri light,9, "FFFFFF") script(super) append
putdocx table cvd(1,3) = ("Disease Burden "), bold 
putdocx table cvd(1,3) = ("1"), bold halign(right) script(super) append

putdocx table cvd(2,2) = ("Number of "), bold font(calibri light,9, "FFFFFF") 
putdocx table cvd(2,2) = ("Deaths"), append bold font(calibri light,9, "FFFFFF") 
putdocx table cvd(2,3) = ("Rate"), font(calibri light,9, "FFFFFF") linebreak bold
putdocx table cvd(2,3) = ("2019"), font(calibri light,9, "FFFFFF") append bold

putdocx table cvd(2,4) = ("M:F"), font(calibri light,9, "FFFFFF") bold         

putdocx table cvd(2,5) = ("Change"), font(calibri light,9, "FFFFFF") linebreak bold
putdocx table cvd(2,5) = ("2000-2019"), font(calibri light,9, "FFFFFF") append bold

putdocx table cvd(2,6) = ("Percent"), font(calibri light,9, "FFFFFF") linebreak bold    
putdocx table cvd(2,6) = ("change"), font(calibri light,9, "FFFFFF") append bold    

putdocx table cvd(2,7) = ("Number of "), bold 
putdocx table cvd(2,7) = ("DALYs"), append bold 

putdocx table cvd(2,8) = ("Rate"), font(calibri light,9) linebreak bold
putdocx table cvd(2,8) = ("2019"), font(calibri light,9) append bold

putdocx table cvd(2,9) = ("M:F"), font(calibri light,9) bold  

putdocx table cvd(2,10) = ("Change"), font(calibri light,9) linebreak bold
putdocx table cvd(2,10) = ("2000-2019"), font(calibri light,9) append bold

putdocx table cvd(2,11) = ("Percent"), font(calibri light,9) linebreak bold    
putdocx table cvd(2,11) = ("change"), font(calibri light,9) append bold    

putdocx table cvd(4,1) = ("Drug Use Disorders"), halign(right) bold
///putdocx table cvd(4,1) = ("1"), halign(right) script(super) append

putdocx table cvd(5,1) = ("Depressive Disorders"), halign(right) bold

putdocx table cvd(6,1) = ("Anxiety Disorders"), halign(right) bold
/// putdocx table cvd(6,1) = ("2"), halign(right) script(super) append

putdocx table cvd(7,1) = ("Alcohol Use Disorders"), halign(right) bold
/// putdocx table cvd(7,1) = ("3"), halign(right) script(super) append

putdocx table cvd(8,1) = ("Schizophrenia"), halign(right) bold
/// putdocx table cvd(8,1) = ("4"), halign(right) script(super) append

putdocx table cvd(9,1) = ("All Mental Health"), halign(right) bold
putdocx table cvd(9,1) = (" 2"), bold halign(right) script(super) append

putdocx table cvd(11,1) = ("Migraine"), halign(right) bold
/// putdocx table cvd(10,1) = ("4"), halign(right) script(super) append

putdocx table cvd(12,1) = ("Alzheimer/Dementias"), halign(right) bold
/// putdocx table cvd(11,1) = ("4"), halign(right) script(super) append

putdocx table cvd(13,1) = ("Epilepsy"), halign(right) bold
/// putdocx table cvd(12,1) = ("4"), halign(right) script(super) append

putdocx table cvd(14,1) = ("Non-migraine headache"), halign(right) bold
/// putdocx table cvd(13,1) = ("4"), halign(right) script(super) append

putdocx table cvd(15,1) = ("Parkinson disease"), halign(right) bold
/// putdocx table cvd(14,1) = ("5"), halign(right) script(super) append

putdocx table cvd(16,1) = ("All neurological"), halign(right) bold
putdocx table cvd(16,1) = (" 3"), bold halign(right) script(super) append


** ----------------------
** DATA
** ----------------------
** COL2. Deaths
putdocx table cvd(4,2) = ("$deaths1") , nformat(%12.0fc) trim 
putdocx table cvd(5,2) = ("$deaths2") , nformat(%12.0fc) trim  
putdocx table cvd(6,2) = ("$deaths3") , nformat(%12.0fc) trim  
putdocx table cvd(7,2) = ("$deaths4") , nformat(%12.0fc) trim  
putdocx table cvd(8,2) = ("$deaths5") , nformat(%12.0fc) trim  
putdocx table cvd(9,2) = ("$deaths11") , nformat(%12.0fc) trim  
putdocx table cvd(11,2) = ("$deaths6") , nformat(%12.0fc) trim  
putdocx table cvd(12,2) = ("$deaths7") , nformat(%12.0fc) trim  
putdocx table cvd(13,2) = ("$deaths8") , nformat(%12.0fc) trim  
putdocx table cvd(14,2) = ("$deaths9") , nformat(%12.0fc) trim  
putdocx table cvd(15,2) = ("$deaths10") , nformat(%12.0fc) trim  
putdocx table cvd(16,2) = ("$deaths12") , nformat(%12.0fc) trim  

** COL3. Mortality Rates
putdocx table cvd(4,3) = ("$arate1") , nformat(%9.1fc)  trim
putdocx table cvd(5,3) = ("$arate2") , nformat(%9.1fc)  trim
putdocx table cvd(6,3) = ("<0.1") 
putdocx table cvd(7,3) = ("$arate4") , nformat(%9.1fc)  trim
putdocx table cvd(8,3) = ("$arate5") , nformat(%9.1fc)  trim
putdocx table cvd(9,3) = ("$arate11") , nformat(%9.1fc)  trim
putdocx table cvd(11,3) = ("<0.1") 
putdocx table cvd(12,3) = ("$arate7") , nformat(%9.1fc)  trim
putdocx table cvd(13,3) = ("$arate8") , nformat(%9.1fc)  trim
putdocx table cvd(14,3) = ("$arate9") , nformat(%9.1fc)  trim
putdocx table cvd(15,3) = ("$arate10") , nformat(%9.1fc)  trim
putdocx table cvd(16,3) = ("$arate12") , nformat(%9.1fc)  trim

** COL4. Sex ratio
putdocx table cvd(4,4) = ("$sratio1") , nformat(%9.2fc)  trim
putdocx table cvd(5,4) = ("-") 
putdocx table cvd(6,4) = ("-") 
putdocx table cvd(7,4) = ("$sratio4") , nformat(%9.2fc)  trim
putdocx table cvd(8,4) = ("$sratio5") , nformat(%9.2fc)  trim
putdocx table cvd(9,4) = ("$sratio11") , nformat(%9.2fc)  trim
putdocx table cvd(11,4) = ("-") 
putdocx table cvd(12,4) = ("$sratio7") , nformat(%9.2fc)  trim
putdocx table cvd(13,4) = ("$sratio8") , nformat(%9.2fc)  trim
putdocx table cvd(14,4) = ("-") 
putdocx table cvd(15,4) = ("$sratio10") , nformat(%9.2fc)  trim
putdocx table cvd(16,4) = ("$sratio12") , nformat(%9.2fc)  trim

** COL5. Mortality Rate Change since 2000
putdocx table cvd(4,5) = image("`outputpath'\graphics\spike1.png")
putdocx table cvd(5,5) = ("-") 
putdocx table cvd(6,5) = ("-") 
putdocx table cvd(7,5) = image("`outputpath'\graphics\spike4.png")
putdocx table cvd(8,5) = image("`outputpath'\graphics\spike5.png")
putdocx table cvd(9,5) = image("`outputpath'\graphics\spike11.png")
putdocx table cvd(11,5) = ("-") 
putdocx table cvd(12,5) = image("`outputpath'\graphics\spike7.png")
putdocx table cvd(13,5) = image("`outputpath'\graphics\spike8.png")
putdocx table cvd(14,5) = ("-") 
putdocx table cvd(15,5) = image("`outputpath'\graphics\spike10.png")
putdocx table cvd(16,5) = image("`outputpath'\graphics\spike12.png")

** COL6. Percent change
putdocx table cvd(4,6) = image("`outputpath'\graphics\mrc1.png"), width(25pt)
putdocx table cvd(5,6) = ("-") 
putdocx table cvd(6,6) = ("-") 
putdocx table cvd(7,6) = image("`outputpath'\graphics\mrc4.png"), width(25pt)
putdocx table cvd(8,6) = image("`outputpath'\graphics\mrc5.png"), width(25pt)
putdocx table cvd(9,6) = image("`outputpath'\graphics\mrc11.png"), width(25pt)
putdocx table cvd(11,6) = ("-")
putdocx table cvd(12,6) = image("`outputpath'\graphics\mrc7.png"), width(25pt)
putdocx table cvd(13,6) = image("`outputpath'\graphics\mrc8.png"), width(25pt)
putdocx table cvd(14,6) = ("-") 
putdocx table cvd(15,6) = image("`outputpath'\graphics\mrc10.png"), width(25pt)
putdocx table cvd(16,6) = image("`outputpath'\graphics\mrc12.png"), width(25pt)

** COL7. DALY in 2019
putdocx table cvd(4,7) = ("$daly1") , nformat(%12.0fc)  trim
putdocx table cvd(5,7) = ("$daly2") , nformat(%12.0fc)  trim
putdocx table cvd(6,7) = ("$daly3") , nformat(%12.0fc)  trim
putdocx table cvd(7,7) = ("$daly4") , nformat(%12.0fc)  trim
putdocx table cvd(8,7) = ("$daly5") , nformat(%12.0fc)  trim
putdocx table cvd(9,7) = ("$daly11") , nformat(%12.0fc)  trim
putdocx table cvd(11,7) = ("$daly6") , nformat(%12.0fc)  trim
putdocx table cvd(12,7) = ("$daly7") , nformat(%12.0fc)  trim
putdocx table cvd(13,7) = ("$daly8") , nformat(%12.0fc)  trim
putdocx table cvd(14,7) = ("$daly9") , nformat(%12.0fc)  trim
putdocx table cvd(15,7) = ("$daly10") , nformat(%12.0fc)  trim
putdocx table cvd(16,7) = ("$daly12") , nformat(%12.0fc)  trim

** COL8. DALY Rates
putdocx table cvd(4,8) = ("$drate1") , nformat(%9.1fc)  trim
putdocx table cvd(5,8) = ("$drate2") , nformat(%9.1fc)  trim
putdocx table cvd(6,8) = ("$drate3") , nformat(%9.1fc)  trim
putdocx table cvd(7,8) = ("$drate4") , nformat(%9.1fc)  trim
putdocx table cvd(8,8) = ("$drate5") , nformat(%9.1fc)  trim
putdocx table cvd(9,8) = ("$drate11") , nformat(%9.1fc)  trim
putdocx table cvd(11,8) = ("$drate6") , nformat(%9.1fc)  trim
putdocx table cvd(12,8) = ("$drate7") , nformat(%9.1fc)  trim
putdocx table cvd(13,8) = ("$drate8") , nformat(%9.1fc)  trim
putdocx table cvd(14,8) = ("$drate9") , nformat(%9.1fc)  trim
putdocx table cvd(15,8) = ("$drate10") , nformat(%9.1fc)  trim
putdocx table cvd(16,8) = ("$drate12") , nformat(%9.1fc)  trim

** COL9. Sex ratio
putdocx table cvd(4,9) = ("$sdaly1") , nformat(%9.2fc)  trim
putdocx table cvd(5,9) = ("$sdaly2") , nformat(%9.2fc)  trim
putdocx table cvd(6,9) = ("$sdaly3") , nformat(%9.2fc)  trim
putdocx table cvd(7,9) = ("$sdaly4") , nformat(%9.2fc)  trim
putdocx table cvd(8,9) = ("$sdaly5") , nformat(%9.2fc)  trim
putdocx table cvd(9,9) = ("$sdaly11") , nformat(%9.2fc)  trim
putdocx table cvd(11,9) = ("$sdaly6") , nformat(%9.2fc)  trim
putdocx table cvd(12,9) = ("$sdaly7") , nformat(%9.2fc)  trim
putdocx table cvd(13,9) = ("$sdaly8") , nformat(%9.2fc)  trim
putdocx table cvd(14,9) = ("$sdaly9") , nformat(%9.2fc)  trim
putdocx table cvd(15,9) = ("$sdaly10") , nformat(%9.2fc)  trim
putdocx table cvd(16,9) = ("$sdaly12") , nformat(%9.2fc)  trim

** COL9. DALY Change since 2000
putdocx table cvd(4,10) = image("`outputpath'\graphics\spike_daly1.png")
putdocx table cvd(5,10) = image("`outputpath'\graphics\spike_daly2.png")
putdocx table cvd(6,10) = image("`outputpath'\graphics\spike_daly3.png")
putdocx table cvd(7,10) = image("`outputpath'\graphics\spike_daly4.png")
putdocx table cvd(8,10) = image("`outputpath'\graphics\spike_daly5.png")
putdocx table cvd(9,10) = image("`outputpath'\graphics\spike_daly11.png")
putdocx table cvd(11,10) = image("`outputpath'\graphics\spike_daly6.png")
putdocx table cvd(12,10) = image("`outputpath'\graphics\spike_daly7.png")
putdocx table cvd(13,10) = image("`outputpath'\graphics\spike_daly8.png")
putdocx table cvd(14,10) = image("`outputpath'\graphics\spike_daly9.png")
putdocx table cvd(15,10) = image("`outputpath'\graphics\spike_daly10.png")
putdocx table cvd(16,10) = image("`outputpath'\graphics\spike_daly12.png")

** COL10. Percent change 
putdocx table cvd(4,11) = image("`outputpath'\graphics\dalyc1.png"), width(25pt)
putdocx table cvd(5,11) = image("`outputpath'\graphics\dalyc2.png"), width(25pt)
putdocx table cvd(6,11) = image("`outputpath'\graphics\dalyc3.png"), width(25pt)
putdocx table cvd(7,11) = image("`outputpath'\graphics\dalyc4.png"), width(25pt)
putdocx table cvd(8,11) = image("`outputpath'\graphics\dalyc5.png"), width(25pt)
putdocx table cvd(9,11) = image("`outputpath'\graphics\dalyc11.png"), width(25pt)
putdocx table cvd(11,11) = image("`outputpath'\graphics\dalyc6.png"), width(25pt)
putdocx table cvd(12,11) = image("`outputpath'\graphics\dalyc7.png"), width(25pt)
putdocx table cvd(13,11) = image("`outputpath'\graphics\dalyc8.png"), width(25pt)
putdocx table cvd(14,11) = image("`outputpath'\graphics\dalyc9.png"), width(25pt)
putdocx table cvd(15,11) = image("`outputpath'\graphics\dalyc10.png"), width(25pt)
putdocx table cvd(16,11) = image("`outputpath'\graphics\dalyc12.png"), width(25pt)


** Column alignment
putdocx table cvd(.,1), halign(right) 
putdocx table cvd(.,2), halign(right) 
putdocx table cvd(.,3/6), halign(center) 
putdocx table cvd(.,7), halign(right) 
putdocx table cvd(.,8/10), halign(center) 
putdocx table cvd(1,2), halign(center) 
putdocx table cvd(1,3), halign(center) 

** FINAL TABLE NOTES
putdocx table cvd(17,2) = ("(1) ") , script(super) font(calibri light, 8)
putdocx table cvd(17,2) = ("Mortality is described using the age-standardized mortality rate. Disease Burden is described using the age-standardized DALY rate. Both rates presented per 100,000 population.") , append font(calibri light, 8) 

putdocx table cvd(17,2) = ("(2) ") , script(super) font(calibri light, 8) append
putdocx table cvd(17,2) = ("Includes all mental and substance-use disorders. Other conditions not listed include ") , append font(calibri light, 8) 
putdocx table cvd(17,2) = ("bipolar disorders, eating disorders, autism and asperger syndrome, childhood ") , append font(calibri light, 8) 
putdocx table cvd(17,2) = ("behavioral disorders, and idiopathic intellectual disability. ") , append font(calibri light, 8) 
putdocx table cvd(17,2) = ("(All Mental and substance use disorders ICD codes: F04-F99, G72.1, Q86.0, X41-X42, X44, X45). ") , append font(calibri light, 8) 

putdocx table cvd(17,2) = ("  (3) ") , script(super) font(calibri light, 8) append
putdocx table cvd(17,2) = ("Includes all neurological conditions. Other conditions not listed include ") , append font(calibri light, 8) 
putdocx table cvd(17,2) = ("Multiple sclerosis, cerebral palsy, motor neuron disease. ") , append font(calibri light, 8) 
putdocx table cvd(17,2) = ("(All neurological conditions ICD codes: F01-F03, G06-G98, minus G14 and G72.1). ") , append font(calibri light, 8) 

/// putdocx table cvd(15,2) = ("  (3) ") , script(super) font(calibri light, 8) append
/// putdocx table cvd(15,2) = ("Cardiomyopathy, myocarditis, endocarditis") , append font(calibri light, 8) 

/// putdocx table cvd(15,2) = ("  (4) ") , script(super) font(calibri light, 8) append
/// putdocx table cvd(15,2) = ("Rheumatic heart disease") , append font(calibri light, 8) 

/// putdocx table cvd(15,2) = ("  (5) ") , script(super) font(calibri light, 8) append
/// putdocx table cvd(15,2) = ("All CVD includes 'other' circulatory diseases. ICD codes: I00, I26-I28, I34-I37, I44-I51, I70-I99") , append font(calibri light, 8) linebreak

** Save the Table
putdocx save "`outputpath'\graphics\table_mentalhealth.docx" , replace


