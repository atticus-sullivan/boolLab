local lpeg = require"lpeg"
local utils = require"cond_expression_utils"
local tabular = require"tabular"

-- Lexical Elements
local Space = lpeg.S(" \n\t")^0
local var = lpeg.C(lpeg.R("Az")^1) * Space
local OR  = lpeg.C(lpeg.S("+") + lpeg.P("or") ) * Space
local AND = lpeg.C(lpeg.S("*") + lpeg.P("and")) * Space
local Open = "(" * Space
local Close = ")" * Space
local NOT = lpeg.C(lpeg.P("not") + lpeg.P("not")) * Space

-- Grammar
local Exp, Term, Factor = lpeg.V"Exp", lpeg.V"Term", lpeg.V"Factor"
G = lpeg.P{ Exp,
	Exp = lpeg.Ct(Term * (OR * Term)^0),
	Term = lpeg.Ct(Factor * (AND * Factor)^0),
	Factor = lpeg.Ct(NOT^-1 * (var + Open * Exp * Close)),
}
-- check if reached end of inputstring (-1 is empty string if nothing comes behind)
G = Space * G * -1

local expression = {str=nil, expr=nil, table=nil, vars=nil, parser=G} -- default values here

function expression:new(o) -- key/value passing
	o = o or {}
	setmetatable(o, self) -- use the same metatable for all objects
	self.__index = self -- lookup in class if key is not found
	return o
end

expression.__call = function(self, o) return self:new(o) end
setmetatable(expression, expression)

-- instanciation
-- obj = expression:new{attrs}
-- inheritance
-- sub = expression:new() -- overwrite function as sub:foo

function expression:str2expr()
	assert(type(self.str) == "string", "Cannot build expr, since str is not set")
	self.expr = self.parser:match(self.str)
	return self
end

function expression:expr2str()
	assert(type(self.expr) == "table", "cannot build string without expr")
	local function foo(expr)
		if type(expr) ~= "table" then return tostring(expr) end
		if #expr == 1 then return foo(expr[1]) end
		local r = "("
		local first = true
		for _,v in ipairs(expr) do
			local pref = first and "" or " "
			r = r .. pref .. foo(v)
			first = false
		end
		return r .. ")"
	end
	self.str = foo(self.expr)
	return self
end

function expression:eval(assignment)
	assert(type(self.expr) == "table", "can only evaluate expression if expr is set")
	-- evaluate a given expression based on a given assignment
	-- expression is supposed to be some sort of tree encoded with lists
	-- e.g. {"a", "and" {"b", "or", "c"}}
	local function foo(expr, assignment)
		-- if leaf in expression fill in the variable value
		if type(expr) ~= "table" then
			return assignment[expr]
		end
		-- catches and {...} -> ignore the layer
		if #expr == 1 then
			return foo(expr[1], assignment)
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
			return not foo(expr[2], assignment)
		else
			local o1 = foo(expr[1], assignment)
			for i=2,#expr,2 do
				o1 = e[expr[i]](
					o1,
					foo(expr[i+1], assignment)
					)
			end
			return o1
		end
	end
	return foo(self.expr, assignment)
end

function expression:expr2table()
	assert(type(self.expr) == "table" and type(self.vars) == "table", "vars and expr have to be set to be able to generate the table")
	self.table = {}
	for p in utils.permute(self.vars) do
		local input = ""
		for _,v in ipairs(self.vars) do
			input = input .. utils.bool2str(p[v])
		end
		local output = utils.bool2str(self:eval(p))
		self.table[input] = output
	end
	return self
end

function expression:expr2vars()
	assert(type(self.expr) == "table", "cannot retrieve vars if expr is not given")
	-- go through the parsed expression and collect all used variables
	-- returns a table with the variables as keys (done to simulate a set)
	local function foo(expr, vars)
		if vars == nil then vars = {} end
		if type(expr) ~= "table" then
			vars[expr] = "1"
			return vars
		end
		if #expr <= 2 then
			foo(expr[#expr], vars)
			return vars
		end
		foo(expr[1], vars)
		for i=2,#expr,2 do
			foo(expr[i+1], vars)
		end
		return vars
	end
	self.vars = utils.set2list(foo(self.expr, {}))
	table.sort(self.vars) -- sort the variables for uniform output
	return self
end

function expression:table2knfexpr(short)
	assert(type(self.table) == "table", "table has to be set for knfexpr")
	self.expr = {}
	local firstOuter = true
	for input,output in pairs(self.table) do
		if output == "0" then
			if not firstOuter then table.insert(self.expr, short and "*" or "and") end
			firstOuter = false
			local firstInner = true
			local i = 1
			local maxterm = {}
			for v in input:gmatch(".") do
				if not firstInner then table.insert(maxterm, short and "+" or "or") end
				firstInner = false
				if v == "0" then
					table.insert(maxterm, {self.vars[i]})
				else
					table.insert(maxterm, {short and "not" or "not", self.vars[i]})
				end
				i = i+1
			end
			table.insert(self.expr, maxterm)
		end
	end
	return self
end

function expression:table2dnfexpr(short)
	assert(type(self.table) == "table", "table has to be set for dnfexpr")
	self.expr = {}
	local firstOuter = true
	for input,output in pairs(self.table) do
		if output == "1" then
			if not firstOuter then table.insert(self.expr, short and "+" or "or") end
			firstOuter = false
			local firstInner = true
			local i = 1
			local minterm = {}
			for v in input:gmatch(".") do
				if not firstInner then table.insert(minterm, short and "*" or "and") end
				firstInner = false
				if v == "1" then
					table.insert(minterm, {self.vars[i]})
				else
					table.insert(minterm, {short and "not" or "not", self.vars[i]})
				end
				i = i+1
			end
			table.insert(self.expr, minterm)
		end
	end
	return self
end

function expression:equiv(other)
	local set1 = utils.list2set(self.vars)
	local set2 = utils.list2set(other.vars)
	local vars = utils.union(set1, set2)

	for p in utils.permute(vars) do
		if self:eval(p) ~= other:eval(p) then return false end
	end
	return true
end

function expression.print_truthtable(...) -- prints truthtable of arguments
	local tab = {}

	local vars = {}
	for i,v in ipairs({...}) do
		assert(type(v.vars) == "table", string.format("vars has to be set for truthtable printing (arg %d)", i))
		assert(type(v.expr) == "table", string.format("expr has to be set for truthtable printing (arg %d)", i))
		assert(type(v.str) == "string", string.format("str has to be set for truthtable printing (arg %d)", i))
		vars = utils.union(vars, v.vars)
	end
	table.sort(vars)

	local hdr = {}
	for _,v in ipairs(vars) do
		table.insert(hdr, v)
	end
	table.insert(hdr, "")
	for _,v in ipairs({...}) do
		table.insert(hdr, "\"" .. v.str .. "\"")
	end
	table.insert(tab, hdr)

	local row 
	for p in utils.permute(vars) do
		row = {}
		for _,v in ipairs(vars) do
			table.insert(row, utils.bool2str(p[v]))
		end
		table.insert(row, "")
		for _,v in ipairs({...}) do
			table.insert(row, utils.bool2str(v:eval(p)))
		end
		table.insert(tab, row)
	end

	print()
	tabular.tabular_printing(tab)
end

return expression
