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
** aging-read-population.do
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
** aging-020-figure1.do
** --------------------------------
        ** Load population data --> paper1_population2
        ** Keep 1980, 2020, 2060
        ** Collapse to region and sub-regions
        ** Calculate proportions of population in broad age groups (0-19, 20-69, 70+)
        ** Calculate percentage point rise between years (2000 to 2020, and 2020 to 2060)
        ** Calculate some stats for Paper - Results section (Paragraph 2)
        ** Calculate percentage change 70+ between 1980 and 2020, and between 2020 and 2060.
        ** Construct dot matrix for graphic
        ** Plot graph --> Figure 1

** --------------------------------
** aging-030-figure2.do
** --------------------------------
        ** Load population data --> paper1_population2
        ** Keep 1980, 2020, 2060
        ** Collapse to region and sub-regions
        ** Calculate age-group percentages (0-19, 20-69, 70+)
        ** Keep women and men combined
        ** Create new alphabetical country codes
        ** Metrics for graphic (RHS table) --> dependency ratio in 2020 and in 2060
        ** Country order based on 2020 dependency ratio
        ** Calculate some statistics for Paper / Results / Paragraph 4
        ** Graph --> Equiplot

** --------------------------------
** aging-040-table1.do
** --------------------------------
        ** Load population data --> paper1_population2
        ** Keep 2000 and 2020. Keep Americas region. Create PAHO / WHO sub-regions
        ** Create age groups and proportions of population in each age group
        ** Article Table 1. Women and Men combined.
        ** Create new order for countries in Table (by subregions)
        ** Calculate growth rates
        ** Calculate statistics for paper / Results / Paragraph 3
        ** Construct Word Table -->  ncd_table1
        ** --> Repeat for Men only. In Supplement --> supplement-ncd-table-men
        ** --> Repeat for Women only. In Supplement --> supplement-ncd-table-women


** --------------------------------
** aging-050-table2.do
** --------------------------------
        ** Load ncd mortality data --> paper1_chap2_000_mr
        ** Load ncd DALY data --> paper1_chap2_000_daly
        ** Load ncd YLL data --> paper1_chap2_000_yll
        ** Load ncd YLD data --> paper1_chap2_000_yld
        ** Keep overall causes, Americas region, years 2000 and 2019
        ** Join the 4 datasets
        ** COLS 1 and 2 of Table are ROW HEADERS
        ** COL 3 --> Count of events in 2019 for women
        ** COL 4 --> Count of events in 2019 for men
        ** COL 5 --> Rates per 100,000 in 2019 for women
        ** COL 6 --> Rates per 100,000 in 2019 for men
        ** COL 7 --> Percent change in rates between 2000 and 2019 for women
        ** COL 8 --> Percent change in count between 2000 and 2019 for women
        ** COL 9 --> Percent change in rates between 2000 and 2019 for men
        ** COL 10 --> Percent change in count between 2000 and 2019 for men
        **
        ** Statistics for Results, Paragraph 5
        **
        ** Construct Word table --> ncd_table2_version3


** --------------------------------
** aging-060-figure3.do
** NO LONGER USED 
** SEE aging-070-figure3-and-uncertainty.do
** --------------------------------
        ** Load ncd mortality data --> paper1_chap2_000_mr
        ** Restrict to Combined group of 6 NCD groupings (CVD, cancer, respiratory, diabetes, mental health, neurological)
        ** Calculate: Percent change in deaths due to population growth 
        ** Calculate: Percent change in deaths due to population aging
        ** Calculate: Percent change in death overall (2000 - 2019)  
        ** Calculate: Remaining Percent change in death = due to epi causes (2000 - 2019)
        **
        ** Repeat process for DALYs


** --------------------------------
** aging-070-figure3-and-uncertainty.do
** --------------------------------
        ** Create NEW Figure 3 charts that now also incorporate an uncertainty panel
        ** Main figure uses decomposition point estimates
        ** LHS: decomposition panel
        ** RHS: UI panel for point estimate
        ** Save the result to a single page PDF
        **
        ** Repeat the process for 
                ** deaths lower UI bound
                ** deaths upper UI bound
                ** DALYs point estimate 
                ** DALYs lower UI bound
                ** DALYs upper UI bound
        ** So we end up with SIX (6) charts
        ** Two used in Main paper (point estimates for deaths and DALYs)
        ** All used in Supplement, along with accompanying Table of UI for overall percentage change in deaths/DALYs

** --------------------------------
** aging-070-figure3-supplement.do
** aging-070-figure3-supplement-sex-combined.do
** --------------------------------
        ** Repeats --> aging-060-figure3.do
        ** Stratified by WOMEN and MEN / Deaths and DALYs. Outputs (Figure + Table for each) located in supplement
        ** Women deaths
        ** Women DALYs
        ** Men deaths
        ** Men DALYs

** --------------------------------
** aging-080-country-reports.do
** --------------------------------
        ** Keep years 2000, 2020, 2040, 2060
        ** Collpase and create PAHO sub-regions and the overal region of the Americas
        ** Create age groups and percent population in each age group
        ** Alphabetical code for individual countries
        ** Second code for looping through countries by sub-region
        ** Table metrics
            ** TOTAL    : Population values as globals (pop)
            ** GROUP3   : 70+ population as globals (p70)
            ** PERC3    : 70+ percentage as globals (perc70)
            ** GR       : Growth rate (gr)
            ** GR3      : Growth rate in 70+ (gr3)
            ** DR3      : Old-age dependency ratio (dr3)
        **
        ** Graphic: Matrix of dots for percentage 70+
        **
        ** Individual Country Reports as loop


** --------------------------------
** aging-100-mortality.do
** --------------------------------

        ** PART 1. REGION-LEVEL MORTALITY. SEX-SPECIFIC
        ** Use  --> who-ghe-deaths-001-who2-allcauses
        ** Save --> death1 (was: paper1-chap3_byage_groups_malefemale)
        **          Number of deaths AND pop. By Sex. By Age. By GHE-Cause.
        ** Save --> mortalityrate1 (was paper1-chap2_000a_mr_region-groups)
        **          Adjusted rate. By Sex. By GHE-Cause. For Americas overall

        ** PART 2. REGION-LEVEL MORTALITY. SEX-COMBINED
        ** Use  --> who-ghe-deaths-001-who2-allcauses
        ** Save --> death2 (was: paper1-chap3_byage_groups_both)
        **          Number of deaths AND pop. By Age. By GHE-Cause.
        ** Save --> mortalityrate2 (was: paper1-chap2_000a_mr_region_groups_both)
        **          Adjusted rate. By GHE-Cause. For Americas overall

        ** Join the two rate files
        ** Save --> mortalityrate_12 (was: paper1-chap2_000_mr)
    
        ** PART 3. COUNTRY-LEVEL MORTALITY. SEX-SPECIFIC
        ** Use  --> who-ghe-deaths-001-who2-allcauses
        ** Save --> deaths3 (was: paper1-chap3_byage_country_groups_malefemale)
        **          Number of deaths AND pop.

        ** PART 4. COUNTRY-LEVEL MORTALITY. SEX-COMBINED
        ** Use  --> who-ghe-deaths-001-who2-allcauses
        ** Save --> deaths4 (was: paper1-chap3_byage_country_groups_both)
        **          Number of deaths AND pop.


** --------------------------------
** aging-200-daly.do
** --------------------------------

        ** PART 1. REGION-LEVEL DALY. SEX-SPECIFIC
        ** Use  --> who-ghe-daly-001-who2-allcauses
        ** Save --> daly1 (was: paper1-chap3_byage_groups_malefemale_daly)
        **          Number of dalys AND pop. By Sex. By Age. By GHE-Cause.
        ** Save --> dalyrate1 (was paper1-chap2_000e_daly_region_groups)
        **          Adjusted rate. By Sex. By GHE-Cause. For Americas overall

        ** PART 2. REGION-LEVEL DALY. SEX-COMBINED
        ** Use  --> who-ghe-daly-001-who2-allcauses
        ** Save --> daly2 (was: paper1-chap3_byage_groups_both_daly)
        **          Number of dalys AND pop. By Age. By GHE-Cause.
        ** Save --> dalyrate2 (was: paper1-chap2_000e_daly_region_groups_both)
        **          Adjusted rate. By GHE-Cause. For Americas overall

        ** Join the two rate files
        ** Save --> dalyrate_12 (was: paper1-chap2_000_daly)
    
        ** PART 3. COUNTRY-LEVEL DALY. SEX-SPECIFIC
        ** Use  --> who-ghe-daly-001-who2-allcauses
        ** Save --> daly3 (was: paper1-chap3_byage_country_groups_malefemale_daly)
        **          Number of deaths AND pop.

        ** PART 4. COUNTRY-LEVEL DALY. SEX-COMBINED
        ** Use  --> who-ghe-daly-001-who2-allcauses
        ** Save --> daly4 (was: paper1-chap3_byage_country_groups_both_daly)
        **          Number of deaths AND pop.


** --------------------------------
** aging-300-yld.do
** --------------------------------

        ** PART 1. REGION-LEVEL YLD. SEX-SPECIFIC
        ** Use  --> who-ghe-yld-001-who2-allcauses
        ** Save --> yld1 (was: chap3_byage_groups_malefemale)
        **          Number of ylds AND pop. By Sex. By Age. By GHE-Cause.
        ** Save --> yldrate1 (was chap2_000j_yld_region_groups)
        **          Adjusted rate. By Sex. By GHE-Cause. For Americas overall

        ** PART 2. REGION-LEVEL YLD. SEX-COMBINED
        ** Use  --> who-ghe-yld-001-who2-allcauses
        ** Save --> yld2 (was: paper1-chap3_byage_groups_both_yld)
        **          Number of ylds AND pop. By Age. By GHE-Cause.
        ** Save --> yldrate2 (was: chap2_000j_yld_region_groups_both)
        **          Adjusted rate. By GHE-Cause. For Americas overall

        ** Join the two rate files
        ** Save --> yldrate_12 (was: paper1-chap2_000_yld)
    
        ** PART 3. COUNTRY-LEVEL YLD. SEX-SPECIFIC

        ** PART 4. COUNTRY-LEVEL YLD. SEX-COMBINED
        ** Use  --> who-ghe-yld-001-who2-allcauses
        ** Save --> yld4 (was: paper1-chap3_byage_country_groups_both_yld)
        **          Number of deaths AND pop.

** --------------------------------
** aging-400-yll.do
** --------------------------------

        ** PART 1. REGION-LEVEL YLL. SEX-SPECIFIC
        ** Use  --> who-ghe-yll-001-who2-allcauses
        ** Save --> yllrate1 (was chap2_000p_yll_region_groups)
        **          Adjusted rate. By Sex. By GHE-Cause. For Americas overall

        ** PART 2. REGION-LEVEL YLL. SEX-COMBINED
        ** Use  --> who-ghe-yll-001-who2-allcauses
        ** Save --> yllrate2 (was: chap2_000p_yll_region_groups_both)
        **          Adjusted rate. By GHE-Cause. For Americas overall

        ** Join the two rate files
        ** Save --> yllrate_12 (was: paper1-chap2_000_yll)
    
        ** PART 3. COUNTRY-LEVEL YLL. SEX-SPECIFIC

        ** PART 4. COUNTRY-LEVEL YLL. SEX-COMBINED
        ** Use  --> who-ghe-yll-001-who2-allcauses
        ** Save --> yll4 (was: paper1-chap3_byage_country_groups_both_yll)
        **          Number of deaths AND pop.


** --------------------------------
** aging-500-mortality-daly-join.do
** --------------------------------
        ** Joins each mortality/daly count and mortality/daly rate file with lower and upper bounds
        ** Creates the following files
        **        \from-who\mortalityrate_12_ci
        **        \from-who\dalyrate_12_ci




** --------------------------------
** aging-600-mortality-uncertainty.do
** aging-600-mortality-uncertainty-women.do
** aging-600-mortality-uncertainty-men.do
** --------------------------------
        ** Load Mortality datasets created in ageing-100 (deaths) and aging-200 (DALYs) - see above for descriptions
        ** Restrict to the 6 combined NCD category
        ** Re-calculate the decomposition for THREE scenarios
                ** Point estimate
                ** Lower UI bound
                ** Upper UI bound
        ** Save the resulting decomposition in : decomposition_deaths.dta
        ** repeat for DALYs                    : decomposition_dalys.dta
        ** Join into a single decomposition dataset: decomposition.dta

