local lpeg = require("lpeg")

local field,record

local _M = {}
setmetatable(_M, {
	__call = function(_, sep)
		assert(type(sep) == "string" and #sep == 1, "sep has to be a string and be of length 1 (effectively being a char)")

		field = lpeg.S(" ")^0 * '"' * lpeg.Cs(((lpeg.P(1) - '"') + lpeg.P('""') / '"')^0) * '"' * lpeg.S(" ")^0 +
					  lpeg.S(" ")^0 * lpeg.C((1 - lpeg.S(sep .. '\n"'))^0) * lpeg.S(" ")^0
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
