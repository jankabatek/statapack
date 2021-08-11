********************************************************************************
*        TTEST - compare means of independent data subsets       
********************************************************************************
* FORMAT:	TTEST age no_mar  , base(div) by(psw) com(MHLdist) i(lvl_gen_CMPL)
*------------------j.kabatek@unimelb.edu.au, 03/2017, (c)----------------------*

capture program drop TTEST2

program define TTEST2
	syntax  [namelist], BY(varlist) base(varname) [COMmon(varlist) mf Ivars(namelist)] //[cntd]

	/* OUTPUT FORMATTING PRESETS */
	local colwidth = 5
	local valwidth = 7
	
	/* Temporary vars with correct comparison groups */
	local grouplist `by'
	set more off
  
	qui forvalues a = 1/1{ //auxiliary for loop to supress commands
		if "`namelist'" != "" {
			forvalues i = 1/2{
				n di " "
				if `i'==1{
					n di as text "MEN"
				}
				else{
					n di as text "WOMEN"
				}
		  
				local num: word count `grouplist'
				local linelength = 12*(`num' +  3) + 4
				n di as text "{hline 23} {hline `linelength'}"  
				
				n di as result %-23s "   Variable " "{c |}" %`colwidth's " " as text %`valwidth's "BASE"  _continue
				foreach group in `grouplist' {
					n di %`colwidth's " " as text %`valwidth's substr("`group'",1,`valwidth') _continue
					n di %`colwidth's " " as text %`valwidth's substr("Diff",1,`valwidth') _continue
					n di %`colwidth's " " as text %`valwidth's substr("Pval",1,`valwidth') _continue
				}
				n di " "
				
				foreach name in `namelist' { 
					foreach group in `grouplist' {
						ttest `name'`i' if (`base'==1 | `group'==1) , by(`group')
						local MU_norm = r(mu_1)
						local MU_`group'= r(mu_2)	
						local DIF_`group' = r(mu_1)-r(mu_2)
						local RP_`group' = r(p)
						if `DIF_`group'' < 0 {
							local SGN_`group' res
						}
						else {
							local SGN_`group' err
						}
						if abs(r(t)) > 2.58 {
							local SIG_`group' "***"
						}
						else if abs(r(t)) > 1.96 {
							local SIG_`group' "** "
						}
						else if abs(r(t)) > 1.65 {
							local SIG_`group' "*  "
						}
						else{
							local SIG_`group' "   "
						}
					}
					n di as text %-23s "`name'" "{c |}" %`colwidth's " " as result %`valwidth'.2f `MU_norm' %`colwidth's " "  _continue					
					foreach group in `grouplist' {
						n di as `SGN_`group'' %`valwidth'.2f `MU_`group'' as result %-`colwidth's "`SIG_`group''"     _continue 
						n di as result %`valwidth'.2f `DIF_`group'' as result %-`colwidth's "`SIG_`group''"     _continue 
						n di as result %`valwidth'.3f `RP_`group'' as result %-`colwidth's "`SIG_`group''"     _continue 
					}
					
					n di " "
				}
				
				/* categorical variable decomposition */
				foreach ivar in `ivars' { 			 
					cap drop ttaux*
					qui tab `ivar'`i', gen(ttaux_)
					qui d  ttaux_*, varl
					local ivgroups =  r(varlist)
					
					n di as text %23s "   " "{c |}"
					n di as text %23s "- `:var label  `ivar'`i'' - " "{c |}"
					local cnt = 0
					foreach name in `ivgroups' { 
						foreach group in `grouplist' {
							ttest `name' if (`base'==1 | `group'==1) , by(`group')
							local MU_norm = r(mu_1)
							local MU_`group'= r(mu_2)	
							local DIF_`group' = r(mu_1)-r(mu_2)
							local RP_`group' = r(p)
							if `DIF_`group'' < 0 {
								local SGN_`group' res
							}
							else {
								local SGN_`group' err
							}
							if abs(r(t)) > 2.58 {
								local SIG_`group' "***"
							}
							else if abs(r(t)) > 1.96 {
								local SIG_`group' "** "
							}
							else if abs(r(t)) > 1.65 {
								local SIG_`group' "*  "
							}
							else{
								local SIG_`group' "   "
							}
						}
						
						n di as text %-23s "`:label `:value label  `ivar'`i'' `cnt''" "{c |}" %`colwidth's " " as result %`valwidth'.2f `MU_norm' %`colwidth's " " _continue
						local cnt = `cnt' + 1						
						foreach group in `grouplist' {
							n di as `SGN_`group'' %`valwidth'.2f `MU_`group'' as result %-`colwidth's "`SIG_`group''"     _continue 
							n di as result %`valwidth'.2f `DIF_`group'' as result %-`colwidth's "`SIG_`group''"     _continue 
							n di as result %`valwidth'.3f `RP_`group'' as result %-`colwidth's "`SIG_`group''"     _continue 

						}
						n di " "
					}	
					drop ttaux*
				} 
				n di as text "{hline 23} {hline `linelength'}"  
				
			} 
		}
	  
		/* COMMON VARIABLES */
		if "`common'" != "" {	  
			n di as text "COUPLE"
			n di as text "{hline 23} {hline `linelength'}"  
			n di as result %-23s " Variable " "{c |}" %`colwidth's " " as text %`valwidth's "BASE"  _continue
			foreach group in `grouplist' {
				n di %`colwidth's " " as text %`valwidth's substr("`group'",1,`valwidth') _continue
				n di %`colwidth's " " as text %`valwidth's substr("Diff",1,`valwidth') _continue
				n di %`colwidth's " " as text %`valwidth's substr("Pval",1,`valwidth') _continue
			}
			n di " "
			
			foreach name in `common' { 
				foreach group in `grouplist' {
					ttest `name' `ifclause' if (`base'==1 | `group'==1) , by(`group')
					local MU_norm = r(mu_1)
					local MU_`group'= r(mu_2)	
					local DIF_`group' = r(mu_1)-r(mu_2)
					local RP_`group' = r(p)
					if `DIF_`group'' < 0 {
						local SGN_`group' res
					}
					else {
						local SGN_`group' err
					}
					if abs(r(t)) > 2.58 {
						local SIG_`group' "***"
					}
					else if abs(r(t)) > 1.96 {
						local SIG_`group' "** "
					}
					else if abs(r(t)) > 1.65 {
						local SIG_`group' "*  "
					}
					else{
						local SIG_`group' "   "
					}
				}
			n di as text %-23s "`name'" "{c |}" %`colwidth's " " as result %`valwidth'.2f `MU_norm' %`colwidth's " " _continue				
				foreach group in `grouplist' {
					n di as `SGN_`group'' %`valwidth'.2f `MU_`group'' as result %-`colwidth's "`SIG_`group''"     _continue 
					n di as result %`valwidth'.3f `DIF_`group'' as result %-`colwidth's "`SIG_`group''"     _continue 
					n di as result %`valwidth'.3f `RP_`group'' as result %-`colwidth's "`SIG_`group''"     _continue 

				}
				n di " "
			}
			n di as text "{hline 23} {hline `linelength'}"  
		}
		
		n di "                      Values in red are lower than those reported in the 1st column."
		n di "                                   *** p<0.01, ** p<0.05, * p <0.1"
	}
end

