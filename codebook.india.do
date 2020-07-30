/* Financing and Productivity: Evidence from Indian Manufacturing Industry */
/* Prowess dataset used in this project is from the Center for Monitoring Indian Economy (CMIE) */


// Cleaning Process //
// Importing each excel files into Stata and merging all the files//

* 1. TFP *
reshape month sales csfg csweg gfa nfa noemploy, i(code)j(year)

* 2. Raw material *
reshape rmss rme sstc ppe pfwc compen salary, i(code)j(year)

* 3. Short-term Loans * 
reshape long currlp currliab sb sbbank sbfininst sbcsgov sbsyn, i(code)j(year)

* 4. Long-term Loans *
reshape nonculiab lbecp lbbank lbfininst lbcsgov lbsyn. i(code)j(year)

merge m:m code using D:\Dropbox\K\USF_IDEC\Thesis\Data\TFP.dta
drop merge
merge m:m code using D:\Dropbox\K\USF_IDEC\Thesis\Data\long_loans.dta
drop merge
merge m:m code using D:\Dropbox\K\USF_IDEC\Thesis\Data\short_loans.dta
drop merge
merge m:m name using D:\Dropbox\K\USF_IDEC\Thesis\Data\pincode.dta
drop merge
merge m:m state using D:\Dropbox\K\USF_IDEC\Thesis\Data\gdp.dta
drop merge


// Cleaning Process 2 //
set more off
use "/Users/Kate/Dropbox/K/USF_IDEC/Thesis/Data/New_Prowess_Final_1.dta"

* Dropping missing observations *
sort name year
drop if sales==.
drop if grossfixassets==. 
drop if gdp_de==.

* Dropping firms with less than 2 years *
sort name
by name: gen count=_N
order count, a(year)
drop if count<=2

* Labeling variables *
label variable rgdp "Real GDP"
label variable ngdp "Nominal GDP"
label variable gdp_de "GDP deflator"
notes gdp_de: INDIA=National GDP Deflator

* Replacing state with UNKNOW for those firms without region info *
replace region="UNKNOWN" if region=="INDIA"

* Convering format *
format year %ty

* Convering int into the correct unit *
gen Rgdp = rgdp/1000000
gen Ngdp = ngdp/1000000
gen Gdp_de = (Ngdp/Rgdp)*100

* Making a panel data *
encode name, gen(id)
tsset id year
egen region1=group(region)
egen industry1=group(industry)

* Generating variables *
egen aggreloan= rowtotal(srtborrow longborrow)
egen prisrtloan= rowtotal(srtborrowbank srtborrowfin srtborrowsyn)
egen prilngloan= rowtotal(longborrowbank longborrowfin longborrowsyn)
egen pubsrtloan=rowtotal(srtborrowgov)
egen publngloan= rowtotal(longborrowgov)
egen srtloan=rowtotal(srtborrow)
egen lngloan=rowtotal(longborrow)

gen rsales=sales/gdp_de
gen rgrossfixassets= grossfixassets/gdp_de
gen raggreloan=aggreloan/gdp_de
gen rsrtloan= srtloan/gdp_de
gen rlngloan= lngloan/gdp_de
gen rpubsrtloan= pubsrtloan/gdp_de
gen rpublngloan= publngloan/gdp_de
gen rprisrtloan= prisrtloan/gdp_de
gen rprilngloan= prilngloan/gdp_de
gen rnetfixasset=netfixasset/gdp_de

gen lnsales= ln(rsales)
gen lngfixasset= ln(rgrossfixassets)
gen lnaggreloan= ln(raggreloan) 
gen lnsrtloan=ln(rsrtloan)
gen lnlngloan=ln(rlngloan)
gen lnpubsrtloan=ln(rpubsrtloan) 
gen lnpublngloan=ln(rpublngloan) 
gen lnprisrtloan=ln(rprisrtloan) 
gen lnprilngloan=ln(rprilngloan) 
gen lnrgdp=ln(Rgdp)
gen lnpop=ln(population)
gen lnnetfixasset=ln(rnetfixasset)

sort id year
by id: gen lagaggreloan=l.lnaggreloan
gen lagprisrtloan=l.lnprisrtloan
gen lagprilngloan=l.lnprilngloan
gen lagpublngloan=l.lnpublngloan
gen lagfixasset=l.lngfixasset
gen lagsrtloan=l.lnsrtloan
gen laglngloan=l.lnlngloan
gen lagrgdp=l.lnrgdp




// Analysis Process //

* Descriptive statistics *
sum id year lnsales lngfixasset lnnetfixasset lnaggreloan lnsrtloan lnlngloan lnprisrtloan lnprilngloan lnpubsrtloan lnpublngloan lnrgdp lnpop literacyrate

* Regression template *

* 1. Total sales *
eststo: quietly xtreg lnsales lnaggreloan lagfixasset lagrgdp lnpop literacyrate c.lnaggreloan#c.lagrgdp i.year i.region1 i.industry1, vce (cluster region)
eststo: quietly xtreg lnsales lnsrtloan lagfixasset lagrgdp lnpop literacyrate c.lnsrtloan#c.lagrgdp i.year i.region1 i.industry1, vce (cluster region)
eststo: quietly xtreg lnsales lnlngloan lagfixasset lagrgdp lnpop literacyrate c.lnlngloan#c.lagrgdp i.year i.region1 i.industry1, vce (cluster region)
eststo: quietly xtreg lnsales lnprisrtloan lagfixasset lagrgdp lnpop literacyrate c.lnprisrtloan#c.lagrgdp i.year i.region1 i.industry1, vce (cluster region)
eststo: quietly xtreg lnsales lnprilngloan lagfixasset lagrgdp lnpop literacyrate c.lnprilngloan#c.lagrgdp i.year i.region1 i.industry1, vce (cluster region)

esttab using table1.rtf, nogap se(3) star(* 0.10 ** 0.05 *** 0.01) b(3)
eststo clear

* 2. Gross fixed assets *
eststo: quietly xtreg lngfixasset lnaggreloan lagrgdp lnpop literacyrate c.lnaggreloan#c.lagrgdp i.year i.region1 i.industry1, vce (cluster region)
eststo: quietly xtreg lngfixasset lnsrtloan lagrgdp lnpop literacyrate c.lnsrtloan#c.lagrgdp i.year i.region1 i.industry1, vce (cluster region)
eststo: quietly xtreg lngfixasset lnlngloan lagrgdp lnpop literacyrate c.lnlngloan#c.lagrgdp i.year i.region1 i.industry1, vce (cluster region)
eststo: quietly xtreg lngfixasset lnprisrtloan lagrgdp lnpop literacyrate c.lnprisrtloan#c.lagrgdp i.year i.region1 i.industry1, vce (cluster region)
eststo: quietly xtreg lngfixasset lnprilngloan lagrgdp lnpop literacyrate c.lnprilngloan#c.lagrgdp i.year i.region1 i.industry1, vce (cluster region)

esttab using table2.rtf, nogap se(3) star(* 0.10 ** 0.05 *** 0.01) b(3)
eststo clear

* 3. Net fixed assets *
eststo: quietly xtreg lnnetfixasset lnaggreloan lagrgdp lnpop literacyrate c.lnaggreloan#c.lagrgdp i.year i.region1 i.industry1, vce (cluster region)
eststo: quietly xtreg lnnetfixasset lnsrtloan lagrgdp lnpop literacyrate c.lnsrtloan#c.lagrgdp i.year i.region1 i.industry1, vce (cluster region)
eststo: quietly xtreg lnnetfixasset lnlngloan lagrgdp lnpop literacyrate c.lnlngloan#c.lagrgdp i.year i.region1 i.industry1, vce (cluster region)
eststo: quietly xtreg lnnetfixasset lnprisrtloan lagrgdp lnpop literacyrate c.lnprisrtloan#c.lagrgdp i.year i.region1 i.industry1, vce (cluster region)
eststo: quietly xtreg lnnetfixasset lnprilngloan lagrgdp lnpop literacyrate c.lnprilngloan#c.lagrgdp i.year i.region1 i.industry1, vce (cluster region)

esttab using table3.rtf, nogap se(3) star(* 0.10 ** 0.05 *** 0.01) b(3)
eststo clear

* 4. Lagged function *
eststo: quietly xtreg lnsales lagaggreloan lagfixasset lagrgdp lnpop literacyrate c.lagaggreloan#c.lagrgdp i.year i.region1 i.industry1, vce (cluster region)
eststo: quietly xtreg lnsales lagsrtloan lagfixasset lagrgdp lnpop literacyrate c.lagsrtloan#c.lagrgdp i.year i.region1 i.industry1, vce (cluster region)
eststo: quietly xtreg lnsales laglngloan lagfixasset lagrgdp lnpop literacyrate c.laglngloan#c.lagrgdp i.year i.region1 i.industry1, vce (cluster region)
eststo: quietly xtreg lnsales lagprisrtloan lagfixasset lagrgdp lnpop literacyrate c.lagprisrtloan#c.lagrgdp i.year i.region1 i.industry1, vce (cluster region)
eststo: quietly xtreg lnsales lagprilngloan lagfixasset lagrgdp lnpop literacyrate c.lagprilngloan#c.lagrgdp i.year i.region1 i.industry1, vce (cluster region)

eststo: quietly xtreg lngfixasset lagaggreloan lagrgdp lnpop literacyrate c.lagaggreloan#c.lagrgdp i.year i.region1 i.industry1, vce (cluster region)
eststo: quietly xtreg lngfixasset lagsrtloan lagrgdp lnpop literacyrate c.lagsrtloan#c.lagrgdp i.year i.region1 i.industry1, vce (cluster region)
eststo: quietly xtreg lngfixasset laglngloan lagrgdp lnpop literacyrate c.laglngloan#c.lagrgdp i.year i.region1 i.industry1, vce (cluster region)
eststo: quietly xtreg lngfixasset lagprisrtloan lagrgdp lnpop literacyrate c.lagprisrtloan#c.lagrgdp i.year i.region1 i.industry1, vce (cluster region)
eststo: quietly xtreg lngfixasset lagprilngloan lagrgdp lnpop literacyrate c.lagprilngloan#c.lagrgdp i.year i.region1 i.industry1, vce (cluster region)

eststo: quietly xtreg lnnetfixasset lagaggreloan lagrgdp lnpop literacyrate c.lagaggreloan#c.lagrgdp i.year i.region1 i.industry1, vce (cluster region)
eststo: quietly xtreg lnnetfixasset lagsrtloan lagrgdp lnpop literacyrate c.lagsrtloan#c.lagrgdp i.year i.region1 i.industry1, vce (cluster region)
eststo: quietly xtreg lnnetfixasset laglngloan lagrgdp lnpop literacyrate c.laglngloan#c.lagrgdp i.year i.region1 i.industry1, vce (cluster region)
eststo: quietly xtreg lnnetfixasset lagprisrtloan lagrgdp lnpop literacyrate c.lagprisrtloan#c.lagrgdp i.year i.region1 i.industry1, vce (cluster region)
eststo: quietly xtreg lnnetfixasset lagprilngloan lagrgdp lnpop literacyrate c.lagprilngloan#c.lagrgdp i.year i.region1 i.industry1, vce (cluster region)

esttab using table4.rtf, nogap se(2) star(* 0.10 ** 0.05 *** 0.01) b(3)
eststo clear



// Creating subsamples //

* 1. Computer software *
preserve
keep if industry1==26
eststo: quietly xtreg lnsales lnaggreloan lagfixasset lagrgdp lnpop literacyrate c.lnaggreloan#c.lagrgdp i.year i.region1, vce (cluster region)
eststo: quietly xtreg lnsales lnsrtloan lagfixasset lagrgdp lnpop literacyrate c.lnsrtloan#c.lagrgdp i.year i.region1, vce (cluster region)
eststo: quietly xtreg lnsales lnlngloan lagfixasset lagrgdp lnpop literacyrate c.lnlngloan#c.lagrgdp i.year i.region1, vce (cluster region)
eststo: quietly xtreg lnsales lnprisrtloan lagfixasset lagrgdp lnpop literacyrate c.lnprisrtloan#c.lagrgdp i.year i.region1, vce (cluster region)
eststo: quietly xtreg lnsales lnprilngloan lagfixasset lagrgdp lnpop literacyrate c.lnprilngloan#c.lagrgdp i.year i.region1, vce (cluster region)

esttab using table_com_1.rtf, nogap se(3) star(* 0.10 ** 0.05 *** 0.01) b(3)
eststo clear

eststo: quietly xtreg lngfixasset lnaggreloan lagrgdp lnpop literacyrate c.lnaggreloan#c.lagrgdp i.year i.region1, vce (cluster region)
eststo: quietly xtreg lngfixasset lnsrtloan lagrgdp lnpop literacyrate c.lnsrtloan#c.lagrgdp i.year i.region1, vce (cluster region)
eststo: quietly xtreg lngfixasset lnlngloan lagrgdp lnpop literacyrate c.lnlngloan#c.lagrgdp i.year i.region1, vce (cluster region)
eststo: quietly xtreg lngfixasset lnprisrtloan lagrgdp lnpop literacyrate c.lnprisrtloan#c.lagrgdp i.year i.region1, vce (cluster region)
eststo: quietly xtreg lngfixasset lnprilngloan lagrgdp lnpop literacyrate c.lnprilngloan#c.lagrgdp i.year i.region1, vce (cluster region)

esttab using table_com_2.rtf, nogap se(3) star(* 0.10 ** 0.05 *** 0.01) b(3)
eststo clear

eststo: quietly xtreg lnnetfixasset lnaggreloan lagrgdp lnpop literacyrate c.lnaggreloan#c.lagrgdp i.year i.region1, vce (cluster region)
eststo: quietly xtreg lnnetfixasset lnsrtloan lagrgdp lnpop literacyrate c.lnsrtloan#c.lagrgdp i.year i.region1, vce (cluster region)
eststo: quietly xtreg lnnetfixasset lnlngloan lagrgdp lnpop literacyrate c.lnlngloan#c.lagrgdp i.year i.region1, vce (cluster region)
eststo: quietly xtreg lnnetfixasset lnprisrtloan lagrgdp lnpop literacyrate c.lnprisrtloan#c.lagrgdp i.year i.region1, vce (cluster region)
eststo: quietly xtreg lnnetfixasset lnprilngloan lagrgdp lnpop literacyrate c.lnprilngloan#c.lagrgdp i.year i.region1, vce (cluster region)

esttab using table_com_3.rtf, nogap se(3) star(* 0.10 ** 0.05 *** 0.01) b(3)
eststo clear

eststo: quietly xtreg lnsales lagaggreloan lagfixasset lagrgdp lnpop literacyrate c.lagaggreloan#c.lagrgdp i.year i.region1, vce (cluster region)
eststo: quietly xtreg lnsales lagsrtloan lagfixasset lagrgdp lnpop literacyrate c.lagsrtloan#c.lagrgdp i.year i.region1, vce (cluster region)
eststo: quietly xtreg lnsales laglngloan lagfixasset lagrgdp lnpop literacyrate c.laglngloan#c.lagrgdp i.year i.region1, vce (cluster region)
eststo: quietly xtreg lnsales lagprisrtloan lagfixasset lagrgdp lnpop literacyrate c.lagprisrtloan#c.lagrgdp i.year i.region1, vce (cluster region)
eststo: quietly xtreg lnsales lagprilngloan lagfixasset lagrgdp lnpop literacyrate c.lagprilngloan#c.lagrgdp i.year i.region1, vce (cluster region)

eststo: quietly xtreg lngfixasset lagaggreloan lagrgdp lnpop literacyrate c.lagaggreloan#c.lagrgdp i.year i.region1, vce (cluster region)
eststo: quietly xtreg lngfixasset lagsrtloan lagrgdp lnpop literacyrate c.lagsrtloan#c.lagrgdp i.year i.region1, vce (cluster region)
eststo: quietly xtreg lngfixasset laglngloan lagrgdp lnpop literacyrate c.laglngloan#c.lagrgdp i.year i.region1, vce (cluster region)
eststo: quietly xtreg lngfixasset lagprisrtloan lagrgdp lnpop literacyrate c.lagprisrtloan#c.lagrgdp i.year i.region1, vce (cluster region)
eststo: quietly xtreg lngfixasset lagprilngloan lagrgdp lnpop literacyrate c.lagprilngloan#c.lagrgdp i.year i.region1, vce (cluster region)

eststo: quietly xtreg lnnetfixasset lagaggreloan lagrgdp lnpop literacyrate c.lagaggreloan#c.lagrgdp i.year i.region1, vce (cluster region)
eststo: quietly xtreg lnnetfixasset lagsrtloan lagrgdp lnpop literacyrate c.lagsrtloan#c.lagrgdp i.year i.region1, vce (cluster region)
eststo: quietly xtreg lnnetfixasset laglngloan lagrgdp lnpop literacyrate c.laglngloan#c.lagrgdp i.year i.region1, vce (cluster region)
eststo: quietly xtreg lnnetfixasset lagprisrtloan lagrgdp lnpop literacyrate c.lagprisrtloan#c.lagrgdp i.year i.region1, vce (cluster region)
eststo: quietly xtreg lnnetfixasset lagprilngloan lagrgdp lnpop literacyrate c.lagprilngloan#c.lagrgdp i.year i.region1, vce (cluster region)

esttab using table_com_4.rtf, nogap se(2) star(* 0.10 ** 0.05 *** 0.01) b(3)
eststo clear

* 2. Non-computer software *
preserve
drop if industry1==26
eststo: quietly xtreg lnsales lnaggreloan lagfixasset lagrgdp lnpop literacyrate c.lnaggreloan#c.lagrgdp i.year i.region1 i.industry1, vce (cluster region)
eststo: quietly xtreg lnsales lnsrtloan lagfixasset lagrgdp lnpop literacyrate c.lnsrtloan#c.lagrgdp i.year i.region1 i.industry1, vce (cluster region)
eststo: quietly xtreg lnsales lnlngloan lagfixasset lagrgdp lnpop literacyrate c.lnlngloan#c.lagrgdp i.year i.region1 i.industry1, vce (cluster region)
eststo: quietly xtreg lnsales lnprisrtloan lagfixasset lagrgdp lnpop literacyrate c.lnprisrtloan#c.lagrgdp i.year i.region1 i.industry1, vce (cluster region)
eststo: quietly xtreg lnsales lnprilngloan lagfixasset lagrgdp lnpop literacyrate c.lnprilngloan#c.lagrgdp i.year i.region1 i.industry1, vce (cluster region)

esttab using table_nonc_1.rtf, nogap se(3) star(* 0.10 ** 0.05 *** 0.01) b(3)
eststo clear

eststo: quietly xtreg lngfixasset lnaggreloan lagrgdp lnpop literacyrate c.lnaggreloan#c.lagrgdp i.year i.region1 i.industry1, vce (cluster region)
eststo: quietly xtreg lngfixasset lnsrtloan lagrgdp lnpop literacyrate c.lnsrtloan#c.lagrgdp i.year i.region1 i.industry1, vce (cluster region)
eststo: quietly xtreg lngfixasset lnlngloan lagrgdp lnpop literacyrate c.lnlngloan#c.lagrgdp i.year i.region1 i.industry1, vce (cluster region)
eststo: quietly xtreg lngfixasset lnprisrtloan lagrgdp lnpop literacyrate c.lnprisrtloan#c.lagrgdp i.year i.region1 i.industry1, vce (cluster region)
eststo: quietly xtreg lngfixasset lnprilngloan lagrgdp lnpop literacyrate c.lnprilngloan#c.lagrgdp i.year i.region1 i.industry1, vce (cluster region)

esttab using table_nonc_2.rtf, nogap se(3) star(* 0.10 ** 0.05 *** 0.01) b(3)
eststo clear

eststo: quietly xtreg lnnetfixasset lnaggreloan lagrgdp lnpop literacyrate c.lnaggreloan#c.lagrgdp i.year i.region1 i.industry1, vce (cluster region)
eststo: quietly xtreg lnnetfixasset lnsrtloan lagrgdp lnpop literacyrate c.lnsrtloan#c.lagrgdp i.year i.region1 i.industry1, vce (cluster region)
eststo: quietly xtreg lnnetfixasset lnlngloan lagrgdp lnpop literacyrate c.lnlngloan#c.lagrgdp i.year i.region1 i.industry1, vce (cluster region)
eststo: quietly xtreg lnnetfixasset lnprisrtloan lagrgdp lnpop literacyrate c.lnprisrtloan#c.lagrgdp i.year i.region1 i.industry1, vce (cluster region)
eststo: quietly xtreg lnnetfixasset lnprilngloan lagrgdp lnpop literacyrate c.lnprilngloan#c.lagrgdp i.year i.region1 i.industry1, vce (cluster region)

esttab using table_nonc_3.rtf, nogap se(3) star(* 0.10 ** 0.05 *** 0.01) b(3)
eststo clear

eststo: quietly xtreg lnsales lagaggreloan lagfixasset lagrgdp lnpop literacyrate c.lagaggreloan#c.lagrgdp i.year i.region1 i.industry1, vce (cluster region)
eststo: quietly xtreg lnsales lagsrtloan lagfixasset lagrgdp lnpop literacyrate c.lagsrtloan#c.lagrgdp i.year i.region1 i.industry1, vce (cluster region)
eststo: quietly xtreg lnsales laglngloan lagfixasset lagrgdp lnpop literacyrate c.laglngloan#c.lagrgdp i.year i.region1 i.industry1, vce (cluster region)
eststo: quietly xtreg lnsales lagprisrtloan lagfixasset lagrgdp lnpop literacyrate c.lagprisrtloan#c.lagrgdp i.year i.region1 i.industry1, vce (cluster region)
eststo: quietly xtreg lnsales lagprilngloan lagfixasset lagrgdp lnpop literacyrate c.lagprilngloan#c.lagrgdp i.year i.region1 i.industry1, vce (cluster region)

eststo: quietly xtreg lngfixasset lagaggreloan lagrgdp lnpop literacyrate c.lagaggreloan#c.lagrgdp i.year i.region1 i.industry1, vce (cluster region)
eststo: quietly xtreg lngfixasset lagsrtloan lagrgdp lnpop literacyrate c.lagsrtloan#c.lagrgdp i.year i.region1 i.industry1, vce (cluster region)
eststo: quietly xtreg lngfixasset laglngloan lagrgdp lnpop literacyrate c.laglngloan#c.lagrgdp i.year i.region1 i.industry1, vce (cluster region)
eststo: quietly xtreg lngfixasset lagprisrtloan lagrgdp lnpop literacyrate c.lagprisrtloan#c.lagrgdp i.year i.region1 i.industry1, vce (cluster region)
eststo: quietly xtreg lngfixasset lagprilngloan lagrgdp lnpop literacyrate c.lagprilngloan#c.lagrgdp i.year i.region1 i.industry1, vce (cluster region)

eststo: quietly xtreg lnnetfixasset lagaggreloan lagrgdp lnpop literacyrate c.lagaggreloan#c.lagrgdp i.year i.region1 i.industry1, vce (cluster region)
eststo: quietly xtreg lnnetfixasset lagsrtloan lagrgdp lnpop literacyrate c.lagsrtloan#c.lagrgdp i.year i.region1 i.industry1, vce (cluster region)
eststo: quietly xtreg lnnetfixasset laglngloan lagrgdp lnpop literacyrate c.laglngloan#c.lagrgdp i.year i.region1 i.industry1, vce (cluster region)
eststo: quietly xtreg lnnetfixasset lagprisrtloan lagrgdp lnpop literacyrate c.lagprisrtloan#c.lagrgdp i.year i.region1 i.industry1, vce (cluster region)
eststo: quietly xtreg lnnetfixasset lagprilngloan lagrgdp lnpop literacyrate c.lagprilngloan#c.lagrgdp i.year i.region1 i.industry1, vce (cluster region)

esttab using table_nonc_4.rtf, nogap se(2) star(* 0.10 ** 0.05 *** 0.01) b(3)
eststo clear



// Grouping samples by geographic location //
gen geoloc=0 
replace geoloc=1 if region=="CHANDIGARH" | region=="DELHI" | region=="HARYANA" | region=="HIMACHAL PRADESH" | region=="JAMMU & KASHMIR" | region=="PUNJAB" | region=="UTTAR PRADESH" | region=="UTTARAKHAND"
replace geoloc=2 if region=="KARNATAKA" | region=="KERALA" | region=="PONDICHERRY" | region=="TAMIL NADU" | region=="ANDHRA PRADESH"
replace geoloc=3 if region=="BIHAR" | region=="NAGALAND" | region=="ODISHA" | region=="WEST BENGAL"
replace geoloc=4 if region=="GOA" | region=="GUJARAT" | region=="MAHARASHTRA" | region=="RAJASTHAN"
replace geoloc=5 if region=="CHATTISGARH" | region=="JHARKHAND" | region=="MADHYA PRADESH"
replace geoloc=6 if region=="ASSAM" | region=="MEGHALAYA"

notes political: Region category: 0: National wide, 1: North, 2: South, 3: East, 4: West, 5: Central, 6: Northeast

* 1. North *
eststo: quietly xtreg lnsales lnaggreloan lagfixasset lagrgdp lnpop literacyrate c.lnaggreloan#c.lagrgdp i.year i.region1 i.industry1 if geoloc==1, vce (cluster region)
eststo: quietly xtreg lnsales lnsrtloan lagfixasset lagrgdp lnpop literacyrate c.lnsrtloan#c.lagrgdp i.year i.region1 i.industry1 if geoloc==1, vce (cluster region)
eststo: quietly xtreg lnsales lnlngloan lagfixasset lagrgdp lnpop literacyrate c.lnlngloan#c.lagrgdp i.year i.region1 i.industry1 if geoloc==1, vce (cluster region)
eststo: quietly xtreg lnsales lnprisrtloan lagfixasset lagrgdp lnpop literacyrate c.lnprisrtloan#c.lagrgdp i.year i.region1 i.industry1 if geoloc==1, vce (cluster region)
eststo: quietly xtreg lnsales lnprilngloan lagfixasset lagrgdp lnpop literacyrate c.lnprilngloan#c.lagrgdp i.year i.region1 i.industry1 if geoloc==1, vce (cluster region)

esttab using table_N_1.rtf, nogap se(3) star(* 0.10 ** 0.05 *** 0.01) b(3)
eststo clear

eststo: quietly xtreg lngfixasset lnaggreloan lagrgdp lnpop literacyrate c.lnaggreloan#c.lagrgdp i.year i.region1 i.industry1 if geoloc==1, vce (cluster region)
eststo: quietly xtreg lngfixasset lnsrtloan lagrgdp lnpop literacyrate c.lnsrtloan#c.lagrgdp i.year i.region1 i.industry1 if geoloc==1, vce (cluster region)
eststo: quietly xtreg lngfixasset lnlngloan lagrgdp lnpop literacyrate c.lnlngloan#c.lagrgdp i.year i.region1 i.industry1 if geoloc==1, vce (cluster region)
eststo: quietly xtreg lngfixasset lnprisrtloan lagrgdp lnpop literacyrate c.lnprisrtloan#c.lagrgdp i.year i.region1 i.industry1 if geoloc==1, vce (cluster region)
eststo: quietly xtreg lngfixasset lnprilngloan lagrgdp lnpop literacyrate c.lnprilngloan#c.lagrgdp i.year i.region1 i.industry1 if geoloc==1, vce (cluster region)

esttab using table_N_2.rtf, nogap se(3) star(* 0.10 ** 0.05 *** 0.01) b(3)
eststo clear

eststo: quietly xtreg lnnetfixasset lnaggreloan lagrgdp lnpop literacyrate c.lnaggreloan#c.lagrgdp i.year i.region1 i.industry1 if geoloc==1, vce (cluster region)
eststo: quietly xtreg lnnetfixasset lnsrtloan lagrgdp lnpop literacyrate c.lnsrtloan#c.lagrgdp i.year i.region1 i.industry1 if geoloc==1, vce (cluster region)
eststo: quietly xtreg lnnetfixasset lnlngloan lagrgdp lnpop literacyrate c.lnlngloan#c.lagrgdp i.year i.region1 i.industry1 if geoloc==1, vce (cluster region)
eststo: quietly xtreg lnnetfixasset lnprisrtloan lagrgdp lnpop literacyrate c.lnprisrtloan#c.lagrgdp i.year i.region1 i.industry1 if geoloc==1, vce (cluster region)
eststo: quietly xtreg lnnetfixasset lnprilngloan lagrgdp lnpop literacyrate c.lnprilngloan#c.lagrgdp i.year i.region1 i.industry1 if geoloc==1, vce (cluster region)

esttab using table_N_3.rtf, nogap se(3) star(* 0.10 ** 0.05 *** 0.01) b(3)
eststo clear

* 2. South *
eststo: quietly xtreg lnsales lnaggreloan lagfixasset lagrgdp lnpop literacyrate c.lnaggreloan#c.lagrgdp i.year i.region1 i.industry1 if geoloc==2, vce (cluster region)
eststo: quietly xtreg lnsales lnsrtloan lagfixasset lagrgdp lnpop literacyrate c.lnsrtloan#c.lagrgdp i.year i.region1 i.industry1 if geoloc==2, vce (cluster region)
eststo: quietly xtreg lnsales lnlngloan lagfixasset lagrgdp lnpop literacyrate c.lnlngloan#c.lagrgdp i.year i.region1 i.industry1 if geoloc==2, vce (cluster region)
eststo: quietly xtreg lnsales lnprisrtloan lagfixasset lagrgdp lnpop literacyrate c.lnprisrtloan#c.lagrgdp i.year i.region1 i.industry1 if geoloc==2, vce (cluster region)
eststo: quietly xtreg lnsales lnprilngloan lagfixasset lagrgdp lnpop literacyrate c.lnprilngloan#c.lagrgdp i.year i.region1 i.industry1 if geoloc==2, vce (cluster region)

esttab using table_S_1.rtf, nogap se(3) star(* 0.10 ** 0.05 *** 0.01) b(3)
eststo clear

eststo: quietly xtreg lngfixasset lnaggreloan lagrgdp lnpop literacyrate c.lnaggreloan#c.lagrgdp i.year i.region1 i.industry1 if geoloc==2, vce (cluster region)
eststo: quietly xtreg lngfixasset lnsrtloan lagrgdp lnpop literacyrate c.lnsrtloan#c.lagrgdp i.year i.region1 i.industry1 if geoloc==2, vce (cluster region)
eststo: quietly xtreg lngfixasset lnlngloan lagrgdp lnpop literacyrate c.lnlngloan#c.lagrgdp i.year i.region1 i.industry1 if geoloc==2, vce (cluster region)
eststo: quietly xtreg lngfixasset lnprisrtloan lagrgdp lnpop literacyrate c.lnprisrtloan#c.lagrgdp i.year i.region1 i.industry1 if geoloc==2, vce (cluster region)
eststo: quietly xtreg lngfixasset lnprilngloan lagrgdp lnpop literacyrate c.lnprilngloan#c.lagrgdp i.year i.region1 i.industry1 if geoloc==2, vce (cluster region)

esttab using table_S_2.rtf, nogap se(3) star(* 0.10 ** 0.05 *** 0.01) b(3)
eststo clear

eststo: quietly xtreg lnnetfixasset lnaggreloan lagrgdp lnpop literacyrate c.lnaggreloan#c.lagrgdp i.year i.region1 i.industry1 if geoloc==2, vce (cluster region)
eststo: quietly xtreg lnnetfixasset lnsrtloan lagrgdp lnpop literacyrate c.lnsrtloan#c.lagrgdp i.year i.region1 i.industry1 if geoloc==2, vce (cluster region)
eststo: quietly xtreg lnnetfixasset lnlngloan lagrgdp lnpop literacyrate c.lnlngloan#c.lagrgdp i.year i.region1 i.industry1 if geoloc==2, vce (cluster region)
eststo: quietly xtreg lnnetfixasset lnprisrtloan lagrgdp lnpop literacyrate c.lnprisrtloan#c.lagrgdp i.year i.region1 i.industry1 if geoloc==2, vce (cluster region)
eststo: quietly xtreg lnnetfixasset lnprilngloan lagrgdp lnpop literacyrate c.lnprilngloan#c.lagrgdp i.year i.region1 i.industry1 if geoloc==2, vce (cluster region)

esttab using table_S_3.rtf, nogap se(3) star(* 0.10 ** 0.05 *** 0.01) b(3)
eststo clear

* 3. East *
eststo: quietly xtreg lnsales lnaggreloan lagfixasset lagrgdp lnpop literacyrate c.lnaggreloan#c.lagrgdp i.year i.region1 i.industry1 if geoloc==3, vce (cluster region)
eststo: quietly xtreg lnsales lnsrtloan lagfixasset lagrgdp lnpop literacyrate c.lnsrtloan#c.lagrgdp i.year i.region1 i.industry1 if geoloc==3, vce (cluster region)
eststo: quietly xtreg lnsales lnlngloan lagfixasset lagrgdp lnpop literacyrate c.lnlngloan#c.lagrgdp i.year i.region1 i.industry1 if geoloc==3, vce (cluster region)
eststo: quietly xtreg lnsales lnprisrtloan lagfixasset lagrgdp lnpop literacyrate c.lnprisrtloan#c.lagrgdp i.year i.region1 i.industry1 if geoloc==3, vce (cluster region)
eststo: quietly xtreg lnsales lnprilngloan lagfixasset lagrgdp lnpop literacyrate c.lnprilngloan#c.lagrgdp i.year i.region1 i.industry1 if geoloc==3, vce (cluster region)

esttab using table_E_1.rtf, nogap se(3) star(* 0.10 ** 0.05 *** 0.01) b(3)
eststo clear

eststo: quietly xtreg lngfixasset lnaggreloan lagrgdp lnpop literacyrate c.lnaggreloan#c.lagrgdp i.year i.region1 i.industry1 if geoloc==3, vce (cluster region)
eststo: quietly xtreg lngfixasset lnsrtloan lagrgdp lnpop literacyrate c.lnsrtloan#c.lagrgdp i.year i.region1 i.industry1 if geoloc==3, vce (cluster region)
eststo: quietly xtreg lngfixasset lnlngloan lagrgdp lnpop literacyrate c.lnlngloan#c.lagrgdp i.year i.region1 i.industry1 if geoloc==3, vce (cluster region)
eststo: quietly xtreg lngfixasset lnprisrtloan lagrgdp lnpop literacyrate c.lnprisrtloan#c.lagrgdp i.year i.region1 i.industry1 if geoloc==3, vce (cluster region)
eststo: quietly xtreg lngfixasset lnprilngloan lagrgdp lnpop literacyrate c.lnprilngloan#c.lagrgdp i.year i.region1 i.industry1 if geoloc==3, vce (cluster region)

esttab using table_E_2.rtf, nogap se(3) star(* 0.10 ** 0.05 *** 0.01) b(3)
eststo clear

eststo: quietly xtreg lnnetfixasset lnaggreloan lagrgdp lnpop literacyrate c.lnaggreloan#c.lagrgdp i.year i.region1 i.industry1 if geoloc==3, vce (cluster region)
eststo: quietly xtreg lnnetfixasset lnsrtloan lagrgdp lnpop literacyrate c.lnsrtloan#c.lagrgdp i.year i.region1 i.industry1 if geoloc==3, vce (cluster region)
eststo: quietly xtreg lnnetfixasset lnlngloan lagrgdp lnpop literacyrate c.lnlngloan#c.lagrgdp i.year i.region1 i.industry1 if geoloc==3, vce (cluster region)
eststo: quietly xtreg lnnetfixasset lnprisrtloan lagrgdp lnpop literacyrate c.lnprisrtloan#c.lagrgdp i.year i.region1 i.industry1 if geoloc==3, vce (cluster region)
eststo: quietly xtreg lnnetfixasset lnprilngloan lagrgdp lnpop literacyrate c.lnprilngloan#c.lagrgdp i.year i.region1 i.industry1 if geoloc==3, vce (cluster region)

esttab using table_E_3.rtf, nogap se(3) star(* 0.10 ** 0.05 *** 0.01) b(3)
eststo clear

* 4. West *
eststo: quietly xtreg lnsales lnaggreloan lagfixasset lagrgdp lnpop literacyrate c.lnaggreloan#c.lagrgdp i.year i.region1 i.industry1 if geoloc==4, vce (cluster region)
eststo: quietly xtreg lnsales lnsrtloan lagfixasset lagrgdp lnpop literacyrate c.lnsrtloan#c.lagrgdp i.year i.region1 i.industry1 if geoloc==4, vce (cluster region)
eststo: quietly xtreg lnsales lnlngloan lagfixasset lagrgdp lnpop literacyrate c.lnlngloan#c.lagrgdp i.year i.region1 i.industry1 if geoloc==4, vce (cluster region)
eststo: quietly xtreg lnsales lnprisrtloan lagfixasset lagrgdp lnpop literacyrate c.lnprisrtloan#c.lagrgdp i.year i.region1 i.industry1 if geoloc==4, vce (cluster region)
eststo: quietly xtreg lnsales lnprilngloan lagfixasset lagrgdp lnpop literacyrate c.lnprilngloan#c.lagrgdp i.year i.region1 i.industry1 if geoloc==4, vce (cluster region)

esttab using table_W_1.rtf, nogap se(3) star(* 0.10 ** 0.05 *** 0.01) b(3)
eststo clear

eststo: quietly xtreg lngfixasset lnaggreloan lagrgdp lnpop literacyrate c.lnaggreloan#c.lagrgdp i.year i.region1 i.industry1 if geoloc==4, vce (cluster region)
eststo: quietly xtreg lngfixasset lnsrtloan lagrgdp lnpop literacyrate c.lnsrtloan#c.lagrgdp i.year i.region1 i.industry1 if geoloc==4, vce (cluster region)
eststo: quietly xtreg lngfixasset lnlngloan lagrgdp lnpop literacyrate c.lnlngloan#c.lagrgdp i.year i.region1 i.industry1 if geoloc==4, vce (cluster region)
eststo: quietly xtreg lngfixasset lnprisrtloan lagrgdp lnpop literacyrate c.lnprisrtloan#c.lagrgdp i.year i.region1 i.industry1 if geoloc==4, vce (cluster region)
eststo: quietly xtreg lngfixasset lnprilngloan lagrgdp lnpop literacyrate c.lnprilngloan#c.lagrgdp i.year i.region1 i.industry1 if geoloc==4, vce (cluster region)

esttab using table_W_2.rtf, nogap se(3) star(* 0.10 ** 0.05 *** 0.01) b(3)
eststo clear

eststo: quietly xtreg lnnetfixasset lnaggreloan lagrgdp lnpop literacyrate c.lnaggreloan#c.lagrgdp i.year i.region1 i.industry1 if geoloc==4, vce (cluster region)
eststo: quietly xtreg lnnetfixasset lnsrtloan lagrgdp lnpop literacyrate c.lnsrtloan#c.lagrgdp i.year i.region1 i.industry1 if geoloc==4, vce (cluster region)
eststo: quietly xtreg lnnetfixasset lnlngloan lagrgdp lnpop literacyrate c.lnlngloan#c.lagrgdp i.year i.region1 i.industry1 if geoloc==4, vce (cluster region)
eststo: quietly xtreg lnnetfixasset lnprisrtloan lagrgdp lnpop literacyrate c.lnprisrtloan#c.lagrgdp i.year i.region1 i.industry1 if geoloc==4, vce (cluster region)
eststo: quietly xtreg lnnetfixasset lnprilngloan lagrgdp lnpop literacyrate c.lnprilngloan#c.lagrgdp i.year i.region1 i.industry1 if geoloc==4, vce (cluster region)

esttab using table_W_3.rtf, nogap se(3) star(* 0.10 ** 0.05 *** 0.01) b(3)
eststo clear
