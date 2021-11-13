--- Utilities for the cond_expression module.

local _M = {}

--- Creates a shallow copy of a table (array part).
-- Might use penlight for that thing
-- @tparam table t the table to copy
-- @treturn table copy of t
local function shallow_copy(t)
	local r = {}
	for i,v in ipairs(t) do
		r[i] = v
	end
	return r
end

--- iterator (1) for permuting over all possible assignments of a list of variables.
-- Generates in an ascending order (if seen assignment as binary number)
-- **Attention:** This function will modify it's `vars` argument (will be empty on each yield)
-- @tparam {string,...} vars a list of variable names (strings)
-- @tparam tab assignment accumulator in the recursion
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

--- iterator (2) for permuting over all possible assignments of a list of variables.
-- Generates in an ascending order (if seen assignment as binary number)
-- @tparam {string,...} vars a list of variable names (strings)
-- @return the iterator based on coroutines
function _M.permute(vars)
	local _vars = shallow_copy(vars) -- copy since _permute will modify vars
	return coroutine.wrap(function() _permute(_vars, {}) end)
end

--- Convert booleans to strings (`0`/`1`).
-- @tparam bool x the boolean to convert
-- @return the textual representation
function _M.bool2str(x)
	if x then return "1" else return "0" end
end

--- Converts a set (keys are values) to an array.
-- maybe replace with penlight
-- @tparam tab set a table with the keys as values
-- @treturn tab a list of the set entries
function _M.set2list(set)
	local list = {}
	for k,_ in pairs(set) do
		table.insert(list, k)
	end
	return list
end

--- Converts an array to a set (keys are values).
-- maybe replace with penlight
-- @tparam tab list
-- @treturn tab a table with the keys as values
function _M.list2set(list)
	local set = {}
	for _,v in ipairs(list) do
		set[v] = "1"
	end
	return set
end

--- Perform a union on two sets.
-- maybe replace with penlight
-- sets are tables with the keys as values
-- @tparam set t1 the one set
-- @tparam set t2 the other set
-- @treturn set a new set containing the set entries of both sets
function _M.union(t1,t2)
	local r = {}
	for k,v in pairs(t1) do
		r[k] = v
	end
	for k,v in pairs(t2) do
		r[k] = v
	end
	return r
end

--- Print a nested table
-- maybe replace with penlight
-- @tparam tab t the nested table
function _M.table_print(t)
	local function table_print_exec(t)
		if type(t) ~= "table" then io.write(tostring(t)) return end
		io.write("{")
		for _,v in ipairs(t) do
			table_print_exec(v)
			io.write(", ")
		end
		io.write("}")
	end
	table_print_exec(t)
	print()
end

return _M
