** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    aging-600-mortality-uncertainty.do
    //  project:				    UN WPP (2019 edition)
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	16-Nov-2022
    //  algorithm task			    Sensitivity work for mortality data

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
    log using "`logpath'\aging-600-mortality-uncertainty", replace
** HEADER -----------------------------------------------------

tempfile decomp1 decomp2 decomp3 decomp

** Decomp dataset. Men only
use "`datapath'\from-who\decomposition_men", clear
gen sex = 1
save `decomp1', replace

** Decomp dataset. Women only
use "`datapath'\from-who\decomposition_women", clear
gen sex = 2
save `decomp2', replace

** Decomp dataset. Women and Men combined
use "`datapath'\from-who\decomposition", clear
gen sex = 3
save `decomp3', replace

use `decomp1', clear
append using `decomp2'
append using `decomp3'
label define sex_ 1 "men" 2 "women" 3 "both"
label values sex sex_
order sex, after(type)
save `decomp', replace



** Sex-Stratified RESULTS. A few figures
sort ch1 
** DEATHS. Combined / Women / Men
list iso3n type ch1 ch2 ch3 if type==1 & sex==3 , sep(10) line(120)
list iso3n type ch1 ch2 ch3 if type==1 & sex==2 , sep(10) line(120)
list iso3n type ch1 ch2 ch3 if type==1 & sex==1 , sep(10) line(120)

** DALY. Combined / Women / Men
list iso3n type ch1 ch2 ch3 if type==2 & sex==3 , sep(10) line(120)
list iso3n type ch1 ch2 ch3 if type==2 & sex==2 , sep(10) line(120)
list iso3n type ch1 ch2 ch3 if type==2 & sex==1 , sep(10) line(120)

** Typical (median) values
collapse (mean) ch1_m=ch1 ch2_m=ch2 ch3_m=ch3  (p50) ch1_p50=ch1 ch2_p50=ch2 ch3_p50=ch3, by(type sex) 
/*
** Calculate Index of Disparity for the following
** Overall change (ch1). 95% UI (ch2 - ch3)
** Change due to population growth (gr1). 95% UI (gr2 - gr3)
** Change due to population aging (as1). 95% UI (as2 - as3)
** Change due to age-specific rates (ep1). 95% UI (ep2 - ep3)

** ---------------------------------------------------
** Statistics for the text to accompany this graphic
** Simple relative measure of inequality : Rate (R)
** Simple absolute measure of inequality : Difference (D)
** Simple relative measure of inequality : Index of Disparity (ID) 
** ---------------------------------------------------

** Drop the overall regional totals
** drop if iso3n==2000

** OVERALL CHANGE
** by Type (mortality and DALY) 
** By SEX
forval x = 1(1)3 {

    ** (R) Simple - relative
    bysort type sex : egen m_min`x' = min(ch`x')
    bysort type sex : egen m_max`x' = max(ch`x')
    gen rel_sim`x' = abs(m_max / m_min)
    label var rel_sim`x' "Relative inequality x=`x': WHO simple measure"

    ** (D) Simple - absolute
    gen abs_sim`x' = m_max`x' - m_min`x'
    label var abs_sim`x' "Absolute inequality x=`x': WHO simple measure"
    drop m_min`x' m_max`x' 

    ** (ID) Complex - relative
    * --> Index of Disparity (Each country compared to Americas overall change)
    * --> number of countries in group (n=33)
    bysort type sex : gen J = _N - 2
    gen americas`x' = ch`x' if iso3n==2000
    bysort type sex: egen ch_am`x' = min(americas`x') 
    drop americas`x'
    order ch_am`x', after(ch`x')
    gen id1_`x' = abs(ch`x' - ch_am`x')
    bysort type sex: egen id2_`x' = sum(id1_`x') 
    gen id3_`x' = id2_`x' / ch_am`x'
    drop ch_am`x'
    gen id`x' = (1/J) * id3_`x' * 100
    drop id1_`x' id2_`x' id3_`x' J
    order abs_sim`x' rel_sim`x' id`x' , after(sex)
}

    ** Collapse to 1 row per TYPE / SEX combination
    collapse (mean) id*, by(type sex)
    order type sex id1 id2 id3 
**    rename id1 id_ch1
**    rename id2 id_ch2
**    rename id3 id_ch3
    gen change = 1
    tempfile ch
    save `ch', replace



** GROWTH CHANGE
** by Type (mortality and DALY) 
** By SEX
use `decomp', clear
forval x = 1(1)3 {

    ** (R) Simple - relative
    bysort type sex : egen m_min`x' = min(gr`x')
    bysort type sex : egen m_max`x' = max(gr`x')
    gen rel_sim`x' = abs(m_max / m_min)
    label var rel_sim`x' "Relative inequality x=`x': WHO simple measure"

    ** (D) Simple - absolute
    gen abs_sim`x' = m_max`x' - m_min`x'
    label var abs_sim`x' "Absolute inequality x=`x': WHO simple measure"
    drop m_min`x' m_max`x' 

    ** (ID) Complex - relative
    * --> Index of Disparity (Each country compared to Americas overall change)
    * --> number of countries in group (n=33)
    bysort type sex : gen J = _N - 2
    gen americas`x' = gr`x' if iso3n==2000
    bysort type sex: egen gr_am`x' = min(americas`x') 
    drop americas`x'
    order gr_am`x', after(gr`x')
    gen id1_`x' = abs(gr`x' - gr_am`x')
    bysort type sex: egen id2_`x' = sum(id1_`x') 
    gen id3_`x' = id2_`x' / gr_am`x'
    drop gr_am`x'
    gen id`x' = (1/J) * id3_`x' * 100
    drop id1_`x' id2_`x' id3_`x' J
    order abs_sim`x' rel_sim`x' id`x' , after(sex)
}

    ** Collapse to 1 row per TYPE / SEX combination
    collapse (mean) id*, by(type sex)
    keep type sex id1 
**    rename id1 id_gr1
    gen change = 2
    tempfile gr
    save `gr', replace





** AGING CHANGE
** by Type (mortality and DALY) 
** By SEX
use `decomp', clear
forval x = 1(1)3 {

    ** (R) Simple - relative
    bysort type sex : egen m_min`x' = min(as`x')
    bysort type sex : egen m_max`x' = max(as`x')
    gen rel_sim`x' = abs(m_max / m_min)
    label var rel_sim`x' "Relative inequality x=`x': WHO simple measure"

    ** (D) Simple - absolute
    gen abs_sim`x' = m_max`x' - m_min`x'
    label var abs_sim`x' "Absolute inequality x=`x': WHO simple measure"
    drop m_min`x' m_max`x' 

    ** (ID) Complex - relative
    * --> Index of Disparity (Each country compared to Americas overall change)
    * --> number of countries in group (n=33)
    bysort type sex : gen J = _N - 2
    gen americas`x' = as`x' if iso3n==2000
    bysort type sex: egen as_am`x' = min(americas`x') 
    drop americas`x'
    order as_am`x', after(as`x')
    gen id1_`x' = abs(as`x' - as_am`x')
    bysort type sex: egen id2_`x' = sum(id1_`x') 
    gen id3_`x' = id2_`x' / as_am`x'
    drop as_am`x'
    gen id`x' = (1/J) * id3_`x' * 100
    drop id1_`x' id2_`x' id3_`x' J
    order abs_sim`x' rel_sim`x' id`x' , after(sex)
}

    ** Collapse to 1 row per TYPE / SEX combination
    collapse (mean) id*, by(type sex)
    keep type sex id1 
    gen change = 3
**    rename id1 id_as1
    tempfile as
    save `as', replace





** EPI CHANGE
** by Type (mortality and DALY) 
** By SEX
use `decomp', clear
forval x = 1(1)3 {

    ** (R) Simple - relative
    bysort type sex : egen m_min`x' = min(ep`x')
    bysort type sex : egen m_max`x' = max(ep`x')
    gen rel_sim`x' = abs(m_max / m_min)
    label var rel_sim`x' "Relative inequality x=`x': WHO simple measure"

    ** (D) Simple - absolute
    gen abs_sim`x' = m_max`x' - m_min`x'
    label var abs_sim`x' "Absolute inequality x=`x': WHO simple measure"
    drop m_min`x' m_max`x' 

    ** (ID) Complex - relative
    * --> Index of Disparity (Each country compared to Americas overall change)
    * --> number of countries in group (n=33)
    bysort type sex : gen J = _N - 1
    gen americas`x' = ep`x' if iso3n==2000
    bysort type sex: egen ep_am`x' = min(americas`x') 
    drop americas`x'
    order ep_am`x', after(ep`x')
    gen id1_`x' = abs(ep`x' - ep_am`x')
    bysort type sex: egen id2_`x' = sum(id1_`x') 
    gen id3_`x' = id2_`x' / ep_am`x'
    drop ep_am`x'
    gen id`x' = abs((1/J) * id3_`x' * 100)
    drop id1_`x' id2_`x' id3_`x' J
    order abs_sim`x' rel_sim`x' id`x' , after(sex)
}

    ** Collapse to 1 row per TYPE / SEX combination
    collapse (mean) id*, by(type sex)
    keep type sex id1 
    gen change = 4
**    rename id1 id_ep1
    tempfile ep
    save `ep', replace

use `ch', clear
append using `gr'
append using `as'
append using `ep'
label define change_ 1 "total" 2 "growth" 3 "aging" 4 "epi"
label values change change_
order change, after(sex)

** Table format
reshape wide id1 id2 id3, i(type sex) j(change)
drop id22 id32 id23 id33 id24 id34
rename id11 id_ch
rename id31 id_lch
rename id21 id_uch 
rename id12 id_gr
rename id13 id_as
rename id14 id_ep
order type sex id_ch id_lch id_uch id_gr id_as id_ep 

sort type sex 
gen uid = _n
** Data to Globals
                forval s = 1(1)6 {
                    preserve
                        keep if uid==`s'
                        ** (1) id_ch
                        global  idch_`s' = id_ch
                        global idlch_`s' = id_lch
                        global iduch_`s' = id_uch
                        ** (2) id_gr
                        global idgr_`s' = id_gr
                        ** (2) id_as
                        global idas_`s' = id_as
                        ** (2) id_ep
                        global idep_`s' = id_ep
                    restore
                }


** TABLE FOR PAPER
        ** Construct Word Table, Dim: 42 rows by 6 cols
        putdocx begin , font("calibri light", 10)
        putdocx table t1 = (7,8) 

        ** Structural formats
        putdocx table t1(.,1) , width(12.5%)
        putdocx table t1(.,2) , width(12.5%)
        putdocx table t1(.,3) , width(12.5%)
        putdocx table t1(.,4) , width(12.5%)
        putdocx table t1(.,5) , width(12.5%)
        putdocx table t1(.,6) , width(12.5%)
        putdocx table t1(.,7) , width(12.5%)
        putdocx table t1(.,8) , width(12.5%)

        **putdocx table t1(1,3) , colspan(2)
        **putdocx table t1(1,4) , colspan(2)
        putdocx table t1(1,.) , shading("bfbfbf")
        putdocx table t1(2/7,.) , shading("ffffff")
        putdocx table t1(2/3,.) , border(bottom, single, e6e6e6)
        putdocx table t1(5/6,.) , border(bottom, single, e6e6e6)

        ** x2 Header rows
        ** Row 1
        putdocx table t1(1,1) = ("Metric"), halign(right)
        putdocx table t1(1,2) = ("Sex"), halign(right)
        putdocx table t1(1,3) = ("Overall Change"), halign(right)
        putdocx table t1(1,4) = ("Lower 95% UI"), halign(right)
        putdocx table t1(1,5) = ("Upper 95% UI"), halign(right)
        putdocx table t1(1,6) = ("Change (growth)"), halign(right)
        putdocx table t1(1,7) = ("Change (aging)"), halign(right)
        putdocx table t1(1,8) = ("Change (epi)"), halign(right)
        ** Col 1
        putdocx table t1(2,1) = ("Deaths"), halign(right)
        putdocx table t1(3,1) = (" "), halign(right)
        putdocx table t1(4,1) = (" "), halign(right)
        putdocx table t1(5,1) = ("DALYs"), halign(right)
        putdocx table t1(6,1) = (" "), halign(right)
        putdocx table t1(7,1) = (" "), halign(right)
        ** Col 2
        putdocx table t1(2,2) = ("Men"), halign(right)
        putdocx table t1(3,2) = ("Women"), halign(right)
        putdocx table t1(4,2) = ("Combined"), halign(right)
        putdocx table t1(5,2) = ("Men"), halign(right)
        putdocx table t1(6,2) = ("Women"), halign(right)
        putdocx table t1(7,2) = ("Combined"), halign(right)

        local row = 2 
            forval s = 1(1)6 {            
                putdocx table t1(`row', 3) = ("${idch_`s'}"), halign(right) nformat(%5.1f)
                putdocx table t1(`row', 4) = ("${idlch_`s'}"), halign(right) nformat(%5.1f)
                putdocx table t1(`row', 5) = ("${iduch_`s'}"), halign(right) nformat(%5.1f)
                putdocx table t1(`row', 6) = ("${idgr_`s'}"), halign(right) nformat(%5.1f)
                putdocx table t1(`row', 7) = ("${idas_`s'}"), halign(right) nformat(%5.1f)
                putdocx table t1(`row', 8) = ("${idep_`s'}"), halign(right) nformat(%5.1f)
                local row = `row' + 1
            }



        ** Save Word table
        putdocx save "`outputpath'/articles/paper-ncd/article-draft/ncd_table3", replace 
