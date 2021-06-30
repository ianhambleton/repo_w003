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


** Mortality Rate statistics first
use "`datapath'\from-who\chap2_cvd_mr", clear

** Create new GHE CoD order for Table 
gen cod = 1 if ghecause==1130 
replace cod = 2 if ghecause==1140
replace cod = 3 if ghecause==1120
replace cod = 4 if ghecause==1150
replace cod = 5 if ghecause==1110
replace cod = 6 if ghecause==1100
drop if ghecause==1160 
#delimit ; 
label define cod_   1 "ischaemic" 
                    2 "stroke" 
                    3 "hypertensive" 
                    4 "cardiomyopathy etc" 
                    5 "rheumatic" 
                    6 "all cvd", modify ;
#delimit cr
label values cod cod_ 

** -----------------------------------------------------
** COLUMN 1
** Outputs: deaths1 to deaths6
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
** Outputs: arate1 to arate6
** -----------------------------------------------------
** Mortality Rate in 2019
preserve
    sort sex cod 
    replace arate = arate* 100000 
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


/*

** -----------------------------------------------------
** COLUMN 3 
** Outputs: spike1.png to spike6.png
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
                (rarea rel_arate y year if cod==`a' & sex==3 & region==2000 , sort lw(none) color("`mrate'%25"))
                (line rel_arate year if cod==`a' & sex==3 & region==2000, sort lc("`mrate'*0.5") fc("`mrate'*0.5") lw(6) msize(2.5))
                ///(sc rel_arate year if cod==`a' & sex==3 & region==2000, sort m(O) mfc("gs16") mlw(1) mlc("`mrate'") msize(3.5) )
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
    }
restore



** -----------------------------------------------------
** COLUMN 4 
** Outputs: improve{1-6}.png or worsen{1-6}.png
** -----------------------------------------------------
** Graphic of Absolute or Relative Change between 2000 and 2019
preserve
    keep if sex==3 & region==2000 & (year==2000 | year==2019)
    keep year cod arate 
    replace arate = arate* 100000 
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
        }
    }
restore

*/

** -----------------------------------------------------
** COLUMN 5 
** Outputs: sratio1 to sratio6
** -----------------------------------------------------
** Ratio of Men to Women in 2019
preserve
    keep if sex<3 & region==2000 & year==2019
    keep sex cod arate 
    replace arate = arate* 100000 
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
** COLS 6 to 9  
** DALY metrics
** -----------------------------------------------------
    use "`datapath'\from-who\chap2_cvd_daly", clear

    ** Create new GHE CoD order for Table 
    gen cod = 1 if ghecause==1130 
    replace cod = 2 if ghecause==1140
    replace cod = 3 if ghecause==1120
    replace cod = 4 if ghecause==1150
    replace cod = 5 if ghecause==1110
    replace cod = 6 if ghecause==1100
    drop if ghecause==1160 
    #delimit ; 
    label define cod_   1 "ischaemic" 
                        2 "stroke" 
                        3 "hypertensive" 
                        4 "cardiomyopathy etc" 
                        5 "rheumatic" 
                        6 "all cvd", modify ;
    #delimit cr
    label values cod cod_ 


** -----------------------------------------------------
** COLUMN 6  
** DALY 2019
** -----------------------------------------------------
** DALY combined
preserve
    keep if region==2000 & year==2019 
    collapse (sum) daly, by(cod)
    tabdisp cod , cell(daly) format(%11.0fc)

    sort cod 
    gen daly_int = round(daly)
    mkmat cod daly_int , matrix(col6)
    matrix list col6
    forval x = 1(1)6 {
        global daly`x' = col6[`x',2]
    }
restore


/*

** -----------------------------------------------------
** COLUMN 7 
** Outputs: spike1.png to spike6.png
** -----------------------------------------------------
** Sparkline of Mortality Rate change over time

preserve
    keep if region==2000

    ** DALY value for women and men combined
    collapse (sum) daly , by(year cod region)
    gen sex=3

    ** Relative Rate 
    gen daly1 = daly if year==2000
    bysort sex cod : egen daly2 = min(daly1)
    drop daly1 
    gen rel_daly = daly/daly2

    ** Zero line for shading boundary 
    gen y = 0 

    ** Women and Men combined
    forval a = 1(1)6 { 
        #delimit ;
            gr twoway 
                (rarea rel_daly y year if cod==`a' & sex==3 & region==2000 , sort lw(none) color("`daly'%25"))
                (line rel_daly year if cod==`a' & sex==3 & region==2000, sort lc("`daly'*0.5") fc("`daly'*0.5") lw(6) msize(2.5))
                ///(sc rel_arate year if cod==`a' & sex==3 & region==2000, sort m(O) mfc("gs16") mlw(1) mlc("`daly'") msize(3.5) )
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
    }
restore





** -----------------------------------------------------
** COLUMN 8 
** Outputs: improve{1-6}.png or worsen{1-6}.png
** -----------------------------------------------------
** Graphic of Absolute or Relative Change between 2000 and 2019
preserve

    ** DALY value for women and men combined
    collapse (sum) daly , by(year cod region)
    gen sex=3
    
    keep if sex==3 & region==2000 & (year==2000 | year==2019)
    keep year cod daly  
    format daly %12.1fc 
    reshape wide daly, i(cod) j(year)

    ** Improving rate (green chart) or Worsening rate (so red chart) 
    gen change = . 
    replace change = 1 if daly2019 < daly2000
    replace change = 2 if daly2019 >= daly2000
    label define change_ 1 "improving" 2 "worsening", modify 
    label values change change_

    ** absolute change
    gen daly_ac = sqrt((daly2000 - daly2019)^2)
    ** percentage change
    gen daly_pc = ( (sqrt((daly2000 - daly2019)^2)) / daly2000 ) * 100

    sort cod 
    gen daly_pc_int = round(daly_pc)
    mkmat cod daly_pc_int , matrix(col4)
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
                        name(improve_daly`a')
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
                        text(0.9 1.175 "${pc`a'}", place(e) size(60) color("`worsen'%75") just(center) margin(l=2 r=2 t=2 b=2))
                        
                        legend(off)
                        name(worsen_daly`a')
                        ;
            #delimit cr
            graph export "`outputpath'\graphics\dalyc`a'.png" , replace
        }
    }
restore

*/

** -----------------------------------------------------
** COLUMN 9 
** Outputs: sdaly1 to sdaly6
** -----------------------------------------------------
** Ratio of Men to Women in 2019
preserve

    ** DALY value for women and men combined
    ** collapse (sum) daly , by(year cod region)
    ** gen sex=3
    
    keep if region==2000 & year==2019
    keep sex cod daly 
    reshape wide daly, i(cod) j(sex)

    gen daly_ratio = daly1 / daly2 
    tabdisp cod , cell(daly_ratio) format(%6.2fc)
    sort cod 
    gen daly_ratio_int = round(daly_ratio, 0.01)
    mkmat cod daly_ratio_int , matrix(col5)
    matrix list col5
    forval x = 1(1)6 {
        global sdaly`x' = col5[`x',2]
    }
restore



** -----------------------------------------------------
** AUTOMATED WORD TABLE FOR REPORT
** -----------------------------------------------------
putdocx begin , pagesize(A4) font(calibri light, 9)
putdocx table cvd = (10 , 10) 

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
putdocx table cvd(1/2,3/6), bold border(all, single, "000000") shading("EAB0EE")
putdocx table cvd(1/2,7/10), bold border(all, single, "000000") shading("B1CDE5")

** Merge FOUR top rows for headers
putdocx table cvd(1,3),colspan(4)
putdocx table cvd(1,4),colspan(4)

** Merge COL1 and COL2 rows 1 and 2
putdocx table cvd(1,1),rowspan(2)
putdocx table cvd(1,2),rowspan(2)

** ROW 10 as single cell for comments
putdocx table cvd(10,2),colspan(9)
putdocx table cvd(10,.),halign(left) font(calibri light, 8)
putdocx table cvd(10,.),border(left, single, "FFFFFF")
putdocx table cvd(10,.),border(right, single, "FFFFFF")
putdocx table cvd(10,.),border(bottom, single, "FFFFFF")

** ----------------------
** Row and Column Titles
** ----------------------
putdocx table cvd(1,2) = ("Deaths"), 
putdocx table cvd(1,3) = ("Mortality Rate"), 
putdocx table cvd(1,4) = ("Disease Burden"), 

putdocx table cvd(2,3) = ("Rate"), font(calibri light,9) linebreak
putdocx table cvd(2,3) = ("2019"), font(calibri light,9) append

putdocx table cvd(2,4) = ("M : F"), font(calibri light,9)         

putdocx table cvd(2,5) = ("Change"), font(calibri light,9) linebreak
putdocx table cvd(2,5) = ("2000-2019"), font(calibri light,9) append

putdocx table cvd(2,6) = ("Percent"), font(calibri light,9) linebreak    
putdocx table cvd(2,6) = ("change"), font(calibri light,9) append    

putdocx table cvd(2,7) = ("Rate"), font(calibri light,9) linebreak
putdocx table cvd(2,7) = ("2019"), font(calibri light,9) append

putdocx table cvd(2,8) = ("M : F"), font(calibri light,9)  

putdocx table cvd(2,9) = ("Change"), font(calibri light,9) linebreak
putdocx table cvd(2,9) = ("2000-2019"), font(calibri light,9) append

putdocx table cvd(2,10) = ("Percent"), font(calibri light,9) linebreak    
putdocx table cvd(2,10) = ("change"), font(calibri light,9) append    

putdocx table cvd(4,1) = ("Ischaemic "), halign(right)
putdocx table cvd(4,1) = ("1"), halign(right) script(super) append

putdocx table cvd(5,1) = ("Stroke"), halign(right)

putdocx table cvd(6,1) = ("Hypertensive "), halign(right)
putdocx table cvd(6,1) = ("2"), halign(right) script(super) append

putdocx table cvd(7,1) = ("Cardiomyopthy "), halign(right)
putdocx table cvd(7,1) = ("3"), halign(right) script(super) append

putdocx table cvd(8,1) = ("Rheumatic "), halign(right)
putdocx table cvd(8,1) = ("4"), halign(right) script(super) append

putdocx table cvd(9,1) = ("All CVD "), halign(right)
putdocx table cvd(9,1) = ("5"), halign(right) script(super) append

** ----------------------
** DATA
** ----------------------
** COL1. Deaths
putdocx table cvd(4,2) = ("$deaths1") , nformat(%12.0fc) trim 
putdocx table cvd(5,2) = ("$deaths2") , nformat(%12.0fc) trim  
putdocx table cvd(6,2) = ("$deaths3") , nformat(%12.0fc) trim  
putdocx table cvd(7,2) = ("$deaths4") , nformat(%12.0fc) trim  
putdocx table cvd(8,2) = ("$deaths5") , nformat(%12.0fc) trim  
putdocx table cvd(9,2) = ("$deaths6") , nformat(%12.0fc) trim  

** COL2. Mortality Rates
putdocx table cvd(4,3) = ("$arate1") , nformat(%9.1fc)  trim
putdocx table cvd(5,3) = ("$arate2") , nformat(%9.1fc)  trim
putdocx table cvd(6,3) = ("$arate3") , nformat(%9.1fc)  trim
putdocx table cvd(7,3) = ("$arate4") , nformat(%9.1fc)  trim
putdocx table cvd(8,3) = ("$arate5") , nformat(%9.1fc)  trim
putdocx table cvd(9,3) = ("$arate6") , nformat(%9.1fc)  trim

** COL3. Sex ratio
putdocx table cvd(4,4) = ("$sratio1") , nformat(%9.2fc)  trim
putdocx table cvd(5,4) = ("$sratio2") , nformat(%9.2fc)  trim
putdocx table cvd(6,4) = ("$sratio3") , nformat(%9.2fc)  trim
putdocx table cvd(7,4) = ("$sratio4") , nformat(%9.2fc)  trim
putdocx table cvd(8,4) = ("$sratio5") , nformat(%9.2fc)  trim
putdocx table cvd(9,4) = ("$sratio6") , nformat(%9.2fc)  trim

** COL4. Mortality Rate Change since 2000
putdocx table cvd(4,5) = image("`outputpath'\graphics\spike1.png")
putdocx table cvd(5,5) = image("`outputpath'\graphics\spike2.png")
putdocx table cvd(6,5) = image("`outputpath'\graphics\spike3.png")
putdocx table cvd(7,5) = image("`outputpath'\graphics\spike4.png")
putdocx table cvd(8,5) = image("`outputpath'\graphics\spike5.png")
putdocx table cvd(9,5) = image("`outputpath'\graphics\spike6.png")

** COL5. Percent change
putdocx table cvd(4,6) = image("`outputpath'\graphics\mrc1.png"), width(25pt)
putdocx table cvd(5,6) = image("`outputpath'\graphics\mrc2.png"), width(25pt)
putdocx table cvd(6,6) = image("`outputpath'\graphics\mrc3.png"), width(25pt)
putdocx table cvd(7,6) = image("`outputpath'\graphics\mrc4.png"), width(25pt)
putdocx table cvd(8,6) = image("`outputpath'\graphics\mrc5.png"), width(25pt)
putdocx table cvd(9,6) = image("`outputpath'\graphics\mrc6.png"), width(25pt)

** COL6. DALY in 2019
putdocx table cvd(4,7) = ("$daly1") , nformat(%12.0fc)  trim
putdocx table cvd(5,7) = ("$daly2") , nformat(%12.0fc)  trim
putdocx table cvd(6,7) = ("$daly3") , nformat(%12.0fc)  trim
putdocx table cvd(7,7) = ("$daly4") , nformat(%12.0fc)  trim
putdocx table cvd(8,7) = ("$daly5") , nformat(%12.0fc)  trim
putdocx table cvd(9,7) = ("$daly6") , nformat(%12.0fc)  trim

** COL9. Sex ratio
putdocx table cvd(4,8) = ("$sdaly1") , nformat(%9.2fc)  trim
putdocx table cvd(5,8) = ("$sdaly2") , nformat(%9.2fc)  trim
putdocx table cvd(6,8) = ("$sdaly3") , nformat(%9.2fc)  trim
putdocx table cvd(7,8) = ("$sdaly4") , nformat(%9.2fc)  trim
putdocx table cvd(8,8) = ("$sdaly5") , nformat(%9.2fc)  trim
putdocx table cvd(9,8) = ("$sdaly6") , nformat(%9.2fc)  trim

** COL7. DALY Change since 2000
putdocx table cvd(4,9) = image("`outputpath'\graphics\spike_daly1.png")
putdocx table cvd(5,9) = image("`outputpath'\graphics\spike_daly2.png")
putdocx table cvd(6,9) = image("`outputpath'\graphics\spike_daly3.png")
putdocx table cvd(7,9) = image("`outputpath'\graphics\spike_daly4.png")
putdocx table cvd(8,9) = image("`outputpath'\graphics\spike_daly5.png")
putdocx table cvd(9,9) = image("`outputpath'\graphics\spike_daly6.png")

** COL8. Percent change 
putdocx table cvd(4,10) = image("`outputpath'\graphics\dalyc1.png"), width(25pt)
putdocx table cvd(5,10) = image("`outputpath'\graphics\dalyc2.png"), width(25pt)
putdocx table cvd(6,10) = image("`outputpath'\graphics\dalyc3.png"), width(25pt)
putdocx table cvd(7,10) = image("`outputpath'\graphics\dalyc4.png"), width(25pt)
putdocx table cvd(8,10) = image("`outputpath'\graphics\dalyc5.png"), width(25pt)
putdocx table cvd(9,10) = image("`outputpath'\graphics\dalyc6.png"), width(25pt)

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
putdocx table cvd(10,2) = ("Ischaemic heart disease") , append font(calibri light, 8) 

putdocx table cvd(10,2) = ("  (2) ") , script(super) font(calibri light, 8) append
putdocx table cvd(10,2) = ("Hypertensive heart disease") , append font(calibri light, 8) 

putdocx table cvd(10,2) = ("  (3) ") , script(super) font(calibri light, 8) append
putdocx table cvd(10,2) = ("Cardiomyopathy, myocarditis, endocarditis") , append font(calibri light, 8) 

putdocx table cvd(10,2) = ("  (4) ") , script(super) font(calibri light, 8) append
putdocx table cvd(10,2) = ("Rheumatic heart disease") , append font(calibri light, 8)  

putdocx table cvd(10,2) = ("  (5) ") , script(super) font(calibri light, 8) append
putdocx table cvd(10,2) = ("All CVD includes 'other' circulatory diseases. ICD codes: I00, I26-I28, I34-I37, I44-I51, I70-I99") , append font(calibri light, 8) linebreak

** Save the Table
putdocx save "`outputpath'\graphics\table_cvd.docx" , replace


