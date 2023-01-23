** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap2-210-cvd-table.do
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
    local datapath "X:\OneDrive - The University of the West Indies\Writing\w003\data"

    ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    local logpath "X:\OneDrive - The University of the West Indies\Writing\w003\tech-docs"

    ** REPORTS and Other outputs
    local outputpath "X:\OneDrive - The University of the West Indies\Writing\w003\outputs"

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\chap2-210-cvd-table", replace
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



** -----------------------------------------------------
** TABLE PART ONE 
** DEATHS METRICS
** -----------------------------------------------------

** Mortality Rate statistics first
use "`datapath'\from-who\chap2_000_mr_adjusted", clear
rename mortr arate 

** Create new GHE CoD order for Table 
** 3 - IHD
** 4 - stroke
** 2 - Hypertensive
** 5 - Cardiomyopathy
** 1 - Rheumatic
** 400 - All CVD
gen cod = 1 if ghecause==3 
replace cod = 2 if ghecause==4
replace cod = 3 if ghecause==2
replace cod = 4 if ghecause==5
replace cod = 5 if ghecause==1
replace cod = 6 if ghecause==400
#delimit ; 
label define cod_   1 "ischaemic" 
                    2 "stroke" 
                    3 "hypertensive" 
                    4 "cardiomyopathy etc" 
                    5 "rheumatic" 
                    6 "all cvd", modify ;
#delimit cr
label values cod cod_ 
keep if cod<=6

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
    forval x = 1(1)6 {
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
    keep if region==2000 & year==2019 & sex==3
    ** Women and Men combined  
    tabdisp cod , cell(arate) format(%6.1fc) 
    sort cod 
    gen arate_int = round(arate, 0.1)
    mkmat cod arate_int , matrix(col2)
    matrix list col2
    forval x = 1(1)6 {
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

    ** Zero line for shading boundary 
    gen y = 0 

    ** Relative Rate 
    gen ar1 = arate if year==2000
    bysort sex cod : egen ar2 = min(ar1)
    drop ar1 
    gen rel_arate = arate/ar2

    ** Women and Men combined
    forval a = 1(1)6 { 
        #delimit ;
            gr twoway 
                (rarea rel_arate y year if cod==`a' & sex==3 & region==2000 , sort lw(none) color("`cvd1'%85"))
                (line rel_arate year if cod==`a' & sex==3 & region==2000, sort lc("`cvd1'") fc("`cvd1'") lw(6) msize(2.5))
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
        graph export "`outputpath'\reports\graphics\table2-1\table2-1-col4-row`a'.pdf", replace
        graph export "`outputpath'\reports\graphics\table2-1\table2-1-col4-row`a'.svg", replace
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
    forval x = 1(1)6 {
        global pc`x' = col4[`x',2]
    }

    ** GRAPHIC
    ** Different graphic according to improving or worsening mortality rate
    forval a = 1(1)6 { 
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
                        text(0.9 1.175 "${pc`a'}", place(e) size(60) color("`improve'%75") just(center) margin(l=2 r=2 t=2 b=2))
                        
                        legend(off)
                        name(improve`a')
                        ;
            #delimit cr
            graph export "`outputpath'\graphics\mrc`a'.png" , replace
            ///graph export "`outputpath'\reports\graphics\table2-1\table2-1-col5-row`a'.pdf", replace
            ///graph export "`outputpath'\reports\graphics\table2-1\table2-1-col5-row`a'.svg", replace            
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
                        text(0.9 1.175 "${pc`a'}", place(e) size(60) color("`worsen'%75") just(center) margin(l=2 r=2 t=2 b=2))
                        
                        legend(off)
                        name(worsen`a')
                        ;
            #delimit cr
            graph export "`outputpath'\graphics\mrc`a'.png" , replace
            ///graph export "`outputpath'\reports\graphics\table2-1\table2-1-col5-row`a'.pdf", replace
            ///graph export "`outputpath'\reports\graphics\table2-1\table2-1-col5-row`a'.svg", replace            
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
    forval x = 1(1)6 {
        global sratio`x' = col5[`x',2]
    }
restore






** -----------------------------------------------------
** TABLE PART TWO 
** DALY METRICS
** -----------------------------------------------------

** Mortality Rate statistics first
use "`datapath'\from-who\chap2_000_daly_adjusted", clear
rename dalyr arate

** Create new GHE CoD order for Table 
** 3 - IHD
** 4 - stroke
** 2 - Hypertensive
** 5 - Cardiomyopathy
** 1 - Rheumatic
** 400 - All CVD
gen cod = 1 if ghecause==3 
replace cod = 2 if ghecause==4
replace cod = 3 if ghecause==2
replace cod = 4 if ghecause==5
replace cod = 5 if ghecause==1
replace cod = 6 if ghecause==400

#delimit ; 
label define cod_   1 "ischaemic" 
                    2 "stroke" 
                    3 "hypertensive" 
                    4 "cardiomyopathy etc" 
                    5 "rheumatic" 
                    6 "all cvd", modify ;
#delimit cr
label values cod cod_ 
keep if cod<=6


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
    forval x = 1(1)6 {
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
    forval x = 1(1)6 {
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
    gen y = 0 

    ** Relative Rate 
    rename arate drate 
    gen ar1 = drate if year==2000
    bysort sex cod : egen ar2 = min(ar1)
    drop ar1 
    gen rel_drate = drate/ar2

    ** Women and Men combined
    forval a = 1(1)6 { 
        #delimit ;
            gr twoway 
                (rarea rel_drate y year if cod==`a' & sex==3 & region==2000 , sort lw(none) color("`cvd2'%85"))
                (line rel_drate year if cod==`a' & sex==3 & region==2000, sort lc("`cvd2'") fc("`cvd2'") lw(6) msize(2.5))
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
        graph export "`outputpath'\reports\graphics\table2-1\table2-1-col9-row`a'.pdf", replace
        graph export "`outputpath'\reports\graphics\table2-1\table2-1-col9-row`a'.svg", replace    
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
    forval x = 1(1)6 {
        global pc`x' = col4[`x',2]
    }

    ** GRAPHIC
    ** Different graphic according to improving or worsening mortality rate
    forval a = 1(1)6 { 
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
                        text(0.9 1.175 "${pc`a'}", place(e) size(60) color("`improve'%75") just(center) margin(l=2 r=2 t=2 b=2))
                        
                        legend(off)
                        name(dimprove`a')
                        ;
            #delimit cr
            graph export "`outputpath'\graphics\dalyc`a'.png" , replace
            ///graph export "`outputpath'\reports\graphics\table2-1\table2-1-col10-row`a'.pdf", replace
            ///graph export "`outputpath'\reports\graphics\table2-1\table2-1-col10-row`a'.svg", replace            
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
                        text(0.9 1.175 "${pc`a'}", place(e) size(60) color("`worsen'%75") just(center) margin(l=2 r=2 t=2 b=2))
                        
                        legend(off)
                        name(dworsen`a')
                        ;
            #delimit cr
            graph export "`outputpath'\graphics\dalyc`a'.png" , replace
            ///graph export "`outputpath'\reports\graphics\table2-1\table2-1-col10-row`a'.pdf", replace
            ///graph export "`outputpath'\reports\graphics\table2-1\table2-1-col10-row`a'.svg", replace            
         }
    }
restore



** -----------------------------------------------------
** COLUMN 10 
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
    forval x = 1(1)6 {
        global sdaly`x' = col5[`x',2]
    }
restore


/*

** -----------------------------------------------------
** AUTOMATED WORD TABLE FOR REPORT
** -----------------------------------------------------
putdocx begin , pagesize(A4) font(calibri light, 9)
putdocx table cvd = (10 , 11) 

** ----------------------
** Formatting
** ----------------------
** All cells - vertical centering
putdocx table cvd(.,.), valign(center) 

** ROW3 - remove left and right borders
putdocx table cvd(3,.), border(left, single, "FFFFFF") 
putdocx table cvd(3,.), border(right, single, "FFFFFF") 

** COL1 - no formatting
putdocx table cvd(1/2,1), bold border(all, single, "FFFFFF") 
putdocx table cvd(4/9,1), bold border(all, single, "FFFFFF") 

** COL2 - Add back left hand side border
putdocx table cvd(1/2,2), border(left, single, "000000") 
putdocx table cvd(4/9,2), border(left, single, "000000") 

** ROWS 1 and 2 - shading
putdocx table cvd(1/2,2/6), bold border(all, single, "000000") shading("9467bd")
putdocx table cvd(1/2,7/11), bold border(all, single, "000000") shading("c5b0d5")

** Merge FOUR top rows for headers
putdocx table cvd(1,2),colspan(5)
putdocx table cvd(1,3),colspan(5)

** Merge COL1 and COL2 rows 1 and 2
putdocx table cvd(1,1),rowspan(2)

** ROW 10 as single cell for comments
putdocx table cvd(10,2),colspan(10)
putdocx table cvd(10,.),halign(left) font(calibri light, 8)
putdocx table cvd(10,.),border(left, single, "FFFFFF")
putdocx table cvd(10,.),border(right, single, "FFFFFF")
putdocx table cvd(10,.),border(bottom, single, "FFFFFF")

** ----------------------
** Row and Column Titles
** ----------------------
putdocx table cvd(1,2) = ("Mortality "), bold font(calibri light,9, "FFFFFF")
putdocx table cvd(1,2) = ("1"), bold halign(right) font(calibri light,9, "FFFFFF") script(super) append
putdocx table cvd(1,3) = ("Disease Burden "), bold 
putdocx table cvd(1,3) = ("1"), bold halign(right) script(super) append

putdocx table cvd(2,2) = ("Number of "), bold font(calibri light,9, "FFFFFF") 
putdocx table cvd(2,2) = ("Deaths"), bold font(calibri light,9, "FFFFFF") append
putdocx table cvd(2,3) = ("Rate"), font(calibri light,9, "FFFFFF") linebreak bold
putdocx table cvd(2,3) = ("2019"), font(calibri light,9, "FFFFFF") append bold

putdocx table cvd(2,4) = ("M:F"), font(calibri light,9, "FFFFFF") bold         

putdocx table cvd(2,5) = ("Change"), font(calibri light,9, "FFFFFF") linebreak bold
putdocx table cvd(2,5) = ("2000-2019"), font(calibri light,9, "FFFFFF") append bold

putdocx table cvd(2,6) = ("Percent"), font(calibri light,9, "FFFFFF") linebreak bold    
putdocx table cvd(2,6) = ("change"), font(calibri light,9, "FFFFFF") append bold    

putdocx table cvd(2,7) = ("Number of "), bold
putdocx table cvd(2,7) = ("DALYs"), bold append

putdocx table cvd(2,8) = ("Rate"), font(calibri light,9) linebreak bold
putdocx table cvd(2,8) = ("2019"), font(calibri light,9) append bold

putdocx table cvd(2,9) = ("M:F"), font(calibri light,9) bold  

putdocx table cvd(2,10) = ("Change"), font(calibri light,9) linebreak bold
putdocx table cvd(2,10) = ("2000-2019"), font(calibri light,9) append bold

putdocx table cvd(2,11) = ("Percent"), font(calibri light,9) linebreak bold    
putdocx table cvd(2,11) = ("change"), font(calibri light,9) append bold    

putdocx table cvd(4,1) = ("Ischemic "), halign(right) bold
putdocx table cvd(4,1) = ("2"), bold halign(right) script(super) append

putdocx table cvd(5,1) = ("Stroke"), halign(right) bold

putdocx table cvd(6,1) = ("Hypertensive "), halign(right) bold
putdocx table cvd(6,1) = ("3"), bold halign(right) script(super) append

putdocx table cvd(7,1) = ("Cardiomyopathy "), halign(right) bold
putdocx table cvd(7,1) = ("4"), bold halign(right) script(super) append

putdocx table cvd(8,1) = ("Rheumatic "), halign(right) bold
putdocx table cvd(8,1) = ("5"), bold halign(right) script(super) append

putdocx table cvd(9,1) = ("All CVD "), halign(right) bold
putdocx table cvd(9,1) = ("6"), bold halign(right) script(super) append

** ----------------------
** DATA
** ----------------------
** COL2. Deaths
putdocx table cvd(4,2) = ("$deaths1") , nformat(%12.0fc) trim 
putdocx table cvd(5,2) = ("$deaths2") , nformat(%12.0fc) trim  
putdocx table cvd(6,2) = ("$deaths3") , nformat(%12.0fc) trim  
putdocx table cvd(7,2) = ("$deaths4") , nformat(%12.0fc) trim  
putdocx table cvd(8,2) = ("$deaths5") , nformat(%12.0fc) trim  
putdocx table cvd(9,2) = ("$deaths6") , nformat(%12.0fc) trim  

** COL3. Mortality Rates
putdocx table cvd(4,3) = ("$arate1") , nformat(%9.1fc)  trim
putdocx table cvd(5,3) = ("$arate2") , nformat(%9.1fc)  trim
putdocx table cvd(6,3) = ("$arate3") , nformat(%9.1fc)  trim
putdocx table cvd(7,3) = ("$arate4") , nformat(%9.1fc)  trim
putdocx table cvd(8,3) = ("$arate5") , nformat(%9.1fc)  trim
putdocx table cvd(9,3) = ("$arate6") , nformat(%9.1fc)  trim

** COL4. Sex ratio
putdocx table cvd(4,4) = ("$sratio1") , nformat(%9.2fc)  trim
putdocx table cvd(5,4) = ("$sratio2") , nformat(%9.2fc)  trim
putdocx table cvd(6,4) = ("$sratio3") , nformat(%9.2fc)  trim
putdocx table cvd(7,4) = ("$sratio4") , nformat(%9.2fc)  trim
putdocx table cvd(8,4) = ("$sratio5") , nformat(%9.2fc)  trim
putdocx table cvd(9,4) = ("$sratio6") , nformat(%9.2fc)  trim

** COL5. Mortality Rate Change since 2000
putdocx table cvd(4,5) = image("`outputpath'\graphics\spike1.png")
putdocx table cvd(5,5) = image("`outputpath'\graphics\spike2.png")
putdocx table cvd(6,5) = image("`outputpath'\graphics\spike3.png")
putdocx table cvd(7,5) = image("`outputpath'\graphics\spike4.png")
putdocx table cvd(8,5) = image("`outputpath'\graphics\spike5.png")
putdocx table cvd(9,5) = image("`outputpath'\graphics\spike6.png")

** COL6. Percent change
putdocx table cvd(4,6) = image("`outputpath'\graphics\mrc1.png"), width(25pt)
putdocx table cvd(5,6) = image("`outputpath'\graphics\mrc2.png"), width(25pt)
putdocx table cvd(6,6) = image("`outputpath'\graphics\mrc3.png"), width(25pt)
putdocx table cvd(7,6) = image("`outputpath'\graphics\mrc4.png"), width(25pt)
putdocx table cvd(8,6) = image("`outputpath'\graphics\mrc5.png"), width(25pt)
putdocx table cvd(9,6) = image("`outputpath'\graphics\mrc6.png"), width(25pt)


** COL7. DALY in 2019
putdocx table cvd(4,7) = ("$daly1") , nformat(%12.0fc)  trim
putdocx table cvd(5,7) = ("$daly2") , nformat(%12.0fc)  trim
putdocx table cvd(6,7) = ("$daly3") , nformat(%12.0fc)  trim
putdocx table cvd(7,7) = ("$daly4") , nformat(%12.0fc)  trim
putdocx table cvd(8,7) = ("$daly5") , nformat(%12.0fc)  trim
putdocx table cvd(9,7) = ("$daly6") , nformat(%12.0fc)  trim

** COL8. DALY Rates
putdocx table cvd(4,8) = ("$drate1") , nformat(%9.1fc)  trim
putdocx table cvd(5,8) = ("$drate2") , nformat(%9.1fc)  trim
putdocx table cvd(6,8) = ("$drate3") , nformat(%9.1fc)  trim
putdocx table cvd(7,8) = ("$drate4") , nformat(%9.1fc)  trim
putdocx table cvd(8,8) = ("$drate5") , nformat(%9.1fc)  trim
putdocx table cvd(9,8) = ("$drate6") , nformat(%9.1fc)  trim

** COL9. Sex ratio
putdocx table cvd(4,9) = ("$sdaly1") , nformat(%9.2fc)  trim
putdocx table cvd(5,9) = ("$sdaly2") , nformat(%9.2fc)  trim
putdocx table cvd(6,9) = ("$sdaly3") , nformat(%9.2fc)  trim
putdocx table cvd(7,9) = ("$sdaly4") , nformat(%9.2fc)  trim
putdocx table cvd(8,9) = ("$sdaly5") , nformat(%9.2fc)  trim
putdocx table cvd(9,9) = ("$sdaly6") , nformat(%9.2fc)  trim

** COL9. DALY Change since 2000
putdocx table cvd(4,10) = image("`outputpath'\graphics\spike_daly1.png")
putdocx table cvd(5,10) = image("`outputpath'\graphics\spike_daly2.png")
putdocx table cvd(6,10) = image("`outputpath'\graphics\spike_daly3.png")
putdocx table cvd(7,10) = image("`outputpath'\graphics\spike_daly4.png")
putdocx table cvd(8,10) = image("`outputpath'\graphics\spike_daly5.png")
putdocx table cvd(9,10) = image("`outputpath'\graphics\spike_daly6.png")

** COL10. Percent change 
putdocx table cvd(4,11) = image("`outputpath'\graphics\dalyc1.png"), width(25pt)
putdocx table cvd(5,11) = image("`outputpath'\graphics\dalyc2.png"), width(25pt)
putdocx table cvd(6,11) = image("`outputpath'\graphics\dalyc3.png"), width(25pt)
putdocx table cvd(7,11) = image("`outputpath'\graphics\dalyc4.png"), width(25pt)
putdocx table cvd(8,11) = image("`outputpath'\graphics\dalyc5.png"), width(25pt)
putdocx table cvd(9,11) = image("`outputpath'\graphics\dalyc6.png"), width(25pt)



** Column alignment
putdocx table cvd(.,1), halign(right) 
putdocx table cvd(.,2), halign(right) 
putdocx table cvd(.,3/6), halign(center) 
putdocx table cvd(.,7), halign(right) 
putdocx table cvd(.,8/10), halign(center) 
putdocx table cvd(1,2), halign(center) 
putdocx table cvd(1,3), halign(center) 

** FINAL TABLE NOTES
putdocx table cvd(10,2) = ("(1) ") , script(super) font(calibri light, 8)
putdocx table cvd(10,2) = ("Mortality is described using the age-standardized mortality rate. Disease Burden is described using the age-standardized DALY rate. Both rates presented per 100,000 population.") , append font(calibri light, 8) 

putdocx table cvd(10,2) = ("(2) ") , script(super) font(calibri light, 8) append 
putdocx table cvd(10,2) = ("Ischemic heart disease") , append font(calibri light, 8) 

putdocx table cvd(10,2) = ("  (3) ") , script(super) font(calibri light, 8) append
putdocx table cvd(10,2) = ("Hypertensive heart disease") , append font(calibri light, 8) 

putdocx table cvd(10,2) = ("  (4) ") , script(super) font(calibri light, 8) append
putdocx table cvd(10,2) = ("Cardiomyopathy, myocarditis, endocarditis") , append font(calibri light, 8) 

putdocx table cvd(10,2) = ("  (5) ") , script(super) font(calibri light, 8) append
putdocx table cvd(10,2) = ("Rheumatic heart disease") , append font(calibri light, 8) 

putdocx table cvd(10,2) = ("  (6) ") , script(super) font(calibri light, 8) append
putdocx table cvd(10,2) = ("All CVD includes 'other' circulatory diseases (All CVD ICD codes: I00-I99. Other CVD ICD codes: I00, I26-I28, I34-I37, I44-I51, I70-I99)") , append font(calibri light, 8) linebreak

** Save the Table
putdocx save "`outputpath'\graphics\table_cvd.docx" , replace


