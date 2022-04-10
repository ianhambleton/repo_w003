** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap2-200-cvd-stats.do
    //  project:				    WHO Global Health Estimates
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	26-Apr-2021
    //  algorithm task			    Preparing CVD mortality rates: PAHO-subregions in the Americas

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
    log using "`logpath'\chap2-200-cvd-stats", replace
** HEADER -----------------------------------------------------


** Load primary deaths dataset
use "`datapath'\from-who\chap2_000_adjusted", clear

** 9-APR-2022
** Percentage of deaths and DALYs from conditions reported in this report
** Used in Intro to Chapter 3
**preserve
    keep if region==2000 & sex==3 & ghecause>=100 
    keep dths daly ghecause year
    ** Label the broad causes
    #delimit ; 
    label define ghecause_  
                        100  "all causes"
                        200  "communicable"
                        300  "NCD"
                        400  "CVD"
                        500  "cancer"
                        600  "respiratory"
                        700  "diabetes"
                        800  "mental"
                        900 "neurological"
                        1000  "injuries", modify
                        ;
    #delimit cr
    label values ghecause ghecause_
    reshape wide dths daly, i(year) j(ghecause)
    gen report_dtot = dths400 + dths500 + dths600 + dths700 + dths800 + dths900 + dths1000
    gen report_dalytot = daly400 + daly500 + daly600 + daly700 + daly800 + daly900 + daly1000
    gen perc1 = (report_dtot / dths100) * 100
    gen perc2 = (report_dalytot / daly100) * 100
    list year perc1 perc2
/*restore


** Restrict to Americas ONLY
keep if region==2000 & sex==3
keep dths daly year ghecause 
reshape wide dths daly, i(year) j(ghecause)


** CODES
**    1  "Rheumatic heart disease"
**    2  "Hypertensive heart disease"
**    3  "Ischaemic heart disease"
**    4  "Stroke"
**    5  "Cardiomyopathy etc"
**    400  ALL CVD
**    100  ALL DEATHS

** CVD as percentage of all deaths
gen p400 = (dths400/dths100)*100
gen ddrat400 = daly400 / dths400
gen ddrat_all = daly100 / dths100
** Ischaemic as percentage of CVD and all-deaths
gen p3a = (dths3/dths400)*100
gen p3b = (dths3/dths100)*100

** Stroke as percentage of CVD and all-deaths
gen p4a = (dths4/dths400)*100
gen p4b = (dths4/dths100)*100

** Hypertensive as percentage of CVD and all-deaths
gen p2a = (dths2/dths400)*100
gen p2b = (dths2/dths100)*100

** Cardiomyopathy as percentage of CVD and all-deaths
gen p5a = (dths5/dths400)*100
gen p5b = (dths5/dths100)*100

** Rheumatic as percentage of CVD and all-deaths
gen p1a = (dths1/dths400)*100
gen p1b = (dths1/dths100)*100

**-----------------------------------------------------------
** IHD (3)
**-----------------------------------------------------------
** Mortality rates by sex
use "`datapath'\from-who\chap2_000_mr_adjusted", clear
rename mortr arate 
keep if ghecause == 3 & region==2000
drop  ghecause paho_subregion pop_mortr
** 1=men 2=women 3=both
reshape wide arate dths, i(year) j(sex)
gen aratio = arate1 / arate2
gen adiff = arate1 - arate2
gen ddiff = dths1 - dths2 
order year dths* ddiff arate* 
format dths1 %12.1fc
format dths2 %12.1fc
format dths3 %12.1fc
format ddiff %12.1fc
    noi dis "IHD" 
    noi list year arate1 arate2 arate3 aratio adiff ddiff, noobs ab(20)

** DALY rates by sex
use "`datapath'\from-who\chap2_000_daly_adjusted", clear
rename dalyr arate
keep if ghecause == 3 & region==2000
drop  ghecause paho_subregion pop_dalyr
** 1=men 2=women 3=both
reshape wide arate daly, i(year) j(sex)
gen aratio = arate1 / arate2
gen adiff = arate1 - arate2
gen ddiff = daly1 - daly2 
order year daly* ddiff arate* 
format daly1 %12.1fc
format daly2 %12.1fc
format daly3 %12.1fc
format ddiff %12.1fc

    noi dis "IHD" 
    noi list year arate1 arate2 arate3 aratio adiff ddiff, noobs ab(20)

**-----------------------------------------------------------
** STROKE (4)
**-----------------------------------------------------------
** Mortality rates by sex
use "`datapath'\from-who\chap2_000_mr_adjusted", clear
rename mortr arate 
keep if ghecause == 4 & region==2000
drop  ghecause paho_subregion pop_mortr
** 1=men 2=women 3=both
reshape wide arate dths, i(year) j(sex)
gen aratio = arate1 / arate2
gen adiff = arate1 - arate2
gen ddiff = dths1 - dths2 
order year dths* ddiff arate* 
format dths1 %12.1fc
format dths2 %12.1fc
format dths3 %12.1fc
format ddiff %12.1fc
    noi dis "STROKE" 
    noi list year arate1 arate2 arate3 aratio adiff ddiff, noobs ab(20)

** DALY rates by sex
use "`datapath'\from-who\chap2_000_daly_adjusted", clear
rename dalyr arate 
keep if ghecause == 4 & region==2000
drop  ghecause paho_subregion pop_dalyr
** 1=men 2=women 3=both
reshape wide arate daly, i(year) j(sex)
gen aratio = arate1 / arate2
gen adiff = arate1 - arate2
gen ddiff = daly1 - daly2 
order year daly* ddiff arate* 
format daly1 %12.1fc
format daly2 %12.1fc
format daly3 %12.1fc
format ddiff %12.1fc
    noi dis "STROKE" 
    noi list year arate1 arate2 arate3 aratio adiff ddiff, noobs ab(20)



**-----------------------------------------------------------
** HYPERTENSIVE HEART DISEASE (2)
**-----------------------------------------------------------
** Mortality rates by sex
use "`datapath'\from-who\chap2_000_mr_adjusted", clear
rename mortr arate 
keep if ghecause == 2 & region==2000
drop  ghecause paho_subregion pop_mortr
** 1=men 2=women 3=both
reshape wide arate dths, i(year) j(sex)
gen aratio = arate1 / arate2
gen adiff = arate1 - arate2
gen ddiff = dths1 - dths2 
order year dths* ddiff arate* 
format dths1 %12.1fc
format dths2 %12.1fc
format dths3 %12.1fc
format ddiff %12.1fc
    noi dis "HHD" 
    noi list year arate1 arate2 arate3 aratio adiff ddiff, noobs ab(20)

** DALY rates by sex
use "`datapath'\from-who\chap2_000_daly_adjusted", clear
rename dalyr arate 
keep if ghecause == 2 & region==2000
drop  ghecause paho_subregion pop_dalyr
** 1=men 2=women 3=both
reshape wide arate daly, i(year) j(sex)
gen aratio = arate1 / arate2
gen adiff = arate1 - arate2
gen ddiff = daly1 - daly2 
order year daly* ddiff arate* 
format daly1 %12.1fc
format daly2 %12.1fc
format daly3 %12.1fc
format ddiff %12.1fc
    noi dis "HHD" 
    noi list year arate1 arate2 arate3 aratio adiff ddiff, noobs ab(20)


**-----------------------------------------------------------
** CARDIOMYOPATHY etc (5)
**-----------------------------------------------------------
** Mortality rates by sex
use "`datapath'\from-who\chap2_000_mr_adjusted", clear
rename mortr arate 
keep if ghecause == 5 & region==2000
drop  ghecause paho_subregion pop_mortr
** 1=men 2=women 3=both
reshape wide arate dths, i(year) j(sex)
gen aratio = arate1 / arate2
gen adiff = arate1 - arate2
gen ddiff = dths1 - dths2 
order year dths* ddiff arate* 
format dths1 %12.1fc
format dths2 %12.1fc
format dths3 %12.1fc
format ddiff %12.1fc
    noi dis "CARDIOMYOPATHY" 
    noi list year arate1 arate2 arate3 aratio adiff ddiff, noobs ab(20)

** DALY rates by sex
use "`datapath'\from-who\chap2_000_daly_adjusted", clear
rename dalyr arate 
keep if ghecause == 5 & region==2000
drop  ghecause paho_subregion pop_dalyr
** 1=men 2=women 3=both
reshape wide arate daly, i(year) j(sex)
gen aratio = arate1 / arate2
gen adiff = arate1 - arate2
gen ddiff = daly1 - daly2 
order year daly* ddiff arate* 
format daly1 %12.1fc
format daly2 %12.1fc
format daly3 %12.1fc
format ddiff %12.1fc
    noi dis "CARDIOMYOPATHY" 
    noi list year arate1 arate2 arate3 aratio adiff ddiff, noobs ab(20)

**-----------------------------------------------------------
** Rheumatic Heart Disease (1)
**-----------------------------------------------------------
** Mortality rates by sex
use "`datapath'\from-who\chap2_000_mr_adjusted", clear
rename mortr arate 
keep if ghecause == 1 & region==2000
drop  ghecause paho_subregion pop_mortr
** 1=men 2=women 3=both
reshape wide arate dths, i(year) j(sex)
gen aratio = arate1 / arate2
gen adiff = arate1 - arate2
gen ddiff = dths1 - dths2 
order year dths* ddiff arate* 
format dths1 %12.1fc
format dths2 %12.1fc
format dths3 %12.1fc
format ddiff %12.1fc
    noi dis "RHD" 
    noi list year arate1 arate2 arate3 aratio adiff ddiff, noobs ab(20)

** DALY rates by sex
use "`datapath'\from-who\chap2_000_daly_adjusted", clear
rename dalyr arate 
keep if ghecause == 1 & region==2000
drop  ghecause paho_subregion pop_dalyr
** 1=men 2=women 3=both
reshape wide arate daly, i(year) j(sex)
gen aratio = arate1 / arate2
gen adiff = arate1 - arate2
gen ddiff = daly1 - daly2 
order year daly* ddiff arate* 
format daly1 %12.1fc
format daly2 %12.1fc
format daly3 %12.1fc
format ddiff %12.1fc
    noi dis "RHEUMATIC" 
    noi list year arate1 arate2 arate3 aratio adiff ddiff, noobs ab(20)



**-----------------------------------------------------------
** All CVD (400)
** Percent Improvement
** Death excess (men vs women)
**-----------------------------------------------------------
use "`datapath'\from-who\chap2_000_daly_adjusted", clear
keep if ghecause == 400 & region==2000
drop  ghecause paho_subregion pop_dalyr
rename dalyr drate
tempfile daly 
save `daly', replace
use "`datapath'\from-who\chap2_000_mr_adjusted", clear
keep if ghecause == 400 & region==2000
drop  ghecause paho_subregion pop_mortr
rename mortr mrate
merge 1:1 year sex using `daly'
drop _merge
** 1=men 2=women 3=both
reshape wide mrate drate dths daly, i(year) j(sex)
order year mrate* drate* dths* daly* 
** Restrict to 2000 and 2019, and reshape to wide
** drop daly* dths* 
keep if year==2000 | year==2019
gen k=1
reshape wide dths1 dths2 dths3 daly1 daly2 daly3 mrate1 mrate2 mrate3 drate1 drate2 drate3, i(k) j(year)
order k mrate1* mrate2* mrate3* drate1* drate2* drate3* dths1* dths2* dths3* daly1* daly2* daly3*
** percentage improvement
gen mperc1 = ((mrate12019 - mrate12000)/mrate12000) * 100
gen mperc2 = ((mrate22019 - mrate22000)/mrate22000) * 100
gen mperc3 = ((mrate32019 - mrate32000)/mrate32000) * 100
gen dperc1 = ((drate12019 - drate12000)/drate12000) * 100
gen dperc2 = ((drate22019 - drate22000)/drate22000) * 100
gen dperc3 = ((drate32019 - drate32000)/drate32000) * 100
format mperc1 mperc2 mperc3 dperc1 dperc2 dperc3 %9.1f
** death excess (women and men combined)
gen dth_excess = dths12019-dths22019
gen daly_excess = daly12019-daly22019
format dths12019 dths22019 daly12019 daly22019 dth_excess daly_excess %12.0fc
    ** Transpose
    drop k
    xpose , clear varname format(%15.1fc)
    order _varname
    dis "ALL CVD - Change between 2000 and 2019"
    noi list _varname v1, sep(6) linesize(120)





**-----------------------------------------------------------
** IHD (3)
** Percent Improvement
** Death excess (men vs women)
**-----------------------------------------------------------
use "`datapath'\from-who\chap2_000_daly_adjusted", clear
rename dalyr arate 
keep if ghecause == 3 & region==2000
drop  ghecause paho_subregion pop_dalyr
rename arate drate
tempfile daly 
save `daly', replace
use "`datapath'\from-who\chap2_000_mr_adjusted", clear
rename mortr arate 
keep if ghecause == 3 & region==2000
drop  ghecause paho_subregion pop_mortr
rename arate mrate
merge 1:1 year sex using `daly'
drop _merge
** 1=men 2=women 3=both
reshape wide mrate drate dths daly, i(year) j(sex)
order year mrate* drate* dths* daly* 
** Restrict to 2000 and 2019, and reshape to wide
** drop daly* dths* 
keep if year==2000 | year==2019
gen k=1
reshape wide dths1 dths2 dths3 daly1 daly2 daly3 mrate1 mrate2 mrate3 drate1 drate2 drate3, i(k) j(year)
order k mrate1* mrate2* mrate3* drate1* drate2* drate3* dths1* dths2* dths3* daly1* daly2* daly3*
** percentage improvement
gen mperc1 = ((mrate12019 - mrate12000)/mrate12000) * 100
gen mperc2 = ((mrate22019 - mrate22000)/mrate22000) * 100
gen mperc3 = ((mrate32019 - mrate32000)/mrate32000) * 100
gen dperc1 = ((drate12019 - drate12000)/drate12000) * 100
gen dperc2 = ((drate22019 - drate22000)/drate22000) * 100
gen dperc3 = ((drate32019 - drate32000)/drate32000) * 100
format mperc1 mperc2 mperc3 dperc1 dperc2 dperc3 %9.1f
** death excess (women and men combined)
gen dth_excess = dths12019-dths22019
gen daly_excess = daly12019-daly22019
format dths12019 dths22019 daly12019 daly22019 dth_excess daly_excess %12.0fc
    ** Transpose
    drop k
    xpose , clear varname format(%15.2fc)
    order _varname
    dis "IHD - Change between 2000 and 2019"
    noi list _varname v1, sep(6) linesize(120)



**-----------------------------------------------------------
** STROKE (4)
** Percent Improvement
** Death excess (men vs women)
**-----------------------------------------------------------
use "`datapath'\from-who\chap2_000_daly_adjusted", clear
rename dalyr arate 
keep if ghecause == 4 & region==2000
drop  ghecause paho_subregion pop_dalyr
rename arate drate
tempfile daly 
save `daly', replace
use "`datapath'\from-who\chap2_000_mr_adjusted", clear
rename mortr arate 
keep if ghecause == 4 & region==2000
drop  ghecause paho_subregion pop_mortr
rename arate mrate
merge 1:1 year sex using `daly'
drop _merge
** 1=men 2=women 3=both
reshape wide mrate drate dths daly, i(year) j(sex)
order year mrate* drate* dths* daly* 
** Restrict to 2000 and 2019, and reshape to wide
** drop daly* dths* 
keep if year==2000 | year==2019
gen k=1
reshape wide dths1 dths2 dths3 daly1 daly2 daly3 mrate1 mrate2 mrate3 drate1 drate2 drate3, i(k) j(year)
order k mrate1* mrate2* mrate3* drate1* drate2* drate3* dths1* dths2* dths3* daly1* daly2* daly3*
** percentage improvement
gen mperc1 = ((mrate12019 - mrate12000)/mrate12000) * 100
gen mperc2 = ((mrate22019 - mrate22000)/mrate22000) * 100
gen mperc3 = ((mrate32019 - mrate32000)/mrate32000) * 100
gen dperc1 = ((drate12019 - drate12000)/drate12000) * 100
gen dperc2 = ((drate22019 - drate22000)/drate22000) * 100
gen dperc3 = ((drate32019 - drate32000)/drate32000) * 100
format mperc1 mperc2 mperc3 dperc1 dperc2 dperc3 %9.1f
** death excess (women and men combined)
gen dth_excess = dths12019-dths22019
gen daly_excess = daly12019-daly22019
format dths12019 dths22019 daly12019 daly22019 dth_excess daly_excess %12.0fc
    ** Transpose
    drop k
    xpose , clear varname format(%15.2fc)
    order _varname
    dis "STROKE - Change between 2000 and 2019"
    noi list _varname v1, sep(6) linesize(120)



    
**-----------------------------------------------------------
** HHD (2)
** Percent Improvement
** Death excess (men vs women)
**-----------------------------------------------------------
use "`datapath'\from-who\chap2_000_daly_adjusted", clear
rename dalyr arate 
keep if ghecause == 2 & region==2000
drop  ghecause paho_subregion pop_dalyr
rename arate drate
tempfile daly 
save `daly', replace
use "`datapath'\from-who\chap2_000_mr_adjusted", clear
rename mortr arate 
keep if ghecause == 2 & region==2000
drop  ghecause paho_subregion pop_mortr
rename arate mrate
merge 1:1 year sex using `daly'
drop _merge
** 1=men 2=women 3=both
reshape wide mrate drate dths daly, i(year) j(sex)
order year mrate* drate* dths* daly* 
** Restrict to 2000 and 2019, and reshape to wide
** drop daly* dths* 
keep if year==2000 | year==2019
gen k=1
reshape wide dths1 dths2 dths3 daly1 daly2 daly3 mrate1 mrate2 mrate3 drate1 drate2 drate3, i(k) j(year)
order k mrate1* mrate2* mrate3* drate1* drate2* drate3* dths1* dths2* dths3* daly1* daly2* daly3*
** percentage improvement
gen mperc1 = ((mrate12019 - mrate12000)/mrate12000) * 100
gen mperc2 = ((mrate22019 - mrate22000)/mrate22000) * 100
gen mperc3 = ((mrate32019 - mrate32000)/mrate32000) * 100
gen dperc1 = ((drate12019 - drate12000)/drate12000) * 100
gen dperc2 = ((drate22019 - drate22000)/drate22000) * 100
gen dperc3 = ((drate32019 - drate32000)/drate32000) * 100
format mperc1 mperc2 mperc3 dperc1 dperc2 dperc3 %9.1f
** death excess (women and men combined)
gen dth_excess = dths12019-dths22019
gen daly_excess = daly12019-daly22019
format dths12019 dths22019 daly12019 daly22019 dth_excess daly_excess %12.0fc
    ** Transpose
    drop k
    xpose , clear varname format(%15.2fc)
    order _varname
    dis "HHD - Change between 2000 and 2019"
    noi list _varname v1, sep(6) linesize(120)



        
**-----------------------------------------------------------
** CARDIOMYOPATHY (5)
** Percent Improvement
** Death excess (men vs women)
**-----------------------------------------------------------
use "`datapath'\from-who\chap2_000_daly_adjusted", clear
rename dalyr arate 
keep if ghecause == 5 & region==2000
drop  ghecause paho_subregion pop_dalyr
rename arate drate
tempfile daly 
save `daly', replace
use "`datapath'\from-who\chap2_000_mr_adjusted", clear
rename mortr arate 
keep if ghecause == 5 & region==2000
drop  ghecause paho_subregion pop_mortr
rename arate mrate
merge 1:1 year sex using `daly'
drop _merge
** 1=men 2=women 3=both
reshape wide mrate drate dths daly, i(year) j(sex)
order year mrate* drate* dths* daly* 
** Restrict to 2000 and 2019, and reshape to wide
** drop daly* dths* 
keep if year==2000 | year==2019
gen k=1
reshape wide dths1 dths2 dths3 daly1 daly2 daly3 mrate1 mrate2 mrate3 drate1 drate2 drate3, i(k) j(year)
order k mrate1* mrate2* mrate3* drate1* drate2* drate3* dths1* dths2* dths3* daly1* daly2* daly3*
** percentage improvement
gen mperc1 = ((mrate12019 - mrate12000)/mrate12000) * 100
gen mperc2 = ((mrate22019 - mrate22000)/mrate22000) * 100
gen mperc3 = ((mrate32019 - mrate32000)/mrate32000) * 100
gen dperc1 = ((drate12019 - drate12000)/drate12000) * 100
gen dperc2 = ((drate22019 - drate22000)/drate22000) * 100
gen dperc3 = ((drate32019 - drate32000)/drate32000) * 100
format mperc1 mperc2 mperc3 dperc1 dperc2 dperc3 %9.1f
** death excess (women and men combined)
gen dth_excess = dths12019-dths22019
gen daly_excess = daly12019-daly22019
format dths12019 dths22019 daly12019 daly22019 dth_excess daly_excess %12.0fc
    ** Transpose
    drop k
    xpose , clear varname format(%15.2fc)
    order _varname
    dis "CARDIOMYOPATHY - Change between 2000 and 2019"
    noi list _varname v1, sep(6) linesize(120)



    
**-----------------------------------------------------------
** RHEUMATIC (1)
** Percent Improvement
** Death excess (men vs women)
**-----------------------------------------------------------
use "`datapath'\from-who\chap2_000_daly_adjusted", clear
rename dalyr arate 
keep if ghecause == 1 & region==2000
drop  ghecause paho_subregion pop_dalyr
rename arate drate
tempfile daly 
save `daly', replace
use "`datapath'\from-who\chap2_000_mr_adjusted", clear
rename mortr arate 
keep if ghecause == 1 & region==2000
drop  ghecause paho_subregion pop_mortr
rename arate mrate
merge 1:1 year sex using `daly'
drop _merge
** 1=men 2=women 3=both
reshape wide mrate drate dths daly, i(year) j(sex)
order year mrate* drate* dths* daly* 
** Restrict to 2000 and 2019, and reshape to wide
** drop daly* dths* 
keep if year==2000 | year==2019
gen k=1
reshape wide dths1 dths2 dths3 daly1 daly2 daly3 mrate1 mrate2 mrate3 drate1 drate2 drate3, i(k) j(year)
order k mrate1* mrate2* mrate3* drate1* drate2* drate3* dths1* dths2* dths3* daly1* daly2* daly3*
** percentage improvement
gen mperc1 = ((mrate12019 - mrate12000)/mrate12000) * 100
gen mperc2 = ((mrate22019 - mrate22000)/mrate22000) * 100
gen mperc3 = ((mrate32019 - mrate32000)/mrate32000) * 100
gen dperc1 = ((drate12019 - drate12000)/drate12000) * 100
gen dperc2 = ((drate22019 - drate22000)/drate22000) * 100
gen dperc3 = ((drate32019 - drate32000)/drate32000) * 100
format mperc1 mperc2 mperc3 dperc1 dperc2 dperc3 %9.1f
** death excess (women and men combined)
gen dth_excess = dths12019-dths22019
gen daly_excess = daly12019-daly22019
format dths12019 dths22019 daly12019 daly22019 dth_excess daly_excess %12.0fc
    ** Transpose
    drop k
    xpose , clear varname format(%15.2fc)
    order _varname
    dis "RHEUMATIC - Change between 2000 and 2019"
    noi list _varname v1, sep(6) linesize(120)


