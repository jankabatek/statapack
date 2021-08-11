capture program drop EST_REPLACE_B
	
program define EST_REPLACE_B, eclass
	syntax anything [if]
	ereturn repost b = `anything'
end
