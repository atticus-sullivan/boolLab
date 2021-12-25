--- Nicely print tabulars
local _M = {}

local function max(a,b) return (a ~= nil and a > b) and a or b end

--- Print a tabular nicely.
-- prints a nice tabular with even sized columns (if they don't get too big)
-- @tparam tab content a tabular holding tables (rows) of columns
-- @tparam bool plain if the == lines should be printed
-- @tparam[opt] file file file to print to
function _M.tabular_printing(content, plain, file)
	file = file or io.stdout -- set default value
	local colSizes = {}
	for _,v1 in ipairs(content) do
		for i2,v2 in ipairs(v1) do
			colSizes[i2] = max(colSizes[i2], #v2)
		end
	end
	local format = ""
	local first = true
	for _,v in ipairs(colSizes) do
		local x
		if v < 100 then x = v else
			file:write("Warning one column is larger than 100 characters", "\n")
			x = 99
		end
		if not first then
			format = format .. " | %-" .. tostring(x) .. "s"
		else
			format = format .. "%-" .. tostring(x) .. "s"
			first = false
		end
	end
	first = true
	local function _sum(t)
		local r = 0
		for _,v in ipairs(t) do
			r = r + v+3
		end
		return r
	end
	for _,v in ipairs(content) do
		file:write(string.format(format, table.unpack(v, 1, #colSizes)), "\n")
		if first and not plain then
			file:write(string.rep("=", _sum(colSizes)-3), "\n")
		end
		first = false
	end
	if not plain then
		file:write(string.rep("=", _sum(colSizes)-3), "\n")
	end
end

return _M
