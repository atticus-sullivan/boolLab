
local file = io.open("t")
local hdr = file:read("*line")

-- str shall be the string representation of the expression
-- expr is the table-tree representation of the expression

-- ones  is a list of strings e.g. "010" giving 1 on the output TODO maybe string -> list
-- zeros is a list of strings e.g. "010" giving 0 on the output TODO maybe string -> list
-- => together this is table

-- vars is a list of strings containing the used variables

-- local expression = {str=nil, expr=nil, table=nil, vars=nil, parser=G} -- default values here

local exprs = {}
local _,start = hdr:find("|  |")
for x in hdr:gmatch([[| "(.-)" ]], start) do
	table.insert(exprs, {str=x, ones={}, zeros={}, out={}, vars={}})
	print(x)
end
