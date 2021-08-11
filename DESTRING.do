********************************************************************************
*                DESTRING - program for faster decoding of string vars        
********************************************************************************
* DESTRING 	turns string variables into numerical variables of desired type. 
* INPUT: 	varlist = bunch of string variables. Non-string vars are ignored. 
* 			OPTIONAL: 	typ = resulting data type (byte, int, float, etc.)
* 						
* OUTPUT: 	returns recoded variables (replaced)
*
* FORMAT:	DESTRING *_mx, typ(int)
*------------------j.kabatek@unimelb.edu.au, 07/2016, (c)----------------------*

capture program drop DESTRING

program define DESTRING
	syntax varlist(min=1), [typ(string asis)] 
	
	qui d  `varlist', varl  	//in order to get string of all variable names! (VERY USEFUL)
	local varlist_full =  r(varlist)
	
	foreach var in `varlist_full' {
		cap confirm string variable `var'
		if !_rc {
				qui cap drop `var'_f 
				gen `typ' `var'_f = real(`var')
				qui drop `var'
				qui rename `var'_f `var'
		}
	}
				
	if "`typ'" == "" {
		compress `varlist_full' //if type left not specified, compress as much as possible.
	}
end
