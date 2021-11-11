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

local function shallow_copy(t)
	local r = {}
	for i,v in ipairs(t) do
		r[i] = v
	end
	return r
end

local function boolToStr(x)
	if x then return "1" else return "0" end
end

return {
	union = union,
	table_print = table_print,
	shallow_copy = shallow_copy,
	boolToStr = boolToStr,
}
