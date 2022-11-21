** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    paper1-100-population.do
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
    local datapath "X:\OneDrive - The University of the West Indies\Writing\w003\data"

    ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    local logpath "X:\OneDrive - The University of the West Indies\Writing\w003\tech-docs"

    ** REPORTS and Other outputs
    local outputpath "X:\OneDrive - The University of the West Indies\Writing\w003\outputs"

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\paper1-100-population", replace
** HEADER -----------------------------------------------------



** PART 1
** POPULATON DATA

** --------------------------------
** paper1-110-population.do
** --------------------------------
        ** Data from UN WPP (2019). ESTIMATES UP TO 2020
        ** 1. Load Total population (women and men combined)
        ** 2. Link to ISO codes 
        ** 3. Keep 33 countries of the Americas
        ** 4. Save --> save "`datapath'/paper1_population2_both"
        **
        ** 5. Repeat for MEN only --> paper1_population2_men
        ** 6. Repeat for WOMEN only --> paper1_population2_women
        **
        ** 7. Repeat Women and Men for Medium Predictions (2020 to 2060) --> paper1_population2_both_pred
        ** 8. Repeat Men only for Medium Predictions (2020 to 2060) --> paper1_population2_men_pred
        ** 9. Repeat Women and Men for Medium Predictions (2020 to 2060) --> paper1_population2_women_pred
        **
        ** 10. Join the datasets --> paper1_population2

** --------------------------------
** paper1-100-population.do
** --------------------------------