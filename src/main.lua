local expression = require"cond_expression"

local e1 = expression:new{str="a * b or c"}
print(e1.vars)
e1:str2expr():expr2vars():expr2table()
for k,v in pairs(e1.table) do
	print(k, v)
end
print(e1.str)
e1:table2dnfexpr(true):expr2str()
print(e1.str)

e1:print_truthtable()

local exprs = expression.read("t")
for k,v in pairs(exprs) do
	print(k)
	v:table2dnfexpr(true):expr2str()
	v:print_truthtable()
end

for k,v in pairs(exprs) do
	print(k, table.concat(v.vars, ","))
	for k1,v1 in pairs(v.table) do
		print(k1, "->", v1)
	end
end
