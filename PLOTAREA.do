********************************************************************************
*         PLOTAREA - plots disagregated shares in an area graph       
******************************************************************************** 
* PLOTAREA 	computes categorical shares of the variable of interest 
* 			(e.g., industry) over distinct values of the running variable 
*			(e.g., age of the workers) and plots them in an area graph   
*
* REQUIRES: one outcome variable and one running variable
*			 
* INPUT: 	varlist  = categorical variable of interest
*			over()	 = running variable (preferably integer)
*
* OPTIONAL: options  = add any stata twoway graph options: opt(`" "') 
*
* COMMENTS: graphregion is white by default
*			  
/* EXAMPLE: 
			sysuse nlsw88.dta 
			PLOTAREA industry, over(age) opt( legend(off) title("Industry shares, by age") ) 
*/
*
*------------------j.kabatek@unimelb.edu.au, 08/2021, (c)----------------------*

cap mata: mata drop SHARES()
mata
function SHARES()
	{
		MATVAL_ORIG = st_matrix("cell_val")
		MATVAL 		= MATVAL_ORIG
		 
		/* inverse selection : first category comes on the top of the graph */
		for (j=1; j<=cols(MATVAL); j++) {
			jinv = cols(MATVAL) - (j-1)
			MATVAL[,j] = MATVAL_ORIG[,jinv]
		} 
		
		SUMVAL = rowsum(MATVAL)
		
		for (j=1; j<=cols(MATVAL); j++) {
			for (i=1; i<=rows(MATVAL); i++) {
				MATVAL[i,j] = MATVAL[i,j] / SUMVAL[i,1]
			}
		}
		
		for (j=2; j<=cols(MATVAL); j++) {
			for (i=1; i<=rows(MATVAL); i++) {
				
				MATVAL[i,j] = MATVAL[i,j] + MATVAL[i,(j-1)] 
			}
		}
		
		st_matrix("MATVAL",MATVAL)
	}
end

********************************************************************************
capture program drop PLOTAREA  
program define PLOTAREA
	syntax varlist(max=1) [if], over(varname) [OPTions(string asis)] 
								 
	qui { 
		cap drop cell* 
		cap drop sum_val* 
		cap drop x_val*
		
		tab `over' `varlist' `if' , matcell(cell_val) matrow(x_val)
		
		local M = colsof(cell_val)
		svmat x_val
		
		mata: SHARES()
		svmat MATVAL, names(cell_val)
  
		local graph_syntax = ""
		local graph area
		
		forvalues m = `M'(-1)1{
			local graph_syntax `graph_syntax' (`graph' cell_val`m' x_val1 , `pattern`j'' yaxis(1 2) )
		}
		local graph_syntax twoway `graph_syntax'
		`graph_syntax', graphregion(fcolor(white) lcolor(white)) `options' 
  
	}
end
 
 