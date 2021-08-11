# Statapack

this is a collection of custom stata programs that I use on a regular basis:

    DESTRING
    EST_ADD
    EST_REPLACE
    PLOTAREA
    PLOTB 
    PLOTSUMS
    PLOTTABS
    TICTOC

The PLOT family of commands is particularly useful, expanding the graphing toolkit of Stata by commands which:
1. plot conditional shares of dummy variables (e.g., employment shares over time, or industry shares of workers)
2. plot conditional means of any variables (e.g., average wages over time)
3. plot conditional shares of categorical variables (e.g., industry shares over time)
4. plot coefficient estimates of factorized regressors

The PLOT commands have two main advantages: they are very fast, and they allow user to store multiple graphs in memory and overlay them into one plot. To use them, just execute the respective do-files in the preamble of your code. 

Note: PLOT commands only work with Stata 16 and above because they leverage frame structures. If you want to make it work for earlier versions of Stata, remove the frame structures from the code. Also, if you like these commands and you would like to convert them into a proper .ado Stata format with help files and all that, please get in touch. 


