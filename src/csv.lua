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

local lpeg = require("lpeg")

local field,record

local function stripSpace(s)
	local r = s:gsub("%s*$", "")
	return r
end

local _M = {}
setmetatable(_M, {
	__call = function(_, sep)
		assert(type(sep) == "string" and #sep == 1, "sep has to be a string and be of length 1 (effectively being a char)")

		field = lpeg.S(" ")^0 * '"' * lpeg.Cs(((lpeg.P(1) - '"') + lpeg.P('""') / '"')^0) * '"' * lpeg.S(" ")^0 +
					  lpeg.S(" ")^0 * lpeg.C((1 - lpeg.S(sep .. '\n"'))^0) / stripSpace * lpeg.S(" ")^0
		record = field * (sep * field)^0 * (lpeg.P'\n' + -1)
		return _M
	end
})

function _M.csv(s)
	if not record then
		_M(";") -- default value for the sep
	end
	return record:match(s)
end

return _M
