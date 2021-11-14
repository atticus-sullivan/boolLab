local expression = require"cond_expression"
local read = require"read"

local e1 = expression{str="a * b or c"}
e1:str2expr():expr2vars():expr2table()
for k,v in pairs(e1.table) do
	print(k, v)
end
print(e1.str)
e1:table2dnfexpr(true):expr2str()
print(e1.str)

e1:print_truthtable()

local exprs = read.read("t")
for k,v in pairs(exprs) do
	print(k)
	v:table2dnfexpr(true):expr2str()
	v:print_truthtable()
end
