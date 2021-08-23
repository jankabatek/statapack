/*	capture confirm file "${DATA}/DUMMY_DATA.dta"
	if _rc != 0 {
		webuse set https://www.jankabatek.com/datasets/
		webuse https://www.jankabatek.com/datasets/daughters_pseudo_data 
	}
	
	*/
	
	
	clear
	set more off							
	set obs 80000								
	set seed 123
	
	gen gr = 1 + (_n>=40000)
	gen x1 = floor(log(rnormal(3,2)) * 10) + 25 
	drop if x1 < 0 
	replace x1 = 50 - x1 if gr ==1
	 
	PLOTTABS if gr==1, over(x1) clear 
	PLOTTABS if gr==2, over(x1) gr(bar) opt(title("Frequencies of observations, conditional on x") xtitle("x") ytitle("Frequency") legend(on order(1 "Group 1" 2 "Group 2")) xsize(7)"')  gropt(`" color(%50))
	
		 
	gen gr10 = mod(_n,10) + 1 
	gen x2 = floor(_n/100)
	gen y =  log(x2) - log(gr10) + rnormal(0,0.01)
	replace y = . if y <0
	
	PLOTMEANS y if gr10 ==1, over(x2) clear opt(legend(off) ytitle(y) xtitle(x) title(Conditional means of outcome y for 10 groups) xsize(6))
	for num 2/10: PLOTMEANS y if gr10 ==X, over(x2) gray opt(legend(off) ytitle(y) xtitle(x) title(Conditional means of outcome y for 10 groups) xsize(6))
	
	  
	gen z = 3*(1 - (_n / _N)^2) + rnormal(0,1.5) - 0.5
	replace z = 0 if z <0 
	replace z = 3 if z >3
	replace z = round(z)
	cap gen x3 = floor(_n/1000)
	*PLOTAREA z, over(x3) opt(`" title("Shares of observations belonging"  "to groups 1-4, conditional on x") xtitle("x") ytitle("Share") legend(on rows(4) pos(3) order(1 "Group 1" 2 "Group 2" 3 "Group 3" 4 "Group 4")) xsize(7) "')
	 
	 
	 
	webuse set https://www.jankabatek.com/datasets/
	webuse plotdata, clear
	qui https://raw.githubusercontent.com/jankabatek/statapack/master/PLOTTABS.do
	PLOTTABS if gr==1, over(x1) clear 
	PLOTTABS if gr==2, over(x1) graph(bar) options(title("Frequencies of observations, conditional on x") xtitle("x") ytitle("Frequency") legend(on order(1 "Group 1" 2 "Group 2")) xsize(7)"')  gropt(`" color(%50))
 