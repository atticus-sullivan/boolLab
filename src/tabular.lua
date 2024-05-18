-- boolLab
-- Copyright (C) 2024  Lukas Heindl
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

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
