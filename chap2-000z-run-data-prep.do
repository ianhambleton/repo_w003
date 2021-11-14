** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap2-000z-run-data-prep.do
    //  project:				    WHO Global Health Estimates
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	19-August-2021
    //  algorithm task			    Final datasets for general use

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
    log using "`logpath'\chap2-000z-run-data-prep", replace
** HEADER -----------------------------------------------------

** Mortality Rate files
/// do "C:\Sync\OneDrive - The University of the West Indies\repo_ianhambleton\repo_w003\chap2-000a-mr-global-groups.do"
/// do "C:\Sync\OneDrive - The University of the West Indies\repo_ianhambleton\repo_w003\chap2-000a-mr-region-americas.do"
/// do "C:\Sync\OneDrive - The University of the West Indies\repo_ianhambleton\repo_w003\chap2-000a-mr-region-groups-worldbank.do"
/// do "C:\Sync\OneDrive - The University of the West Indies\repo_ianhambleton\repo_w003\chap2-000a-mr-region-groups.do"
/// do "C:\Sync\OneDrive - The University of the West Indies\repo_ianhambleton\repo_w003\chap2-000a-mr-region.do"
/// do "C:\Sync\OneDrive - The University of the West Indies\repo_ianhambleton\repo_w003\chap2-000b-mr-subregion-groups.do"
/// do "C:\Sync\OneDrive - The University of the West Indies\repo_ianhambleton\repo_w003\chap2-000b-mr-subregion.do"
/// do "C:\Sync\OneDrive - The University of the West Indies\repo_ianhambleton\repo_w003\chap2-000c-mr-country-groups.do"
/// do "C:\Sync\OneDrive - The University of the West Indies\repo_ianhambleton\repo_w003\chap2-000c-mr-country.do"
** Numbers of deaths files
/// "C:\Sync\OneDrive - The University of the West Indies\repo_ianhambleton\repo_w003\do chap2-000d-deaths-AFR.do"
/// "C:\Sync\OneDrive - The University of the West Indies\repo_ianhambleton\repo_w003\do chap2-000d-deaths-EMR.do"
/// "C:\Sync\OneDrive - The University of the West Indies\repo_ianhambleton\repo_w003\do chap2-000d-deaths-EUR.do"
/// "C:\Sync\OneDrive - The University of the West Indies\repo_ianhambleton\repo_w003\do chap2-000d-deaths-SEAR.do"
/// "C:\Sync\OneDrive - The University of the West Indies\repo_ianhambleton\repo_w003\do chap2-000d-deaths-WPR.do"
/// "C:\Sync\OneDrive - The University of the West Indies\repo_ianhambleton\repo_w003\do chap2-000d-deaths.do"
** Joining
/// "C:\Sync\OneDrive - The University of the West Indies\repo_ianhambleton\repo_w003\do chap2-000d-mr-join-wb.do"
/// "C:\Sync\OneDrive - The University of the West Indies\repo_ianhambleton\repo_w003\do chap2-000d-mr-join.do"

** DALY rate files
/// do "C:\Sync\OneDrive - The University of the West Indies\repo_ianhambleton\repo_w003\chap2-000e-daly-region-groups.do"
/// do "C:\Sync\OneDrive - The University of the West Indies\repo_ianhambleton\repo_w003\chap2-000e-daly-region.do"
do "C:\Sync\OneDrive - The University of the West Indies\repo_ianhambleton\repo_w003\chap2-000f-daly-subregion-groups.do"
do "C:\Sync\OneDrive - The University of the West Indies\repo_ianhambleton\repo_w003\chap2-000f-daly-subregion.do"
do "C:\Sync\OneDrive - The University of the West Indies\repo_ianhambleton\repo_w003\chap2-000g-daly-country-groups.do"
do "C:\Sync\OneDrive - The University of the West Indies\repo_ianhambleton\repo_w003\chap2-000g-daly-country.do"
** Numbers of deaths files
do "C:\Sync\OneDrive - The University of the West Indies\repo_ianhambleton\repo_w003\chap2-000h-daly-AFR.do"
do "C:\Sync\OneDrive - The University of the West Indies\repo_ianhambleton\repo_w003\chap2-000h-daly-EMR.do"
do "C:\Sync\OneDrive - The University of the West Indies\repo_ianhambleton\repo_w003\chap2-000h-daly-EUR.do"
do "C:\Sync\OneDrive - The University of the West Indies\repo_ianhambleton\repo_w003\chap2-000h-daly-SEAR.do"
do "C:\Sync\OneDrive - The University of the West Indies\repo_ianhambleton\repo_w003\chap2-000h-daly-WPR.do"
do "C:\Sync\OneDrive - The University of the West Indies\repo_ianhambleton\repo_w003\chap2-000h-daly.do"
** Joining
do "C:\Sync\OneDrive - The University of the West Indies\repo_ianhambleton\repo_w003\chap2-000h-daly-join.do"/// 
** Joining Morality and DALY files
do "C:\Sync\OneDrive - The University of the West Indies\repo_ianhambleton\repo_w003\chap2-000z-final-prep.do"
