local lpeg = require"lpeg"
local tabular = require"tabular"
local utils = require"eqCheck_utils"
local argparse = require"argparse"

-- permute over the differnt assignments for a set of vars (list of strings)
-- ATTENTION: this function will modify the vars list (in effect it will be empty on each yield)
local function _permute(vars, assignment)
	-- if all variables are set, yield the accumulated assignment
	if vars[1] == nil then coroutine.yield(assignment) return end

	-- pop the variable to handle in this recursion step
	local v = table.remove(vars, 1)

	assignment[v] = false
	_permute(vars, assignment) -- go one step deeper in recursion tree, calculating the possible assignments set with v=false

	assignment[v] = true
	_permute(vars, assignment) -- go one step deeper in recursion tree, calculating the possible assignments set with v=true

	-- push the variable since it might have to be processed later again
	table.insert(vars, 1, v)
end

-- wrapper to create a generator
local function permute(vars)
	local _vars = utils.shallow_copy(vars) -- copy since _permute will modify vars
	return coroutine.wrap(function() _permute(_vars, {}) end)
end

-- evaluate a given expression based on a given assignment
-- expression is supposed to be some sort of tree encoded with lists
-- e.g. {"a", "and" {"b", "or", "c"}}
local function eval(expr, assignment)
	-- if leaf in expression fill in the variable value
	if type(expr) ~= "table" then
		return assignment[expr]
	end
	-- catches and {...} -> ignore the layer
	if #expr == 1 then
		return eval(expr[1], assignment)
	end
	-- operator mapping
	local e = {
		["and"] = function(a,b) return a and b end,
		["*"]   = function(a,b) return a and b end,

		["or"] = function(a,b) return a or b end,
		["+"]  = function(a,b) return a or b end,
	}
	-- not is a special case since it is a prefix operator
	if expr[1] == "not" then
		return not eval(expr[2], assignment)
	else
		local o1 = eval(expr[1], assignment)
		for i=2,#expr,2 do
			o1 = e[expr[i]](
				o1,
				eval(expr[i+1], assignment)
				)
		end
		return o1
	end
end

-- go through all permutations of vars and evaluate the expression to print a truthtable
local function truthtable(vars, exprs, raw)
	local tab = {}
	local equals = true
	local last,current -- output of the curent and the last expression to be able to check for missmatch
	table.sort(vars) -- sort the variables for better to look at output

	-- copy for printing the header (nessacary since this row will contain some
	-- other stuff but the original vars is still needed
	local hdr = utils.shallow_copy(vars)
	-- if not raw then
		table.insert(hdr, "")
	-- end
	for _,v in ipairs(exprs) do
		table.insert(hdr, "\"" .. v.str .. "\"")
	end
	table.insert(tab, hdr)

	-- in the following its important that the order of vars is not changed anymore -> ipairs instead of pairs
	for p in permute(vars) do
		local row = {} -- list holding the strings of each cell for the table
		-- generate left side of the truthtable
		for _,v in ipairs(vars) do
			table.insert(row, utils.boolToStr(p[v]))
		end
		-- if not raw then
			table.insert(row, "") -- one empty column to separate right ans left side
			-- generate right side of the truthtable
		-- end
		local first = true
		for _,v in ipairs(exprs) do
			current = eval(v.expr, p)
			-- if multiple expressions are given check for missmatch -> set equals to false
			if not first and current ~= last then equals = false end
			table.insert(row, utils.boolToStr(current))
			last = current
			first = false
		end
		table.insert(tab, row)
	end
	tabular.tabular_printing(tab)
	if not raw then
		print("\nEquals?", equals)
	end
end

-- gerate a parser for the language of booleans
-- returns a match function -> uses a closure to hide the lpeg objects
local function string2TreeGen()
	-- Lexical Elements
	local Space = lpeg.S(" \n\t")^0
	local var = lpeg.C(lpeg.R("az")^1) * Space
	local OR = lpeg.C(lpeg.S("+")) * Space
	local AND = lpeg.C(lpeg.S("*")) * Space
	local Open = "(" * Space
	local Close = ")" * Space
	local NOT = lpeg.C(lpeg.P("not")) * Space

	-- Grammar
	local Exp, Term, Factor = lpeg.V"Exp", lpeg.V"Term", lpeg.V"Factor"
	G = lpeg.P{ Exp,
		Exp = lpeg.Ct(Term * (OR * Term)^0),
		Term = lpeg.Ct(Factor * (AND * Factor)^0),
		Factor = lpeg.Ct(NOT^-1 * (var + Open * Exp * Close)),
	}
	-- check if reached end of inputstring (-1 is empty string if nothing comes behind)
	G = Space * G * -1


	return function(input)
		local r = G:match(input)
		return r
	end
end

-- go through the parsed expression and collect all used variables
-- returns a table with the variables as keys (done to simulate a set)
local function collectVars(expr, vars)
	if vars == nil then vars = {} end
	if type(expr) ~= "table" then
		vars[expr] = "1"
		return vars
	end
	if #expr <= 2 then
		collectVars(expr[#expr], vars)
		return vars
	end
	collectVars(expr[1], vars)
	for i=2,#expr,2 do
		collectVars(expr[i+1], vars)
	end
	return vars
end

local parser = argparse()
parser:argument("bool expr", "boolean expression to be checked"):args("+"):target("exprs")
parser:flag("-r --raw")

local args = parser:parse()
-- TODO argparse

local exprs = {}
local vars_set = {}
local expr,vars
local parser = string2TreeGen()
for _,v in ipairs(args.exprs) do
	expr = parser(v)
	if expr then
		if not args.raw then
			utils.table_print(expr) -- print the result with many {}s
		end
		vars = collectVars(expr)
		 -- union the two sets (epresented by using the keys as set menbers)
		vars_set = utils.union(vars_set,vars)
		-- table storing the parsed expression and the original string
		-- representation of the expression
		table.insert(exprs, {expr=expr, str=v})
	else
		print("Error in parsing " .. v .. " -> skipping")
	end
end

-- convert the set to a list
vars = {}
for k,_ in pairs(vars_set) do
	table.insert(vars, k)
end

if not args.raw then
	print()
end
truthtable(vars, exprs, args.raw)
