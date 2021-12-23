local _M = {}

local function set_eq(s1, s2)
	for k,v in pairs(s1) do
		if s2[k] ~= v then return false end
	end
	for k,v in pairs(s2) do
		if s1[k] ~= v then return false end
	end
	return true
end

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
	for k,_ in pairs(x) do
		foo(k, 1, ret)
	end
	return ret
end

local function shallow_copy(t)
	local res = {}
	for k,v in pairs(t) do
		res[k] = v
	end
	return res
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

local function table_print(t)
	local function table_print_exec(t)
		if type(t) ~= "table" then io.write(tostring(t)) return end
		io.write("{")
		for k,v in pairs(t) do
			io.write(tostring(k), "->")
			table_print_exec(v)
			io.write(", ")
		end
		io.write("}")
	end
	table_print_exec(t)
	print()
end

local function set_size(s)
	local ret = 0
	for _,_ in pairs(s) do
		ret = ret + 1
	end
	return ret
end

function _M.combine(x1,x2)
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

--returns the powerset of s, out of order.
local function powerset(s, start)
  start = start or 1
  if(start > #s) then return {{}} end
  local ret = powerset(s, start + 1)
  for i = 1, #ret do
    ret[#ret + 1] = {s[start], unpack(ret[i])}
  end
  return ret
end

-- TODO remove duplicates
local function perm(set, len)
	local function _perm(set, len, acc)
		for k,_ in pairs(set) do
			set[k] = nil
			acc[k] = true
			if set_size(acc) == len
			then
				coroutine.yield(acc)
			else
				_perm(set, len, acc)
			end
			acc[k] = nil
			set[k] = true
		end
	end
	return coroutine.wrap(function() _perm(set, len, {}) end)
end

function _M.handle_dnf(tab)
	local t = {}
	for k,v in pairs(tab) do
		if v == 1 then t[k] = true end
	end
	table_print(t)

	tab = shallow_copy(t)

	local changed
	repeat
		changed = false
		local t_new = {}
		local used = {}
		for k1,_ in pairs(t) do
			for k2,_ in pairs(t) do
				if k1 ~= k2 then
					local c = _M.combine(k1,k2)
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
		table_print(t_new)
		print()
		t = t_new
	until not changed or set_size(t) == 1

	local ret = {}
	for i=1,set_size(t) do
		for p in perm(t, i) do
			local x = expand(p)
			table_print(p)
			table_print(x)
			if set_eq(x, tab) then
				print("matches")
				table.insert(ret, shallow_copy(p))
			end
			print()
		end
		if #ret > 0 then table_print(ret) return ret end
	end
	print("nothing found")
	return nil
end

local tab1 = {
	["011"] = 1,
	["111"] = 1,
	["101"] = 1,
	["100"] = 1,
}

local tab2 = {
	["001"] = 1,
	["010"] = 1,
	["110"] = 1,
}

-- print_karnaugh_tab(tab2, {"a", "b", "c"})
_M.handle_dnf(tab2)

return _M
