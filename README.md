
## PART 3
## LIFE EXPECTANCY DATASET PREPARATION
## PREFIX: p004
---

### DO FILE: p004-life-global.do
### Load and prepare global lifetable dataset
> input dataset: 
> - lifetable-2019-global.csv  
> Downloaded from WHO GHO website (https://apps.who.int/gho/data/node.main.687?lang=en)
> Downloaded on: 15-Apr-2021


### DO FILE: p004-life-whoregions.do
### Load and prepare WHO regions lifetable datasets
> input dataset: 
> - lifetable-2019-<region>.csv (africa, americas, eastern-mediterranean, europe, south-east-asia, western pacific) 
> Downloaded from WHO GHO website (https://apps.who.int/gho/data/node.main.687?lang=en)
> Downloaded on: 15-Apr-2021


### DO FILE: p004-life-wbregions.do
### Load and prepare WB income groups lifetable datasets
> input dataset: 
> - lifetable-2019-<region>.csv (low-income, low-middle-income, upper-middle-income, high-income) 
> Downloaded from WHO GHO website (https://apps.who.int/gho/data/node.main.687?lang=en)
> Downloaded on: 15-Apr-2021


### DO FILE: p004-life-country.do
### Load and prepare country-level lifetable datasets for the Americas only
> input dataset: 
> - lifetable-2019-<country>.csv, where countries are:
> - antigua
> - argentina 
> - bahamas 
> - barbados
> - belize
> - bolivia
> - brazil
> - canada
> - chile
> - colombia
> - costarica
> - cuba
> - dominican republic
> - ecuador
> - el salvador
> - grenada
> - guatemala
> - guyana
> - haiti
> - honduras
> - jamaica
> - mexico
> - nicaragua
> - panama
> - paraguay
> - peru
> - st lucia
> - st vincent
> - suriname
> - trinidad
> - uruguay
> - usa 
 
> Downloaded from WHO GHO website (https://apps.who.int/gho/data/node.main.687?lang=en)
> Downloaded on: 15-Apr-2021



### DO FILE: p004-life-join.do
### Join the global, regional, and country-level life expectancy datasets
> input datasets: 
> - lifetable-2019-<country>.csv (Countries of the Americas)
> - lifetable-2019-<region>.csv (low-income, low-middle-income, upper-middle-income, high-income) 
> - lifetable-2019-<region>.csv (africa, americas, eastern-mediterranean, europe, south-east-asia, western pacific) 
> - lifetable-2019-global.csv  

The final LE dataset becomes
- americas-ex0.dta


## PART 4
## CHAPTER 1 
## PREFIX: chap1
---

### DO FILE: chap1-life-expectancy-001.do
### Creating choropleth maps of LE0 in 2000 and in 2019
> input datasets: 
> - americas-ex0-full.dta
> - Americas / Caribbean shapefiles from:
> - https://hub.arcgis.com/datasets/UIA::uia-world-countries-boundaries/explore?location=-2.688200%2C0.000000%2C1.54


### DO FILE: chap1-life-expectancy-002-all.do
### Panel Graphic of life expectancy (LE) and Healthy Life Expectancy (HALE) over time for EIGHT subregions of the Americas
> input dataset: 
> - who-lifetable-2019-all.dta
> - who-hale-2019-regions.dta
This graphic is not used. It combines graphs for LE/HALE at birth (top panel set) and LE/HALE at 60 years of age (lower panel set)


### DO FILE: chap1-life-expectancy-002-birth.do
### Panel Graphic of life expectancy (LE) and Healthy Life Expectancy (HALE) AT BIRTH over time for EIGHT subregions of the Americas
> input dataset: 
> - who-lifetable-2019-all.dta
> - who-hale-2019-regions.dta


### DO FILE: chap1-life-expectancy-002-elderly.do
### Panel Graphic of life expectancy (LE) and Healthy Life Expectancy (HALE) AT 60 YEARS over time for EIGHT subregions of the Americas
> input dataset: 
> - who-lifetable-2019-all.dta
> - who-hale-2019-regions.dta


### DO FILE: chap1-life-expectancy-003.do
### Creates most of the metrics we quote in the text associated with the LIFE EXPECTANCY SECTION
> input dataset: 
> - who-lifetable-2019-all.dta
> - who-hale-2019-regions.dta
> - who-ghe-deaths-americas.dta


### DO FILE: chap1-life-expectancy-004-subregions.do
### Panel Equiplot showing range of LE/HALE at birth within each subregion of the Americas.
> input dataset: 
> - who-lifetable-2019-all.dta
> - who-hale-2019-country.dta
This generates an associated discussion of LE/HALE range between countries of the Americas


### DO FILE: chap1-life-expectancy-005-ecological.do
### Panel regression plot - showing association of Health expenditure and health staffing with Life expectancy at birth (for 8 subregions)
> input dataset: 
> - who-lifetable-2019-all.dta
> - who-hale-2019-country.dta
> - Also external datasets:
> - health-expenditure-gho
> - who-ghe-deaths-001-americas
> - World Bank. Per capita GDP. NY.GDP.PCAP.CD
> - doctors-per-10000
> - nurses-per-10000
Brief and not-comprehensive regression work to highlight the role of economics in life expectancy. 


### DO FILE: chap1-mortality-groups-001.do
### Panel Area Chart - showing number of deaths by WHO region and by cause of death group (Communicable, NCDs, Injuries)
> input dataset: 
> - who-ghe-deaths-001-who1/who6 (The 6 WHO regions)


### DO FILE: chap1-mortality-groups-002.do
### Associated statistics for text - number of deaths by WHO region and by cause of death groups
> input dataset: 
> - who-ghe-deaths-001-who1/who6 (The 6 WHO regions)
This DO file produces all statistics associated with number of deaths by WHO region, and percentage of deaths due to three broad causes of death (Communicable, NCDs, Injuries).


### DO FILE: chap1-mortality-groups-003.do
### Panel Area Chart - showing percentage of deaths due to three causes of death (Comm, NCDs, Injury) in - broad age groups (young children, youth, young adults, older adults, the elderly). The Americas only.
> input dataset: 
> - who-ghe-deaths-001-who2 (The Americas only)
This DO file produces all statistics associated with number of deaths by WHO region, and percentage of deaths due to three broad causes of death (Communicable, NCDs, Injuries).



### DO FILE: chap1-mortrate-001.do
### The Americas only. PAHO-Subregions. Mortality Rate calculations
> input dataset: 
> - who-ghe-deaths-001-who2 (The Americas only)


### DO FILE: chap1-mortrate-002.do
### The Americas only. WHO-Regions. Mortality Rate calculations
> input dataset: 
> - who-ghe-deaths-001-who1/who6 


### DO FILE: chap1-mortrate-003.do
### All regions. Panel chart of Mortaity Rates
> input dataset: 
> - chap1_mortrate_001 and chap1_mortrate_002 
Panel chart of mortality rates

### DO FILE: chap1-mortrate-004.do
### Equiplot of Excess Mortality Rate
> input dataset: 
> - chap1_mortrate_001 and chap1_mortrate_002 
Equiplot of Excess Mortality Rates



## CHAPTER TWO

### DO FILE: chap2-cvd-001.do
### Calculate Mortality Rates for CVD: PAHO-Subregions
> input dataset: 
> - who-ghe-deaths-001-who2-allcauses
Equiplot of Excess Mortality Rates

### DO FILE: chap2-cvd-002.do
### Calculate Mortality Rates for CVD: WHO-Regions
> input dataset: 
> - who-ghe-deaths-001-who1/who6-allcauses
Equiplot of Excess Mortality Rates

### DO FILE: chap2-cvd-003.do
### Calculate Mortality Rates for CVD: PAHO-Countries
> input dataset: 
> - who-ghe-deaths-001-who2-allcauses
Equiplot of Excess Mortality Rates

### DO FILE: chap2-cvd-join.do
### Calculate Mortality Rates for CVD: JOIN FILES
> input dataset: 
> - chap2_cvd_001
> - chap2_cvd_002
> - chap2_cvd_003
Join the THREE Mortality Rate files

### DO FILE: chap2-cvd-004.do
### Calculate DALYs for CVD: Countries / Subregions / Regions
> input dataset: 
> - who-ghe-daly-001-who2-allcauses
Equiplot of Excess Mortality Rates

### DO FILE: chap2-cvd-005.do
### Calculate YLLs for CVD: Countries / Subregions / Regions
> input dataset: 
> - who-ghe-yll-001-who2-allcauses
Equiplot of Excess Mortality Rates

