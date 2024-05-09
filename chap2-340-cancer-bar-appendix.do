** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap2-330-cancer-equiplot.do
    //  project:				    WHO Global Health Estimates
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	19-August-2021
    //  algorithm task			    Leading causes of cancer death: by-country equiplot

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
    log using "`logpath'\chap2-330-cancer-equiplot", replace
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
                            ** CANCERS TO USE
                            ** 12   "trachea/lung" 
                            ** 14   "breast" 
                            ** 18   "prostate" 
                            ** 9    "colon/rectum" 
                            ** 15   "cervix uteri" 
                            ** 11   "pancreas"
                            ** 27   "lymphomas/myeloma"
                            ** 8    "stomach"
                            ** 10   "liver"
                            ** 28   "leukemia"
                            ** 500  "all cancers"           (MOVES TO #6 in ORDER)
                            ** 100  "all cause", modif    
                            ** -----------------------------------------------
                            gen     cod = 1 if ghecause==12 
                            replace cod = 2 if ghecause==14
                            replace cod = 3 if ghecause==18
                            replace cod = 4 if ghecause==9
                            replace cod = 5 if ghecause==15
                            replace cod = 6 if ghecause==500
                            replace cod = 7 if ghecause==11
                            replace cod = 8 if ghecause==27
                            replace cod = 9 if ghecause==8
                            replace cod = 10 if ghecause==10
                            replace cod = 11 if ghecause==28

                            #delimit ; 
                            label define cod_   1 "trachea/lung" 
                                                2 "breast" 
                                                3 "prostate" 
                                                4 "colon/rectum" 
                                                5 "cervix uteri" 
                                                7 "pancreas"
                                                8 "lymphomas/myeloma"
                                                9 "stomach"
                                                10 "liver"
                                                11 "leukemia"
                                                6 "all cancers", modify ;
                            #delimit cr
                            label values cod cod_ 
                            sort cod 
                            drop ghecause 
                            order cod region mortr dalyr 
                            keep if cod<=11

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

                            ** COLORS - PURPLES for CVD
                                colorpalette hcl, blues nograph n(14)
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

                            ** Outer boxes (CANCER CAUSES 7-11)
                            local touter1   62 -10   -1 -10   -1 110   62 110   62 -10 

                            local touter2a  62 110   62 230  
                            local touter2b  62 230   -1 230  
                            local touter2c  -1 110   -1 230 

                            local touter3a  62 230    62 350  
                            local touter3b  62 350   -1 350 
                            local touter3c  -1 230   -1 350 

                            local touter4a  62 350    62 470  
                            local touter4b  62 470   -1 470  
                            local touter4c  -1 350   -1 470 

                            local touter5a  62 470    62 590  
                            local touter5b  62 590   -1 590  
                            local touter5c  -1 470    -1 590


                            ** Countries ordered by size for COD (1-6)
                            gsort cod mortr
                            gen region_new = region
                            label values region_new region_
                            #delimit ; 
                                label define region_    28 "Saint Vincent`dagger'"
                                                        1 "Antigua and Barbuda"
                                                        30 "Trinidad and Tobago"
                                                        13 "Dominican Republic"
                                                        2000 "The Americas", modify;
                            #delimit cr
                            decode region_new , gen(region_lab)
                            bysort cod : gen regiono = _n
                            forval x = 1(1)11 {
                                gen region`x' = regiono if cod==`x'
                                labmask region`x' if cod==`x', values(region_lab)
                            }


                            ** Scale all rates to 100 - keeps shape of all bar charts, and allows us to more easily create a panel of 6 charts
                            bysort cod : egen maxr = max(mortr)
                            gen scaler = (mortr/maxr) * 100
                            order maxr scaler , after(mortr) 
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

                            gen origin7 = 0
                            gen origin8 = 120 
                            replace scaler8 = scaler8 + 120
                            gen origin9 = 240
                            replace scaler9 = scaler9 + 240
                            gen origin10 = 360 
                            replace scaler10 = scaler10 + 360
                            gen origin11 = 480 
                            replace scaler11 = scaler11 + 480

                            /// ** St Vincent and the Grenadines -- Too Long - Abbreviate
                            replace region_lab = "Saint Vincent" if region_lab == "Saint Vincent and the Grenadines"
                            /// replace region_lab = "Antigua & Barbuda" if region_lab == "Antigua and Barbuda"


                            ** COUNTRIES with FIVE Highest and FIVE lowest Mortality Rates
                            preserve
                                drop if region==2000
                                sort cod mortr
                                bysort cod: gen include = _n
                                mark keepme if include<=5 | include>=29
                                keep if keepme==1
                                bysort cod : gen regiono2 = _n
                                order include regiono2, after(mortr)
                                ** Trachea/Lung
                                forval x = 1(1)10 {
                                    local cid1_`x' = region_lab[`x'] 
                                }
                                ** Breast
                                forval x = 11(1)20 {
                                    local cid2_`x' = region_lab[`x'] 
                                }
                                ** Prostate
                                forval x = 21(1)30 {
                                    local cid3_`x' = region_lab[`x'] 
                                }
                                ** Colon / Rectum
                                forval x = 31(1)40 {
                                    local cid4_`x' = region_lab[`x'] 
                                }
                                ** Cervix uteri
                                forval x = 41(1)50 {
                                    local cid5_`x' = region_lab[`x'] 
                                }
                                ** ALL cancers
                                forval x = 51(1)60 {
                                    local cid6_`x' = region_lab[`x'] 
                                }
                                ** Pancreas
                                forval x = 61(1)70 {
                                    local cid7_`x' = region_lab[`x'] 
                                }
                                ** Lymphomas/Myelomas
                                forval x = 71(1)80 {
                                    local cid8_`x' = region_lab[`x'] 
                                }    
                                ** Stomach
                                forval x = 81(1)90 {
                                    local cid9_`x' = region_lab[`x'] 
                                }   
                                ** Liver
                                forval x = 91(1)100 {
                                    local cid10_`x' = region_lab[`x'] 
                                }    
                                ** Leukemia
                                forval x = 101(1)110 {
                                    local cid11_`x' = region_lab[`x'] 
                                }        
                                restore



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
        (rbar origin1 scaler6 region6 if cod==6 & region!=2000, horizontal barw(0.6) fcol("`can1'") lcol("`can1'") lw(0.1))           
        (rbar origin1 scaler6 region6 if cod==6 & region==2000, horizontal barw(0.6) fcol(gs0) lcol(gs0) lw(0.1))           
        (sc value6 x6, msymbol(i) mlabel(value6) mlabsize(6) mlabcol(gs8) mlabp(0))
                		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			ysize(16) xsize(4)

			xlab(none, notick labs(7) tlc(gs0) labc(gs0) notick nogrid glc(gs16))
			xscale(noline range(1(1)100)) 
			xtitle("", size(7) color(gs0) margin(l=2 r=2 t=5 b=2)) 
			
			ylab(1(1)34, valuelabel
			labc(gs0) labs(6) tstyle(major_notick) nogrid glc(gs16) angle(0) format(%9.0f) labgap(5))
			yscale(noline lw(vthin) range(-3.5(0.5)36)) 
			ytitle("", size(7) margin(l=2 r=2 t=2 b=2)) 

           /// Region Titles 
           text(37 200 "All CVD" ,  place(c) size(7.5) color(gs8) just(center))

            /// INDEX OF DISPARITY VALUES
           text(35.5  -100 "IoD:"                       ,  place(c) size(11) color("`can1'") just(center))
           text(35.75 -175 "`teardrop'"                ,  place(c) size(5) color("`can1'") just(center))
           text(35.5  -20 "`id6'"                     ,  place(c) size(11) color("`can1'") just(center))

           /// Y-Axis text 
           text(-0.5 -50 "Mortality rate" "(per 100 000)" ,  
                                    place(c) size(6) color(gs8) just(center) linegap(1.25))
           /// NOTES
           text(-2 -350 "`teardrop' IoD = Index of disparity." , 
                                    place(e) size(5) color(gs10) just(left) linegap(1.25))

           text(-3 -350 "`dagger' Saint Vincent = Saint Vincent " ,  
                                    place(e) size(5) color(gs10)  just(left))
           text(-3.5 -350 "and the Grenadines." ,  
                                    place(e) size(5) color(gs10)  just(left))

            legend(off)
			name(bar_mort2019)
			;
#delimit cr	
** Export to Vector Graphic
graph export "`outputpath'\reports\2024-edits\graphics\figA4-2-B.svg", replace
graph export "`outputpath'\reports\2024-edits\graphics\figA4-2-B.pdf", replace





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
                            ** CANCERS TO USE
                            ** 12   "trachea/lung" 
                            ** 14   "breast" 
                            ** 18   "prostate" 
                            ** 9    "colon/rectum" 
                            ** 15   "cervix uteri" 
                            ** 11   "pancreas"
                            ** 27   "lymphomas/myeloma"
                            ** 8    "stomach"
                            ** 10   "liver"
                            ** 28   "leukemia"
                            ** 500  "all cancers"           (MOVES TO #6 in ORDER)
                            ** 100  "all cause", modif    
                            ** -----------------------------------------------
                            gen     cod = 1 if ghecause==12 
                            replace cod = 2 if ghecause==14
                            replace cod = 3 if ghecause==18
                            replace cod = 4 if ghecause==9
                            replace cod = 5 if ghecause==15
                            replace cod = 6 if ghecause==500
                            replace cod = 7 if ghecause==11
                            replace cod = 8 if ghecause==27
                            replace cod = 9 if ghecause==8
                            replace cod = 10 if ghecause==10
                            replace cod = 11 if ghecause==28

                            #delimit ; 
                            label define cod_   1 "trachea/lung" 
                                                2 "breast" 
                                                3 "prostate" 
                                                4 "colon/rectum" 
                                                5 "cervix uteri" 
                                                7 "pancreas"
                                                8 "lymphomas/myeloma"
                                                9 "stomach"
                                                10 "liver"
                                                11 "leukemia"
                                                6 "all cancers", modify ;
                            #delimit cr
                            label values cod cod_ 
                            sort cod 
                            drop ghecause 
                            order cod region mortr dalyr 
                            keep if cod<=11


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

                            ** Countries ordered by size for COD (1-6)
                            gsort cod mortr
                            gen region_new = region
                            label values region_new region_
                                 #delimit ; 
                                label define region_    28 "Saint Vincent`dagger'"
                                                        1 "Antigua and Barbuda"
                                                        30 "Trinidad and Tobago"
                                                        13 "Dominican Republic"
                                                        2000 "The Americas", modify;
                            #delimit cr

                            decode region_new , gen(region_lab)
                            bysort cod : gen regiono = _n
                            forval x = 1(1)11 {
                                gen region`x' = regiono if cod==`x'
                                labmask region`x' if cod==`x', values(region_lab)
                            }

                            ** Scale all rates to 100 - keeps shape of all bar charts, and allows us to more easily create a panel of 6 charts
                            bysort cod : egen maxr = max(mortr)
                            gen scaler = (mortr/maxr) * 100
                            order maxr scaler , after(mortr) 
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

                            ** COUNTRIES with 
                            ** FIVE highest and FIVE lowest Mortality Rates
                            preserve
                                drop if region==2000
                                sort cod mortr
                                bysort cod: gen include = _n
                                mark keepme if include<=5 | include>=29
                                keep if keepme==1
                                bysort cod : gen regiono2 = _n
                                order include regiono2, after(mortr)
                                ** Ischaemic
                                forval x = 1(1)10 {
                                    local cid1_`x' = region_lab[`x'] 
                                }
                                ** Stroke
                                forval x = 11(1)20 {
                                    local cid2_`x' = region_lab[`x'] 
                                }
                                ** Hypertensive
                                forval x = 21(1)30 {
                                    local cid3_`x' = region_lab[`x'] 
                                }
                                ** Cardiomyopathy
                                forval x = 31(1)40 {
                                    local cid4_`x' = region_lab[`x'] 
                                }
                                ** rheumatic
                                forval x = 41(1)50 {
                                    local cid5_`x' = region_lab[`x'] 
                                }
                                ** ALL CVD
                                forval x = 51(1)60 {
                                    local cid6_`x' = region_lab[`x'] 
                                }
                            restore


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
        (rbar origin1 scaler6 region6 if cod==6 & region!=2000, horizontal barw(0.6) fcol("`can1'") lcol("`can1'") lw(0.1))           
        (rbar origin1 scaler6 region6 if cod==6 & region==2000, horizontal barw(0.6) fcol(gs0) lcol(gs0) lw(0.1))           
        (sc value6 x6, msymbol(i) mlabel(value6) mlabsize(6) mlabcol(gs8) mlabp(0))
                		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			ysize(16) xsize(4)

			xlab(none, notick labs(7) tlc(gs0) labc(gs0) notick nogrid glc(gs16))
			xscale(noline range(1(1)100)) 
			xtitle("", size(7) color(gs0) margin(l=2 r=2 t=5 b=2)) 
			
			ylab(1(1)34, valuelabel
			labc(gs0) labs(6) tstyle(major_notick) nogrid glc(gs16) angle(0) format(%9.0f) labgap(5))
			yscale(noline lw(vthin) range(-3.5(0.5)36)) 
			ytitle("", size(7) margin(l=2 r=2 t=2 b=2)) 

           /// Region Titles 
           text(37 200 "All CVD" ,  place(c) size(7.5) color(gs8) just(center))

            /// INDEX OF DISPARITY VALUES
           text(35.5  -100 "IoD:"                       ,  place(c) size(11) color("`can1'") just(center))
           text(35.75 -175 "`teardrop'"                ,  place(c) size(5) color("`can1'") just(center))
           text(35.5  -20 "`id6'"                     ,  place(c) size(11) color("`can1'") just(center))

           /// Y-Axis text 
           text(-0.5 -50 "Mortality rate" "(per 100 000)" ,  
                                    place(c) size(6) color(gs8) just(center) linegap(1.25))
           /// NOTES
           text(-2 -350 "`teardrop' IoD = Index of disparity." , 
                                    place(e) size(5) color(gs10) just(left) linegap(1.25))

           text(-3 -350 "`dagger' Saint Vincent = Saint Vincent " ,  
                                    place(e) size(5) color(gs10)  just(left))
           text(-3.5 -350 "and the Grenadines." ,  
                                    place(e) size(5) color(gs10)  just(left))

            legend(off)
			name(bar_mort2000)
			;
#delimit cr	
** Export to Vector Graphic
graph export "`outputpath'\reports\2024-edits\graphics\figA4-2-A.svg", replace
graph export "`outputpath'\reports\2024-edits\graphics\figA4-2-A.pdf", replace







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
                            ** CANCERS TO USE
                            ** 12   "trachea/lung" 
                            ** 14   "breast" 
                            ** 18   "prostate" 
                            ** 9    "colon/rectum" 
                            ** 15   "cervix uteri" 
                            ** 11   "pancreas"
                            ** 27   "lymphomas/myeloma"
                            ** 8    "stomach"
                            ** 10   "liver"
                            ** 28   "leukemia"
                            ** 500  "all cancers"           (MOVES TO #6 in ORDER)
                            ** 100  "all cause", modif    
                            ** -----------------------------------------------
                            gen     cod = 1 if ghecause==12 
                            replace cod = 2 if ghecause==14
                            replace cod = 3 if ghecause==18
                            replace cod = 4 if ghecause==9
                            replace cod = 5 if ghecause==15
                            replace cod = 6 if ghecause==500
                            replace cod = 7 if ghecause==11
                            replace cod = 8 if ghecause==27
                            replace cod = 9 if ghecause==8
                            replace cod = 10 if ghecause==10
                            replace cod = 11 if ghecause==28

                            #delimit ; 
                            label define cod_   1 "trachea/lung" 
                                                2 "breast" 
                                                3 "prostate" 
                                                4 "colon/rectum" 
                                                5 "cervix uteri" 
                                                7 "pancreas"
                                                8 "lymphomas/myeloma"
                                                9 "stomach"
                                                10 "liver"
                                                11 "leukemia"
                                                6 "all cancers", modify ;
                            #delimit cr
                            label values cod cod_ 
                            sort cod 
                            drop ghecause 
                            order cod region mortr dalyr 
                            keep if cod<=11


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
                            ** Countries ordered by size for COD (1-6)
                            gsort cod dalyr
                            gen region_new = region
                            label values region_new region_
                            #delimit ; 
                                label define region_    28 "Saint Vincent`dagger'"
                                                        1 "Antigua and Barbuda"
                                                        30 "Trinidad and Tobago"
                                                        13 "Dominican Republic"
                                                        2000 "The Americas", modify;
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

                            ** SPACES for Thousand separator
                            gen ad = dalyr 
                            gen ad1 = ad/1000
                            gen ad2 = ad1 - int(ad1)
                            gen ad3 = int(ad1)
                            gen ad4 = ad2 * 1000
                            gen ad5 = round(ad4)
                            drop ad1 ad2 ad4
                            gen ad5s = string(ad5)
                            replace ad5s = "0"+ad5s if ad5<100
                            gen ad3s = string(ad3)
                            replace ad3s = "" if ad3==0
                            gen ad6s = ad3s + " " + ad5s
                            replace ad6s = trim(ad6s) 
                            order ad ad6s
#delimit ;  
	gr twoway 
		/// country values
        (rbar origin1 scaler6 region6 if cod==6 & region!=2000, horizontal barw(0.6) fcol("`can2'") lcol("`can2'") lw(0.1))           
        (rbar origin1 scaler6 region6 if cod==6 & region==2000, horizontal barw(0.6) fcol(gs0) lcol(gs0) lw(0.1))           
        (sc value6 x6, msymbol(i) mlabel(ad6s) mlabsize(6) mlabcol(gs8) mlabp(0))
                		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			ysize(16) xsize(4)

			xlab(none, notick labs(7) tlc(gs0) labc(gs0) notick nogrid glc(gs16))
			xscale(noline range(1(1)100)) 
			xtitle("", size(7) color(gs0) margin(l=2 r=2 t=5 b=2)) 
			
			ylab(1(1)34, valuelabel
			labc(gs0) labs(6) tstyle(major_notick) nogrid glc(gs16) angle(0) format(%9.0f) labgap(10))
			yscale(noline lw(vthin) range(-3.5(0.5)36)) 
			ytitle("", size(7) margin(l=2 r=2 t=2 b=2)) 

           /// Region Titles 
           text(37 200 "All CVD" ,  place(c) size(7.5) color(gs8) just(center))

            /// INDEX OF DISPARITY VALUES
           text(35.5  -200 "IoD:"                       ,  place(c) size(11) color("`can1'") just(center))
           text(35.75 -350 "`teardrop'"                ,  place(c) size(5) color("`can1'") just(center))
           text(35.5  -20 "`id6'"                     ,  place(c) size(11) color("`can1'") just(center))

           /// Y-Axis text 
           text(-0.5 -200 "Disability (DALY) rate" "(per 100 000)" ,  
                                    place(c) size(6) color(gs8) just(center) linegap(1.25))
           /// NOTES
           text(-2 -700 "`teardrop' IoD = Index of disparity." , 
                                    place(e) size(5) color(gs10) just(left) linegap(1.25))

           text(-3 -700 "`dagger' Saint Vincent = Saint Vincent " ,  
                                    place(e) size(5) color(gs10)  just(left))
           text(-3.5 -700 "and the Grenadines." ,  
                                    place(e) size(5) color(gs10)  just(left))

            legend(off)
			name(bar_daly2000)
			;
#delimit cr	
** Export to Vector Graphic
graph export "`outputpath'\reports\2024-edits\graphics\figA4-2-C.svg", replace
graph export "`outputpath'\reports\2024-edits\graphics\figA4-2-C.pdf", replace








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
                            ** CANCERS TO USE
                            ** 12   "trachea/lung" 
                            ** 14   "breast" 
                            ** 18   "prostate" 
                            ** 9    "colon/rectum" 
                            ** 15   "cervix uteri" 
                            ** 11   "pancreas"
                            ** 27   "lymphomas/myeloma"
                            ** 8    "stomach"
                            ** 10   "liver"
                            ** 28   "leukemia"
                            ** 500  "all cancers"           (MOVES TO #6 in ORDER)
                            ** 100  "all cause", modif    
                            ** -----------------------------------------------
                            gen     cod = 1 if ghecause==12 
                            replace cod = 2 if ghecause==14
                            replace cod = 3 if ghecause==18
                            replace cod = 4 if ghecause==9
                            replace cod = 5 if ghecause==15
                            replace cod = 6 if ghecause==500
                            replace cod = 7 if ghecause==11
                            replace cod = 8 if ghecause==27
                            replace cod = 9 if ghecause==8
                            replace cod = 10 if ghecause==10
                            replace cod = 11 if ghecause==28

                            #delimit ; 
                            label define cod_   1 "trachea/lung" 
                                                2 "breast" 
                                                3 "prostate" 
                                                4 "colon/rectum" 
                                                5 "cervix uteri" 
                                                7 "pancreas"
                                                8 "lymphomas/myeloma"
                                                9 "stomach"
                                                10 "liver"
                                                11 "leukemia"
                                                6 "all cancers", modify ;
                            #delimit cr
                            label values cod cod_ 
                            sort cod 
                            drop ghecause 
                            order cod region mortr dalyr 
                            keep if cod<=11

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

                            ** Countries ordered by size for COD (1-6)
                            gsort cod dalyr
                            gen region_new = region
                            label values region_new region_
                            #delimit ; 
                                label define region_    28 "Saint Vincent`dagger'"
                                                        1 "Antigua and Barbuda"
                                                        30 "Trinidad and Tobago"
                                                        13 "Dominican Republic"
                                                        2000 "The Americas", modify;
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

                            ** SPACES for Thousand separator
                            gen ad = dalyr 
                            gen ad1 = ad/1000
                            gen ad2 = ad1 - int(ad1)
                            gen ad3 = int(ad1)
                            gen ad4 = ad2 * 1000
                            gen ad5 = round(ad4)
                            drop ad1 ad2 ad4
                            gen ad5s = string(ad5)
                            replace ad5s = "0"+ad5s if ad5<100
                            gen ad3s = string(ad3)
                            replace ad3s = "" if ad3==0
                            gen ad6s = ad3s + " " + ad5s
                            replace ad6s = trim(ad6s) 
                            order ad ad6s
#delimit ;  
	gr twoway 
		/// country values
        (rbar origin1 scaler6 region6 if cod==6 & region!=2000, horizontal barw(0.6) fcol("`can2'") lcol("`can2'") lw(0.1))           
        (rbar origin1 scaler6 region6 if cod==6 & region==2000, horizontal barw(0.6) fcol(gs0) lcol(gs0) lw(0.1))           
        (sc value6 x6, msymbol(i) mlabel(ad6s) mlabsize(6) mlabcol(gs8) mlabp(0))
                		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			ysize(16) xsize(4)

			xlab(none, notick labs(7) tlc(gs0) labc(gs0) notick nogrid glc(gs16))
			xscale(noline range(1(1)100)) 
			xtitle("", size(7) color(gs0) margin(l=2 r=2 t=5 b=2)) 
			
			ylab(1(1)34, valuelabel
			labc(gs0) labs(6) tstyle(major_notick) nogrid glc(gs16) angle(0) format(%9.0f) labgap(10))
			yscale(noline lw(vthin) range(-3.5(0.5)36)) 
			ytitle("", size(7) margin(l=2 r=2 t=2 b=2)) 

           /// Region Titles 
           text(37 200 "All CVD" ,  place(c) size(7.5) color(gs8) just(center))

            /// INDEX OF DISPARITY VALUES
           text(35.5  -200 "IoD:"                       ,  place(c) size(11) color("`can1'") just(center))
           text(35.75 -350 "`teardrop'"                ,  place(c) size(5) color("`can1'") just(center))
           text(35.5  -20 "`id6'"                     ,  place(c) size(11) color("`can1'") just(center))

           /// Y-Axis text 
           text(-0.5 -200 "Disability (DALY) rate" "(per 100 000)" ,  
                                    place(c) size(6) color(gs8) just(center) linegap(1.25))
           /// NOTES
           text(-2 -700 "`teardrop' IoD = Index of disparity." , 
                                    place(e) size(5) color(gs10) just(left) linegap(1.25))

           text(-3 -700 "`dagger' Saint Vincent = Saint Vincent " ,  
                                    place(e) size(5) color(gs10)  just(left))
           text(-3.5 -700 "and the Grenadines." ,  
                                    place(e) size(5) color(gs10)  just(left))

            legend(off)
			name(bar_daly2019)
			;
#delimit cr	
** Export to Vector Graphic
graph export "`outputpath'\reports\2024-edits\graphics\figA4-2-D.svg", replace
graph export "`outputpath'\reports\2024-edits\graphics\figA4-2-D.pdf", replace