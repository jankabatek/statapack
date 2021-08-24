	clear
	set more off							
	set obs 80000								
	set seed 123
	
	gen gr = 1 + (_n>=40000)
	gen x1 = floor(log(rnormal(3,2)) * 10) + 25 
	drop if x1 < 0 
	replace x1 = 50 - x1 if gr ==1
	 
	*PLOTTABS if gr==1, over(x1) clear 
	*PLOTTABS if gr==2, over(x1) gr(bar) opt(title("Frequencies of observations, conditional on x") xtitle("x") ytitle("Frequency") legend(on order(1 "Group 1" 2 "Group 2")) xsize(7))  gropt(color(%50))
	
		 
	gen gr10 = mod(_n,10) + 1 
	gen x2 = floor(_n/100)
	gen y =  log(x2) - log(gr10) + rnormal(0,0.01)
	replace y = . if y <0
	
	*PLOTMEANS y if gr10 ==1, over(x2) clear opt(legend(off) ytitle(y) xtitle(x) title(Conditional means of outcome y for 10 groups) xsize(6))
	*for num 2/10: PLOTMEANS y if gr10 ==X, over(x2) gray opt(legend(off) ytitle(y) xtitle(x) title(Conditional means of outcome y for 10 groups) xsize(6))
	
	  
	gen gr4 = 3*(1 - (_n / _N)^2) + rnormal(0,1.5) - 0.5
	replace gr4 = 0 if gr4 <0 
	replace gr4 = 3 if gr4 >3
	replace gr4 = round(gr4)
	cap gen x3 = floor(_n/1000)
	*PLOTAREA gr4, over(x3) opt(`" title("Shares of observations belonging"  "to groups 1-4, conditional on x") xtitle("x") ytitle("Share") legend(on rows(4) pos(3) order(1 "Group 1" 2 "Group 2" 3 "Group 3" 4 "Group 4")) xsize(7) "')
	 
	 cap drop d*
	 gen z1 = round(rnormal(0.4,0.1)) + 0.15*(_n>30000)
	 gen z2 = round(rnormal(0.5,0.1)) + 0.25*(_n>40000)
	 gen z3 = round(rnormal(0.6,0.1)) + 0.35*(_n>50000)
 
	 reg z1 i.x3
	 PLOTB i.x3, clear 
	 reg z2 i.x3
	 PLOTB i.x3
	 reg z3 i.x3
	 PLOTB i.x3, opt(title(Comparing coefficient estimates from three regression models) xtitle("Value of factorized regressor x") ytitle("Coefficient estimate") legend(on rows(1) order(4 "1st coeff.set" 5 "2nd coeff.set" 6 "3rd coeff.set")) xsize(6.5))
	 
	 compress
	 save "C:\Users\jkabatek\plotdata.dta", replace
	 