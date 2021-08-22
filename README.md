# Statapack

this is a collection of custom stata programs that I use on a regular basis:

    EST_ADD
    EST_REPLACE
    PLOTAREA
    PLOTB 
    PLOTMEANS
    PLOTTABS
    TICTOC

The PLOT family of commands is particularly useful, enabling Stata users to:
1. plot multiple conditional frequencies (e.g., numbers of workers by age and gender)
2. plot multiple conditional shares of dummy variables (e.g., employment shares over time by region)
3. plot multiple conditional means of variables (e.g., average wages over time by gender)
4. plot multiple conditional shares of categorical variables (e.g., industry shares over time)
5. plot multiple coefficient estimates of factorized regressors

The PLOT family has two main advantages: the commands are very fast, they use the bare minimum of memory, and they allow user to store multiple graphs in memory and overlay them into one plot. To use the commands, just execute the respective do-files in the Stata command line (or paste them into the preamble of your code). 

Note: PLOT commands only work with Stata 16 and above because they leverage frame structures. If you want to make it work for earlier versions of Stata, remove the frame structures from the code. 
If you like these commands and would like to help with converting them into proper .ado Stata routines with help files and all that, please get in touch. 

## Example 1: Conditional frequencies with PLOTTABS

This example is equivalent to merging two histograms with discrete bin widths (with option *freq*):
 
![2 histograms](figures/2histograms.png) 

Code:

    webuse set https://www.jankabatek.com/datasets/
    webuse plotdata, clear
    qui do https://raw.githubusercontent.com/jankabatek/statapack/master/PLOTTABS.do
    // first histogram (gr=1), option clear erases previous PLOT data from the memory
    PLOTTABS if gr==1, over(x1) clear 
    // second histogram (gr=2), specify the graph type, twoway options & graph options (options are wrapped in `" "' to allow for titles and legends that use parentheses) 
    PLOTTABS if gr==2, over(x1) graph(bar) options(`" title("Frequencies of observations, conditional on x") xtitle("x") ytitle("Frequency") legend(on order(1 "Group 1" 2 "Group 2")) xsize(7)"')  gropt(`"color(%50)"')


