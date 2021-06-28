** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap2-cvd-summary-table.do
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
    log using "`logpath'\chap2-cvd-summary-table", replace
** HEADER -----------------------------------------------------



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
    tabdisp cod  , cell(dths) format(%12.0fc)
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
    tabdisp cod , cell(arate) format(%12.1fc) 
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
** Outputs: spike1.png to spike6.png
** -----------------------------------------------------
** Sparkline of Mortality Rate change over time
preserve
    keep if region==2000

    ** Color Scheme
    colorpalette ptol, rainbow n(12)  nograph
    local list r(p) 
    ** Mortality Rate
    local mrate `r(p1)'
    ** DALY
    local daly `r(p2)'
    ** Improve and worsen
    local improve `r(p7)'
    local worsen `r(p12)'



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

                        text(1.4 1.17 "{&dArr}", place(w) size(75) color("`improve'%50") just(center) margin(l=2 r=2 t=2 b=2))
                        text(0.9 1.175 "${pc`a'}", place(e) size(60) color("`improve'%50") just(center) margin(l=2 r=2 t=2 b=2))
                        
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

                        text(0.9 1.17 "{&uArr}", place(w) size(75) color("`worsen'%50") just(center) margin(l=2 r=2 t=2 b=2))
                        text(0.9 1.175 "${pc`a'}", place(e) size(60) color("`worsen'%50") just(center) margin(l=2 r=2 t=2 b=2))
                        
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
** Outputs: sratio1 to sratio6
** -----------------------------------------------------
** Ratio of Men to Women in 2019
preserve
    keep if sex<3 & region==2000 & year==2019
    keep sex cod arate 
    replace arate = arate* 100000 
    reshape wide arate, i(cod) j(sex)

    gen arate_ratio = arate1 / arate2 
    tabdisp cod , cell(arate_ratio) format(%12.2fc)
    sort cod 
    gen arate_ratio_int = round(arate_ratio)
    mkmat cod arate_ratio_int , matrix(col5)
    matrix list col5
    forval x = 1(1)6 {
        global sratio`x' = col5[`x',2]
    }
restore



** -----------------------------------------------------
** COLUMN 6  
** Outputs: daly1 to daly6
** -----------------------------------------------------
** DALY combined
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

    keep if region==2000 & year==2019 
    collapse (sum) daly, by(cod)
    tabdisp cod , cell(daly) format(%12.0fc)

    sort cod 
    gen daly_int = round(daly)
    mkmat cod daly_int , matrix(col6)
    matrix list col6
    forval x = 1(1)6 {
        global daly`x' = col6[`x',2]
    }










** WORD TABLE
putdocx begin , pagesize(A4) font(calibri light, 9)
putdocx table cvd = (9 , 11) 

** Formatting

** All cells - vertical centering
putdocx table cvd(.,.), valign(center) 

** COL2 - remove top and bottom borders
putdocx table cvd(.,2), border(top, single, "FFFFFF") 
putdocx table cvd(.,2), border(bottom, single, "FFFFFF") 

** ROW3 - remove left and right borders
putdocx table cvd(3,.), border(left, single, "FFFFFF") 
putdocx table cvd(3,.), border(right, single, "FFFFFF") 

** COL1 - shading
putdocx table cvd(1/2,1), bold halign(left) valign(center) border(all, single, "000000") shading("ECECEC")
putdocx table cvd(4/9,1), bold halign(left) valign(center) border(all, single, "000000") shading("ECECEC")

** ROWS 1 and 2 - shading
putdocx table cvd(1/2,1), bold halign(left) valign(center) border(all, single, "000000") shading("ECECEC")
putdocx table cvd(1/2,3/11), bold halign(left) valign(center) border(all, single, "000000") shading("ECECEC")

** Merge FOUR top rows for headers
putdocx table cvd(1,4),colspan(4)
putdocx table cvd(1,5),colspan(4)

** Merge COL1 and COL3 rows 1 and 2
putdocx table cvd(1,1),rowspan(2)
putdocx table cvd(1,3),rowspan(2)

** Row and Column Titles
putdocx table cvd(1,3) = ("Deaths"), 
putdocx table cvd(1,4) = ("Mortality Rate"), 
putdocx table cvd(1,5) = ("Disease Burden"), 

putdocx table cvd(2,4) = ("Rate 2019"), font(calibri light,9)   
putdocx table cvd(2,5) = ("Change"), font(calibri light,9)      
putdocx table cvd(2,6) = ("% change"), font(calibri light,9)    
putdocx table cvd(2,7) = ("M:F"), font(calibri light,9)         

putdocx table cvd(2,8) = ("DALY 2019"), font(calibri light,9)   
putdocx table cvd(2,9) = ("Change"), font(calibri light,9)      
putdocx table cvd(2,10) = ("% change"), font(calibri light,9)   
putdocx table cvd(2,11) = ("M:F"), font(calibri light,9)        

putdocx table cvd(4,1) = ("Ischaemic")
putdocx table cvd(5,1) = ("Stroke")
putdocx table cvd(6,1) = ("Hypertensive")
putdocx table cvd(7,1) = ("Cardiomyopthy")
putdocx table cvd(8,1) = ("Rheumatic")
putdocx table cvd(9,1) = ("All CVD")

** Deaths
putdocx table cvd(4,3) = ("$deaths1") , nformat(%12.0fc)  
putdocx table cvd(5,3) = ("$deaths2") , nformat(%12.0fc)  
putdocx table cvd(6,3) = ("$deaths3") , nformat(%12.0fc)  
putdocx table cvd(7,3) = ("$deaths4") , nformat(%12.0fc)  
putdocx table cvd(8,3) = ("$deaths5") , nformat(%12.0fc)  
putdocx table cvd(9,3) = ("$deaths6") , nformat(%12.0fc)  

** Mortality Rates
putdocx table cvd(4,4) = ("$arate1") , nformat(%9.1fc)  
putdocx table cvd(5,4) = ("$arate2") , nformat(%9.1fc)  
putdocx table cvd(6,4) = ("$arate3") , nformat(%9.1fc)  
putdocx table cvd(7,4) = ("$arate4") , nformat(%9.1fc)  
putdocx table cvd(8,4) = ("$arate5") , nformat(%9.1fc)  
putdocx table cvd(9,4) = ("$arate6") , nformat(%9.1fc)  

** Change since 2000
putdocx table cvd(4,5) = image("`outputpath'\graphics\spike1.png")
putdocx table cvd(5,5) = image("`outputpath'\graphics\spike2.png")
putdocx table cvd(6,5) = image("`outputpath'\graphics\spike3.png")
putdocx table cvd(7,5) = image("`outputpath'\graphics\spike4.png")
putdocx table cvd(8,5) = image("`outputpath'\graphics\spike5.png")
putdocx table cvd(9,5) = image("`outputpath'\graphics\spike6.png")

** Percent change
putdocx table cvd(4,6) = image("`outputpath'\graphics\mrc1.png"), width(25pt)
putdocx table cvd(5,6) = image("`outputpath'\graphics\mrc2.png"), width(25pt)
putdocx table cvd(6,6) = image("`outputpath'\graphics\mrc3.png"), width(25pt)
putdocx table cvd(7,6) = image("`outputpath'\graphics\mrc4.png"), width(25pt)
putdocx table cvd(8,6) = image("`outputpath'\graphics\mrc5.png"), width(25pt)
putdocx table cvd(9,6) = image("`outputpath'\graphics\mrc6.png"), width(25pt)


putdocx table cvd(.,.), valign(center) 
putdocx table cvd(.,.), halign(right) 

putdocx save "`outputpath'\graphics\table_cvd.docx" , replace


