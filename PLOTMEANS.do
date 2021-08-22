********************************************************************************
*         PLOTMEANS - plots within-group arithmetic means across groups    
********************************************************************************
* PLOTSUMS 	computes group-specific means for a variable of interest by OLS and 
* plots them (can be repeated for comparison purposes).
*
* REQUIRES: one outcome variable and one group variable
*			 
* INPUT: 	varlist = variable that is averaged 
*			over()	= group variable

* OPTIONAL: clear 	 = delete stored graphs. Without this option, additional 
*                      graphs are stored in the same data frame and plotted
*			frame    = choose name for the data frame that stores the graphs 
*			options  = add any stata graph options: opt(`" "')
*			nogen 	 = suppress graph, generates only data
*			plotonly = do not tabulate new values, plot stored graphs only 
*
*			graph 	 = choose graph type. Default is a line 
*			iflabel  = label lines by used if-conditions 
*			pattern	 = visual separation of distinct graph lines 
*
* COMMENTS: - requires Stata 16 and higher (leveraging frames structures)
*           - graphregion is white by default, and ysize is set to 5
*			  
/* EXAMPLE: 
			sysuse nlsw88.dta
			PLOTSUMS wage, over(age) clear gr(connected) opt(`" title("Average wages by age") xtitle("Age") ytitle("Avg. wage") "')
*/
*
*------------------j.kabatek@unimelb.edu.au, 08/2021, (c)----------------------*

capture program drop PLOTMEANS

program define PLOTMEANS
	syntax varlist(max=1) [if], over(varname) [clear divx(int 1) FRame(string) GRaph(name) GRAYscale NOGen NOLabel OPTions(string) PATtern IFLabel PLOTonly  ] 
								
	qui {
	    
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
		cap confirm var `varlist'
		
		** how many variables stored already?
		local i = 0
		while _rc ==0 {
			local i = `i' + 1
			frame `frame_pt': cap confirm var plot_val`i'1
		}
		
		if "`plotonly'" != ""  {
			local i = `i' -1	
			n di as err `i' " - plotting already stored graphs"
		}
		else {	
			n di as err `i'
			
			tempvar overtemp
			gen `overtemp' = `over'
			
			** get the plotted categories (xval) 
			tab `overtemp' `if' , matrow(x_val)
			
			** avoid negative-value factorization errors
			qui sum `over' `if'
			local rmin = r(min)
			if `rmin'< 0 {
			    replace `overtemp' = `overtemp' - `rmin'
			}
	
			** get the plotted means (by OLS, plotval`i') 
			reg `varlist' ibn.`overtemp' `if', nocons  //ibn indicates no base level (!)
			
			mat RES = r(table)
			mat plot_val`i' = RES[1,1...]'
			mat plot_val`i' = plot_val`i'/`divx'
		  
			
			** store the graph data in the respective frame
			if `i'==1 { 
				frame `frame_pt': svmat x_val 
				frame `frame_pt': svmat plot_val`i'
			}
			if `i'>1  {
				frame frame_pt_aux: svmat x_val 
				frame frame_pt_aux: svmat plot_val`i'
				frame frame_pt_aux: tempfile aux
				frame frame_pt_aux: save `aux', replace
				frame `frame_pt': merge 1:1 x_val1 using `aux', nogen
				frame `frame_pt': sort x_val1
			} 
			
			** assign conditional labels to auxiliary plot variables?
			if "`iflabel'" != "" {
				frame `frame_pt': label var plot_val`i'1 `"`if'"' 
			}
			else {
				local aux_num = wordcount("`varlist'")
				local aux_label : word `aux_num' of `varlist'				
				frame `frame_pt': label var plot_val`i'1  "`aux_label'"
			}	
			
		}		
		
		** line (and dash?) pattern definition
		if "`pattern'" !="" {
		 local pattern1 lpattern(solid)  msymbol(O)
		 local pattern2 lpattern(shortdash)  msymbol(D)
		 local pattern3 lpattern(longdash)   msymbol(S)
		 local pattern4 lpattern(longdash_shortdash)  msymbol(T)
		} 
		
		if "`grayscale'" !="" {
			local `i'
			forvalues j = 1/`i'{
				local val = floor((`i'-`j')/`i'*15)
				local pattern`j' lcolor(gs`val')
			}
		}
		
		*graph type option 
		if "`graph'"== "" local graph = "line"
		n di "  - plot type: " "`graph'" 
		
		local graph_syntax = ""
		forvalues j = 1/`i'{
			local graph_syntax `graph_syntax' (`graph' plot_val`j'1 x_val1 , `pattern`j'' )
		}
		local graph_syntax twoway `graph_syntax'
		 
		if "`nogen'" == "" frame `frame_pt': `graph_syntax' , graphregion(fcolor(white)) ysize(5) `options'
	}
end

 
