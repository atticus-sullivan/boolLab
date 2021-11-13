--- Nicely print tabulars
local _M = {}

local function max(a,b) return (a ~= nil and a > b) and a or b end

--- Print a tabular nicely.
-- prints a nice tabular with even sized columns (if they don't get too big)
-- @tparam tab content a tabular holding tables (rows) of columns
function _M.tabular_printing(content)
	local colSizes = {}
	for _,v1 in ipairs(content) do
		for i2,v2 in ipairs(v1) do
			colSizes[i2] = max(colSizes[i2], #v2)
		end
	end
	local format = "| "
	for _,v in ipairs(colSizes) do
		local x
		if v < 100 then x = v else
			print("Warning one column is larger than 100 characters")
			x = 99
		end
		format = format .. "%-" .. tostring(x) .. "s | "
	end
	local first = true
	local function _sum(t)
		local r = 0
		for _,v in ipairs(t) do
			r = r + v+3
		end
		return r
	end
	for _,v in ipairs(content) do
		print(string.format(format, table.unpack(v, 1, #colSizes)))
		if first then
			print(string.rep("=", 1+_sum(colSizes)))
		end
		first = false
	end
	print(string.rep("=", 1+_sum(colSizes)))
end

return _M
