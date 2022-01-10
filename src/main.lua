local expression = require"cond_expression"

local e1 = expression:new{str="a * b or c", vars=nil}

e1:str2expr():expr2vars():expr2table()
-- loop over the table and print it manually
for k,v in pairs(e1.table) do
	print(k, v)
end
e1:print_truthtable()

print(e1.str)
e1:table2dnfexpr(true):expr2str()
print(e1.str)

-- multiple expressions can be in input table -> table of expressions is
-- returned with the specified name as key
local exprs = expression.read("t")
-- loop over the read expressions and do some printing
for k,v in pairs(exprs) do
	print(k)
	v:table2dnfexpr(true):expr2str()
	v:print_truthtable()
end

local e = exprs["y"]
-- chaining is supported too
e = e:expr2table():expr2vars():table2knfmin():expr2str()
print(e.str)
