local _M = {}

local utils      = require("cond_expression_utils")

local function expand(x)
	local function foo(x, i, acc)
		if i == #x+1 then acc[x] = true return end
		if x:sub(i,i) == "x" then
			local x0 = x:gsub("x", "0", 1)
			local x1 = x:gsub("x", "1", 1)
			foo(x0, i+1, acc)
			foo(x1, i+1, acc)
		else
			foo(x, i+1, acc)
		end
	end
	local ret = {}
	for _,v in pairs(x) do
		foo(v, 1, ret)
	end
	return ret
end

local function print_karnaugh_tab(t, vars)
	local gray = {
		{"0","1"},
		{"00", "01", "11", "10"},
		{"000", "001", "011", "010", "110", "111", "101", "100"},
		{
			"0000",
			"0001",
			"0011",
			"0010",
			"0110",
			"0111",
			"0101",
			"0100",
			"1100",
			"1101",
			"1111",
			"1110",
			"1010",
			"1011",
			"1001",
			"1000",
		}
	}
	local y = #vars - math.ceil(#vars/2)
	local x = math.ceil(#vars/2)
	local first = true
	for _,v1 in ipairs(gray[y]) do
		if not first then io.write("\n") else first = false end
		for _,v2 in ipairs(gray[x]) do
			if t[v2..v1] then io.write("1") else io.write(" ") end
			io.write(" ")
		end
		io.write("\n")
	end
end

local function combine(x1,x2)
	local ret,diff = "",0
	for i=1,#x1 do
		if x1:sub(i,i) == x2:sub(i,i)
		then
			ret = ret .. x1:sub(i,i)
		elseif x1:sub(i,i) ~= "x" and x2:sub(i,i) ~= "x" then
			diff = diff + 1
			ret = ret .. "x"
		else
			-- at least one different char was x
			return nil
		end
	end

	if diff > 1 then return nil else return ret end
end

local function perm(iterable, r)
	-- iterable is not to be modified from the outside
	local function foo(iterable, r)
		local pool = utils.shallow_copy(iterable)
		local n = #pool
		if r > n then return end
		local indices = {}
		for i=1,r do indices[i] = i end

		local ret = {}
		for i,v in ipairs(indices) do ret[i] = pool[v] end
		coroutine.yield(ret)

		while true do
			local globI = nil
			for i=r,1,-1 do
				if indices[i] ~= i+n-r then globI = i break end
			end
			if not globI then return end

			indices[globI] = indices[globI] + 1
			for j=globI+1,r do
				indices[j] = indices[j-1] + 1
			end

			ret = {}
			for i,v in ipairs(indices) do ret[i] = pool[v] end
			coroutine.yield(ret)
		end
	end
	iterable = utils.set2list(iterable)
	return coroutine.wrap(function() foo(iterable, r) end)
end

local function minimize(t)
	local tab = utils.shallow_copy(t)

	local changed
	repeat
		changed = false
		local t_new = {}
		local used = {}
		for k1,_ in pairs(t) do
			for k2,_ in pairs(t) do
				if k1 ~= k2 then
					local c = combine(k1,k2)
					if c then
						t_new[c] = true
						changed = true
						used[k1],used[k2] = true,true
						print("changed", c, k1, k2)
					else
						t_new[k1] = true
					end
				end
			end
		end
		for k,_ in pairs(used) do
			if t_new[k] then t_new[k] = nil end
		end
		utils.table_print_pairs(t_new)
		print()
		t = t_new
	until not changed or utils.set_size(t) == 1

	local ret = {}
	for i=1,utils.set_size(t) do
		for p in perm(t, i) do
			local x = expand(p)
			utils.table_print_pairs(p)
			utils.table_print_pairs(x)
			if utils.tab_eq(x, tab) then
				print("matches")
				table.insert(ret, utils.shallow_copy(p))
			end
			print()
		end
		if #ret > 0 then utils.table_print_pairs(ret) return ret end
	end
	print("nothing found")
	return nil
end

function _M.handle_knf(tab,vars)
	local t = {}
	for k,v in pairs(tab) do
		if v == "0" then t[k] = true end
	end
	local ret = {}
	for _,m in ipairs(minimize(t)) do
		local e = {}
		for _,v1 in pairs(m) do
			local sub = {}
			local i = 1
			for v2 in v1:gmatch(".") do
				assert(i <= #vars, "subexpressions longer than variables")
				if v2 == "x" then
				elseif v2 == "1" then
					table.insert(sub, {"not", vars[i]})
					table.insert(sub, "or")
				elseif v2 == "0" then
					table.insert(sub, {vars[i]})
					table.insert(sub, "or")
				else
					error(string.format("Unknown char %s in subexpression %s", v2, v1))
				end
				i = i+1
			end
			table.remove(sub)
			table.insert(e, sub)
			table.insert(e, "and")
		end
		table.remove(e)
		table.insert(ret, e)
	end
	return ret
end

function _M.handle_dnf(tab,vars)
	local t = {}
	for k,v in pairs(tab) do
		if v == "1" then t[k] = true end
	end
	local ret = {}
	for _,m in ipairs(minimize(t)) do
		local e = {}
		for _,v1 in pairs(m) do
			local sub = {}
			local i = 1
			for v2 in v1:gmatch(".") do
				assert(i <= #vars, "subexpressions longer than variables")
				if v2 == "x" then
				elseif v2 == "0" then
					table.insert(sub, {"not", vars[i]})
					table.insert(sub, "and")
				elseif v2 == "1" then
					table.insert(sub, {vars[i]})
					table.insert(sub, "and")
				else
					error(string.format("Unknown char %s in subexpression %s", v2, v1))
				end
				i = i+1
			end
			table.remove(sub)
			table.insert(e, sub)
			table.insert(e, "or")
		end
		table.remove(e)
		table.insert(ret, e)
	end
	return ret
end

-- local tab = {
-- 	["000"] = "0",
-- 	["001"] = "0",
-- 	["010"] = "0",
-- 	["011"] = "1",
-- 	["100"] = "1",
-- 	["101"] = "1",
-- 	["110"] = "0",
-- 	["111"] = "1",
-- }
-- local r = _M.handle_knf(tab, {"a", "b", "c"})
-- for _,v in ipairs(r) do
-- 	utils.table_print(v)
-- end

-- print()

-- tab = {
-- 	["000"] = "0",
-- 	["001"] = "1",
-- 	["010"] = "1",
-- 	["011"] = "0",
-- 	["100"] = "0",
-- 	["101"] = "0",
-- 	["110"] = "1",
-- 	["111"] = "0",
-- }
-- r = _M.handle_knf(tab, {"a", "b", "c"})
-- for _,v in ipairs(r) do
-- 	utils.table_print(v)
-- end

return _M
