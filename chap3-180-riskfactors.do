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
    local datapath "C:\yasuki\Sync\output\analyse-write\w003\data"

    ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    local logpath "C:\yasuki\Sync\output\analyse-write\w003\tech-docs"

    ** REPORTS and Other outputs
    local outputpath "C:\yasuki\Sync\output\analyse-write\w003\outputs"

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\chap3-160-mr-subregion", replace
** HEADER -----------------------------------------------------


** -----------------------------------------------------
** BMI from NCD-RisC
** -----------------------------------------------------

insheet using "`datapath'\from-ncdrisc\NCD_RisC_Lancet_2017_BMI_age_standardised_country.csv", comma clear names 
rename countryregionworld cname
rename iso iso3c 
rename prevalenceofbmi30kgmobesity bmi30
rename prevalenceofbmi35kgmsevereobesit bmi35 
rename prevalenceofbmi185kgmunderweight bmi185
rename prevalenceofbmi185kgmto20kgm bmi185_20
rename prevalenceofbmi20kgmto25kgm bmi20_25
rename prevalenceofbmi25kgmto30kgm bmi25_30
rename prevalenceofbmi30kgmto35kgm bmi30_35
rename prevalenceofbmi35kgmto40kgm bmi35_40
rename prevalenceofbmi40kgmmorbidobesit bmi40
keep cname iso3c sex year meanbmi bmi*

foreach var in bmi30 bmi35 bmi185 bmi185_20 bmi20_25 bmi25_30 bmi30_35 bmi35_40 bmi40 {
    replace `var' = `var' * 100
}

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

keep if paho_subregion<.
keep if year==2016
order paho_subregion, after(iso3c) 


** Broad subregions
gen subr = 2  
replace subr = 1 if paho_subregion==5 | paho_subregion==6
label define subr_ 1 "Caribbean" 2 "Rest of the Americas"
label values subr subr_

** Table
** 2-nov-2021
** These modelled estimates do not highlight Caribbean as having particularly extreme levels of Obesity
table paho_subregion sex, stat(mean bmi35_40) nformat(%9.1f)

