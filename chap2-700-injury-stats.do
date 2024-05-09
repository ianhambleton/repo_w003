** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap2-700-injury-stats.do
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
    local datapath "C:\Sync\CaribData\My Drive\output\analyse-write\w003\data"

    ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    local logpath "C:\Sync\CaribData\My Drive\output\analyse-write\w003\tech-docs"

    ** REPORTS and Other outputs
    local outputpath "C:\Sync\CaribData\My Drive\output\analyse-write\w003\outputs"

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\chap2-700-injury-stats", replace
** HEADER -----------------------------------------------------



tempfile t1

** Mortality AND DALY rates 
use "`datapath'\from-who\chap2_000_adjusted", clear

**------------------------------------------------
** INJURIES / EXTERNAL CAUSES
**------------------------------------------------
** Using DALY rate in 2019 as the ordering criterion
**  - top 5 injuries 
**
** First keep just injuires 
** 
** MENTAL HEALTH
** 48   "road injury" 
** 49   "poisonings" 
** 50   "falls" 
** 51   "Fire and heat" 
** 52   "drowning" 
** 53   "mechanical causes"
** 54   "natural disasters"
** 55   "self-harm"
** 56   "Interpersonal violence"
** 57   "Collective violence"
**
** COMBINED
** 1000  "all injuries"
** 100  "all cause", modif    
** -----------------------------------------------
#delimit ;
keep if ghecause==48 |
        ghecause==49 |
        ghecause==50 |
        ghecause==51 |
        ghecause==52 |
        ghecause==53 |
        ghecause==54 |
        ghecause==55 |
        ghecause==56 |
        ghecause==57; 
#delimit cr
keep if year==2019 & sex==3 & region==2000
gsort -mortr
gen top5 = _n
keep ghecause top5
tempfile keepme
save `keepme', replace

** Mortality AND DALY rates 
use "`datapath'\from-who\chap2_000_adjusted", clear
merge m:1 ghecause using `keepme'
drop _merge
** Keep all mental health + neurological
keep if top5<. | ghecause==100 | ghecause==1000
** Keep top 5 from injuries 
keep if top5<=5 | ghecause==100 | ghecause==1000
order top5 ghecause year sex region
sort top5 ghecause year sex region

** Save the dataset for use in Table command
save "`datapath'\from-who\chap2_000_adjusted_injuriesonly", replace

**------------------------------------------------
** BEGIN STATISTICS FOR TEXT
** to accompany the CANCER METRICS TABLE
** (1) 56   "interpersonal violence" 
** (2) 48   "road injury" 
** (3) 55   "self harm" 
** (4) 50   "falls" 
** (5) 52   "drowning" 
** 1000     "all injuries"
** 100      "all cause", modif    
** -----------------------------------------------
gen cod = .
replace cod = 1 if ghecause==56
replace cod = 2 if ghecause==48
replace cod = 3 if ghecause==55
replace cod = 4 if ghecause==50
replace cod = 5 if ghecause==52
replace cod = 6 if ghecause==1000
replace cod = 7 if ghecause==100
#delimit ;
label define cod_   1   "interpersonal violence" 
                    2   "road injury" 
                    3   "self harm" 
                    4   "falls" 
                    5   "drowning" 
                    6  "all injuries"
                    7  "all cause", modify;
#delimit cr
label values cod cod_    
keep if cod<=7

** COD as proportion of ALL INJURIES and ALL DEATHS
** Women and men combined, all Americas
keep if sex==3 & region==2000
drop sex region
collapse (sum) dths daly, by(year cod)
reshape wide dths daly, i(year) j(cod)
forval x = 1(1)7 {
    format dths`x' %15.1fc
    format daly`x' %15.1fc
}
** ALL INJURIES as percentage of all deaths
gen p1000 = (dths6/dths7)*100
gen p1000daly = (daly6/daly7)*100
gen ddrat1000 = daly6 / dths6
gen ddrat_all = daly7 / dths7

** TOP 5 INJURIES - as percentage of INJURIES and all-deaths
forval x = 1(1)5 { 
    gen p`x'a = (dths`x'/dths6)*100
    gen p`x'b = (dths`x'/dths7)*100
    ** DTH to DALY ratio
    gen ddrat`x' = daly`x' / dths`x'
}


**-----------------------------------------------------------
** INTERPERSONAL VIOLENCE (ghecause==56)
** Mortality rates by sex
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_adjusted", clear
    rename mortr mrate
    rename dalyr drate
    keep if ghecause == 56 & region==2000
    drop pop*
    ** 1=men 2=women 3=both
    reshape wide mrate dths drate daly, i(year) j(sex)
    /// DEATHS
    gen mratio_rate = mrate1 / mrate2
    gen mdiff_rate = mrate1 - mrate2
    gen mdiff_count = dths1 - dths2 
    /// DALY
    gen dratio_rate = drate1 / drate2
    gen ddiff_rate = drate1 - drate2
    gen ddiff_count = daly1 - daly2 

    order year dths* daly* mrate* drate* mratio* mdiff* dratio* ddiff* 
    format dths* daly* mrate* drate* mratio* mdiff* dratio* ddiff*   %12.2fc

    noi dis "INTERPERSONAL VIOLENCE" 
    noi list year mrate1 mrate2 mrate3 mratio_rate mdiff_rate mdiff_count, noobs ab(20)
    noi list year drate1 drate2 drate3 dratio_rate ddiff_rate ddiff_count, noobs ab(20) linesize(120)
}


**-----------------------------------------------------------
** ROAD INJURY (ghecause==48)
** Mortality rates by sex
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_adjusted", clear
    rename mortr mrate
    rename dalyr drate
    keep if ghecause == 48 & region==2000
    drop pop*
    ** 1=men 2=women 3=both
    reshape wide mrate dths drate daly, i(year) j(sex)
    /// DEATHS
    gen mratio_rate = mrate1 / mrate2
    gen mdiff_rate = mrate1 - mrate2
    gen mdiff_count = dths1 - dths2 
    /// DALY
    gen dratio_rate = drate1 / drate2
    gen ddiff_rate = drate1 - drate2
    gen ddiff_count = daly1 - daly2 

    order year dths* daly* mrate* drate* mratio* mdiff* dratio* ddiff* 
    format dths* daly* mrate* drate* mratio* mdiff* dratio* ddiff*   %12.2fc

    noi dis "ROAD INJURY" 
    noi list year mrate1 mrate2 mrate3 mratio_rate mdiff_rate mdiff_count, noobs ab(20)
    noi list year drate1 drate2 drate3 dratio_rate ddiff_rate ddiff_count, noobs ab(20) linesize(120)
}

**-----------------------------------------------------------
** SELF HARM  (ghecause==55)
** Mortality rates by sex
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_adjusted", clear
    rename mortr mrate
    rename dalyr drate
    keep if ghecause == 55 & region==2000
    drop pop*
    ** 1=men 2=women 3=both
    reshape wide mrate dths drate daly, i(year) j(sex)
    /// DEATHS
    gen mratio_rate = mrate1 / mrate2
    gen mdiff_rate = mrate1 - mrate2
    gen mdiff_count = dths1 - dths2 
    /// DALY
    gen dratio_rate = drate1 / drate2
    gen ddiff_rate = drate1 - drate2
    gen ddiff_count = daly1 - daly2 

    order year dths* daly* mrate* drate* mratio* mdiff* dratio* ddiff* 
    format dths* daly* mrate* drate* mratio* mdiff* dratio* ddiff*   %12.2fc

    noi dis "SELF HARM" 
    noi list year mrate1 mrate2 mrate3 mratio_rate mdiff_rate mdiff_count, noobs ab(20)
    noi list year drate1 drate2 drate3 dratio_rate ddiff_rate ddiff_count, noobs ab(20) linesize(120)
}

**-----------------------------------------------------------
** FALLS  (ghecause==50)
** Mortality rates by sex
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_adjusted", clear
    rename mortr mrate
    rename dalyr drate
    keep if ghecause == 50 & region==2000
    drop pop*
    ** 1=men 2=women 3=both
    reshape wide mrate dths drate daly, i(year) j(sex)
    /// DEATHS
    gen mratio_rate = mrate1 / mrate2
    gen mdiff_rate = mrate1 - mrate2
    gen mdiff_count = dths1 - dths2 
    /// DALY
    gen dratio_rate = drate1 / drate2
    gen ddiff_rate = drate1 - drate2
    gen ddiff_count = daly1 - daly2 

    order year dths* daly* mrate* drate* mratio* mdiff* dratio* ddiff* 
    format dths* daly* mrate* drate* mratio* mdiff* dratio* ddiff*   %12.2fc

    noi dis "FALLS" 
    noi list year mrate1 mrate2 mrate3 mratio_rate mdiff_rate mdiff_count, noobs ab(20)
    noi list year drate1 drate2 drate3 dratio_rate ddiff_rate ddiff_count, noobs ab(20) linesize(120)
}

**-----------------------------------------------------------
** DROWNING  (ghecause==52)
** Mortality rates by sex
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_adjusted", clear
    rename mortr mrate
    rename dalyr drate
    keep if ghecause == 52 & region==2000
    drop pop*
    ** 1=men 2=women 3=both
    reshape wide mrate dths drate daly, i(year) j(sex)
    /// DEATHS
    gen mratio_rate = mrate1 / mrate2
    gen mdiff_rate = mrate1 - mrate2
    gen mdiff_count = dths1 - dths2 
    /// DALY
    gen dratio_rate = drate1 / drate2
    gen ddiff_rate = drate1 - drate2
    gen ddiff_count = daly1 - daly2 

    order year dths* daly* mrate* drate* mratio* mdiff* dratio* ddiff* 
    format dths* daly* mrate* drate* mratio* mdiff* dratio* ddiff*   %12.2fc

    noi dis "DROWNING" 
    noi list year mrate1 mrate2 mrate3 mratio_rate mdiff_rate mdiff_count, noobs ab(20)
    noi list year drate1 drate2 drate3 dratio_rate ddiff_rate ddiff_count, noobs ab(20) linesize(120)
}

**-----------------------------------------------------------
** ALL INJURIES  (ghecause==1000)
** Mortality rates by sex
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_adjusted", clear
    rename mortr mrate
    rename dalyr drate
    keep if ghecause == 1000 & region==2000
    drop pop*
    ** 1=men 2=women 3=both
    reshape wide mrate dths drate daly, i(year) j(sex)
    /// DEATHS
    gen mratio_rate = mrate1 / mrate2
    gen mdiff_rate = mrate1 - mrate2
    gen mdiff_count = dths1 - dths2 
    /// DALY
    gen dratio_rate = drate1 / drate2
    gen ddiff_rate = drate1 - drate2
    gen ddiff_count = daly1 - daly2 

    order year dths* daly* mrate* drate* mratio* mdiff* dratio* ddiff* 
    format dths* daly* mrate* drate* mratio* mdiff* dratio* ddiff*   %12.2fc

    noi dis "ALL INJURIES" 
    noi list year mrate1 mrate2 mrate3 mratio_rate mdiff_rate mdiff_count, noobs ab(20)
    noi list year drate1 drate2 drate3 dratio_rate ddiff_rate ddiff_count, noobs ab(20) linesize(120)
}




**-----------------------------------------------------------
** All INJURIES (1000)
** Percent Improvement
** Death excess (men vs women)
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_daly_adjusted", clear
    keep if ghecause == 1000 & region==2000
    rename dalyr drate
    tempfile daly 
    save `daly', replace
    use "`datapath'\from-who\chap2_000_mr_adjusted", clear
    keep if ghecause == 1000 & region==2000
    rename mortr mrate
    merge 1:1 year sex using `daly'
    drop _merge pop*
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
    dis "ALL INJURIES - Change between 2000 and 2019"
    noi list _varname v1, sep(6)
}




**-----------------------------------------------------------
** INTERPERSONAL VIOLENCE (56)
** Percent Improvement
** Death excess (men vs women)
**-----------------------------------------------------------
**qui {
    use "`datapath'\from-who\chap2_000_daly_adjusted", clear
    keep if ghecause == 56 & region==2000
    rename dalyr drate
    tempfile daly 
    save `daly', replace
    use "`datapath'\from-who\chap2_000_mr_adjusted", clear
    keep if ghecause == 56 & region==2000
    rename mortr mrate
    merge 1:1 year sex using `daly'
    drop _merge pop*
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
    dis "INTERPERSONAL VIOLENCE - Change between 2000 and 2019"
    noi list _varname v1, sep(6)
}



**-----------------------------------------------------------
** ROAD INJURY (48)
** Percent Improvement
** Death excess (men vs women)
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_daly_adjusted", clear
    keep if ghecause == 48 & region==2000
    rename dalyr drate
    tempfile daly 
    save `daly', replace
    use "`datapath'\from-who\chap2_000_mr_adjusted", clear
    keep if ghecause == 48 & region==2000
    rename mortr mrate
    merge 1:1 year sex using `daly'
    drop _merge pop*
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
    dis "ROAD INJURY - Change between 2000 and 2019"
    noi list _varname v1, sep(6)
}

** Change between 2010 and 2019
qui {
    use "`datapath'\from-who\chap2_000_daly_adjusted", clear
    keep if ghecause == 48 & region==2000
    rename dalyr drate
    tempfile daly 
    save `daly', replace
    use "`datapath'\from-who\chap2_000_mr_adjusted", clear
    keep if ghecause == 48 & region==2000
    rename mortr mrate
    merge 1:1 year sex using `daly'
    drop _merge pop*
    ** 1=men 2=women 3=both
    reshape wide mrate drate dths daly, i(year) j(sex)
    order year mrate* drate* dths* daly* 
    ** Restrict to 2000 and 2019, and reshape to wide
    ** drop daly* dths* 
    keep if year==2010 | year==2019
    gen k=1
    reshape wide dths1 dths2 dths3 daly1 daly2 daly3 mrate1 mrate2 mrate3 drate1 drate2 drate3, i(k) j(year)
    order k mrate1* mrate2* mrate3* drate1* drate2* drate3* dths1* dths2* dths3* daly1* daly2* daly3*
    ** percentage improvement
    gen mperc1 = ((mrate12019 - mrate12010)/mrate12010) * 100
    gen mperc2 = ((mrate22019 - mrate22010)/mrate22010) * 100
    gen mperc3 = ((mrate32019 - mrate32010)/mrate32010) * 100
    gen dperc1 = ((drate12019 - drate12010)/drate12010) * 100
    gen dperc2 = ((drate22019 - drate22010)/drate22010) * 100
    gen dperc3 = ((drate32019 - drate32010)/drate32010) * 100
    format mperc1 mperc2 mperc3 dperc1 dperc2 dperc3 %9.1f
    ** death excess (women and men combined)
    gen dth_excess = dths12019-dths22019
    gen daly_excess = daly12019-daly22019
    format dths12019 dths22019 daly12019 daly22019 dth_excess daly_excess %12.0fc
    ** Transpose
    drop k
    xpose , clear varname format(%15.1fc)
    order _varname
    dis "ROAD INJURY - Change between 2000 and 2019"
    noi list _varname v1, sep(6)
}


**-----------------------------------------------------------
** SELF HARM (55)
** Percent Improvement
** Death excess (men vs women)
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_daly_adjusted", clear
    keep if ghecause == 55 & region==2000
    rename dalyr drate
    tempfile daly 
    save `daly', replace
    use "`datapath'\from-who\chap2_000_mr_adjusted", clear
    keep if ghecause == 55 & region==2000
    rename mortr mrate
    merge 1:1 year sex using `daly'
    drop _merge pop*
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
    dis "SELF HARM - Change between 2000 and 2019"
    noi list _varname v1, sep(6)
}

**-----------------------------------------------------------
** FALLS (50)
** Percent Improvement
** Death excess (men vs women)
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_daly_adjusted", clear
    keep if ghecause == 50 & region==2000
    rename dalyr drate
    tempfile daly 
    save `daly', replace
    use "`datapath'\from-who\chap2_000_mr_adjusted", clear
    keep if ghecause == 50 & region==2000
    rename mortr mrate
    merge 1:1 year sex using `daly'
    drop _merge pop*
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
    dis "FALLS - Change between 2000 and 2019"
    noi list _varname v1, sep(6)
}


**-----------------------------------------------------------
** DROWNING (52)
** Percent Improvement
** Death excess (men vs women)
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_daly_adjusted", clear
    keep if ghecause == 52 & region==2000
    rename dalyr drate
    tempfile daly 
    save `daly', replace
    use "`datapath'\from-who\chap2_000_mr_adjusted", clear
    keep if ghecause == 52 & region==2000
    rename mortr mrate
    merge 1:1 year sex using `daly'
    drop _merge pop*
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
    dis "DROWNING - Change between 2000 and 2019"
    noi list _varname v1, sep(6)
}


