
// This code analyses the price and volumes of Tumut 3, and of nsw prices. It was motivated to try to answer the question of Snowy 2.0's likely dispatch and profitability

* prepare data

clear all

import delimited "/Users/e5110130/Library/CloudStorage/GoogleDrive-bruce.mountain@cmeaustralia.com.au/Shared drives/VEPC/Stata/BM stata tools/Generation price demand analysis tool /Original data files /240604 tumut 3 analysis.csv", encoding(ISO-8859-1)

// Split out the year, month, day, hour, minute
gen Year = substr(settlementdate, 7,4)
gen Month = substr(settlementdate, 4,2)
gen Day = substr(settlementdate,1,2)
gen Hour = substr(settlementdate, 12,2)
gen Minute = substr(settlementdate,15,2)

//generate double eventtime=clock(settlementdate, "DM20Yhm") // create numeric value for time
gen id = _n
//gen num5mins = _N

destring, replace // convert date strings to numbers
gen residual_demand = nswregionaldemand - largescalesolar - wind

save "/Users/e5110130/Library/CloudStorage/GoogleDrive-bruce.mountain@cmeaustralia.com.au/Shared drives/VEPC/Stata/BM stata tools/Generation price demand analysis tool /Dta files/240604 tumut 3 analysis.dta", replace


*** DESCRIPTIVE STUFF

//hourly pumping profile
clear all
use "/Users/e5110130/Library/CloudStorage/GoogleDrive-bruce.mountain@cmeaustralia.com.au/Shared drives/VEPC/Stata/BM stata tools/Generation price demand analysis tool /Dta files/240604 tumut 3 analysis.dta", replace
collapse tumut3pumpsloadsnowyp, by(Year Hour)

//hourly production profile
clear all
use "/Users/e5110130/Library/CloudStorage/GoogleDrive-bruce.mountain@cmeaustralia.com.au/Shared drives/VEPC/Stata/BM stata tools/Generation price demand analysis tool /Dta files/240604 tumut 3 analysis.dta", replace
collapse tumut3powerstationtumut3, by(Year Hour)

//hourly production profile in 2024
clear all
use "/Users/e5110130/Library/CloudStorage/GoogleDrive-bruce.mountain@cmeaustralia.com.au/Shared drives/VEPC/Stata/BM stata tools/Generation price demand analysis tool /Dta files/240604 tumut 3 analysis.dta", replace
keep if Year == 2024
collapse tumut3powerstationtumut3 wind hydro largescalesolar blackcoal naturalgasocgt smallscalesolar batterystorage naturalgasccgt nswmeteredflow, by(Hour)

*various 5-minute prices collapses by hour

clear all
use "/Users/e5110130/Library/CloudStorage/GoogleDrive-bruce.mountain@cmeaustralia.com.au/Shared drives/VEPC/Stata/BM stata tools/Generation price demand analysis tool /Dta files/240604 tumut 3 analysis.dta", replace
keep if Year >= 2024
collapse (p5) nswpricemwh, by(Hour)

clear all
use "/Users/e5110130/Library/CloudStorage/GoogleDrive-bruce.mountain@cmeaustralia.com.au/Shared drives/VEPC/Stata/BM stata tools/Generation price demand analysis tool /Dta files/240604 tumut 3 analysis.dta", replace
keep if Year >= 2024
collapse (p25) nswpricemwh, by(Hour)

clear all
use "/Users/e5110130/Library/CloudStorage/GoogleDrive-bruce.mountain@cmeaustralia.com.au/Shared drives/VEPC/Stata/BM stata tools/Generation price demand analysis tool /Dta files/240604 tumut 3 analysis.dta", replace
keep if Year >= 2024
collapse (p50) nswpricemwh, by(Hour)

clear all
use "/Users/e5110130/Library/CloudStorage/GoogleDrive-bruce.mountain@cmeaustralia.com.au/Shared drives/VEPC/Stata/BM stata tools/Generation price demand analysis tool /Dta files/240604 tumut 3 analysis.dta", replace
keep if Year >= 2024
collapse nswpricemwh, by(Hour)

clear all
use "/Users/e5110130/Library/CloudStorage/GoogleDrive-bruce.mountain@cmeaustralia.com.au/Shared drives/VEPC/Stata/BM stata tools/Generation price demand analysis tool /Dta files/240604 tumut 3 analysis.dta", replace
keep if Year >= 2024
collapse (p75) nswpricemwh, by(Hour)

clear all
use "/Users/e5110130/Library/CloudStorage/GoogleDrive-bruce.mountain@cmeaustralia.com.au/Shared drives/VEPC/Stata/BM stata tools/Generation price demand analysis tool /Dta files/240604 tumut 3 analysis.dta", replace
keep if Year >= 2024
collapse (p95) nswpricemwh, by(Hour)

*analysis of average daily pump and generation prices 

	clear all
	use "/Users/e5110130/Library/CloudStorage/GoogleDrive-bruce.mountain@cmeaustralia.com.au/Shared drives/VEPC/Stata/BM stata tools/Generation price demand analysis tool /Dta files/240604 tumut 3 analysis.dta", replace
	keep if Year >= 2023
	bysort Year Month Day Hour: gen hourly_price = sum(nswpricemwh)/12
	keep if  Minute ==55
	//bysort Year Month Day: gen gen_hourly_price = sum(hourly_price)/8 if Hour >= 6 & Hour <9|Hour >=17 & Hour<22
	bysort Year Month Day: gen gen_hourly_price = sum(hourly_price)/5 if Hour >=17 & Hour<22
	keep if Hour ==21 & Minute==55
	sum(gen_hourly_price), detail 

clear all
use "/Users/e5110130/Library/CloudStorage/GoogleDrive-bruce.mountain@cmeaustralia.com.au/Shared drives/VEPC/Stata/BM stata tools/Generation price demand analysis tool /Dta files/240604 tumut 3 analysis.dta", replace
keep if Year >= 2023
bysort Year Month Day Hour: gen hourly_price = sum(nswpricemwh)/12
keep if  Minute ==55
//bysort Year Month Day: gen pump_hourly_price = sum(hourly_price)/16 if Hour != 6 & Hour != 7 & Hour !=8 & Hour !=17 & Hour !=18 & Hour !=19 & Hour !=20 & Hour !=21
bysort Year Month Day: gen pump_hourly_price = sum(hourly_price)/6 if Hour >= 10 & Hour <= 16

//keep if Hour ==21 & Minute==55
keep if Hour ==15 & Minute==55

sum(pump_hourly_price), detail


* production collapse

clear all
use "/Users/e5110130/Library/CloudStorage/GoogleDrive-bruce.mountain@cmeaustralia.com.au/Shared drives/VEPC/Stata/BM stata tools/Generation price demand analysis tool /Dta files/240604 tumut 3 analysis.dta", replace
keep if Year == 2024
collapse tumut3powerstationtumut3 wind hydro largescalesolar blackcoal naturalgasocgt smallscalesolar batterystorage naturalgasccgt nswmeteredflow, by(Hour)


*pairwise correlations

clear all
use "/Users/e5110130/Library/CloudStorage/GoogleDrive-bruce.mountain@cmeaustralia.com.au/Shared drives/VEPC/Stata/BM stata tools/Generation price demand analysis tool /Dta files/240604 tumut 3 analysis.dta", replace
keep if Year == 2023
pwcorr tumut3powerstationtumut3  hydro  blackcoal naturalgasocgt  naturalgasccgt nswmeteredflow nswpricemwh

//hourly correlations
bysort Year Month Day Hour: gen hourly_price = sum(nswpricemwh)/12
bysort Year Month Day Hour: gen hourly_ocgt = sum(naturalgasocgt)/12
bysort Year Month Day Hour: gen hourly_hydro = sum(hydro)/12
bysort Year Month Day Hour: gen hourly_tumut3powerstationtumut3 = sum(tumut3powerstationtumut3)/12
pwcorr hourly_tumut3powerstationtumut3 hourly_price hourly_ocgt hourly_hydro 



* hourly price profile in 2023
clear all
use "/Users/e5110130/Library/CloudStorage/GoogleDrive-bruce.mountain@cmeaustralia.com.au/Shared drives/VEPC/Stata/BM stata tools/Generation price demand analysis tool /Dta files/240604 tumut 3 analysis.dta", replace
keep if Year == 2023
keep if Hour >=17 & Hour<= 21
histogram nswpricemwh, bin(30) frequency
bysort Month Day Hour: egen h1= total(nswpricemwh) if Minute>=0 & Minute<=25
bysort Month Day Hour: egen h2 = total(nswpricemwh) if Minute>=30 & Minute<=55
keep if Minute ==0 | Minute == 30
gen hh= h1/6 if Minute ==0 
replace hh= h2/6 if Minute ==30
drop if hh>500 | hh<=0
histogram hh
histogram hh, fraction normal xtitle(Half-hourly prices ($/MWh) between 5pm and 9pm in 2023)
(bin=35, start=5.4183335, width=13.892809)
 dotplot hh

clear all
use "/Users/e5110130/Library/CloudStorage/GoogleDrive-bruce.mountain@cmeaustralia.com.au/Shared drives/VEPC/Stata/BM stata tools/Generation price demand analysis tool /Dta files/240604 tumut 3 analysis.dta", replace
keep if Year == 2023
keep if Hour >=7 & Hour<= 17
bysort Month Day Hour: egen h1= total(nswpricemwh) if Minute>=0 & Minute<=25
bysort Month Day Hour: egen h2 = total(nswpricemwh) if Minute>=30 & Minute<=55
keep if Minute ==0 | Minute == 30
gen hh= h1/6 if Minute ==0 
replace hh= h2/6 if Minute ==30
drop if hh>500 | hh<=-100
histogram hh
histogram hh, fraction normal xtitle(Half-hourly prices ($/MWh) between 7am and 5pm in 2023)
(bin=25, start=5.4183335, width=13.892809)
 dotplot hh

* vwap when charging, by day in 2023

clear all
use "/Users/e5110130/Library/CloudStorage/GoogleDrive-bruce.mountain@cmeaustralia.com.au/Shared drives/VEPC/Stata/BM stata tools/Generation price demand analysis tool /Dta files/240604 tumut 3 analysis.dta", replace
keep if Year == 2023
gen charging_dollars = nswpricemwh * tumut3pumpsloadsnowyp/12
bysort Year Month Day: gen vwap_charging = sum(charging_dollars)*12 / sum(tumut3pumpsloadsnowyp)
keep if Hour==23 & Minute==55
histogram vwap_charging, frequency xtitle(Frequency of daily volume weighted average price ($/MWh) paid to charge  in 2023)


* vwap when generating, by day in 2023

clear all
use "/Users/e5110130/Library/CloudStorage/GoogleDrive-bruce.mountain@cmeaustralia.com.au/Shared drives/VEPC/Stata/BM stata tools/Generation price demand analysis tool /Dta files/240604 tumut 3 analysis.dta", replace
keep if Year == 2023
gen charging_dollars = nswpricemwh * tumut3powerstationtumut3/12
bysort Year Month Day: gen vwap_charging = sum(charging_dollars)*12 / sum(tumut3pumpsloadsnowyp)
keep if Hour==23 & Minute==55
histogram vwap_charging, frequency xtitle(Daily wolume weighted average price paid when generating ($/MWh) in 2023)


* annual vwap when charging

clear all
use "/Users/e5110130/Library/CloudStorage/GoogleDrive-bruce.mountain@cmeaustralia.com.au/Shared drives/VEPC/Stata/BM stata tools/Generation price demand analysis tool /Dta files/240604 tumut 3 analysis.dta", replace
//keep if Year == 2023
bysort Year: gen cum_pump = sum(tumut3pumpsloadsnowyp)
gen charging_dollars = nswpricemwh * tumut3pumpsloadsnowyp
bysort Year: gen cum_dollars = sum(charging_dollars)
bysort Year: gen vwap_charging = cum_dollars / cum_pump
keep if Month==12 & Day==31 & Hour ==23 & Minute ==55
bysort Year: sum(cum_dollars cum_pump vwap_charging)

* annual vwap when generating

clear all
use "/Users/e5110130/Library/CloudStorage/GoogleDrive-bruce.mountain@cmeaustralia.com.au/Shared drives/VEPC/Stata/BM stata tools/Generation price demand analysis tool /Dta files/240604 tumut 3 analysis.dta", replace
//keep if Year == 2024
drop if nswpricemwh>1000
bysort Year: gen cum_gen = sum(tumut3powerstationtumut3)
gen gen_dollars = nswpricemwh * tumut3powerstationtumut3
bysort Year: gen cum_gen_dollars = sum(gen_dollars)
bysort Year: gen vwap_gen = cum_gen_dollars / cum_gen
keep if Month==12 & Day==31 & Hour ==23 & Minute ==55
bysort Year: sum(cum_gen_dollars cum_gen vwap_gen)

* proportion of production in price bands in 2023

clear all
use "/Users/e5110130/Library/CloudStorage/GoogleDrive-bruce.mountain@cmeaustralia.com.au/Shared drives/VEPC/Stata/BM stata tools/Generation price demand analysis tool /Dta files/240604 tumut 3 analysis.dta", replace
keep if Year == 2024
//sort nswpricemwh
//gen counting_id = _n

gen count_gen = 1 if tumut3powerstationtumut3>0
egen total_gen = total(tumut3powerstationtumut3)

gen count_minus50 = 1 if nswpricemwh<-50
egen time_minus50 = total(count_minus50)
egen prod_minus50 = total(tumut3powerstationtumut3) if nswpricemwh<-50

gen count_minus50_to_0 = 1 if nswpricemwh>=-50 & nswpricemwh<0
egen time_minus50_to_0 = total(count_minus50_to_0) 
egen prod_minus50_to_0 = total(tumut3powerstationtumut3) if nswpricemwh>=-50 & nswpricemwh<0

gen count_0_to_50 = 1 if nswpricemwh>=0 & nswpricemwh<50
egen time_0_to_50 = total(count_0_to_50) 
egen prod_0_to_50 = total(tumut3powerstationtumut3) if nswpricemwh>=0 & nswpricemwh<50

gen count_50_to_100 = 1 if nswpricemwh>=50 & nswpricemwh<100
egen time_50_to_100 = total(count_50_to_100) 
egen prod_50_to_100 = total(tumut3powerstationtumut3) if nswpricemwh>=50 & nswpricemwh<100

gen count_100_to_150 = 1 if nswpricemwh>=100 & nswpricemwh<150
egen time_100_to_150 = total(count_100_to_150) 
egen prod_100_to_150 = total(tumut3powerstationtumut3) if nswpricemwh>=100 & nswpricemwh<150

gen count_150_to_200 = 1 if nswpricemwh>=150 & nswpricemwh<200
egen time_150_to_200 = total(count_150_to_200) 
egen prod_150_to_200 = total(tumut3powerstationtumut3) if nswpricemwh>=150 & nswpricemwh<200

gen count_200_to_250 = 1 if nswpricemwh>=200 & nswpricemwh<250
egen time_200_to_250 = total(count_200_to_250) 
egen prod_200_to_250 = total(tumut3powerstationtumut3) if nswpricemwh>=200 &nswpricemwh<250

gen count_250_to_300 = 1 if nswpricemwh>=250 & nswpricemwh<300
egen time_250_to_300 = total(count_250_to_300) 
egen prod_250_to_300 = total(tumut3powerstationtumut3) if nswpricemwh>=250 & nswpricemwh<300

gen count_300_to_350 = 1 if nswpricemwh>=300 & nswpricemwh<350
egen time_300_to_350 = total(count_300_to_350) 
egen prod_300_to_350 = total(tumut3powerstationtumut3) if nswpricemwh>=300 & nswpricemwh<350

gen count_350_to_400 = 1 if nswpricemwh>=350 & nswpricemwh<400
egen time_350_to_400 = total(count_350_to_400) 
egen prod_350_to_400 = total(tumut3powerstationtumut3) if nswpricemwh>=350 & nswpricemwh<400

gen count_400plus = 1 if nswpricemwh>=400 
egen time_400plus = total(count_400plus) 
egen prod_400plus = total(tumut3powerstationtumut3)if nswpricemwh>=400 


//sum(time_minus50 time_0_to_50 time_50_to_100 time_100_to_150 time_150_to_200 time_200_to_250 time_250_to_300 time_300_to_350 time_350_to_400 time_400plus) 

sum(prod_minus50 prod_minus50_to_0 prod_0_to_50 prod_50_to_100 prod_100_to_150 prod_150_to_200 prod_200_to_250 prod_250_to_300 prod_300_to_350 prod_350_to_400 prod_400plus)


* segment analysis of  production for different levels of hydro, tumut3 and gas dispatch in NSW in 2023, 2024 or 2023+2024

clear all
use "/Users/e5110130/Library/CloudStorage/GoogleDrive-bruce.mountain@cmeaustralia.com.au/Shared drives/VEPC/Stata/BM stata tools/Generation price demand analysis tool /Dta files/240604 tumut 3 analysis.dta", replace
//keep if Year == 2023
//keep if Year == 2024
keep if Year >= 2023 

sum nswpricemwh residual_demand nswregionaldemand blackcoal  naturalgasccgt hydro tumut3powerstationtumut3 naturalgasocgt colongrapowerstationcg1cg2cg3cg4 uranquintypowerstationuranq11ura

mean nswpricemwh residual_demand nswregionaldemand blackcoal  naturalgasccgt hydro tumut3powerstationtumut3 naturalgasocgt colongrapowerstationcg1cg2cg3cg4 uranquintypowerstationuranq11ura
mean nswpricemwh residual_demand nswregionaldemand blackcoal  naturalgasccgt hydro tumut3powerstationtumut3 naturalgasocgt colongrapowerstationcg1cg2cg3cg4 uranquintypowerstationuranq11ura  if hydro+naturalgasocgt<=0
mean nswpricemwh residual_demand nswregionaldemand blackcoal  naturalgasccgt hydro tumut3powerstationtumut3 naturalgasocgt colongrapowerstationcg1cg2cg3cg4 uranquintypowerstationuranq11ura if hydro+naturalgasocgt>=0 & hydro+naturalgasocgt <=200
mean nswpricemwh residual_demand nswregionaldemand blackcoal  naturalgasccgt hydro tumut3powerstationtumut3 naturalgasocgt colongrapowerstationcg1cg2cg3cg4 uranquintypowerstationuranq11ura if hydro+naturalgasocgt>200 & hydro+naturalgasocgt<=600
mean nswpricemwh residual_demand nswregionaldemand blackcoal  naturalgasccgt hydro tumut3powerstationtumut3 naturalgasocgt colongrapowerstationcg1cg2cg3cg4 uranquintypowerstationuranq11ura if hydro+naturalgasocgt>600 & hydro+naturalgasocgt<=1000
mean nswpricemwh residual_demand nswregionaldemand blackcoal  naturalgasccgt hydro tumut3powerstationtumut3 naturalgasocgt colongrapowerstationcg1cg2cg3cg4 uranquintypowerstationuranq11ura if hydro+naturalgasocgt>1000 & hydro+naturalgasocgt<=1400
mean nswpricemwh residual_demand nswregionaldemand blackcoal  naturalgasccgt hydro tumut3powerstationtumut3 naturalgasocgt colongrapowerstationcg1cg2cg3cg4 uranquintypowerstationuranq11ura if hydro+naturalgasocgt>1400 & hydro+naturalgasocgt<=1800
mean nswpricemwh residual_demand nswregionaldemand blackcoal  naturalgasccgt hydro tumut3powerstationtumut3 naturalgasocgt colongrapowerstationcg1cg2cg3cg4 uranquintypowerstationuranq11ura if hydro+naturalgasocgt>1800 & hydro+naturalgasocgt<=2200
mean nswpricemwh residual_demand nswregionaldemand blackcoal  naturalgasccgt hydro tumut3powerstationtumut3 naturalgasocgt colongrapowerstationcg1cg2cg3cg4 uranquintypowerstationuranq11ura if hydro+naturalgasocgt>2200 & hydro+naturalgasocgt<=2600
mean nswpricemwh residual_demand nswregionaldemand blackcoal  naturalgasccgt hydro tumut3powerstationtumut3 naturalgasocgt colongrapowerstationcg1cg2cg3cg4 uranquintypowerstationuranq11ura if hydro+naturalgasocgt >2600

* volumes by year
clear all
use "/Users/e5110130/Library/CloudStorage/GoogleDrive-bruce.mountain@cmeaustralia.com.au/Shared drives/VEPC/Stata/BM stata tools/Generation price demand analysis tool /Dta files/240604 tumut 3 analysis.dta", replace

tabulate Year, sum(tumut3pumpsloadsnowyp)
tabulate Year, sum(tumut3powerstationtumut3)  

gen nonzero_tumut3pumpsloadsnowyp = tumut3pumpsloadsnowyp if tumut3pumpsloadsnowyp !=0
gen nonzero_tumut3powerstationtumut3 = tumut3powerstationtumut3 if tumut3powerstationtumut3 !=0
tabulate Year, summarize(nonzero_tumut3pumpsloadsnowyp) mean
tabulate Year, summarize(nonzero_tumut3powerstationtumut3) mean

histogram nonzero_tumut3pumpsloadsnowyp
histogram nonzero_tumut3powerstationtumut3

//drop if Year==2022
//histogram nonzero_tumut3powerstationtumut3

egen total_pump = total(tumut3pumpsloadsnowyp), by(Year)
egen total_gen = total(tumut3powerstationtumut3), by(Year)
tabulate Year, sum(total_pump)

tabulate Year, sum(total_gen) 

*** CORE ANALYSIS

*  segment into quartlies based on t3 daily income and analyse income production and price, for 2023 and 2024 

clear all
use "/Users/e5110130/Library/CloudStorage/GoogleDrive-bruce.mountain@cmeaustralia.com.au/Shared drives/VEPC/Stata/BM stata tools/Generation price demand analysis tool /Dta files/240604 tumut 3 analysis.dta", replace

keep if Year ==2024 // choose one or more years to analyse

bysort Year Month Day: gen daily_tumut3_gen = sum(tumut3powerstationtumut3)/12 
bysort Year Month Day: gen daily_gas_gen = sum(naturalgasocgt)/12 
bysort Year Month Day: gen daily_hydro_gen = sum(hydro)/12
bysort Year Month Day: gen daily_peaking_gen = sum(naturalgasocgt+ hydro +tumut3powerstationtumut3)/12 
gen t3income = tumut3powerstationtumut3*nswpricemwh/12
bysort Year Month Day: gen daily_t3income = sum(t3income)
gen daily_t3avgprice = daily_t3income/daily_tumut3_gen

keep if Hour ==23 & Minute==55 //to get a single total per day

xtile quart = daily_t3income, nq(4) //quartiles based on t3 income

gen t3incomeq1 = sum(daily_t3income) if quart==1
gen t3incomeq2 = sum(daily_t3income) if quart==2
gen t3incomeq3 = sum(daily_t3income) if quart==3
gen t3incomeq4 = sum(daily_t3income) if quart==4

gen t3genq1 = sum(daily_tumut3_gen) if quart==1
gen t3genq2 = sum(daily_tumut3_gen) if quart==2
gen t3genq3 = sum(daily_tumut3_gen) if quart==3
gen t3qenq4 = sum(daily_tumut3_gen) if quart==4

gen t3avgpriceq1 = t3incomeq1/t3genq1
gen t3avgpriceq2 = t3incomeq2/t3genq2
gen t3avgpriceq3 = t3incomeq3/t3genq3
gen t3avgpriceq4 = t3incomeq4/t3qenq4

gen peakgenq1 = sum(daily_peaking_gen) if quart==1
gen peakgenq2 = sum(daily_peaking_gen) if quart==2
gen peakgenq3 = sum(daily_peaking_gen) if quart==3
gen peakgenq4 = sum(daily_peaking_gen) if quart==4

summarize(t3incomeq1 t3incomeq2 t3incomeq3 t3incomeq4 t3genq1 t3genq2 t3genq3 t3qenq4 peakgenq1 peakgenq2 peakgenq3 peakgenq4 t3avgpriceq1 t3avgpriceq2 t3avgpriceq3 t3avgpriceq4)

*  then analyse daily t3 pumping based on the segments determined based on production for 2023 and 2024

clear all
use "/Users/e5110130/Library/CloudStorage/GoogleDrive-bruce.mountain@cmeaustralia.com.au/Shared drives/VEPC/Stata/BM stata tools/Generation price demand analysis tool /Dta files/240604 tumut 3 analysis.dta", replace

keep if Year == 2024 //covers 2023 and or 2024

gen t3cost = tumut3pumpsloadsnowyp*nswpricemwh/12
bysort Year Month Day: gen daily_tumut3_pump = sum(tumut3pumpsloadsnowyp)/12 
bysort Year Month Day: gen daily_t3cost = sum(t3cost)
gen daily_t3avgpumpprice = daily_t3cost/daily_tumut3_pump

gen t3income = tumut3powerstationtumut3*nswpricemwh/12
bysort Year Month Day: gen daily_t3income = sum(t3income)

keep if Hour ==23 & Minute==55 //to get a single total per day

xtile quart = daily_t3income, nq(4) //quartiles based on t3 income

gen t3costq1 = sum(daily_t3cost) if quart==1
gen t3costq2 = sum(daily_t3cost) if quart==2
gen t3costq3 = sum(daily_t3cost) if quart==3
gen t3costq4 = sum(daily_t3cost) if quart==4

gen t3pumpq1 = sum(daily_tumut3_pump) if quart==1 //add up the hourly MWs 
gen t3pumpq2 = sum(daily_tumut3_pump) if quart==2
gen t3pumpq3 = sum(daily_tumut3_pump) if quart==3
gen t3pumpq4 = sum(daily_tumut3_pump) if quart==4

gen t3avgpumppriceq1 = t3costq1/t3pumpq1
gen t3avgpumppriceq2 = t3costq2/t3pumpq2
gen t3avgpumppriceq3 = t3costq3/t3pumpq3
gen t3avgpumppriceq4 = t3costq4/t3pumpq4

summarize(t3costq1 t3costq2 t3costq3 t3costq4 t3pumpq1 t3pumpq2 t3pumpq3 t3pumpq4 t3avgpumppriceq1 t3avgpumppriceq2 t3avgpumppriceq3 t3avgpumppriceq4)



* investigate  prices when different generators are at the margin in 2023, 2024 or 2023 & 2024

clear all
use "/Users/e5110130/Library/CloudStorage/GoogleDrive-bruce.mountain@cmeaustralia.com.au/Shared drives/VEPC/Stata/BM stata tools/Generation price demand analysis tool /Dta files/240604 tumut 3 analysis.dta", replace
//keep if Year == 2023
//keep if Year == 2024
keep if Year >= 2023

gen peakinggen = naturalgasocgt+ hydro +tumut3powerstationtumut3

//keep if nswpricemwh<500 & nswpricemwh>0

sum blackcoal hydro tumut3powerstationtumut3 naturalgasocgt nswpricemwh if  peakinggen <= 0 
sum blackcoal hydro tumut3powerstationtumut3 naturalgasocgt nswpricemwh if  hydro>0 & tumut3powerstationtumut3==0 & naturalgasocgt ==0 
sum blackcoal hydro tumut3powerstationtumut3 naturalgasocgt nswpricemwh nswregionaldemand if  tumut3powerstationtumut3>0 & naturalgasocgt==0 
sum blackcoal hydro tumut3powerstationtumut3 naturalgasocgt colongrapowerstationcg1cg2cg3cg4 uranquintypowerstationuranq11ura nswpricemwh nswregionaldemand if  naturalgasocgt>0 


// OTHER ANALYSIS 
 
*above and below hydo average segmental analysis of Tumut3 production and charging considering hydro production and price in 2023

clear all
use "/Users/e5110130/Library/CloudStorage/GoogleDrive-bruce.mountain@cmeaustralia.com.au/Shared drives/VEPC/Stata/BM stata tools/Generation price demand analysis tool /Dta files/240604 tumut 3 analysis.dta", replace
keep if Year == 2023

//first, segment production on either side of the mean daily production from hydro 

bysort Year Month Day: gen daily_tumut3 = sum(tumut3powerstationtumut3)/12 if Hour>=16 & Hour<21 //mwh that tumut3 produced between 4pm and 9pm
bysort Year Month Day: gen daily_nswpricemwh = sum(nswpricemwh)/12/5 if Hour>=16 & Hour<21 //average price during those 5 hours
bysort Year Month Day: gen daily_hydro = sum(hydro)/12 if Hour>=16 & Hour<21 //mwh that hydro produced

keep if Hour ==20 & Minute ==55
sum(daily_hydro), detail  
gen avg_hydro = 3928

//do sums for segment when hydro is less than average per day

gen low_tumut3= daily_tumut3 if daily_hydro<avg_hydro //daily tumut3 mwh when hydro produces less than the daily average between 4pm and 9pm
gen low_price = daily_nswpricemwh if daily_hydro<avg_hydro  //daily average price on days when hydro produces less than daily average between 4pm and 9pm
gen low_hydro = daily_hydro if daily_hydro<avg_hydro 
sum(low_tumut3 low_hydro low_price)
histogram low_tumut3, frequency ytitle(Number of days) xtitle(MWh) title(Tumut 3 daily gen (4pm to 9pm) on days when NSW hydro between 4pm and 9pm is less than average, size(small) ring(0))
drop if low_price>300
histogram low_price, frequency ytitle(Number of days) xtitle($/MWh) title(Average spot price (4pm to 9pm) on days when NSW hydro between 4pm and 9pm is less than average, size(small) ring(0))


//do sums for segment when hydro is more than average per day

clear all
use "/Users/e5110130/Library/CloudStorage/GoogleDrive-bruce.mountain@cmeaustralia.com.au/Shared drives/VEPC/Stata/BM stata tools/Generation price demand analysis tool /Dta files/240604 tumut 3 analysis.dta", replace
keep if Year == 2023

bysort Year Month Day: gen daily_tumut3 = sum(tumut3powerstationtumut3)/12 if Hour>=16 & Hour<21 //mwh that tumut3 produced between 4pm and 9pm
bysort Year Month Day: gen daily_nswpricemwh = sum(nswpricemwh)/12/5 if Hour>=16 & Hour<21 //average price during those 5 hours
bysort Year Month Day: gen daily_hydro = sum(hydro)/12 if Hour>=16 & Hour<21 //mwh that hydro produced

keep if Hour ==20 & Minute ==55 // this gives the total
sum(daily_hydro), detail  
gen avg_hydro = 3928

gen high_tumut3= daily_tumut3/5 if daily_hydro >= avg_hydro //daily tumut3 mwh when hydro produces more than the daily average
gen high_price = daily_nswpricemwh if daily_hydro>=avg_hydro //daily average price mwh when hydro produces more than the daily average
gen high_hydro = daily_hydro/5 if daily_hydro>=avg_hydro 
sum(high_tumut3 high_hydro high_price)
histogram high_tumut3, frequency ytitle(Number of days) xtitle(MWh) title(Tumut 3 daily gen (4pm to 9pm) on days when NSW hydro between 4pm and 9pm is more than average, size(small) ring(0))
drop if high_price>400
histogram high_price, frequency ytitle(Number of days) xtitle($/MWh) title(Average spot price (4pm to 9pm) on days when NSW hydro between 4pm and 9pm is more than average, size(small) ring(0))
 
 
//prepare and export data for revenue duration curve analysis in excel

sort Year nonzero_generating_dollars
export delimited Year nonzero_generating_dollars nswpricemwh tumut3powerstationtumut3 using "/Users/e5110130/Library/CloudStorage/GoogleDrive-bruce.mountain@cmeaustralia.com.au/Shared drives/VEPC/Stata/BM stata tools/Generation price demand analysis tool /Excel Results files/240723 tumut 3 results", replace

*  look at the price and charging on low and high days (in the 16 hours before the generating period) in 2023

clear all
use "/Users/e5110130/Library/CloudStorage/GoogleDrive-bruce.mountain@cmeaustralia.com.au/Shared drives/VEPC/Stata/BM stata tools/Generation price demand analysis tool /Dta files/240604 tumut 3 analysis.dta", replace
keep if Year == 2023

bysort Year Month Day: gen daily_hydro = sum(hydro)/12 //mwh that hydro produced

bysort Year Month Day: gen daily_tumut3_pump = sum(tumut3powerstationtumut3)/12 if Hour<16 & Hour>=0 //MWh that tumut3 pumped
bysort Year Month Day: gen daily_nswpricemwh_pump = sum(nswpricemwh)/12/15 if Hour<16 & Hour>=0 //average price during those 16 hours

keep if Hour ==15 & Minute==55 //to get a single value per day

gen low_tumut3_pump= daily_tumut3_pump if daily_hydro<avg_hydro
gen low_price_pumping = daily_nswpricemwh_pump if daily_hydro<avg_hydro
sum(low_tumut3_pump low_price_pumping)

histogram low_price_pumping, percent xtitle(Average hourly price ($/MWh) between 0h00 and 16h00 on days when hydro generation is less than average) xlabel(0(15)200)


gen high_tumut3_pump= daily_tumut3_pump/15 if daily_hydro>avg_hydro
gen high_price_pumping = daily_nswpricemwh_pump if daily_hydro>avg_hydro
sum(high_tumut3_pump high_price_pumping)

*Supply curve analysis

clear all
use "/Users/e5110130/Library/CloudStorage/GoogleDrive-bruce.mountain@cmeaustralia.com.au/Shared drives/VEPC/Stata/BM stata tools/Generation price demand analysis tool /Dta files/240604 tumut 3 analysis.dta", replace
keep if Year == 2023

 twoway (scatter nswpricemwh nswregionaldemand)
 
 keep if nswpricemwh>0 & nswpricemwh<=500
 
 sum nswpricemwh
 
 gen nswimports = nswmeteredflow if nswmeteredflow>0
 
 gen nswsupply = nswregionaldemand+nswimports
 
 sum nswsupply
 
  twoway (scatter nswpricemwh nswsupply)
  
  gen log_nswpricemwh = log(nswpricemwh)
  gen log_nswsupply = log(nswsupply)
  
  regress log_nswpricemwh log_nswsupply
  
  twoway (scatter log_nswpricemwh log_nswsupply)
  
  sum nswsupply //4499 to 14773
  sum log_nswsupply // 8.41 to 9.60
  
  save "/Users/e5110130/Library/CloudStorage/GoogleDrive-bruce.mountain@cmeaustralia.com.au/Shared drives/VEPC/Stata/BM stata tools/Generation price demand analysis tool /Dta files/241014 tumut 3 supply curve analysis.dta", replace

  //First supply decile
  use "/Users/e5110130/Library/CloudStorage/GoogleDrive-bruce.mountain@cmeaustralia.com.au/Shared drives/VEPC/Stata/BM stata tools/Generation price demand analysis tool /Dta files/241014 tumut 3 supply curve analysis.dta", replace
  keep if nswsupply>= 4499 & nswsupply <=4499+((14773-4499)/100)*10
  regress log_nswsupply log_nswpricemwh
  sum nswpricemwh
  
  //Second supply decile
  use "/Users/e5110130/Library/CloudStorage/GoogleDrive-bruce.mountain@cmeaustralia.com.au/Shared drives/VEPC/Stata/BM stata tools/Generation price demand analysis tool /Dta files/241014 tumut 3 supply curve analysis.dta", replace
  keep if nswsupply>= 4499+((14773-4499)/100)*10 & nswsupply <=4499+((14773-4499)/100)*20 & nswpricemwh<500
  regress log_nswsupply log_nswpricemwh
  sum nswpricemwh
  
   //Eighth supply decile
  use "/Users/e5110130/Library/CloudStorage/GoogleDrive-bruce.mountain@cmeaustralia.com.au/Shared drives/VEPC/Stata/BM stata tools/Generation price demand analysis tool /Dta files/241014 tumut 3 supply curve analysis.dta", replace
  keep if nswsupply>= 4499+((14773-4499)/100)*70 & nswsupply <=4499+((14773-4499)/100)*80 & nswpricemwh<500
  regress log_nswsupply log_nswpricemwh
  sum nswpricemwh
  
  //Ninth supply decile
  use "/Users/e5110130/Library/CloudStorage/GoogleDrive-bruce.mountain@cmeaustralia.com.au/Shared drives/VEPC/Stata/BM stata tools/Generation price demand analysis tool /Dta files/241014 tumut 3 supply curve analysis.dta", replace
  keep if nswsupply>= 4499+((14773-4499)/100)*80 & nswsupply <=4499+((14773-4499)/100)*90 & nswpricemwh<500
  regress log_nswsupply log_nswpricemwh
  sum nswpricemwh
  
  //95th to 100th percentile 
  use "/Users/e5110130/Library/CloudStorage/GoogleDrive-bruce.mountain@cmeaustralia.com.au/Shared drives/VEPC/Stata/BM stata tools/Generation price demand analysis tool /Dta files/241014 tumut 3 supply curve analysis.dta", replace
  keep if nswsupply>= 4499+((14773-4499)/100)*95 & nswsupply <=4499+((14773-4499)/100)*100 & nswpricemwh<500
  regress log_nswsupply log_nswpricemwh
  sum nswpricemwh
  
  // now take coal out of the equation 
  
  gen peakinggen = nswregionaldemand - blackcoal + nswimports 
  
  gen log_peakinggen = log(peakinggen)

  twoway (scatter log_nswpricemwh log_peakinggen)
	
  //keep if log_peakinggen>7
  
  twoway (scatter log_nswpricemwh log_peakinggen)

  regress log_nswpricemwh log_peakinggen
  
// focus on relationship between price and Tumut3 generation

keep if tumut3powerstationtumut3>0

gen log_tumut3powerstationtumut3 = log(tumut3powerstationtumut3)

   twoway (scatter log_nswpricemwh log_tumut3powerstationtumut3)
   
   regress log_tumut3powerstationtumut3 log_nswpricemwh 
  
  

*Regression of generation against prices

clear all
use "/Users/e5110130/Library/CloudStorage/GoogleDrive-bruce.mountain@cmeaustralia.com.au/Shared drives/VEPC/Stata/BM stata tools/Generation price demand analysis tool /Dta files/240604 tumut 3 analysis.dta", replace
keep if Year == 2023
egen total_generation = total(tumut3powerstationtumut3)
gen proportion_total_generation = tumut3powerstationtumut3/total_generation
gen price_generating = nswpricemwh if tumut3powerstationtumut3>0
sort  price_generating 
drop if price_generating <0
gen log_price_generating = log(price_generating)
gen log_proportion_total_generation = log(proportion_total_generation)
regress log_proportion_total_generation log_price_generating

*Regression of pumping demand against prices



*  weighted average charging price and charging dollar cost by year
clear all
use "/Users/e5110130/Library/CloudStorage/GoogleDrive-bruce.mountain@cmeaustralia.com.au/Shared drives/VEPC/Stata/BM stata tools/Generation price demand analysis tool /Dta files/240604 tumut 3 analysis.dta", replace


gen charging_dollars = nswpricemwh * tumut3pumpsloadsnowyp/12
bysort Year: gen vwap_charging = sum(charging_dollars)*12 / sum(tumut3pumpsloadsnowyp)
tabulate Year, summarize(vwap_charging) means

gen nonzero_charging_dollars = charging_dollars if charging_dollars !=0 //t3 often sits idle
egen total_chargedollars = total(nonzero_charging_dollars), by(Year)
tabulate Year, sum(total_chargedollars) 

histogram nonzero_charging_dollars
tabulate Year, summarize(nonzero_charging_dollars) means

*  price when charging
gen charge_price = nswpricemwh if tumut3pumpsloadsnowyp>0
histogram charge_price

//keep if Year ==2023
//histogram charge_price

* weighted average generating price and income by year
gen generating_dollars = nswpricemwh*tumut3powerstationtumut3/12
bysort Year: gen vwap_generating = sum(generating_dollars)*12 / sum(tumut3powerstationtumut3)
tabulate Year, summarize(vwap_generating) means

gen nonzero_generating_dollars = generating_dollars if generating_dollars !=0
egen total_gendollars = total(nonzero_generating_dollars), by(Year) 

tabulate Year, sum(nonzero_generating_dollars)
tabulate Year, sum(total_gendollars) 
by Year: count nonzero_generating_dollars

*  2023 price when charging
keep if Year ==2023
gen gen_price = log(nswpricemwh) if tumut3powerstationtumut3>0
histogram gen_price, percent xtitle(Spot price when generating) xmtick(##1)
(bin=52, start=-3.9120231, width=.26209951)
 twoway (scatter gen_price tumut3powerstationtumut3)


* impact of Tumut 3 dispatch at $69/MWh on weighted average market prices
  
clear all
use "/Users/e5110130/Library/CloudStorage/GoogleDrive-bruce.mountain@cmeaustralia.com.au/Shared drives/VEPC/Stata/BM stata tools/Generation price demand analysis tool /Dta files/240604 tumut 3 analysis.dta", replace

keep if Year>=2023

gen marketrevenue = nswpricemwh * nswregionaldemand/12
bysort Year: gen vwap = sum(marketrevenue)*12 / sum(nswregionaldemand)
tabulate Year, summarize(vwap) means

replace nswpricemwh = 69 if nswpricemwh>69

gen marketrevenue69 = nswpricemwh * nswregionaldemand/12
bysort Year: gen vwap69 = sum(marketrevenue69)*12 / sum(nswregionaldemand)
tabulate Year, summarize(vwap69) means
  
  
* Relationship between spare Tumut 3 capacity and price

clear all
use "/Users/e5110130/Library/CloudStorage/GoogleDrive-bruce.mountain@cmeaustralia.com.au/Shared drives/VEPC/Stata/BM stata tools/Generation price demand analysis tool /Dta files/240604 tumut 3 analysis.dta", replace
keep if Year >= 2023

gen sparet3gen = .
replace sparet3gen = 1800-tumut3powerstationtumut3 if tumut3powerstationtumut3>0
regress nswpricemwh sparet3gen

gen log_sparet3gen = log(sparet3gen)
gen log_nswpricemwh = log(nswpricemwh)
regress log_nswpricemwh log_sparet3gen 


  
*Analysis of effect of much higher Tumut 3 operation on market prices

Steps 

1.	Pump flat out from 10h00 to 16h00 (6 hours)
2.	Work out how much extra energy from this and work out average price
3.	Allocate this extra generation from 17h00 to 20h00
4.	Work out % change in spare T3 generation as a result of this
5.	Establish relationship between price and spare t3 generation
6.	Predict price with new spare T3 generation, work out average price before new generation, work out average price after new generation, compare. 
  

* 1.	Pump flat out from 10h00 to 16h00 (6 hours)
clear all
use "/Users/e5110130/Library/CloudStorage/GoogleDrive-bruce.mountain@cmeaustralia.com.au/Shared drives/VEPC/Stata/BM stata tools/Generation price demand analysis tool /Dta files/240604 tumut 3 analysis.dta", replace
keep if Year >= 2023

gen newt3pump = .
replace newt3pump = 600 if Hour >=10 & Hour <16 //pump at constant 600 MW between these hours

* 2. Work out how much extra energy from this
gen new_tumut3pumpsloadsnowyp = tumut3pumpsloadsnowyp
replace new_tumut3pumpsloadsnowyp = newt3pump if  Hour >=10 & Hour <16

gen cum_pump = sum(tumut3pumpsloadsnowyp)/12
gen cum_newpump = sum(new_tumut3pumpsloadsnowyp)/12

sum cum_pump cum_newpump
  
gen pump_diff = new_tumut3pumpsloadsnowyp - tumut3pumpsloadsnowyp

gen pump_price = .
replace pump_price = nswpricemwh if Hour >=10 & Hour <16 

gen avg_pump_price = sum(pump_price)/(12*365*6*2)

sum avg_pump_price

gen cum_pump_diff = sum(pump_diff)/12 // find difference in pumped amount
egen x = max(cum_pump_diff) // this is the increase in pumping

sum x
*3.	Allocate this extra generation from 17h00 to 20h00  

gen new_tumut3powerstationtumut3 = tumut3powerstationtumut3
replace new_tumut3powerstationtumut3 = tumut3powerstationtumut3 + x*0.75/(365*3*2) if Hour>=17 & Hour <20   // add the additional pumped hydro adjusted for round trip losses
sum  new_tumut3powerstationtumut3

gen cum_tumut3powerstationtumut3 = sum(tumut3powerstationtumut3)/12
gen cum_new_tumut3powerstationtumut3 = sum(new_tumut3powerstationtumut3)/12

sum cum_tumut3powerstationtumut3 cum_new_tumut3powerstationtumut3

replace new_tumut3powerstationtumut3 = 1800 if new_tumut3powerstationtumut3>1800 // lop off those few instances when the additional pumped energy results in production more than 1800 MW
sum  new_tumut3powerstationtumut3
 
gen newcum_tumut3powerstationtumut3 = sum(new_tumut3powerstationtumut3)/12 
 
sum  newcum_tumut3powerstationtumut3 // see how much energy has been lopped off by comnparing to cum_new_tumut3powerstationtumut3

*4.	Work out % change in spare T3 generation in each trading interval as a result of this  
  

gen spare_old = 1800 - tumut3powerstationtumut3
gen spare_new = 1800 - new_tumut3powerstationtumut3
gen percentchange = (spare_old- spare_new)/spare_old*100


*5.	Establish relationship between price and spare t3 generation

//keep if nswpricemwh<10000

gen sparet3gen = spare_old if tumut3powerstationtumut3>0 & Hour>=17 & Hour <20

gen log_sparet3gen = log(sparet3gen)
gen log_nswpricemwh = log(nswpricemwh)
regress log_nswpricemwh log_sparet3gen 

*6.	Predict price in peak period with new spare T3 generation, work out average price before new generation, work out average price after new generation, compare. 


gen new_nswpricemwh = nswpricemwh*0.4139*percentchange/100 if  Hour>=17 & Hour <20 // using the regression coefficient
gen nswpricemwh_peak = nswpricemwh if  Hour>=17 & Hour <20   

sum new_nswpricemwh nswpricemwh_peak

* Predict spot price effect over the whole period

gen new_price = nswpricemwh
replace new_price = nswpricemwh*0.4139*percentchange/100 if  Hour>=17 & Hour <20

sum new_price nswpricemwh,detail
