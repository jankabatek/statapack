********************************************************************************
*       PLOTB - plots the regression estimates of a factorized variable         
********************************************************************************
* PLOTB 	plots the resgression estimates of a factorized variable (i.`VAR')
*
* REQUIRES: one variable used in the preceding regression
*			 
* INPUT: 	varlist = variable that is graphed
* 	
* OPTIONAL: clear 	 = delete stored graphs. Without this option, additional 
*                      graphs are stored in the same data frame and plotted
*			constr   = plot only a subset of factors from num1 to num2 
*			dropzero = replace zero values by missing (not plotted)
*			frame    = choose name for the data frame that stores the graphs
*			graph 	 = choose graph type. Default is a line
*			options  = add any stata graph options: opt(`" "')
*			nogen 	 = suppress graph, generates only data
*			nose 	 = suppress conf. intervals, plot only coeff. estimates
*			plotonly = do not tabulate new values, plot stored graphs only 
*			yshift 	 = shift y-axis values by pre-specified number
*			xshift 	 = shift x-axis values by pre-specified number
*  	  
* COMMENTS: - requires Stata 16 and higher (leveraging frames structures)
*           - graphregion is white by default 
*
/* EXAMPLE: 
			sysuse nlsw88.dta
			reg never_married i.age
			PLOTB age, clear gr(connected) opt(`" title("Title") "')
*/
*
*------------------j.kabatek@unimelb.edu.au, 08/2021, (c)----------------------*

capture program drop PLOTB

program define PLOTB

	syntax  anything,	[clear CONstraint(numlist max=2) DROPZero GRaph(name) FRame(string) NOSE NOGen OPTions(string) PLOTonly XSHift(real 0)  YSHift(real 0)  ]  
		local varlist `anything'
		  
		local color1 
		local color2
		local color3
		local color4
		local color5
								 
		** find out from which frame is the PLOTTABS command called
		frame pwf
		local frame_orig = r(currentframe)
		
		** define the plottab output frame (stores the graph data), override create cmd if already exists		 
		if "`frame'" == ""  {
			local frame_pt frame_pt
		}
		cap frame create `frame_pt'
		
		** define the auxiliary output frame_orig
		cap frame drop   frame_pt_aux
		cap frame create frame_pt_aux
		
		** if `clear', delete the graph data already stored in the frame
		if "`plotonly'" == ""  {
			if "`clear'" != "" frame `frame_pt': cap drop x_val* 
			if "`clear'" != "" frame `frame_pt': cap drop plot_val* 
		}
		
		** do variables exist? (nullifies _rc for the rest)
		*cap confirm var `varlist' 
		cap di " "
		
		** how many variables stored already?
		local i = 0
		while _rc ==0 {
			local i = `i' + 1
			frame `frame_pt': cap confirm var plot_val`i'2
		}
		 
		** only plotting?
		if "`plotonly'" != ""  {
			local i = `i' -1	
			n di as err `i' " - plotting already stored graphs"
		}
		else {												 
			/* PREP */
			if "`constraint'" =="" { 
				qui sum `varlist'
				local min = r(min)
				local max = r(max)
			}
			else {
				tokenize "`constraint'"
				local min = `1'
				local max = `2'
			}

			local cols = 4
			if "`nose'" !="" {
				local cols  = 2
				n di as err "  - just estimates, no standard errors"
			}

			mat PL = J(1,`cols',.)
			/* READ ESTIMATES INTO A MATRIX */
			qui forvalues ii= `min'/`max' {
				cap di _b[`ii'.`varlist']
				if _rc ==0 {
					if "`nose'" =="" {
						local LC = _b[`ii'.`varlist'] - 1.96*_se[`ii'.`varlist']
						local UC = _b[`ii'.`varlist'] + 1.96*_se[`ii'.`varlist']
						mat PL = [PL \ `ii' , _b[`ii'.`varlist'], `LC', `UC' ]
					}
					else {
						mat PL = [PL \ `ii' , _b[`ii'.`varlist']]
					}
				}
			}
 
			/* TURN MATRIX INTO AUX VARIABLES */
			cap drop PL_AUX*
			frame `frame_pt': svmat PL, names(plot_val`i')
			
			qui if "`dropzero'" !="" {
				frame `frame_pt':  for var plot_val*: replace X = . if X ==0
			}
			
			if "`xshift'" !="" {
				frame `frame_pt':  replace plot_val`i'1 = plot_val`i'1 + `xshift'
			}
			
			if "`yshift'" !="" {
				frame `frame_pt': for num 2/4:  replace plot_val`i'X = plot_val`i'X + `yshift'
			}

			/* PLOT AUX VARIABLES */
			** graph type
			if "`graph'"== "" local graph = "line"
			n di "  - plot type: " "`graph'" 
				
			** additive twoway command
			local graph_syntax = ""
			forvalues j = 1/`i'{
				if "`nose'" !="" {
					local graph_syntax2 `graph_syntax2' (`graph' plot_val`j'2 plot_val`j'1 , `pattern`j'' )
				}
				else {
					local graph_syntax1 `graph_syntax1' (rarea plot_val`j'3 plot_val`j'4  plot_val`j'1 , `pattern`j'' fcolor(%15`color`j'')    lwidth(none) )
					local graph_syntax2 `graph_syntax2' (`graph' plot_val`j'2 plot_val`j'1 , `pattern`j'' )
				}
			}
			local graph_syntax twoway `graph_syntax1' `graph_syntax2'
			** plot
			
			if "`nogen'" == "" {
				frame `frame_pt':  `graph_syntax' , graphregion(fcolor(white)) `options'
			}  
		}
		 
end

 