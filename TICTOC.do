********************************************************************************  
********************************************************************************
* TICTOC 	is a Matlab-style timer, free of all that useless syntax 
* INPUT: 	OPTIONAL: anylist = number for  
* 						
* OUTPUT: 	time
*
* FORMAT:	TIC 1
*			TOC 1
*------------------j.kabatek@unimelb.edu.au, 07/2016, (c)----------------------*

capture program drop TIC

program define TIC
	syntax [anything]

	cap confirm number `anything'
	if !_rc {
		di as err "Clock No. `anything' is turned on!"
	}
	else {
		local anything = 10
	}
	
	timer clear `anything'
	timer on `anything'
	
end

capture program drop TOC

program define TOC
	syntax [anything] 
 
 
 	cap confirm number `anything'
	if !_rc {
	 di as err "Clock No. `anything' is turned off!"
	}
	else {
	local anything = 10
	}
	
 
	timer off `anything'
	qui timer list `anything'
	
	if r(t1)<300 {
		di as err "Elapsed time: " r(t`anything') " sec"
		}
	else {
		di as err "Elapsed time: " r(t`anything') " sec, =" r(t`anything')/60 " mins"
	}
	
	
 
end

 
