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
    local datapath "C:\Sync\CaribData\My Drive\output\analyse-write\w003\data"

    ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    local logpath "C:\Sync\CaribData\My Drive\output\analyse-write\w003\tech-docs"

    ** REPORTS and Other outputs
    local outputpath "C:\Sync\CaribData\My Drive\output\analyse-write\w003\outputs"

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\chap3-160-mr-subregion", replace
** HEADER -----------------------------------------------------

** Prepare the dataset

** ------------------------------------------------------------
** WHO Progress Monitor - 2020
** ------------------------------------------------------------
** Extracted manually from WHO reports (https://www.who.int/nmh/publications/ncd-progress-monitor-2020/en/)
** Download Date: 2-NOV-2021
import excel using "`datapath'/from-who/NCD Progress monitor 2020.xlsx", clear sheet("2020") cellrange(a2:bb25)
sxpose, clear force

rename _var1 cid 
rename _var2 totpop
rename _var3 pmort 
rename _var4 tmort
rename _var5 pdeath

rename _var6 t1 
rename _var7 t2 
rename _var8 t3 
rename _var9 t4 
rename _var10 t5a 
rename _var11 t5b 
rename _var12 t5c 
rename _var13 t5d 
rename _var14 t5e  
rename _var15 t6a 
rename _var16 t6b 
rename _var17 t6c 
rename _var18 t7a
rename _var19 t7b 
rename _var20 t7c 
rename _var21 t7d 
rename _var22 t8 
rename _var23 t9 
rename _var24 t10 

** Variable formatting
drop if _n<=2

** Total country population 
rename totpop temp1
gen totpop  = real(temp1)
drop temp1
order totpop, after(cid)

** % deaths from NCDs  
rename pmort temp1
gen pmort  = real(temp1)
drop temp1
order pmort, after(totpop)

** Total # NCD deaths
rename tmort temp1
gen tmort  = real(temp1)
drop temp1
order tmort, after(pmort)

** Risk of premature death from NCD
rename pdeath temp1
gen pdeath = real(temp1)
drop temp1
order pdeath, after(tmort)

** Targets (categorization)
label define target_ 0 "not achieved" 1 "partially achieved" 2 "fully achieved" .a "DK" .b "NR"

foreach var in t1 t2 t3 t4 t5a t5b t5c t5d t5e t6a t6b t6c t7a t7b t7c t7d t8 t9 t10 {
    replace `var' = ".a" if `var'=="DK"  
    replace `var' = ".b" if `var'=="NR"  
    rename `var' temp1
    gen `var' = real(temp1)
    drop temp1
    label values `var' target_
}

label var cid "Country ID: ISO-3166"
label var totpop "Total country population"
label var pmort "% deaths from NCDs"
label var tmort "Total # NCD deaths"	
label var pdeath "Risk of premature death from NCD"	

rename t8 t17
rename t9 t18
rename t10 t19
rename t5a t5
rename t5b t6 
rename t5c t7 
rename t5d t8
rename t5e t9 
rename t6a t10 
rename t6b t11
rename t6c t12
rename t7a t13
rename t7b t14
rename t7c t15
rename t7d t16

label var t1 "National NCD targets"	
label var t2 "Mortality data"	
label var t3 "Risk factor surveys"	
label var t4 "National integrated NCD policy/strategy/action plan"
label var t5 "increased excise taxes and prices"	
label var t6 "smoke-free policies	"
label var t7 "large graphic health warnings/plain packaging"	
label var t8 "bans on advertising, promotion and sponsorship	"
label var t9 "mass media campaigns	"
label var t10 "restrictions on physical availability"	
label var t11 "advertising bans or comprehensive restrictions	"
label var t12 "increased excise taxes	"
label var t13 "salt/sodium policies"	
label var t14 "saturated fatty acids and trans-fats policies"	
label var t15 "marketing to children restrictions"	
label var t16 "marketing of breast-milk substitutes restrictions	"
label var t17 "Public education and awareness campaign on physical activity"	
label var t18 "Guidelines for management of cancer, CVD, diabetes and CRD"	
label var t19 "Drug therapy/counselling to prevent heart attacks and strokes"

** Gen total score in 2020
egen tscore2020 = rowtotal(t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19)
label data "WHO Progress monitor data"
save "`datapath'/from-who/who_progress_monitor_2020", replace

** Prepare file for heatmap
keep if totpop<. &  pmort<.
rename cid iso3c 
tempfile prog_monitor
save `prog_monitor', replace


** Generating PAHO subregions, then the two broad subregions (Caribbean, Other)
* create PAHO sub-regions (AMERICAS only of course)
* Source: https://www.paho.org/hq/index.php?option=com_content&view=article&id=97:2008-regional-subregional-centers-institutes-programs&Itemid=1110&lang=en
gen paho_subregion = . 
* north america
replace paho_subregion = 1 if iso3c=="CAN"
///replace paho_subregion = 1 if iso3c=="BMU"
replace paho_subregion = 1 if iso3c=="USA"
* central america
replace paho_subregion = 2 if iso3c=="BLZ"
replace paho_subregion = 2 if iso3c=="CRI"
replace paho_subregion = 2 if iso3c=="GTM"
replace paho_subregion = 2 if iso3c=="HND"
replace paho_subregion = 2 if iso3c=="NIC"
replace paho_subregion = 2 if iso3c=="PAN"
replace paho_subregion = 2 if iso3c=="SLV"
* Andean area 
replace paho_subregion = 3 if iso3c=="BOL"
replace paho_subregion = 3 if iso3c=="COL"
replace paho_subregion = 3 if iso3c=="ECU"
replace paho_subregion = 3 if iso3c=="PER"
replace paho_subregion = 3 if iso3c=="VEN"
* Southern Cone 
replace paho_subregion = 4 if iso3c=="ARG"
replace paho_subregion = 4 if iso3c=="CHL"
replace paho_subregion = 4 if iso3c=="PRY"
replace paho_subregion = 4 if iso3c=="URY"
* Latin Caribbean
replace paho_subregion = 5 if iso3c=="CUB"
replace paho_subregion = 5 if iso3c=="DOM"
replace paho_subregion = 5 if iso3c=="HTI"
* Non-Latin Caribbean
///replace paho_subregion = 6 if iso3c=="AIA"
replace paho_subregion = 6 if iso3c=="ATG"
replace paho_subregion = 6 if iso3c=="BHS"
replace paho_subregion = 6 if iso3c=="BRB"
replace paho_subregion = 6 if iso3c=="GRD"
replace paho_subregion = 6 if iso3c=="GUY"
replace paho_subregion = 6 if iso3c=="JAM"
replace paho_subregion = 6 if iso3c=="LCA"
replace paho_subregion = 6 if iso3c=="VCT"
replace paho_subregion = 6 if iso3c=="SUR"
replace paho_subregion = 6 if iso3c=="TTO"

* Mexico & Brazil as separate sub-regions
replace paho_subregion = 7 if iso3c=="BRA"
replace paho_subregion = 8 if iso3c=="MEX"

#delimit ; 
label define paho_subregion_    1 "north america"
                                2 "central american isthmus"
                                3 "andean area"
                                4 "southern cone"
                                5 "latin caribbean"
                                6 "non-latin caribbean"
                                7 "brazil" 
                                8 "mexico";
#delimit cr 
label values paho_subregion paho_subregion_ 

** Broad subregions
gen subr = 2  
replace subr = 1 if paho_subregion==5 | paho_subregion==6
label define subr_ 1 "Caribbean" 2 "Rest of the Americas"
label values subr subr_
order paho_subregion subr, after(iso3c)
order tscore2020, before(t1)
sort tscore

** Total score (ordered by vaues in 2017)
gsort -tscore2020 iso3c
gen iid = _n
order iid tscore2020 iso3c 

drop *totpop *pmort *tmort *pdeath
reshape long t , i(iid iso3c paho_subregion subr) j(monitor)
order iid iso3 paho_subregion subr tscore2020 t  

** Adjust x-axis
gen monitor2 = monitor
forval x = 2(1)19 {
    replace monitor2 = monitor2 + 1.7 if monitor>=`x' 
}

    colorpalette Spectral , nograph
    local list r(p) 
    ** red
    local red1 `r(p2)'
    ** orange
    local ora1 `r(p5)'
    ** blue
    local blu1 `r(p10)'

** Unicode markers for graphic
/// †  	U+2020 (alt-08224)	DAGGER = obelisk, obelus, long cross
/// ‡  	U+2021 (alt-08225)	DOUBLE DAGGER = diesis, double obelisk
/// •  	U+2022 (alt-08226)	BULLET = black small circle
local dagger = uchar(8224)
local ddagger = uchar(8225)
local section = uchar(0167) 
local teardrop = uchar(10045) 

** Heatmap
#delimit ;
	gr twoway
        /// Caribbean
        (sc iid monitor2 if subr==1 & t==0,  xaxis(1 2) msize(4) m(s) mlc(gs10) mfc("`red1'%75") mlw(0.1))
        (sc iid monitor2 if subr==1 & t==1,  xaxis(1 2) msize(4) m(s) mlc(gs10) mfc("`ora1'%75") mlw(0.1))
        (sc iid monitor2 if subr==1 & t==2,  xaxis(1 2) msize(4) m(s) mlc(gs10) mfc("`blu1'%75") mlw(0.1))
        (sc iid monitor2 if subr==1 & t>=.,  xaxis(1 2) msize(4) m(s) mlc(gs10)     mfc(gs10%75) mlw(0.1))

        /// Latin America - Caribbean
		(sc iid monitor2 if subr==2 & t==0,  xaxis(1 2) msize(4) m(s) mlc(gs10) mfc("`red1'%65") mlw(0.1))
        (sc iid monitor2 if subr==2 & t==1,  xaxis(1 2) msize(4) m(s) mlc(gs10) mfc("`ora1'%65") mlw(0.1))
        (sc iid monitor2 if subr==2 & t==2,  xaxis(1 2) msize(4) m(s) mlc(gs10) mfc("`blu1'%65") mlw(0.1))
        (sc iid monitor2 if subr==2 & t>=.,  xaxis(1 2) msize(4) m(s) mlc(gs10)     mfc(gs10%65) mlw(0.1))
		,
			graphregion(color(gs16)) ysize(16) xsize(10)

			xlab(1 "NCD targets"
				 3.7 "Mortality data" 					6.4 "Risk factor survey" 
				 9.1 "NCD policy" 						11.8 "Tobacco. Taxes / prices"
				 14.5 "Smoke-free policies"				17.2 "Tobacco. Packaging"
				 19.9 "Tobacco. Ad bans"				22.6 "Mass media campaigns"
				 25.3 "Alcohol. Restrict availability"	28 "Alcohol. Ad bans"
				 30.7 "Alcohol. Taxes"					33.4 "Salt policies"
				 36.1 "Trans-fats policies"				38.8 "Restrict marketing to kids"
				 41.5 "Restrict breast milk marketing"	44.2 "Physical activity awareness"
				 46.9 "NCD management guidelines"		49.6 "AMI / stroke prevention"
			,
			axis(2) valuelabel labc(gs0) labs(2.25) tstyle(major_notick) nogrid glc(gs16) angle(60) format(%9.0f) labgap(4))
			xlab(none, axis(1) nogrid)
			xscale(axis(2) noline lw(vthin) range(1(1)57))
			xtitle("", axis(2) size(2.5) color(gs0) margin(l=2 r=2 t=5 b=2))
			xscale(off axis(1) noline lw(vthin))
			xtitle("", axis(1) size(3) color(gs0) margin(l=2 r=2 t=5 b=2))

			ylab(1 "Chile" 	                    2 "Costa Rica" 
				 3 "Brazil" 	                4 "Canada" 
				 5 "Colombia" 		            6 "Argentina" 
                 7 "Uruguay"                    8 "United States"
				 9 "Panama"	                    10 "Peru"
				 11 "Ecuador"                   12 "El Salvador"
				 13 "Guatemala"                 14 "Mexico"
				 15 "{bf:Guyana}"	            16 "Honduras"
				 17 "Venezuela"		            18 "{bf:Cuba}"
				 19 "{bf:Dominican Republic}"	20 "{bf:Saint Lucia}"
				 21 "{bf:Trinidad and Tobago}"	22 "Bolivia"
				 23 "{bf:Barbados}"		        24 "{bf:Jamaica}"
				 25 "Paraguay"		            26 "{bf:Suriname}"
				 27 "{bf:Antigua and Barbuda}"	28"Belize"
				 29 "{bf:Saint Vincent}`dagger'"	30 "{bf:Bahamas}"
				 31 "{bf:Grenada}"	            32 "Nicaragua"
				 33 "{bf:Haiti}"		
			,
			valuelabel labgap(1) labc(gs0) labs(2.5) tstyle(major_notick) nogrid glc(gs16) angle(0) format(%9.0f))
			yscale( reverse noline lw(vthin) range(1(1)9))
			ytitle("", size(2.5) margin(l=2 r=2 t=2 b=2))

			/// PROGRESS INDICATOR 
			text(-0.3 25.5 "{bf: WHO progress indicator}",  size(2.5) color(gs0) just(center))
			
			/// WHO prgress score title
			text(35 55 "WHO" "progress" "score",  size(2.5) color(gs10) just(center))

           text(37.5 0 "`dagger' Saint Vincent = Saint Vincent and the Grenadines." ,  
                                    place(e) size(2.25) color(gs10)  just(left))

			/// CHL
			text(1 55 "30",  size(2.5) color(gs10) just(center))
			/// CRI
			text(2 55 "30",  size(2.5) color(gs10) just(center))
			/// BRA
			text(3 55 "29",  size(2.5) color(gs10) just(center))
			/// CAN
			text(4 55 "26",  size(2.5) color(gs10) just(center))
			/// COL
			text(5 55 "26",  size(2.5) color(gs10) just(center))

			/// ARG
			text(6 55 "25",  size(2.5) color(gs10) just(center))
			/// URY
			text(7 55 "22",  size(2.5) color(gs10) just(center))
			/// USA
			text(8 55 "22",  size(2.5) color(gs10) just(center))
			/// PAN
			text(9 55 "21",  size(2.5) color(gs10) just(center))
			/// PER
			text(10 55 "21",  size(2.5) color(gs10) just(center))

			/// ECU 
			text(11 55 "20",  size(2.5) color(gs10) just(center))
			/// SLV
			text(12 55 "20",  size(2.5) color(gs10) just(center))
			/// GTM 
			text(13 55 "19",  size(2.5) color(gs10) just(center))
			/// MEX
			text(14 55 "19",  size(2.5) color(gs10) just(center))
			/// GUY
			text(15 55 "18",  size(2.5) color(gs10) just(center))

			/// HND
			text(16 55 "17",  size(2.5) color(gs10) just(center))
			/// VEN
			text(17 55 "17",  size(2.5) color(gs10) just(center))
			/// CUB
			text(18 55 "16",  size(2.5) color(gs10) just(center))
			/// DOM
			text(19 55 "16",  size(2.5) color(gs10) just(center))
			/// LCA
			text(20 55 "16",  size(2.5) color(gs10) just(center))

			/// TTO
			text(21 55 "16",  size(2.5) color(gs10) just(center))
			/// BOL
			text(22 55 "15",  size(2.5) color(gs10) just(center))
			/// BRB
			text(23 55 "15",  size(2.5) color(gs10) just(center))
			/// JAM
			text(24 55 "15",  size(2.5) color(gs10) just(center))
			/// PRY
			text(25 55 "15", size(2.5) color(gs10) just(center))

			/// SUR
			text(26 55 "15", size(2.5) color(gs10) just(center))
			/// ATG
			text(27 55 "14", size(2.5) color(gs10) just(center))
			/// BLZ
			text(28 55 "12",  size(2.5) color(gs10) just(center))
			/// VCT
			text(29 55 "12",  size(2.5) color(gs10) just(center))
			/// BHS
			text(30 55 "11",  size(2.5) color(gs10) just(center))

			/// GRD
			text(31 55 "9",  size(2.5) color(gs10) just(center))
			/// NIC
			text(32 55 "9",  size(2.5) color(gs10) just(center))
			/// HTI
			text(33 55 "3",  size(2.5) color(gs10) just(center))


			legend(size(2.25) position(7) ring(1) bm(t=1 b=1 l=1 r=0) colf cols(2) rowgap(0.5) colgap(0.5)
			region(fcolor(gs16) lw(none) margin(l=0 r=0 t=0 b=0))
			order(1 2 3 4)
			lab(1 "Not implemented")
			lab(2 "Partially implemented")
			lab(3 "Fully implemented")
			lab(4 "Not reported")
			)
			name(heat_map)
            ;
#delimit cr

** Export to Vector Graphic
** DEC 22nd, 2022
graph export "`outputpath'\reports\2024-edits\graphics\fig33.svg", replace
graph export "`outputpath'\reports\2024-edits\graphics\fig33.pdf", replace

