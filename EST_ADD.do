
capture program drop EST_ADD
	
program define EST_ADD, eclass
	syntax anything , [MATrix(string)]
	*ereturn repost `anything' = `anything'
	mat auxmat = `anything'
	ereturn matrix `matrix' = auxmat
end

 