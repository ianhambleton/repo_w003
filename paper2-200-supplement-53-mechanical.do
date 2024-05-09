** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    paper2-110-table1-version1.do
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
    local datapath "C:\Sync\CaribData\My Drive\output\analyse-write\w003\data"

    ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    local logpath "C:\Sync\CaribData\My Drive\output\analyse-write\w003\tech-docs"

    ** REPORTS and Other outputs
    local outputpath "C:\Sync\CaribData\My Drive\output\analyse-write\w003\outputs"

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\paper2-110-table1-version1", replace
** HEADER -----------------------------------------------------

** Load population file from: 
**      paper2-100-datasets.do 
use "`datapath'/paper2-inj/dataset01", clear

** ------------------------------------------------------------
** Table 1 as follows
** ------------------------------------------------------------
** Deaths: numbers + rates in 2019
** Burden: DALY numbers + rates in 2019
** ---
** COL 1: Region / Subregion
** COL 2: Population count
** ---
** COL 3: Count 2019 (women N)
** COL 4: Count 2019 (men N)
** COL 5: Count 2019 (both N)
** ---
** COL 6: Rate 2019 (women N)
** COL 7: Rate 2019 (men N)
** COL 8: Rate 2019 (both N)
** ---
** COL 9: Rate change (2000-2019) (women N)
** COL 10: Rate change (2000-2019) (men N)
** ------------------------------------------------------------

** Keep selected years
keep if year==2000 | year==2019 

** Keep selected regions + subregions
keep if (region>=100 & region<=800) | region==2000 | region==7000

** (ghecause 48. road injury)
** (ghecause 49. poisonings)
** (ghecause 50. falls)
** (ghecause 51. fire and heat)
** (ghecause 52. drowning)
** (ghecause 53. mechanical forces)
** (ghecause 54. natural disasters)
** (ghecause 55. self harm)
** (ghecause 56. interpersonal violence)
** (ghecause 57. collective violence)

** KEEP interpersonal violence
keep if ghecause==53

** Drop unwanted variables
drop paho_subregion pop_dalyr ghecause
rename pop_mortr pop
rename dths deaths
order year sex region pop daly deaths dalyr mortr

** Generate unique code by region - alphabetically
decode region, gen(rtext) 
egen uid = group(region)
labmask uid, values(rtext) 
order uid
drop rtext 

** Rate change
reshape wide pop daly deaths dalyr mortr , i(uid sex) j(year)
gen ch_dalyr = ((dalyr2019 - dalyr2000) / dalyr2000) * 100
gen ch_mortr = ((mortr2019 - mortr2000) / mortr2000) * 100

** Count change
gen ch_daly   = ((daly2019 - daly2000) / daly2000) * 100
gen ch_deaths = ((deaths2019 - deaths2000) / deaths2000) * 100

** Reshape to long (Pop, Deaths, DALYs) in single column
drop pop2000 daly2000 deaths2000 dalyr2000 mortr2000
rename pop2019 metric1
rename deaths2019 metric2
rename daly2019 metric3
rename mortr2019 metric4
rename dalyr2019 metric5
rename ch_mortr metric6
rename ch_dalyr metric7
rename ch_deaths metric8
rename ch_daly metric9

reshape long metric, i(uid sex) j(type)

label define type_ 1 "pop" 2 "deaths" 3 "dalys" 4 "mortr" 5 "dalyr" 6 "change mr" 7 "change dalyr" 8 "change deaths" 9 "change dalys",modify
label values type type_
sort type region sex

** Table ready region names
#delimit ; 
label define uid_   1 "North America"
                    2 "Central America"
                    3 "Andean Area"
                    4 "Southern Cone"
                    5 "Latin Caribbean"
                    6 "non-Latin Caribbean"
                    7 "Brazil"
                    8 "Mexico"
                    9 "Americas"
                    10 "World", modify;
#delimit cr
label values uid uid_

** Region as String 
decode uid, gen(rtext) 

** ------------------------------------------------------
** TABLE ONE
** ------------------------------------------------------

** ! TO DO
** ! Consider including THREE more columns for change in absolute numbers to compare with rate change

    ** COL1. Region name
            forval r = 1(1)10 {   
                forval s = 1(1)3 {
                    preserve
                        keep if type ==1 & uid==`r' & sex==`s'
                        ** (COL 1) Region name
                        global col1_`r'_`s' = rtext
                        ** (SUPPLEMENT) Population
                        local  pop_`r'_`s' = metric/1000
                        global pop_`r'_`s' : dis %12.1fc `pop_`r'_`s''
                    restore
                }
            }

    ** COLS 2/4. Count 2019 (deaths)
            forval r = 1(1)10 {   
                forval s = 1(1)3 {
                    preserve
                        keep if type ==2 & uid==`r' & sex==`s'
                        ** (COLS 3/5) Count of deaths
                        local  mc_`r'_`s' = metric
                        global mc_`r'_`s' : dis %14.0fc `mc_`r'_`s''
                    restore
                }
            }

    ** COLS 2.4. Count 2019 (DALYs)
            forval r = 1(1)10 {   
                forval s = 1(1)3 {
                    preserve
                        keep if type ==3 & uid==`r' & sex==`s'
                        ** (COLS 3/5) Count of deaths
                        local  dc_`r'_`s' = metric
                        global dc_`r'_`s' : dis %14.0fc `dc_`r'_`s''
                    restore
                }
            }


    ** COLS 5/7. Change 2000-2019 (deaths)
            forval r = 1(1)10 {   
                forval s = 1(1)3 {
                    preserve
                        keep if type ==8 & uid==`r' & sex==`s'
                        ** (COLS 3/5) Count of deaths
                        local  mp1_`r'_`s' = metric
                        global mp1_`r'_`s' : dis %9.1fc `mp1_`r'_`s''
                    restore
                }
            }

    ** COLS 5/7. Change 2000-2019 (DALYs)
            forval r = 1(1)10 {   
                forval s = 1(1)3 {
                    preserve
                        keep if type ==9 & uid==`r' & sex==`s'
                        ** (COLS 3/5) Count of deaths
                        local  dp1_`r'_`s' = metric
                        global dp1_`r'_`s' : dis %9.1fc `dp1_`r'_`s''
                    restore
                }
            }


    ** COLS 8/10. Rate 2019 (death)
            forval r = 1(1)10 {   
                forval s = 1(1)3 {
                    preserve
                        keep if type ==4 & uid==`r' & sex==`s'
                        ** (COLS 3/5) Count of deaths
                        local  mr_`r'_`s' = metric
                        global mr_`r'_`s' : dis %9.1fc `mr_`r'_`s''
                    restore
                }
            }

    ** COLS 8/10. Rate 2019 (DALYs)
            forval r = 1(1)10 {   
                forval s = 1(1)3 {
                    preserve
                        keep if type ==5 & uid==`r' & sex==`s'
                        ** (COLS 3/5) Count of deaths
                        local  dr_`r'_`s' = metric
                        global dr_`r'_`s' : dis %9.0fc `dr_`r'_`s''
                    restore
                }
            }

    ** COLS 11/13. Change 2000-2019 (death rate)
            forval r = 1(1)10 {   
                forval s = 1(1)3 {
                    preserve
                        keep if type ==6 & uid==`r' & sex==`s'
                        ** (COLS 3/5) Count of deaths
                        local  mp2_`r'_`s' = metric
                        global mp2_`r'_`s' : dis %9.1fc `mp2_`r'_`s''
                    restore
                }
            }

    ** COLS 11/13. Change 2000-2019 (DALY rate)
            forval r = 1(1)10 {   
                forval s = 1(1)3 {
                    preserve
                        keep if type ==7 & uid==`r' & sex==`s'
                        ** (COLS 3/5) Count of deaths
                        local  dp2_`r'_`s' = metric
                        global dp2_`r'_`s' : dis %9.1fc `dp2_`r'_`s''
                    restore
                }
            }

        ** Construct Word Table
        putdocx begin , landscape font("calibri light", 10) margin(left, 0.65) margin(right, 0.6)

        putdocx paragraph
        putdocx text ("TABLE. "), bold
        putdocx text ("Deaths and Years Lived with Disability (DALYs) among women and men ")
        putdocx text ("in 8 subregions of the Americas (2000 - 2019). ")

        putdocx table t1 = (23,13) 

        ** Structural formats
        putdocx table t1(.,1)  , width(16%)
        putdocx table t1(.,2)  , width(10%)
        putdocx table t1(.,3)  , width(10%)
        putdocx table t1(.,4)  , width(10%)
        putdocx table t1(.,5)  , width(6%)
        putdocx table t1(.,6)  , width(6%)
        putdocx table t1(.,7)  , width(6%)
        putdocx table t1(.,8)  , width(6%)
        putdocx table t1(.,9)  , width(6%)
        putdocx table t1(.,10) , width(6%)
        putdocx table t1(.,11) , width(6%)
        putdocx table t1(.,12) , width(6%)
        putdocx table t1(.,13) , width(6%)

        putdocx table t1(1,2) , colspan(3)
        putdocx table t1(1,3) , colspan(3)
        putdocx table t1(1,4) , colspan(3)
        putdocx table t1(1,5) , colspan(3)
        putdocx table t1(1,.) , shading("bfbfbf")
        putdocx table t1(2,.) , shading("e6e6e6")
        putdocx table t1(13,.) , shading("e6e6e6")

        ** Grey out some minor cell dividing lines
        putdocx table t1(3/11,.),border(bottom, single, "e6e6e6")
        putdocx table t1(14/22,.),border(bottom, single, "e6e6e6")
        putdocx table t1(.,2/3),border(right, single, "e6e6e6")
        putdocx table t1(.,5/6),border(right, single, "e6e6e6")
        putdocx table t1(.,8/9),border(right, single, "e6e6e6")
        putdocx table t1(.,11/12),border(right, single, "e6e6e6")
        putdocx table t1(1,2),border(right, single, "000000")
        putdocx table t1(1,3),border(right, single, "000000")
        putdocx table t1(1,4),border(right, single, "000000")
        putdocx table t1(1,5),border(right, single, "000000")

        ** x2 Header rows
        ** Row 1
        putdocx table t1(1,1) = ("Region"), halign(left)
        putdocx table t1(2,1) = ("DEATHS"), halign(left)
        putdocx table t1(13,1) = ("DALYs"), halign(left)
        putdocx table t1(1,2) = ("Count"), halign(left)
        putdocx table t1(1,3) = ("Count change (2000 to 2019)"), halign(left)
        putdocx table t1(1,4) = ("Rate (per 100,000)"), halign(left)
        putdocx table t1(1,5) = ("Rate change (2000 to 2019)"), halign(left)
        ** Row 2 and 13
        putdocx table t1(2,2) = ("Men"), halign(right)
        putdocx table t1(2,3) = ("Women"), halign(right)
        putdocx table t1(2,4) = ("Total"), halign(right)
        putdocx table t1(2,5) = ("Men"), halign(right)
        putdocx table t1(2,6) = ("Women"), halign(right)
        putdocx table t1(2,7) = ("Total"), halign(right)
        putdocx table t1(2,8) = ("Men"), halign(right)
        putdocx table t1(2,9) = ("Women"), halign(right)
        putdocx table t1(2,10) = ("Total"), halign(right)
        putdocx table t1(2,11) = ("Men"), halign(right)
        putdocx table t1(2,12) = ("Women"), halign(right)
        putdocx table t1(2,13) = ("Total"), halign(right)
        putdocx table t1(13,2) = ("Men"), halign(right)
        putdocx table t1(13,3) = ("Women"), halign(right)
        putdocx table t1(13,4) = ("Total"), halign(right)
        putdocx table t1(13,5) = ("Men"), halign(right)
        putdocx table t1(13,6) = ("Women"), halign(right)
        putdocx table t1(13,7) = ("Total"), halign(right)
        putdocx table t1(13,8) = ("Men"), halign(right)
        putdocx table t1(13,9) = ("Women"), halign(right)
        putdocx table t1(13,10) = ("Total"), halign(right)
        putdocx table t1(13,11) = ("Men"), halign(right)
        putdocx table t1(13,12) = ("Women"), halign(right)
        putdocx table t1(13,13) = ("Total"), halign(right)

        ** COL 1: Region
        ** COL 2: Population
        ** COL 3: Count (Deaths) Men
        ** COL 4: Count (Deaths) Women
        ** COL 5: Count (Deaths) Total
        ** COL 6: Rate (Deaths) Men
        ** COL 7: Rate (Deaths) Women
        ** COL 8: Rate (Deaths) Total
        ** COL 9: Change (Deaths) Men
        ** COL 10: Change (Deaths) Women
        ** COL 11: Change (Deaths) Total
        forval r = 3(1)12 {
            global roi = `r' - 2
            putdocx table t1(`r',1) =  ("${col1_${roi}_3}"), halign(right)
            ///putdocx table t1(`r',2) =  ("${col2_${roi}_3}"), halign(right)
            putdocx table t1(`r',2) =  ("${mc_${roi}_1}"), halign(right)
            putdocx table t1(`r',3) =  ("${mc_${roi}_2}"), halign(right)
            putdocx table t1(`r',4) =  ("${mc_${roi}_3}"), halign(right)
            putdocx table t1(`r',5) =  ("${mp1_${roi}_1}"), halign(right)
            putdocx table t1(`r',6) = ("${mp1_${roi}_2}"), halign(right)
            putdocx table t1(`r',7) = ("${mp1_${roi}_3}"), halign(right)
            putdocx table t1(`r',8) =  ("${mr_${roi}_1}"), halign(right)
            putdocx table t1(`r',9) =  ("${mr_${roi}_2}"), halign(right)
            putdocx table t1(`r',10) =  ("${mr_${roi}_3}"), halign(right)
            putdocx table t1(`r',11) =  ("${mp2_${roi}_1}"), halign(right)
            putdocx table t1(`r',12) = ("${mp2_${roi}_2}"), halign(right)
            putdocx table t1(`r',13) = ("${mp2_${roi}_3}"), halign(right)
            }
        forval r = 14(1)23 {
            global roi = `r' - 13
            putdocx table t1(`r',1) =  ("${col1_${roi}_3}"), halign(right)
            ///putdocx table t1(`r',2) =  ("${col2_${roi}_3}"), halign(right)
            putdocx table t1(`r',2) =  ("${dc_${roi}_1}"), halign(right)
            putdocx table t1(`r',3) =  ("${dc_${roi}_2}"), halign(right)
            putdocx table t1(`r',4) =  ("${dc_${roi}_3}"), halign(right)
            putdocx table t1(`r',5) =  ("${dp1_${roi}_1}"), halign(right)
            putdocx table t1(`r',6) = ("${dp1_${roi}_2}"), halign(right)
            putdocx table t1(`r',7) = ("${dp1_${roi}_3}"), halign(right)
            putdocx table t1(`r',8) =  ("${dr_${roi}_1}"), halign(right)
            putdocx table t1(`r',9) =  ("${dr_${roi}_2}"), halign(right)
            putdocx table t1(`r',10) =  ("${dr_${roi}_3}"), halign(right)
            putdocx table t1(`r',11) =  ("${dp2_${roi}_1}"), halign(right)
            putdocx table t1(`r',12) = ("${dp2_${roi}_2}"), halign(right)
            putdocx table t1(`r',13) = ("${dp2_${roi}_3}"), halign(right)
            }
        ** Save Word table
        putdocx save "`outputpath'/articles/paper-injury/inj_table_53_mechanical", replace 

