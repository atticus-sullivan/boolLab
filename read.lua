local expression = require("cond_expression")
local utils = require("cond_expression_utils")
local lpeg = require("lpeg")

local _M = {}

local field = lpeg.S(" ")^0 * '"' * lpeg.Cs(((lpeg.P(1) - '"') + lpeg.P'""' / '"')^0) * '"' * lpeg.S(" ")^0 +
                    lpeg.C((1 - lpeg.S'|\n"')^0)

local record = field * ('|' * field)^0 * (lpeg.P'\n' + -1)

local function csv (s)
  return lpeg.match(record, s)
end

function _M.read(fn)
	local file = io.open(fn)
	local hdr = file:read("*line")

	local exprs = {}
	local exprsL = {}
	local varsB = true
	local vars = {}
	for _,x in ipairs(table.pack(csv(hdr))) do
		if x == "" then varsB = false
		elseif varsB then
			table.insert(vars, x)
		else
			table.insert(exprsL, x)
			exprs[x] = expression:new{table={}, vars=utils.shallow_copy(vars)}
		end
	end

	local varsS,i
	for line in file:lines() do
		varsS, varsB, i = "", true, 1
		for _,x in ipairs(table.pack(csv(line))) do
			x = x:match([[%s*"?(.*)"?%s*]]) -- strip whitespaces and surrounding quotes
			if x == "" then varsB = false
			elseif varsB then
				varsS = varsS .. x
			else
				exprs[exprsL[i]].table[varsS] = x
				i = i+1
			end
		end
	end
	return exprs
end

return _M
