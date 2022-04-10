** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap3-160-mr-subregion.do
    //  project:				    WHO Global Health Estimates
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	26-Apr-2021
    //  algorithm task			    Summary graphic of MR change between 2000 and 2019

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
    log using "`logpath'\chap3-160-mr-subregion", replace
** HEADER -----------------------------------------------------


** -----------------------------------------------------
** TABLE PART ONE 
** DEATHS METRICS
** -----------------------------------------------------

tempfile kcancer region_mr12 region_mr3 region_daly12 region_daly3

** Mortality Rate statistics first
** use "`datapath'\from-who\chap2_000_mr", clear
use "`datapath'\from-who\chap2_000_adjusted", clear
rename mortr mrate
rename dalyr drate
drop pop_dalyr
rename pop_mortr pop 
format daly dths pop %15.1fc 
order pop dths daly mrate drate , after(paho_subregion)

** Keep CVD, Cancers, Diabetes
keep if ghecause==400 | ghecause==500 | ghecause==600 | ghecause==31 | ghecause==800 | ghecause==900 |ghecause==1000
keep if sex==3
keep if year==2019
keep if region<100 | region==2000



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

rename ghecause cod

* Caribbean vs the rest
gen subr = 2  
replace subr = 1 if paho_subregion==5 | paho_subregion==6
label define subr_ 1 "Caribbean" 2 "The rest of the Americas"
label values subr subr_

* Caribbean and Central America vs the rest
gen subr3 = 3  
replace subr3 = 1 if paho_subregion==5 | paho_subregion==6
replace subr3 = 2 if paho_subregion==2
label define subr3_ 1 "Caribbean" 2 "Central America" 3 "The rest of the Americas"
label values subr3 subr3_

order drate, after(region)
gsort cod -drate 

** -----------------------------------------------------
** GRAPHIC - BOX PLOT
** -----------------------------------------------------
** Change in GENDER DALY rate between 2000 and 2019
** -----------------------------------------------------


preserve
    drop daly dths mrate 
    reshape wide drate, i(region) j(cod)
    reshape wide drate400 drate500 drate31, i(region) j(subr)

    #delimit ;
    gr hbox drate4001 drate4002 drate600 drate5001 drate5002 drate800 drate311 drate312
        , 
        medtype(cline) medline(lc(gs16) lw(0.5) ) 

        box(1, lc("`cvd1'") fc("`cvd1'") )
        box(2, lc("`cvd1'") fc("`cvd1'") )
        marker(1, mcol("`cvd2'") m(o) msize(3))

        box(3, lc("gs16") fc("gs16") )

        box(4, lc("`can1'") fc("`can1'") )
        box(5, lc("`can1'") fc("`can1'") )
        marker(5, mcol("`can2'") m(o) msize(3) )

        box(6, lc("gs16") fc("gs16") )
        marker(6, mcol("gs16"))

        box(7, lc("`dia1'") fc("`dia1'") )
        box(8, lc("`dia1'") fc("`dia1'") )
        marker(8, mcol("`dia2'") m(o) msize(3) )

        plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin))
        graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin))
        ysize(8) xsize(18)

        ylab(0(2000)10000,
                labc(gs8) labs(4) tstyle(major_notick) nogrid glc(gs16) angle(0) format(%9.0fc) labgap(1))    
        yscale(range(-2500(100)1010))
        ytitle("DALY rate (per 100,000)", size(5) color(gs8) margin(l=0 r=0 t=5 b=0)) 

        text(5 20 "Caribbean" , place(w) size(5) color("gs8") just(left) margin(l=0 r=1 t=4 b=2))
        text(5 9 "Rest of the Americas" , place(w) size(5) color("gs8") just(left) margin(l=0 r=1 t=4 b=2))
        text(5 58 "Caribbean" , place(w) size(5) color("gs8") just(left) margin(l=0 r=1 t=4 b=2))
        text(5 47 "Rest of the Americas" , place(w) size(5) color("gs8") just(left) margin(l=0 r=1 t=4 b=2))
        text(5 96 "Caribbean" , place(w) size(5) color("gs8") just(left) margin(l=0 r=1 t=4 b=2))
        text(5 85 "Rest of the Americas" , place(w) size(5) color("gs8") just(left) margin(l=0 r=1 t=4 b=2))

        text(8700 97  "Guyana" , place(e) size(5) color("`cvd2'") just(left) margin(l=0 r=1 t=4 b=2))
        text(10000 87  "Haiti" , place(e) size(5) color("`cvd2'") just(left) margin(l=0 r=1 t=4 b=2))
        text(4100 46  "Uruguay" , place(e) size(5) color("`can2'") just(left) margin(l=0 r=1 t=4 b=2))
        text(2800 8  "Mexico" , place(e) size(5) color("`dia2'") just(left) margin(l=0 r=1 t=4 b=2))


        legend(order(1 4 7) 
        label(1 "CVD")  
        label(4 "Cancer") 
        label(7 "Diabetes") 
        cols(3) position(6) margin(t=2) size(4.5) symxsize(6) symysize(4) color("gs8")
        )

        name(box1)
    ;
    #delimit cr
restore

/*

** Second plot NOW also seprating central america

**preserve
    drop daly dths mrate 
    reshape wide drate, i(region subr3) j(cod)
    reshape wide drate400 drate500 drate31, i(region) j(subr3)

    #delimit ;
    gr hbox drate4001 drate4002 drate4003 drate600 drate5001 drate5002 drate5003 drate800 drate311 drate312 drate313
        , 
        medtype(cline) medline(lc(gs16) lw(0.5) ) 

        box(1, lc("`cvd1'") fc("`cvd1'") )
        box(2, lc("`cvd1'") fc("`cvd1'") )
        box(3, lc("`cvd1'") fc("`cvd1'") )
        ///marker(1, mcol("`cvd2'") m(o) msize(3))

        box(4, lc("gs16") fc("gs16") )

        box(5, lc("`can1'") fc("`can1'") )
        box(6, lc("`can1'") fc("`can1'") )
        box(7, lc("`can1'") fc("`can1'") )
        ///marker(6, mcol("`can2'") m(o) msize(3) )

        box(8, lc("gs16") fc("gs16") )

        box(9, lc("gs16") fc("gs16") )
        box(9, lc("`dia1'") fc("`dia1'") )
        box(10, lc("`dia1'") fc("`dia1'") )
        ///marker(8, mcol("`dia2'") m(o) msize(3) )

        plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin))
        graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin))
        ysize(8) xsize(18)

        ylab(0(2000)10000,
                labc(gs8) labs(4) tstyle(major_notick) nogrid glc(gs16) angle(0) format(%9.0fc) labgap(1))    
        yscale(range(-2500(100)1010))
        ytitle("DALY rate (per 100,000)", size(5) color(gs8) margin(l=0 r=0 t=5 b=0)) 

        text(5 20 "Caribbean" , place(w) size(5) color("gs8") just(left) margin(l=0 r=1 t=4 b=2))
        text(5 15 "Central America" , place(w) size(5) color("gs8") just(left) margin(l=0 r=1 t=4 b=2))
        text(5 9 "Rest of the Americas" , place(w) size(5) color("gs8") just(left) margin(l=0 r=1 t=4 b=2))
        text(5 58 "Caribbean" , place(w) size(5) color("gs8") just(left) margin(l=0 r=1 t=4 b=2))
        text(5 53 "Central America" , place(w) size(5) color("gs8") just(left) margin(l=0 r=1 t=4 b=2))
        text(5 47 "Rest of the Americas" , place(w) size(5) color("gs8") just(left) margin(l=0 r=1 t=4 b=2))
        text(5 96 "Caribbean" , place(w) size(5) color("gs8") just(left) margin(l=0 r=1 t=4 b=2))
        text(5 85 "Central America" , place(w) size(5) color("gs8") just(left) margin(l=0 r=1 t=4 b=2))
        text(5 74 "Rest of the Americas" , place(w) size(5) color("gs8") just(left) margin(l=0 r=1 t=4 b=2))

        text(8600 97  "Guyana" , place(e) size(5) color("`cvd2'") just(left) margin(l=0 r=1 t=4 b=2))
        text(10000 87  "Haiti" , place(e) size(5) color("`cvd2'") just(left) margin(l=0 r=1 t=4 b=2))
        text(4100 46  "Uruguay" , place(e) size(5) color("`can2'") just(left) margin(l=0 r=1 t=4 b=2))
        text(2800 8  "Mexico" , place(e) size(5) color("`dia2'") just(left) margin(l=0 r=1 t=4 b=2))


        legend(order(1 4 7) 
        label(1 "CVD")  
        label(4 "Cancer") 
        label(7 "Diabetes") 
        cols(3) position(6) margin(t=2) size(4.5) symxsize(6) symysize(4) color("gs8")
        )

        name(box2)
    ;
    #delimit cr
**restore


