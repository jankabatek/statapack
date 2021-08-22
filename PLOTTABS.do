********************************************************************************
*         PLOTTABS - plots frequencies or rates from tabulated variables         
********************************************************************************
* PLOTTABS 	tabulates one or more variables oneway (twoway), and plots 
* 			the resulting frequencies (rates) against the values of (row) variable
*
* REQUIRES: one variable (or two variables, second one being a dummy)
*			 
* INPUT: 	varlist = variables that are tabulated, first one is the row variable
*
* OPTIONAL: clear 	 = delete stored graphs. Without this option, additional 
*                      graphs are stored in the same data frame and plotted
*			frame    = choose name for the data frame that stores the graphs 
*			options  = add any stata twoway options: opt(`" "')
*			groptions= add any stata graph options (for each plotted graph)
*			nogen 	 = suppress graph, generates only data
*			plotonly = do not tabulate new values, plot stored graphs only
*			row 	 = plot twoway rates, default is oneway frequencies 
* 
* 			graph 	 = choose graph type. Default is a line
* 			grayscale= self-explanatory
*			iflabel  = label lines by used if-conditions 
*			pattern	 = visual separation of distinct graph lines
*			patternc = visual separation of distinct graph lines + colours
*			relative = plot values relative to the firt tabulated balue  
*			yzero 	 = include zero on y axis 
*
* COMMENTS: - requires Stata 16 and higher (leveraging frames structures)
*           - graphregion is white by default, and ysize is set to 5
*			  
/* EXAMPLE: 
			sysuse nlsw88.dta
			PLOTTABS age collgrad, clear row gr(connected) opt(`" title("Share of college graduates, by age") xtitle("Age") ytitle("Share") "')
*/
*
*------------------j.kabatek@unimelb.edu.au, 08/2021, (c)----------------------*

** auxiliary MATA subroutine: 
cap mata: mata drop STEPFIND()
mata
function STEPFIND()
	{
		STEP = 0
		i = 0
		MATVAL = st_matrix("plot_val1")
		while (STEP == 0) {
			STEP = floor((max(MATVAL)/4)*(10^i))/(10^i)
			i = i+1	 
		}		
		st_numscalar("ystep",STEP)
	}
end


** PLOTTABS code:
capture program drop PLOTTABS 

program define PLOTTABS
	syntax [varlist(max=2)] [if], [clear DIVide(real 1) dif FRame(string) FMT(string) GRaph(name) GRAYscale GROPTions(string) ///
								 IFLabel NOGen NODraw OPTions(string) PATtern PATTERNCol PLOTonly  ///  
								 RELative row  TWOff YZero ] 		
								 
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
		
		** check whether plotted variable(s) exist (nullifies _rc for the rest)
		cap confirm var `varlist'
	 
		** how many graphs are stored already?
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
			n di as err `i' " - tabulating values for a new graph"
			
			** tabulate command
			tab `varlist' `if' , matcell(cell_val`i') matrow(x_val)
			
			** compute a rate for a binary column variale? 
			if "`row'" != "" {
				local M = rowsof(cell_val`i')
				mat plot_val`i' = J(`M',1,0)
				forvalues m = 1/`M' {
					mat plot_val`i'[`m',1] = cell_val`i'[`m',2] / (cell_val`i'[`m',1] + cell_val`i'[`m',2])
					*di plot_val`i'[`m',1]  
					if "`relative'" != "" {
						if `m' ==1 scalar base = plot_val`i'[1,1]
						mat plot_val`i'[`m',1]= (plot_val`i'[`m',1]/base)*100
					}
					if "`dif'" != "" {
						if `m' ==1 scalar base = plot_val`i'[1,1]
						mat plot_val`i'[`m',1]= (plot_val`i'[`m',1] - base)*100
					}
				}
			}
			** or plot frequencies of the 1st column?
			else {
				mat plot_val`i' = cell_val`i'
				if "`relative'" != "" {
						scalar denom = plot_val`i'[1,1]
						mat plot_val`i'= (plot_val`i'/denom)*100
				}
			}
			
			** divide the values by a constant?
			if "`divide'" != "" {
				mat plot_val`i' = plot_val`i' / `divide'
			}
			
			**store the graph data in the respective frame
			
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
		
		** include zero on the y-axis?
		if "`yzero'" != "" {
			** find the step size for the ylabel option, improve!
			mata: STEPFIND()
			local ystep = ystep
			local ymax = ystep*5
			local options `options' ylabel(0(`ystep')`ymax')
		}	
		
		** pattern definition for visual separation of distinct graph lines
		if "`pattern'" !="" { 
			n di "`pattern'"
		 local pi = 0	
		 forvalues p = 0/5 {
		 	 local pi = `pi' + 1
			 local pattern`pi'  msymbol(O) 	 lpattern(solid)
			 local pi = `pi' + 1
			 local pattern`pi'  msymbol(D) 	 lpattern(shortdash)  
			 local pi = `pi' + 1
			 local pattern`pi'  msymbol(S) 	 lpattern(longdash) 
			 local pi = `pi' + 1
			 local pattern`pi'  msymbol(T) 	 lpattern(longdash_shortdash) 
			 local pi = `pi' + 1
			 local pattern`pi'  msymbol(lgx) lpattern(shortdash_dot) 
		 }
		} 
		
		if "`patterncol'" !="" {
			n di "`patterncol'"
		 local pattern1  msymbol(O) 	color(sand)  	 lpattern(solid)  	 
		 local pattern2  msymbol(D) 	color(brown) 	 lpattern(shortdash)  			 
		 local pattern3  msymbol(S) 	color(gs5) 		 lpattern(longdash)   		  	 
		 local pattern4  msymbol(T)   	color(maroon) 	 lpattern(longdash_shortdash)   
		 local pattern5  msymbol(lgx)	color(cranberry) lpattern(solid)   
		}
		
		if "`grayscale'" !="" {
			local `i'
			forvalues j = 1/`i'{
				local val = floor((`i'-`j')/`i'*15)
				local pattern`j' lcolor(gs`val')
			}
		}
		
		** specific (time?) format for the x axis labels?
		if "`fmt'"!= "" local format = `"xlabel(,format(`fmt'))"'
		 
		** which graph type should be plotted 
		if "`graph'"== "" local graph = "line"
		n di "  - plot type: " "`graph'"  
		
		** two-way command, or streamlined syntax with line- or scatter- command?
		if "`twoff'"== "" {
			local graph_syntax = ""
			forvalues j = 1/`i'{
				local graph_syntax `graph_syntax' (`graph' plot_val`j'1 x_val1 , `pattern`j'' `groptions' )
			}
			local graph_syntax twoway `graph_syntax'
		}	
		else {
			local graph_syntax = ""
			forvalues j = 1/`i'{
				local graph_syntax `graph_syntax' plot_val`j'1  //streamlined does not include pre-specified patterns 
			}
			local graph_syntax `graph' `graph_syntax' x_val1
		}
		 
		** OUTPUT (sourced from the respective frame): 
		if "`nogen'" == ""  frame `frame_pt':  `graph_syntax'  ,  ysize(5) graphregion(fcolor(white) lcolor(white)) `options' `format' `nodraw'
		 
	}
end
 