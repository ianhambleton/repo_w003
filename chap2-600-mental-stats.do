** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap2-600-mental-stats.do
    //  project:				    WHO Global Health Estimates
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	26-Apr-2021
    //  algorithm task			    Preparing Mental health / neurological mortality rates

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
    log using "`logpath'\chap2-600-mental-stats", replace
** HEADER -----------------------------------------------------

tempfile t1

** Mortality AND DALY rates 
use "`datapath'\from-who\chap2_000_adjusted", clear

**------------------------------------------------
** MENTAL HEALTH AND NEUROLOGICAL
**------------------------------------------------
** Using DALY rate in 2019 as the ordering criterion
**  - top 5 mental health conditions
**  - top 5 neurological conditions
**
** First keep just mental health and neurological conditions
** 
** MENTAL HEALTH
** 32   "depressive disorders" 
** 33   "bipolar disorders" 
** 34   "schizophrenia" 
** 35   "Alcohol use disorders" 
** 36   "drug use disorders" 
** 37   "anxiety disorders"
** 38   "eating disorders"
** 39   "Autism and Asperger syndrome"
** 40   "Childhood behavioral disorders"
** 41   "Idiopathic intellectual disability"
**
** NEUROLOGICAL
** 42   "Alzheimer disease and other dementias"
** 43   "Parkinson disease"
** 44   "Epilepsy"
** 45   "Multiple sclerosis"
** 46   "Migraine"
** 47   "Non-migraine headache"
**
** COMBINED
** 800  "all mental health"
** 900  "all neurological"
** 100  "all cause", modif    
** -----------------------------------------------
#delimit ;
keep if ghecause==32 |
        ghecause==33 |
        ghecause==34 |
        ghecause==35 |
        ghecause==36 |
        ghecause==37 |
        ghecause==38 |
        ghecause==39 |
        ghecause==40 |
        ghecause==41 |
        ghecause==42 |
        ghecause==43 |
        ghecause==44 |
        ghecause==45 |
        ghecause==46 |
        ghecause==47; 
#delimit cr
keep if year==2019 & sex==3 & region==2000
gen type = 1 if ghecause >=32 & ghecause<=41
replace type = 2 if ghecause >=42 & ghecause<=47
label define type_ 1 "mental health" 2 "neurological", modify 
label values type type_
gsort type -dalyr
by type : gen top5 = _n
keep type ghecause top5
tempfile type keepme
save `keepme', replace

** Mortality AND DALY rates 
use "`datapath'\from-who\chap2_000_adjusted", clear
merge m:1 ghecause using `keepme'
drop _merge
** Keep all mental health + neurological
keep if top5<. | ghecause==100 | ghecause==800 | ghecause==900
** Keep top 5 from mental health and from neurological
keep if top5<=5 | ghecause==100 | ghecause==800 | ghecause==900
order type top5 ghecause year sex region
sort type top5 ghecause year sex region

** Save the dataset for use in Table command
save "`datapath'\from-who\chap2_000_adjusted_mentalhealthonly", replace




**------------------------------------------------
** Ordered version of ghecause 
** MENTAL HEALTH
** (36)  1   "Drug use disorders" 
** (32)  2   "Depressive disorders" 
** (37)  3   "Anxiety disorders" 
** (35)  4   "Alcohol use disorders" 
** (34)  5   "Schizophrenia" 
** NEUROLOGICAL
** (42)  6   "Alzheimer/dementias"
** (46)  7   "Migraine"
** (44)  8   "Epilepsy"
** (47)  9   "Non-migraine headache"
** (43)  10  "Parkinson disease"
** (800)  11  "all mental"
** (900)  12  "all neurological"
** (100)  13  "all cause"  
** -----------------------------------------------
gen cod = .
replace cod = 1 if type==1 & top5==1
replace cod = 2 if type==1 & top5==2
replace cod = 3 if type==1 & top5==3
replace cod = 4 if type==1 & top5==4
replace cod = 5 if type==1 & top5==5
replace cod = 6 if type==2 & top5==1
replace cod = 7 if type==2 & top5==2
replace cod = 8 if type==2 & top5==3
replace cod = 9 if type==2 & top5==4
replace cod = 10 if type==2 & top5==5
replace cod = 11 if ghecause==800
replace cod = 12 if ghecause==900
replace cod = 13 if ghecause==100
#delimit ;
label define cod_   1   "Drug use disorders" 
                    2   "Depressive disorders" 
                    3   "Anxiety disorders" 
                    4   "Alcohol use disorders" 
                    5   "Schizophrenia" 
                    6   "Alzheimer/dementias"
                    7   "Migraine"
                    8   "Epilepsy"
                    9   "Non-migraine headache"
                    10  "Parkinson's disease"
                    11  "all mental"
                    12  "all neurological"
                    13  "all cause", modify;
#delimit cr
label values cod cod_    
keep if cod<=13



** COD as proportion of ALL MENTAL/NEUROLOGICAL and ALL DEATHS
** Women and men combined, all Americas
preserve
    keep if sex==3 & region==2000
    drop sex region
    collapse (sum) dths daly, by(year cod)
    reshape wide dths daly, i(year) j(cod)
    forval x = 1(1)13 {
        format dths`x' %15.1fc
        format daly`x' %15.1fc
    }

    ** ALL MENTAL / NEUROLOGICAL as percentage of all deaths
    gen p800 = (dths11/dths13)*100
    gen p900 = (dths12/dths13)*100
    gen p800900 = ((dths11+dths12)/dths13)*100

    gen ddrat800 = daly11 / dths11
    gen ddrat900 = daly12 / dths12
    gen ddrat800900 = (daly11 + daly12) / (dths11 + dths12)
    gen ddrat_all = daly13 / dths13

    ** ALL MENTAL / NEUROLOGICAL as percentage of all DALYs
    gen pd800 = (daly11/daly13)*100
    gen pd900 = (daly12/daly13)*100
    gen pd800900 = ((daly11+daly12)/daly13)*100

    ** TOP 5 MENTAL HEALTH CONDITIONS - as percentage of mental health and all-deaths
    forval x = 1(1)5 { 
        /// deaths
        gen pdth_`x'a = (dths`x'/dths11)*100
        gen pdth_`x'b = (dths`x'/dths13)*100
        /// daly
        gen pdaly_`x'a = (daly`x'/daly11)*100
        gen pdaly_`x'b = (daly`x'/daly13)*100
        if `x'==1 {
            dis "Drug use disorders"
        }
        if `x'==2 {
            dis "Depressive disorders"
        }
        if `x'==3 {
            dis "Anxiety disorders"
        }
        if `x'==4 {
            dis "Alcohol-use disorders"
        }
        if `x'==5 {
            dis "Schizophrenia"
        }
        list year pdth_`x'a pdth_`x'b pdaly_`x'a pdaly_`x'b 
    }
    ** TOP 5 NEUROLOGICAL CONDITIONS - as percentage of all neurological and all-deaths
    forval x = 6(1)10 { 
        /// deaths
        gen pdth_`x'a = (dths`x'/dths12)*100
        gen pdth_`x'b = (dths`x'/dths13)*100
        /// daly
        gen pdaly_`x'a = (daly`x'/daly12)*100
        gen pdaly_`x'b = (daly`x'/daly13)*100
        if `x'==6 {
            dis "Alzheimer/dementias"
        }
        if `x'==7 {
            dis "Migraine"
        }
        if `x'==8 {
            dis "Epilepsy"
        }
        if `x'==9 {
            dis "Non-migraine headache"
        }
        if `x'==10 {
            dis "Parkinson's disease"
        }
        list year pdth_`x'a pdth_`x'b pdaly_`x'a pdaly_`x'b 
    }
restore




**-----------------------------------------------------------
** DRUG USE DISORDERS (ghecause==36)
** Mortality rates by sex
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_adjusted", clear
    rename mortr mrate
    rename dalyr drate
    keep if ghecause == 36 & region==2000
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

    noi dis "DRUG USE DISORDERS" 
    noi list year mrate1 mrate2 mrate3 mratio_rate mdiff_rate mdiff_count, noobs ab(20)
    noi list year drate1 drate2 drate3 dratio_rate ddiff_rate ddiff_count, noobs ab(20)
}


**-----------------------------------------------------------
** DEPRESSIVE DISORDERS (ghecause==32)
** Mortality rates by sex
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_adjusted", clear
    rename mortr mrate
    rename dalyr drate
    keep if ghecause == 32 & region==2000
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

    noi dis "DEPRESSIVE DISORDERS" 
    noi list year mrate1 mrate2 mrate3 mratio_rate mdiff_rate mdiff_count, noobs ab(20)
    noi list year drate1 drate2 drate3 dratio_rate ddiff_rate ddiff_count, noobs ab(20)
}


**-----------------------------------------------------------
** ANXIETY DISORDERS  (ghecause==37)
** Mortality rates by sex
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_adjusted", clear
    rename mortr mrate
    rename dalyr drate
    keep if ghecause == 37 & region==2000
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
    format dths* daly* mrate* drate* mratio* mdiff* dratio* ddiff*   %12.4fc

    noi dis "ANXIETY DISORDERS" 
    noi list year mrate1 mrate2 dths3 mrate3 mratio_rate mdiff_rate mdiff_count, noobs ab(20) linesize(120)
    noi list year drate1 drate2 daly3 drate3 dratio_rate ddiff_rate ddiff_count, noobs ab(20) linesize(120)
}


**-----------------------------------------------------------
** ALCOHOL USE DISORDERS  (ghecause==35)
** Mortality rates by sex
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_adjusted", clear
    rename mortr mrate
    rename dalyr drate
    keep if ghecause == 35 & region==2000
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

    noi dis "ALCOHOL USE DISORDERS" 
    noi list year mrate1 mrate2 mrate3 mratio_rate mdiff_rate mdiff_count, noobs ab(20)
    noi list year drate1 drate2 drate3 dratio_rate ddiff_rate ddiff_count, noobs ab(20)
}



**-----------------------------------------------------------
** SCHIZOPHRENIA  (ghecause==34)
** Mortality rates by sex
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_adjusted", clear
    rename mortr mrate
    rename dalyr drate
    keep if ghecause == 34 & region==2000
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

    noi dis "SCHIZOPHRENIA" 
    noi list year mrate1 mrate2 mrate3 mratio_rate mdiff_rate mdiff_count, noobs ab(20)
    noi list year drate1 drate2 drate3 dratio_rate ddiff_rate ddiff_count, noobs ab(20)
}


**-----------------------------------------------------------
** ALZHEIMER / DEMENTIAS (ghecause==42)
** Mortality rates by sex
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_adjusted", clear
    rename mortr mrate
    rename dalyr drate
    keep if ghecause == 42 & region==2000
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

    noi dis "ALZHEIMER / DEMENTIAS" 
    noi list year mrate1 mrate2 mrate3 mratio_rate mdiff_rate mdiff_count, noobs ab(20)
    noi list year drate1 drate2 drate3 dratio_rate ddiff_rate ddiff_count, noobs ab(20)
}


**-----------------------------------------------------------
** MIGRAINE  (ghecause==46)
** Mortality rates by sex
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_adjusted", clear
    rename mortr mrate
    rename dalyr drate
    keep if ghecause == 46 & region==2000
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
    format dths* daly* mrate* drate* mratio* mdiff* dratio* ddiff*   %12.4fc

    noi dis "MIGRAINE" 
    noi list year mrate1 mrate2 dths3 mrate3 mratio_rate mdiff_rate mdiff_count, noobs ab(20) linesize(120)
    noi list year drate1 drate2 daly3 drate3 dratio_rate ddiff_rate ddiff_count, noobs ab(20) linesize(120)
}


**-----------------------------------------------------------
** EPILEPSY  (ghecause==44)
** Mortality rates by sex
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_adjusted", clear
    rename mortr mrate
    rename dalyr drate
    keep if ghecause == 44 & region==2000
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

    noi dis "EPILEPSY" 
    noi list year mrate1 mrate2 mrate3 mratio_rate mdiff_rate mdiff_count, noobs ab(20)
    noi list year drate1 drate2 drate3 dratio_rate ddiff_rate ddiff_count, noobs ab(20)
}


**-----------------------------------------------------------
** NON-MIGRAINE HEADACHE  (ghecause==47)
** Mortality rates by sex
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_adjusted", clear
    rename mortr mrate
    rename dalyr drate
    keep if ghecause == 47 & region==2000
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

    noi dis "NON-MIGRAINE HEADACHE" 
    noi list year mrate1 mrate2 mrate3 mratio_rate mdiff_rate mdiff_count, noobs ab(20)
    noi list year drate1 drate2 drate3 dratio_rate ddiff_rate ddiff_count, noobs ab(20)
}


**-----------------------------------------------------------
** PARKINSON DISEASE  (ghecause==43)
** Mortality rates by sex
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_adjusted", clear
    rename mortr mrate
    rename dalyr drate
    keep if ghecause == 43 & region==2000
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

    noi dis "PARKINSON DISEASE" 
    noi list year mrate1 mrate2 mrate3 mratio_rate mdiff_rate mdiff_count, noobs ab(20)
    noi list year drate1 drate2 drate3 dratio_rate ddiff_rate ddiff_count, noobs ab(20)
}


**-----------------------------------------------------------
** ALL MENTAL HEALTH  (ghecause==800)
** Mortality rates by sex
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_adjusted", clear
    rename mortr mrate
    rename dalyr drate
    keep if ghecause == 800 & region==2000
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

    noi dis "ALL MENTAL HEALTH" 
    noi list year mrate1 mrate2 mrate3 mratio_rate mdiff_rate mdiff_count, noobs ab(20) linesize(120)
    noi list year drate1 drate2 drate3 dratio_rate ddiff_rate ddiff_count, noobs ab(20) linesize(120)
}


**-----------------------------------------------------------
** ALL NEUROLOGICAL  (ghecause==900)
** Mortality rates by sex
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_adjusted", clear
    rename mortr mrate
    rename dalyr drate
    keep if ghecause == 900 & region==2000
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

    noi dis "ALL NEUROLOGICAL" 
    noi list year mrate1 mrate2 mrate3 mratio_rate mdiff_rate mdiff_count, noobs ab(20) linesize(120)
    noi list year drate1 drate2 drate3 dratio_rate ddiff_rate ddiff_count, noobs ab(20) linesize(120)
}


**-----------------------------------------------------------
** All MENTAL HEALTH (800)
** Percent Improvement
** Death excess (men vs women)
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_daly_adjusted", clear
    keep if ghecause == 800 & region==2000
    rename dalyr drate
    tempfile daly 
    save `daly', replace
    use "`datapath'\from-who\chap2_000_mr_adjusted", clear
    keep if ghecause == 800 & region==2000
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
** All NEUROLOGICAL (900)
** Percent Improvement
** Death excess (men vs women)
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_daly_adjusted", clear
    keep if ghecause == 900 & region==2000
    rename dalyr drate
    tempfile daly 
    save `daly', replace
    use "`datapath'\from-who\chap2_000_mr_adjusted", clear
    keep if ghecause == 900 & region==2000
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
** DRUG USE DISORDERS (36)
** Percent Improvement
** Death excess (men vs women)
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_daly_adjusted", clear
    keep if ghecause == 36 & region==2000
    rename dalyr drate
    tempfile daly 
    save `daly', replace
    use "`datapath'\from-who\chap2_000_mr_adjusted", clear
    keep if ghecause == 36 & region==2000
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
    dis "DRUG USE DISORDERS - Change between 2000 and 2019"
    noi list _varname v1, sep(6)
}


**-----------------------------------------------------------
** DEPRESSIVE DISORDERS (32)
** Percent Improvement
** Death excess (men vs women)
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_daly_adjusted", clear
    keep if ghecause == 32 & region==2000
    rename dalyr drate
    tempfile daly 
    save `daly', replace
    use "`datapath'\from-who\chap2_000_mr_adjusted", clear
    keep if ghecause == 32 & region==2000
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
    dis "DEPRESSIVE DISORDERS - Change between 2000 and 2019"
    noi list _varname v1, sep(6)
}


**-----------------------------------------------------------
** ANXIETY DISORDERS (36)
** Percent Improvement
** Death excess (men vs women)
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_daly_adjusted", clear
    keep if ghecause == 37 & region==2000
    rename dalyr drate
    tempfile daly 
    save `daly', replace
    use "`datapath'\from-who\chap2_000_mr_adjusted", clear
    keep if ghecause == 37 & region==2000
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
    dis "ANXIETY DISORDERS - Change between 2000 and 2019"
    noi list _varname v1, sep(6)
}


**-----------------------------------------------------------
** ALCOHOL USE DISORDERS (35)
** Percent Improvement
** Death excess (men vs women)
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_daly_adjusted", clear
    keep if ghecause == 35 & region==2000
    rename dalyr drate
    tempfile daly 
    save `daly', replace
    use "`datapath'\from-who\chap2_000_mr_adjusted", clear
    keep if ghecause == 35 & region==2000
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
    dis "ALCOHOL USE DISORDERS - Change between 2000 and 2019"
    noi list _varname v1, sep(6)
}

**-----------------------------------------------------------
** SCHIZOPHRENIA DISORDERS (34)
** Percent Improvement
** Death excess (men vs women)
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_daly_adjusted", clear
    keep if ghecause == 34 & region==2000
    rename dalyr drate
    tempfile daly 
    save `daly', replace
    use "`datapath'\from-who\chap2_000_mr_adjusted", clear
    keep if ghecause == 34 & region==2000
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
    dis "SCHIZOPHRENIA DISORDERS - Change between 2000 and 2019"
    noi list _varname v1, sep(6)
}

**-----------------------------------------------------------
** ALZHEIMER / DEMENTIAS (42)
** Percent Improvement
** Death excess (men vs women)
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_daly_adjusted", clear
    keep if ghecause == 42 & region==2000
    rename dalyr drate
    tempfile daly 
    save `daly', replace
    use "`datapath'\from-who\chap2_000_mr_adjusted", clear
    keep if ghecause == 42 & region==2000
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
    dis "ALZHEIMER / DEMENTIAS - Change between 2000 and 2019"
    noi list _varname v1, sep(6)
}



**-----------------------------------------------------------
** MIGRAINE (46)
** Percent Improvement
** Death excess (men vs women)
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_daly_adjusted", clear
    keep if ghecause == 46 & region==2000
    rename dalyr drate
    tempfile daly 
    save `daly', replace
    use "`datapath'\from-who\chap2_000_mr_adjusted", clear
    keep if ghecause == 46 & region==2000
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
    dis "MIGRAINE - Change between 2000 and 2019"
    noi list _varname v1, sep(6)
}



**-----------------------------------------------------------
** EPILEPSY (44)
** Percent Improvement
** Death excess (men vs women)
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_daly_adjusted", clear
    keep if ghecause == 44 & region==2000
    rename dalyr drate
    tempfile daly 
    save `daly', replace
    use "`datapath'\from-who\chap2_000_mr_adjusted", clear
    keep if ghecause == 44 & region==2000
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
    dis "EPILEPSY - Change between 2000 and 2019"
    noi list _varname v1, sep(6)
}



**-----------------------------------------------------------
** NON-MIGRAINE HEADACHE (47)
** Percent Improvement
** Death excess (men vs women)
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_daly_adjusted", clear
    keep if ghecause == 47 & region==2000
    rename dalyr drate
    tempfile daly 
    save `daly', replace
    use "`datapath'\from-who\chap2_000_mr_adjusted", clear
    keep if ghecause == 47 & region==2000
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
    dis "NON-MIGRAINE HEADACHE - Change between 2000 and 2019"
    noi list _varname v1, sep(6)
}



**-----------------------------------------------------------
** PARKINSON DISEASE (43)
** Percent Improvement
** Death excess (men vs women)
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_daly_adjusted", clear
    keep if ghecause == 43 & region==2000
    rename dalyr drate
    tempfile daly 
    save `daly', replace
    use "`datapath'\from-who\chap2_000_mr_adjusted", clear
    keep if ghecause == 43 & region==2000
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
    dis "PARKINSON DISEASE - Change between 2000 and 2019"
    noi list _varname v1, sep(6)
}

