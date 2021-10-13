** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap2-400-respiratory-stats.do
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
    log using "`logpath'\chap2-400-respiratory-stats", replace
** HEADER -----------------------------------------------------


** Load primary deaths dataset
use "`datapath'\from-who\chap2_000_adjusted", clear
** Restrict to Americas ONLY
keep if region==2000 & sex==3
** CODES
**    29  "COPD"
**    30  "Asthma"
**    600  ALL CVD
**    100  ALL DEATHS
keep if ghecause==29 | ghecause==30 | ghecause==600 | ghecause==100
keep dths daly year ghecause 
format dths %15.1fc
reshape wide dths daly, i(year) j(ghecause)

** RESPIRATORY as percentage of all deaths
gen p600 = (dths600/dths100)*100
gen ddrat600 = daly600 / dths600
gen ddrat_all = daly100 / dths100

** COPD as percentage of RESP and all-deaths
gen p29a = (dths29/dths600)*100
gen p29b = (dths29/dths100)*100

** Asthma as percentage of CVD and all-deaths
gen p30a = (dths30/dths600)*100
gen p30b = (dths30/dths100)*100
/*
**-----------------------------------------------------------
** COPD (29)
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_adjusted", clear
    rename mortr mrate
    rename dalyr drate
    keep if ghecause == 29 & region==2000
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
    format dths* daly* mrate* drate* mratio* mdiff* dratio* ddiff*   %12.1fc

    noi dis "COPD" 
    noi list year dths1 dths2 dths3 daly1 daly2 daly3, noobs ab(20) linesize(120)
    noi list year mrate1 mrate2 mrate3 mratio_rate mdiff_rate mdiff_count, noobs ab(20)
    noi list year drate1 drate2 drate3 dratio_rate ddiff_rate ddiff_count, noobs ab(20)
}


**-----------------------------------------------------------
** ASTHMA (30)
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_adjusted", clear
    rename mortr mrate
    rename dalyr drate
    keep if ghecause == 30 & region==2000
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
    format dths* daly* mrate* drate* mratio* mdiff* dratio* ddiff*   %12.1fc

    noi dis "ASTHMA" 
    noi list year mrate1 mrate2 mrate3 mratio_rate mdiff_rate mdiff_count, noobs ab(20)
    noi list year drate1 drate2 drate3 dratio_rate ddiff_rate ddiff_count, noobs ab(20)
}


**-----------------------------------------------------------
** All RESPIRATORY (600)
** Percent Improvement
** Death excess (men vs women)
**-----------------------------------------------------------
use "`datapath'\from-who\chap2_000_daly_adjusted", clear
keep if ghecause == 600 & region==2000
drop  ghecause paho_subregion pop_dalyr
rename dalyr drate
tempfile daly 
save `daly', replace
use "`datapath'\from-who\chap2_000_mr_adjusted", clear
keep if ghecause == 600 & region==2000
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


**-----------------------------------------------------------
** COPD (29)
** Percent Improvement
** Death excess (men vs women)
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_daly_adjusted", clear
    keep if ghecause == 29 & region==2000
    rename dalyr drate
    tempfile daly 
    save `daly', replace
    use "`datapath'\from-who\chap2_000_mr_adjusted", clear
    keep if ghecause == 29 & region==2000
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
    dis "ALL MENTAL HEALTH - Change between 2000 and 2019"
    noi list _varname v1, sep(6)
}



**-----------------------------------------------------------
** ATHMA (30)
** Percent Improvement
** Death excess (men vs women)
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_daly_adjusted", clear
    keep if ghecause == 30 & region==2000
    rename dalyr drate
    tempfile daly 
    save `daly', replace
    use "`datapath'\from-who\chap2_000_mr_adjusted", clear
    keep if ghecause == 30 & region==2000
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
    dis "ALL MENTAL HEALTH - Change between 2000 and 2019"
    noi list _varname v1, sep(6)
}
