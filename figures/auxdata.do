/*	capture confirm file "${DATA}/DUMMY_DATA.dta"
	if _rc != 0 {
		webuse set https://www.jankabatek.com/datasets/
		webuse daughters_pseudo_data 
	}
	
	*/
	
	
	clear
	set more off							
	set obs 80000								
	set seed 123
	
	gen gr = 1 + (_n>=40000)
	gen x = floor(log(rnormal(3,2)) * 10) + 25
	drop if x < 0 
	replace x = 50 - x if gr ==1
	 
	PLOTTABS x if gr==1  , clear 
	PLOTTABS x if gr==2  , gr(bar) opt(`" title("Frequencies of records, conditional on x") xtitle("x") ytitle("Frequency") legend(on order(1 "Group 1" 2 "Group 2"))"')  gropt(`" color(%50) "')
	  
	gen y = 3*(1 - (_n / _N)^2) + rnormal(0,1.5) - 0.5
	replace y = 0 if y <0 
	replace y = 3 if y >3
	replace y = round(y)
	cap gen n = floor(_n/1000)
	PLOTAREA y, over(n) opt(`" title("Relative shares of records, conditional on x") xtitle("x") ytitle("Share") legend(on rows(4) pos(3) order(1 "Group 1" 2 "Group 2" 3 "Group 3" 4 "Group 4")) xsize(6) "')
	 
	gen mod = mod(_n,10)
	gen n2 = floor(_n/100)
	gen z =  log(n2) + mod + rnormal(0,2)
	
	PLOTMEANS z, over(n2) clear