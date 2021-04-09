/**************************************************************

	DO file to accompany 
	"The Effect of the TseTse Fly on African Development"
	
	Relies on:
	x_ols
	cgmreg
    
* To run this do file: Change the working directory to the main
folder for everything to run
**************************************************************/
version 12
clear all
set more off
capture log close 

*dataset has all the variables combined from the 3 different data sources
use "data/precolonial.dta", clear


log using analysis.txt, text replace 

* Define control variables
local controlsclimate prop meantemp meanrh itx 
local controlsmalaria prop meantemp meanrh itx malaria_index 
local controlswater prop meantemp meanrh itx malaria_index coast river 
local controlsall prop meantemp meanrh itx malaria_index coast river lon abslat meanalt SI
/*
	Table 1 - Reduced form estimates
*/
for @ in any animal female intensive plow slave central ln_popd_murdock : reg @ TSI `controlsclimate', vce(cluster province)
for @ in any animal female intensive plow slave central ln_popd_murdock : regress @ TSI `controlsmalaria', vce(cluster province)
for @ in any animal female intensive plow slave central ln_popd_murdock : reg @ TSI `controlswater', vce(cluster province)
for @ in any animal female intensive plow slave central ln_popd_murdock : reg @ TSI `controlsall', vce(cluster province)


/*
	Table 2 - Subsistence patterns
*/
for @ in any hunting husbandry agriculture gathering fishing: reg @ TSI `controlsall', vce(cluster province)

/*
	Table 3 - Robustness
*/
*Perturb TSI (1,2)
for @ in any animal female intensive plow slave central ln_popd_murdock : reg @ perturb_TSI1 `controlsall' , vce(cluster province) 
for @ in any animal female intensive plow slave central ln_popd_murdock : reg @ perturb_TSI2 `controlsall' , vce(cluster province) 

* Instrinsic Rate of Growth- (3)  
for @ in any animal female intensive plow slave central ln_popd_murdock : reg @ r `controlsall' , vce(cluster province) 

* Boxplot - (4)  
bcskew0 bp_N = N
for @ in any animal female intensive plow slave central ln_popd_murdock : reg @ bp_N `controlsall' , vce(cluster province)

* Optimum -(5) Rogers and Randolph measure of TseTse 
for @ in any animal female intensive plow slave central ln_popd_murdock : reg @ optimum `controlsall' , vce(cluster province)

* Conley clusters= (6)
gen cutoff1=10
gen cutoff2=10
gen constant=1


foreach var in animal intensive plow female ln_popd_murdock  slave central {
preserve
drop if `var'==.
x_ols lat lon cutoff1 cutoff2  `var' TSI meantemp meanrh itx prop_tropics malaria_index coast river meanalt SI abslat lon constant, xreg(13) coord(2) 
drop epsilon window dis1 dis2
restore 
}


* Country clusters -(7) 
for @ in any animal female intensive plow slave central ln_popd_murdock : reg @ TSI  `controlsall', vce(cluster isocode)

* Multiway clustering- (8) 
for @ in any animal female intensive plow slave central ln_popd_murdock : cgmreg @ TSI  `controlsall', cluster(province isocode)


/*
	Table 4 - Comparing Murdock Map and thiessen polygon
*/
keep if prop_tropics==1 
for @ in any animal female intensive plow slave central ln_popd_murdock : reg @ TSI  `controlsall', cluster(province)
use "data/placebo.dta", clear 
keep if africa == 1
gen prop_tropics=1
for @ in any animal female intensive plow slave central ln_popd_murdock : reg @ TSI  `controlsall', cluster(province)

/*
	Tables 5 & 6 - Placebo/Simulation
*/
use "data/placebo.dta", clear 

*Running different simulations

reg animals TSI  meantemp meanrh itx abslat lon malaria_index coast river meanalt SI africa africa_*, vce(cluster language) 
lincom africa_tsetse + TSI 
preserve
keep if africa==1 
predict v1
replace africa_tsetse=-1
predict v2
gen change=v2-v1
sum animals v2 v1 change
restore
reg plow2  TSI meantemp meanrh itx abslat lon malaria_index coast river meanalt SI africa africa_*,  vce(cluster lang)
lincom africa_tsetse + TSI 
preserve
keep if africa==1 
predict v1
replace africa_tsetse=-1
predict v2
gen change=v2-v1
sum plow2 v2 v1 change
restore
reg intensive  TSI meantemp meanrh itx abslat lon malaria_index coast river meanalt SI africa africa_*, vce(cluster lang)
lincom africa_tsetse + TSI 
preserve
keep if africa==1 
predict v1
replace africa_tsetse=-1
predict v2
gen change=v2-v1
sum intensive  v2 v1 change
restore
reg female  TSI meantemp meanrh itx abslat lon malaria_index coast river meanalt SI africa africa_*, vce(cluster lang)
lincom africa_tsetse + TSI 
preserve
keep if africa==1 
predict v1
replace africa_tsetse=-1
predict v2
gen change=v2-v1
sum female v2 v1 change
restore 
reg slave  TSI meantemp meanrh itx abslat lon malaria_index coast river meanalt SI africa africa_*, vce(cluster lang)
lincom africa_tsetse + TSI 
preserve
keep if africa==1 
predict v1
replace africa_tsetse=-1
predict v2
gen change=v2-v1
sum slave v2 v1 change
restore
reg central TSI meantemp meanrh itx abslat lon malaria_index coast river meanalt SI africa africa_*,  vce(cluster lang)
lincom africa_tsetse + TSI 
preserve
keep if africa==1 
predict v1
replace africa_tsetse=-1
predict v2
gen change=v2-v1
sum central v2 v1 change
restore

/*
	Table 7- Modern Analysis
*/
use "data/subnational.dta", clear
local controlsclimate meantemp meanrh itx  prop_tropics
local controlsmalaria meantemp meanrh itx  prop_tropics malaria
local controlsgeo meantemp meanrh itx abslat prop malaria near_inland coast longitude meanalt SI 

reg ln_lights tsi  `controlsclimate', vce(cluster adm0_code)
reg ln_lights tsi  `controlsmalaria' , vce(cluster adm0_code)
reg ln_lights tsi  `controlsgeo' , vce(cluster adm0_code)
reg ln_lights tsi  `controlsgeo' i.adm0_code , vce(cluster adm0_code)
reg ln_lights tsi  `controlsgeo'  frcn_central  i.adm0_code , vce(cluster adm0_code) 
reg ln_livestock tsi  `controlsclimate', vce(cluster adm0_code)
reg ln_livestock tsi  `controlsmalaria' , vce(cluster adm0_code)
reg ln_livestock tsi  `controlsgeo' , vce(cluster adm0_code)
reg ln_livestock tsi  `controlsgeo' i.adm0_code , vce(cluster adm0_code)
reg ln_livestock tsi  `controlsgeo'  frcn_central  i.adm0_code , vce(cluster adm0_code) 


log close
view analysis.txt

/*
	Figure 1 - TSI vs. SI 
*/ 
use "data/precolonial.dta", clear 
twoway (lfit SI TSI)(scatter SI TSI, sort msymbol(circle) msize(large)  mlcolor(maroon) mfcolor(none) ), ytitle(Suitability for Rainfed Agriculture) xtitle(TseTse Suitability Index) xlabel(, valuelabel) legend(off)
graph save Graph "output/Figure_I.gph", replace

/*
	Figure 4 - Mean Precolonial Outcomes by Quartile TSI 
*/ 
use "data/precolonial.dta", clear
xtile category = TSI, nq(4)
label define quartiles 1 "0-25%" 2 "26-50%" 3 "51-75%" 4 "76-100%"
label values categ quartiles
foreach var in animals plow intensi female slave central city  {
bysort categ: egen total_`var'=count(`var') if `var'==1
sum `var' 
gen global_total_`var'=r(N)
bysort catego: gen _`var'=(total_`var'/global_total_`var')
label var _`var' "Mean `var'"
}
graph bar (mean) _animal _plow _inte _central _city, over(categ) yscale(range(0 .25)) legend(on order(1 "Large Domesticated Animals" 2 "Plow Use" 3 "Intensively Cultivate" 4 "Political Centralization" 5 "City 1800"))
graph save Graph "Figure_IVa.gph", replace 
graph bar (mean) _slave _female, over(cate) bar(2, fcolor(gs10) lcolor(gs16)) legend(on order(1 "Indigenous Slavery" 2 "Female Participation in Agriculture" ))
graph save Graph "output/Figure_IVb.gph", replace 


