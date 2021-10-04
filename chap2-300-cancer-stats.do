** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap2-300-cancer-stats.do
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
    log using "`logpath'\chap2-300-cancer-stats", replace
** HEADER -----------------------------------------------------



tempfile t1

** Mortality AND DALY rates 
use "`datapath'\from-who\chap2_000_adjusted", clear

** Size of 2019 MR in Americas (women and men combined)
keep if region==2000 & sex==3  & (ghecause<=100 | ghecause==500)
** keep if region==2000 & sex==3  & (ghecause<=100 | ghecause==500)
** keep if region==2000 & (ghecause<=100 | ghecause==500)
gsort -mortr
list ghecause mortr

**------------------------------------------------
** BEGIN STATISTICS FOR TEXT
** to accompany the CANCER METRICS TABLE
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
** 500  "all cancers"
** 100  "all cause", modif    
** -----------------------------------------------
gen cod = .
replace cod = 1 if ghecause==12
replace cod = 2 if ghecause==14
replace cod = 3 if ghecause==18
replace cod = 4 if ghecause==9
replace cod = 5 if ghecause==15
replace cod = 6 if ghecause==11
replace cod = 7 if ghecause==27
replace cod = 8 if ghecause==8
replace cod = 9 if ghecause==10
replace cod = 10 if ghecause==28
replace cod = 11 if ghecause==500
replace cod = 12 if ghecause==100
#delimit ;
label define cod_   1   "trachea/lung" 
                    2   "breast" 
                    3   "prostate" 
                    4    "colon/rectum" 
                    5   "cervix uteri" 
                    6   "pancreas"
                    7   "lymphomas/myeloma"
                    8    "stomach"
                    9   "liver"
                    10   "leukemia"
                    11  "all cancers"
                    12  "all cause", modify;
#delimit cr
label values cod cod_    
keep if cod<=12

** COD as proportion of ALL CANCERS and ALL DEATHS
** Women and men combined, all Americas
keep if sex==3 & region==2000
drop sex region
collapse (sum) dths daly, by(year cod)
reshape wide dths daly, i(year) j(cod)
forval x = 1(1)12 {
    format dths`x' %15.1fc
}
** ALL CANCER as percentage of all deaths
gen p500 = (dths11/dths12)*100
gen ddrat500 = daly11 / dths11
gen ddrat_all = daly12 / dths12

** TOP 10 CANCERS - as percentage of CANCERS and all-deaths
forval x = 1(1)11 { 
    gen p`x'a = (dths`x'/dths11)*100
    gen p`x'b = (dths`x'/dths12)*100
}

**-----------------------------------------------------------
** TRACHEA / LUNG (ghecause==12)
** Mortality rates by sex
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_adjusted", clear
    rename mortr mrate
    rename dalyr drate
    keep if ghecause == 12 & region==2000
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

    noi dis "TRACHEA / LUNG" 
    noi list year mrate1 mrate2 mrate3 mratio_rate mdiff_rate mdiff_count, noobs ab(20)
    noi list year drate1 drate2 drate3 dratio_rate ddiff_rate ddiff_count, noobs ab(20)
}


**-----------------------------------------------------------
** BREAST (ghecause==14)
** Mortality rates by sex
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_adjusted", clear
    rename mortr mrate
    rename dalyr drate
    keep if ghecause == 14 & region==2000
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

    noi dis "BREAST" 
    noi list year mrate1 mrate2 mrate3 mratio_rate mdiff_rate mdiff_count, noobs ab(20)
    noi list year drate1 drate2 drate3 dratio_rate ddiff_rate ddiff_count, noobs ab(20)
}

**-----------------------------------------------------------
** PROSTATE  (ghecause==18)
** Mortality rates by sex
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_adjusted", clear
    rename mortr mrate
    rename dalyr drate
    keep if ghecause == 18 & region==2000
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

    noi dis "PROSTATE" 
    noi list year mrate1 mrate2 mrate3 mratio_rate mdiff_rate mdiff_count, noobs ab(20)
    noi list year drate1 drate2 drate3 dratio_rate ddiff_rate ddiff_count, noobs ab(20)
}

**-----------------------------------------------------------
** COLON / RECTAL  (ghecause==9)
** Mortality rates by sex
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_adjusted", clear
    rename mortr mrate
    rename dalyr drate
    keep if ghecause == 9 & region==2000
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

    noi dis "COLON / RECTAL" 
    noi list year mrate1 mrate2 mrate3 mratio_rate mdiff_rate mdiff_count, noobs ab(20)
    noi list year drate1 drate2 drate3 dratio_rate ddiff_rate ddiff_count, noobs ab(20)
}

**-----------------------------------------------------------
** CERVIX UTERI  (ghecause==15)
** Mortality rates by sex
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_adjusted", clear
    rename mortr mrate
    rename dalyr drate
    keep if ghecause == 15 & region==2000
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

    noi dis "CERVIX UTERI" 
    noi list year mrate1 mrate2 mrate3 mratio_rate mdiff_rate mdiff_count, noobs ab(20)
    noi list year drate1 drate2 drate3 dratio_rate ddiff_rate ddiff_count, noobs ab(20)
}

**-----------------------------------------------------------
** PANCREAS (ghecause==11)
** Mortality rates by sex
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_adjusted", clear
    rename mortr mrate
    rename dalyr drate
    keep if ghecause == 11 & region==2000
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

    noi dis "PANCREAS" 
    noi list year mrate1 mrate2 mrate3 mratio_rate mdiff_rate mdiff_count, noobs ab(20)
    noi list year drate1 drate2 drate3 dratio_rate ddiff_rate ddiff_count, noobs ab(20)
}

**-----------------------------------------------------------
** LYMPHOMAS / MYELOMA  (ghecause==27)
** Mortality rates by sex
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_adjusted", clear
    rename mortr mrate
    rename dalyr drate
    keep if ghecause == 27 & region==2000
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

    noi dis "LYMPHOMAS / MYELOMAS" 
    noi list year mrate1 mrate2 mrate3 mratio_rate mdiff_rate mdiff_count, noobs ab(20)
    noi list year drate1 drate2 drate3 dratio_rate ddiff_rate ddiff_count, noobs ab(20)
}
**-----------------------------------------------------------
** STOMACH  (ghecause==8)
** Mortality rates by sex
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_adjusted", clear
    rename mortr mrate
    rename dalyr drate
    keep if ghecause == 8 & region==2000
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

    noi dis "STOMACH" 
    noi list year mrate1 mrate2 mrate3 mratio_rate mdiff_rate mdiff_count, noobs ab(20)
    noi list year drate1 drate2 drate3 dratio_rate ddiff_rate ddiff_count, noobs ab(20)
}
**-----------------------------------------------------------
** LIVER  (ghecause==10)
** Mortality rates by sex
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_adjusted", clear
    rename mortr mrate
    rename dalyr drate
    keep if ghecause == 10 & region==2000
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

    noi dis "LIVER" 
    noi list year mrate1 mrate2 mrate3 mratio_rate mdiff_rate mdiff_count, noobs ab(20)
    noi list year drate1 drate2 drate3 dratio_rate ddiff_rate ddiff_count, noobs ab(20)
}

**-----------------------------------------------------------
** LEUKEMIAS  (ghecause==28)
** Mortality rates by sex
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_adjusted", clear
    rename mortr mrate
    rename dalyr drate
    keep if ghecause == 28 & region==2000
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

    noi dis "LEUKEMIA" 
    noi list year mrate1 mrate2 mrate3 mratio_rate mdiff_rate mdiff_count, noobs ab(20)
    noi list year drate1 drate2 drate3 dratio_rate ddiff_rate ddiff_count, noobs ab(20)
}

**-----------------------------------------------------------
** ALL CANCERS  (ghecause==500)
** Mortality rates by sex
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_adjusted", clear
    rename mortr mrate
    rename dalyr drate
    keep if ghecause == 500 & region==2000
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

    noi dis "ALL CANCERS" 
    noi list year mrate1 mrate2 mrate3 mratio_rate mdiff_rate mdiff_count, noobs ab(20) linesize(120)
    noi list year drate1 drate2 drate3 dratio_rate ddiff_rate ddiff_count, noobs ab(20) linesize(120)
}




**-----------------------------------------------------------
** All CANCERS (500)
** Percent Improvement
** Death excess (men vs women)
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_daly_adjusted", clear
    keep if ghecause == 500 & region==2000
    rename dalyr drate
    tempfile daly 
    save `daly', replace
    use "`datapath'\from-who\chap2_000_mr_adjusted", clear
    keep if ghecause == 500 & region==2000
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
    dis "ALL CANCERS - Change between 2000 and 2019"
    noi list _varname v1, sep(6) linesize(120)
}




**-----------------------------------------------------------
** TRACHEA / LUNG CANCERS (12)
** Percent Improvement
** Death excess (men vs women)
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_daly_adjusted", clear
    keep if ghecause == 12 & region==2000
    rename dalyr drate
    tempfile daly 
    save `daly', replace
    use "`datapath'\from-who\chap2_000_mr_adjusted", clear
    keep if ghecause == 12 & region==2000
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
    dis "ALL CANCERS - Change between 2000 and 2019"
    noi list _varname v1, sep(6)
}



**-----------------------------------------------------------
** BREAST (14)
** Percent Improvement
** Death excess (men vs women)
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_daly_adjusted", clear
    keep if ghecause == 14 & region==2000
    rename dalyr drate
    tempfile daly 
    save `daly', replace
    use "`datapath'\from-who\chap2_000_mr_adjusted", clear
    keep if ghecause == 14 & region==2000
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
    dis "BREAST CANCERS - Change between 2000 and 2019"
    noi list _varname v1, sep(6)
}


**-----------------------------------------------------------
** PROSTATE CANCERS (18)
** Percent Improvement
** Death excess (men vs women)
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_daly_adjusted", clear
    keep if ghecause == 18 & region==2000
    rename dalyr drate
    tempfile daly 
    save `daly', replace
    use "`datapath'\from-who\chap2_000_mr_adjusted", clear
    keep if ghecause == 18 & region==2000
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
    xpose , clear varname format(%15.2fc)
    order _varname
    dis "PROSTATE CANCERS - Change between 2000 and 2019"
    noi list _varname v1, sep(6)
}

**-----------------------------------------------------------
** COLON/RECTUM CANCERS (9)
** Percent Improvement
** Death excess (men vs women)
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_daly_adjusted", clear
    keep if ghecause == 9 & region==2000
    rename dalyr drate
    tempfile daly 
    save `daly', replace
    use "`datapath'\from-who\chap2_000_mr_adjusted", clear
    keep if ghecause == 9 & region==2000
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
    dis "COLON/RECTUM CANCERS - Change between 2000 and 2019"
    noi list _varname v1, sep(6)
}


**-----------------------------------------------------------
** CERVIX UTERI (15)
** Percent Improvement
** Death excess (men vs women)
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_daly_adjusted", clear
    keep if ghecause == 15 & region==2000
    rename dalyr drate
    tempfile daly 
    save `daly', replace
    use "`datapath'\from-who\chap2_000_mr_adjusted", clear
    keep if ghecause == 15 & region==2000
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
    dis "CERVIX UTERI CANCERS - Change between 2000 and 2019"
    noi list _varname v1, sep(6)
}


**-----------------------------------------------------------
** PANCREAS CANCERS (11)
** Percent Improvement
** Death excess (men vs women)
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_daly_adjusted", clear
    keep if ghecause == 11 & region==2000
    rename dalyr drate
    tempfile daly 
    save `daly', replace
    use "`datapath'\from-who\chap2_000_mr_adjusted", clear
    keep if ghecause == 11 & region==2000
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
    dis "PANCREAS CANCERS - Change between 2000 and 2019"
    noi list _varname v1, sep(6)
}


**-----------------------------------------------------------
** LYMPHOMAS/MYELOMA CANCERS (27)
** Percent Improvement
** Death excess (men vs women)
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_daly_adjusted", clear
    keep if ghecause == 27 & region==2000
    rename dalyr drate
    tempfile daly 
    save `daly', replace
    use "`datapath'\from-who\chap2_000_mr_adjusted", clear
    keep if ghecause == 27 & region==2000
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
    dis "LYMPHOMAS/MYELOMA CANCERS - Change between 2000 and 2019"
    noi list _varname v1, sep(6)
}


**-----------------------------------------------------------
** STOMACH CANCERS (8)
** Percent Improvement
** Death excess (men vs women)
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_daly_adjusted", clear
    keep if ghecause == 8 & region==2000
    rename dalyr drate
    tempfile daly 
    save `daly', replace
    use "`datapath'\from-who\chap2_000_mr_adjusted", clear
    keep if ghecause == 8 & region==2000
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
    dis "STOMACH CANCERS - Change between 2000 and 2019"
    noi list _varname v1, sep(6)
}


**-----------------------------------------------------------
** LIVER CANCERS (10)
** Percent Improvement
** Death excess (men vs women)
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_daly_adjusted", clear
    keep if ghecause == 10 & region==2000
    rename dalyr drate
    tempfile daly 
    save `daly', replace
    use "`datapath'\from-who\chap2_000_mr_adjusted", clear
    keep if ghecause == 10 & region==2000
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
    dis "LIVER CANCERS - Change between 2000 and 2019"
    noi list _varname v1, sep(6)
}

**-----------------------------------------------------------
** LEUKEMIA CANCERS (28)
** Percent Improvement
** Death excess (men vs women)
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_daly_adjusted", clear
    keep if ghecause == 28 & region==2000
    rename dalyr drate
    tempfile daly 
    save `daly', replace
    use "`datapath'\from-who\chap2_000_mr_adjusted", clear
    keep if ghecause == 28 & region==2000
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
    dis "LEUKEMIA CANCERS - Change between 2000 and 2019"
    noi list _varname v1, sep(6)
}

