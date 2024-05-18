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
