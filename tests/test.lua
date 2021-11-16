local lester = require 'lester'
local describe, it, expect = lester.describe, lester.it, lester.expect


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

-- Customize lester configuration.
-- lester.show_traceback = false

describe('test', function()
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
		it("dummy", function()
			expect.truthy(true)
		end)
	end)
	describe("bool2str", function()
		it("dummy", function()
			expect.truthy(true)
		end)
	end)
	describe("set2list", function()
		it("dummy", function()
			expect.truthy(true)
		end)
	end)
	describe("list2set", function()
		it("dummy", function()
			expect.truthy(true)
		end)
	end)
	describe("union", function()
		it("dummy", function()
			expect.truthy(true)
		end)
	end)
	describe("table_print", function()
		it("dummy", function()
			expect.truthy(true)
		end)
	end)
end)

local expression = require("cond_expression")
describe('expr', function()
	describe("new", function()
		it("new", function()
			expect.truthy(true)
		end)
	end)
	describe("__call", function()
		it("new", function()
			expect.truthy(true)
		end)
	end)
	describe("str2expr", function()
		it("new", function()
			expect.truthy(true)
		end)
	end)
	describe("expr2str", function()
		it("new", function()
			expect.truthy(true)
		end)
	end)
	describe("eval", function()
		it("new", function()
			expect.truthy(true)
		end)
	end)
	describe("expr2table", function()
		it("new", function()
			expect.truthy(true)
		end)
	end)
	describe("expr2vars", function()
		it("new", function()
			expect.truthy(true)
		end)
	end)
	describe("table2knfexpr", function()
		it("new", function()
			expect.truthy(true)
		end)
	end)
	describe("table2dnfexpr", function()
		it("new", function()
			expect.truthy(true)
		end)
	end)
	describe("equiv", function()
		it("new", function()
			expect.truthy(true)
		end)
	end)
	describe("print_truthtable", function()
		it("new", function()
			expect.truthy(true)
		end)
	end)
end)

lester.report() -- Print overall statistic of the tests run.
lester.exit() -- Exit with success if all tests passed.
