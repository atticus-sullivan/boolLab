local function shallow_copy(t)
	local r = {}
	for i,v in ipairs(t) do
		r[i] = v
	end
	return r
end

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
	local _vars = shallow_copy(vars) -- copy since _permute will modify vars
	return coroutine.wrap(function() _permute(_vars, {}) end)
end

local function bool2str(x)
	if x then return "1" else return "0" end
end

local function set2list(set)
	local list = {}
	for k,_ in pairs(set) do
		table.insert(list, k)
	end
	return list
end

local function list2set(list)
	local set = {}
	for _,v in ipairs(list) do
		set[v] = "1"
	end
	return set
end

local function union(t1,t2)
	local r = {}
	for k,v in pairs(t1) do
		r[k] = v
	end
	for k,v in pairs(t2) do
		r[k] = v
	end
	return r
end

local function table_print(t)
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

return {
	shallow_copy = shallow_copy,
	permute = permute,
	bool2str = bool2str,
	set2list = set2list,
	list2set = list2set,
	table_print = table_print,
	union = union,
}
