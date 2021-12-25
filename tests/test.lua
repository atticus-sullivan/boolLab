local lester = require 'lester'
local describe, it, expect = lester.describe, lester.it, lester.expect

local function check_normalform(expr, stage1, stage2, amountVars)
	for i1,v1 in ipairs(expr) do
		if i1 % 2 == 0 then
			if v1 ~= stage1 then return false end
		else
			if #v1 ~= 2*amountVars-1 then return false end
			for i2,v2 in ipairs(v1) do
				if i2 % 2 == 0 then
					if v2 ~= stage2 then return false end
				else
					if type(v2) == "string" then
					elseif type(v2) == "table" then
						if #v2 == 1 then
							if type(v2[1]) ~= "string" then return false end
						elseif #v2 == 2 then
							if v2[1] ~= "not" then return false end
							if type(v2[2]) ~= "string" then return false end
						else
							return false
						end
					end
				end
			end
		end
	end
	return true
end

local function semantic_eq_expr_tables(e1, e2)
	if     type(e1) == "table" and type(e2) == "table" then
		if     #e1 == 1 and #e2 == 1 then
			return semantic_eq_expr_tables(e1[1], e2[1])
		elseif #e1 == 1 and #e2 ~= 1 then
			return semantic_eq_expr_tables(e1[1], e2)
		elseif #e1 ~= 1 and #e2 == 1 then
			return semantic_eq_expr_tables(e1, e2[1])
		elseif #e1 ~= 1 and #e2 ~= 1 then
			if #e1 ~= #e2 then return false end
			for i,v in pairs(e1) do
				if not semantic_eq_expr_tables(v,e2[i]) then return false end
			end
			return true
		end
	elseif type(e1) == "table" and type(e2) ~= "table" then
		if #e1 ~= 1 then return false end
		return semantic_eq_expr_tables(e1[1], e2)
	elseif type(e1) ~= "table" and type(e2) == "table" then
		if #e2 ~= 1 then return false end
		return semantic_eq_expr_tables(e1, e2[1])
	elseif type(e1) ~= "table" and type(e2) ~= "table" then
		return e1 == e2
	end
end

local function tab_eq(t1, t2)
	for k,v in pairs(t1) do
		if t2[k] ~= v then return false end
	end
	for k,v in pairs(t2) do
		if t1[k] ~= v then return false end
	end
	return true
end

describe('test', function()
	describe('check_normalform', function()
		describe('kdnf', function()
			it('{{"a", "and", "b", "and", "c"}}', function()
				local e = {{"a", "and", "b", "and", "c"}}
				expect.truthy(check_normalform(e, "or", "and", 3))
			end)
			it('{"a", "and", "b", "and", "c"}', function()
				local e = {"a", "and", "b", "and", "c"}
				expect.falsy(check_normalform(e, "or", "and", 3))
			end)
			it('{{"a", "and", "c"}, "or", {"a", "and", "b", "and", "c"}}', function()
				local e = {{"a", "and", "c", "and", {"not", "b"}}, "or", {"a", "and", "b", "and", "c"}}
				expect.truthy(check_normalform(e, "or", "and", 3))
			end)
		end)
		describe('kknf', function()
			it('{{"a", "or", "b", "or", "c"}}', function()
				local e = {{"a", "or", "b", "or", "c"}}
				expect.truthy(check_normalform(e, "and", "or", 3))
			end)
			it('{"a", "or", "b", "or", "c"}', function()
				local e = {"a", "or", "b", "or", "c"}
				expect.falsy(check_normalform(e, "and", "or", 3))
			end)
			it('{{"a", "or", "c"}, "and", {"a", "or", "b", "or", "c"}}', function()
				local e = {{"a", "or", "c", "or", {"not", "b"}}, "and", {"a", "or", "b", "or", "c"}}
				expect.truthy(check_normalform(e, "and", "or", 3))
			end)
		end)
	end)
	describe('tab_eq', function()
		it('{a=true, b=false, c=true} {a=nil, c=true, b=false}', function()
			local t1 = {a=true, b=false, c=true}
			local t2 = {a=nil, c=true, b=false}
			expect.falsy(tab_eq(t1, t2))
		end)
		it('{a=true, b=false, c=true} {a=true, c=true, b=false}', function()
			local t1 = {a=true, b=false, c=true}
			local t2 = {a=true, c=true, b=false}
			expect.truthy(tab_eq(t1, t2))
		end)
	end)
	describe('sem eq', function()
		it('{} and {}', function()
			local e1 = {}
			local e2 = {}
			expect.truthy(semantic_eq_expr_tables(e1,e2))
		end)

		it('{"a"} and {"b"}', function()
			local e1 = {"a"}
			local e2 = {"b"}
			expect.falsy(semantic_eq_expr_tables(e1,e2))
		end)

		it('{"a"} and {"a"}', function()
			local e1 = {"a"}
			local e2 = {"a"}
			expect.truthy(semantic_eq_expr_tables(e1,e2))
		end)

		it('{{"a"}} and {"a"}', function()
			local e1 = {{"a"}}
			local e2 = {"a"}
			expect.truthy(semantic_eq_expr_tables(e1,e2))
		end)

		it('{{"a"}, "b"} and {"a", {"b"}}', function()
			local e1 = {{"a"}, "b"}
			local e2 = {"a", {"b"}}
			expect.truthy(semantic_eq_expr_tables(e1,e2))
		end)

		it('{{"a"}, "and", "b"} and {"a", "*", {"b"}}', function()
			local e1 = {{"a"}, "and", "b"}
			local e2 = {"a", "*", {"b"}}
			expect.falsy(semantic_eq_expr_tables(e1,e2))
		end)

		it('{{"c"}, "and", "b"} and {"a", "and", {"b"}}', function()
			local e1 = {{"c"}, "and", "b"}
			local e2 = {"a", "and", {"b"}}
			expect.falsy(semantic_eq_expr_tables(e1,e2))
		end)

		it('{{"a"}, "and", "b"} and {"a", "and", {"b"}}', function()
			local e1 = {{"a"}, "and", "b"}
			local e2 = {"a", "and", {"b"}}
			expect.truthy(semantic_eq_expr_tables(e1,e2))
		end)
	end)
end)

describe('csv', function()
	describe("csv with |", function()
		local csv = require("csv")("|")
		it("a|b|c", function()
			local l = "a|b|c"
			expect.equal({csv.csv(l)}, {"a", "b", "c"})
		end)
		it("a |b | c", function()
			local l = "a |b |  c"
			expect.equal({csv.csv(l)}, {"a", "b", "c"})
		end)
		it("  a  |  b  |  c  ", function()
			local l = "  a  |  b  |  c  "
			expect.equal({csv.csv(l)}, {"a", "b", "c"})
		end)
		it('"  a  "|  "b"  | " c  "', function()
			local l = '"  a  "|  "b"  | " c  "'
			expect.equal({csv.csv(l)}, {"  a  ", "b", " c  "})
		end)
	end)
	describe("csv with ;", function()
		local csv = require("csv")(";")
		it("a|b|c", function()
			local l = "a;b;c"
			expect.equal({csv.csv(l)}, {"a", "b", "c"})
		end)
		it("a |b | c", function()
			local l = "a ;b ;  c"
			expect.equal({csv.csv(l)}, {"a", "b", "c"})
		end)
		it("  a  ;  b  ;  c  ", function()
			local l = "  a  ;  b  ;  c  "
			expect.equal({csv.csv(l)}, {"a", "b", "c"})
		end)
		it('"  a  ";  "b"  ; " c  "', function()
			local l = '"  a  ";  "b"  ; " c  "'
			expect.equal({csv.csv(l)}, {"  a  ", "b", " c  "})
		end)
	end)
end)

describe('tab', function()
	local file
	lester.before(function() file = io.open("dump", "w") end)
	lester.after(function() file:close() os.remove("dump") end)
	local tabular = require("tabular")
	describe("tabular_print", function()
		it("one file", function()
			local content = {{"a", "b", "c"},{"d", "e", "  f  "},{"g ", " h", "i"}}
			tabular.tabular_printing(content, false, file)
			local ref = "a  | b  | c    \n===============\nd  | e  |   f  \ng  |  h | i    \n===============\n"
			file:close()
			file = io.open("dump")
			expect.equal(ref, file:read("a"))
		end)
		it("snd file", function()
			local content = {{"a", "b", "c"},{"d", "e", "  f  "},{"g ", " h", "i"}}
			tabular.tabular_printing(content, true, file)
			local ref = "a  | b  | c    \nd  | e  |   f  \ng  |  h | i    \n"
			file:close()
			file = io.open("dump")
			expect.equal(ref, file:read("a"))
		end)
	end)
end)

local expression_utils = require("cond_expression_utils")
describe('utils', function()
	describe("permute", function()
		it("{a}", function()
			local cmp = {
				{a=false},
				{a=true}
			}
			for p in expression_utils.permute({"a"}) do
				local j = nil
				for i,v in ipairs(cmp) do
					if tab_eq(v, p) then
						j = i
					end
				end
				expect.exist(j)
				table.remove(cmp, j)
			end
			expect.equal(#cmp, 0)
		end)
		it("{a,b}", function()
			local cmp = {
				{a=false, b=false},
				{a=false, b=true},
				{a=true, b=false},
				{a=true, b=true}
			}
			for p in expression_utils.permute({"a", "b"}) do
				local j = nil
				for i,v in ipairs(cmp) do
					if tab_eq(v, p) then
						j = i
					end
				end
				expect.exist(j)
				table.remove(cmp, j)
			end
			expect.equal(#cmp, 0)
		end)
		it("{a,b,c}", function()
			local cmp = {
				{a=false, b=false, c=false},
				{a=false, b=false, c=true},
				{a=false, b=true, c=false},
				{a=false, b=true, c=true},
				{a=true, b=false, c=false},
				{a=true, b=false, c=true},
				{a=true, b=true, c=false},
				{a=true, b=true, c=true}
			}
			for p in expression_utils.permute({"a", "b", "c"}) do
				local j = nil
				for i,v in ipairs(cmp) do
					if tab_eq(v, p) then
						j = i
					end
				end
				expect.exist(j)
				table.remove(cmp, j)
			end
			expect.equal(#cmp, 0)
		end)
	end)
	describe("bool2str", function()
		it("true", function()
			expect.equal("1", expression_utils.bool2str(true))
		end)
		it("false", function()
			expect.equal("0", expression_utils.bool2str(false))
		end)
	end)
	describe("set2list", function()
		it("{a='1', b='1', c='1'}", function()
			local cmp = {"a", "b", "c"}
			table.sort(cmp)
			local r = expression_utils.set2list({a="1", b="1", c="1"})
			table.sort(r)
			expect.truthy(tab_eq(cmp,r))
		end)
		it("{a='1', b='1', c=nil}", function()
			local cmp = {"a", "b"}
			table.sort(cmp)
			local r = expression_utils.set2list({a="1", b="1", c=nil})
			table.sort(r)
			expect.truthy(tab_eq(cmp,r))
		end)
		it("{[0]='1', [10]=nil, [3]='1'}", function()
			local cmp = {0, 3}
			table.sort(cmp)
			local r = expression_utils.set2list({[0]='1', [10]=nil, [3]='1'})
			table.sort(r)
			expect.truthy(tab_eq(cmp,r))
		end)
	end)
	describe("list2set", function()
		it("{'a', 'b', 'c'}", function()
			expect.truthy(
				tab_eq(expression_utils.list2set({"a", "b", "c"}),
				{a="1", b="1", c="1"})
			)
		end)
		it("{'a', 'c'}", function()
			expect.truthy(
				tab_eq(expression_utils.list2set({"a", "c"}),
				{a="1", c="1"})
			)
		end)
		it("{'1', '2'}", function()
			expect.truthy(
				tab_eq(expression_utils.list2set({1, 2}),
				{[1]="1", [2]="1"})
			)
		end)
	end)
	describe("union", function()
		it('{a="1", c="1"}, {a="1", b="1", d="1"}', function()
			local s1 = {a="1", c="1"}
			local s2 = {a="1", b="1", d="1"}
			local r = {a="1", b="1", c="1", d="1"}
			expect.truthy(tab_eq(expression_utils.union(s1, s2), r))
		end)
		it('{a="1", c=nil}, {a="1", b="1", c="1"}', function()
			local s1 = {a="1", c=nil}
			local s2 = {a="1", b="1", c="1"}
			local r = {a="1", b="1", c="1"}
			expect.truthy(tab_eq(expression_utils.union(s1, s2), r))
		end)
	end)
end)

local expression = require("cond_expression")
describe('expr', function()
	local tries = {}
	local t = {
		["000"] = "0",
		["001"] = "0",
		["010"] = "0",
		["011"] = "1",
		["100"] = "1",
		["101"] = "1",
		["110"] = "1",
		["111"] = "1",
	}
	local tr = {
		str="a+b*c",
		expr={"a", "+", {"b", "*", "c"}},
		knf={{"a", "or", "b", "or", {"not", "c"}}, "and", {"a", "or", "b", "or", "c"}, "and", {"a", "or", {"not", "b"}, "or", "c"}},
		dnf={{{"not", "a"}, "and", "b", "and", "c"}, "or", {"a", "and", {"not", "b"}, "and", {"not", "c"}}, "or", {"a", "and", {"not", "b"}, "and", "c"}, "or", {"a", "and", "b", "and", {"not", "c"}}, "or", {"a", "or", "b", "or", "c"}},
		table=t,
		vars={"a", "b", "c"}
	}
	table.insert(tries, tr)
	t = {
		["000"] = "0",
		["001"] = "0",
		["010"] = "0",
		["011"] = "1",
		["100"] = "0",
		["101"] = "1",
		["110"] = "0",
		["111"] = "1",
	}
	tr = {
		str="(a+b)*c",
		expr={{"a", "+", "b"}, "*", "c"},
		knf={{"a", "or", "b", "or", "c"}, "and", {"a", "or", "b", "or", {"not", "c"}}, "and", {"a", "or", {"not", "b"}, "or", "c"}, "and", {{"not", "a"}, "or", "b", "or", "c"}, "and", {{"not", "a"}, "or", {"not", "b"}, "or", "c"}},
		dnf={{{"not", "a"}, "and", "b", "and", "c"}, "or", {"a", "and", {"not", "b"}, "and", "c"}, "or", {"a", "and", "b", "and", "c"}},
		table=t,
		vars={"a", "b", "c"}
	}
	table.insert(tries, tr)
	describe("new", function()
		it("{}", function()
			expect.truthy(tab_eq(expression:new{}, {}))
		end)
	end)
	describe("__call", function()
		it("{}", function()
			expect.truthy(tab_eq(expression{}, {}))
		end)
		it("{str='a+b*c'}", function()
			expect.truthy(tab_eq(expression{str="a+b*c"}, {str="a+b*c"}))
		end)
	end)
	describe("str2expr", function()
		for _,v in ipairs(tries) do
			it(v.str, function()
				local e = expression{str=v.str}
				e:str2expr()
				expect.truthy(semantic_eq_expr_tables(e.expr, v.expr))
			end)
		end
	end)
	describe("expr2table", function()
		for _,v in ipairs(tries) do
			it(v.str, function()
				local e = expression{expr=v.expr}
				e:expr2vars()
				e:expr2table()
				expect.truthy(semantic_eq_expr_tables(e.table, v.table))
			end)
		end
	end)
	describe("expr2vars", function()
		for _,v in ipairs(tries) do
			it(v.str, function()
				local e = expression{expr=v.expr}
				e:expr2vars()
				expect.truthy(semantic_eq_expr_tables(e.vars, v.vars))
			end)
		end
	end)
	describe("table2knfexpr", function()
		for _,v in ipairs(tries) do
			it(v.str, function()
				local e = expression{table=v.table, vars=v.vars}
				e:table2knfexpr()
				expect.truthy(e:equiv(expression{expr=v.expr, vars=v.vars}))
				expect.truthy(check_normalform(e.expr, "and", "or", #e.vars))
			end)
		end
	end)
	describe("table2dnfexpr", function()
		for _,v in ipairs(tries) do
			it(v.str, function()
				local e = expression{table=v.table, vars=v.vars}
				e:table2dnfexpr()
				expect.truthy(e:equiv(expression{expr=v.expr, vars=v.vars}))
				expect.truthy(check_normalform(e.expr, "or", "and", #e.vars))
			end)
		end
	end)
	describe("equiv", function()
		it('{"a", "and", "b"} and {"b", "and", "a"}', function()
			local e1 = expression{expr={"a", "and", "b"}, vars={"a", "b"}}
			local e2 = expression{expr={"b", "and", "a"}, vars={"a", "b"}}
			expect.truthy(e1:equiv(e2))
		end)
	end)
	describe("read", function()
		it("test1.tab", function()
			local e = expression.read("test1.tab")
			expect.equal(e["y"].vars, {"a", "b", "c"})
			local t = {
				["000"] = "0",
				["001"] = "1",
				["010"] = "0",
				["011"] = "1",
				["100"] = "0",
				["101"] = "1",
				["110"] = "1",
				["111"] = "1",
			}
			expect.equal(e["y"].table, t)
		end)
	end)
end)

lester.report() -- Print overall statistic of the tests run.
lester.exit() -- Exit with success if all tests passed.
