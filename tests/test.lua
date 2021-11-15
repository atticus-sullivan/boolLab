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

local csv = require("csv")
describe('csv', function()
	describe("csv", function()
		it("dummy", function()
			expect.truthy(true)
		end)
	end)
end)

local tabular = require("tabular")
describe('tab', function()
	describe("tabular_print", function()
		it("dummy", function()
			expect.truthy(true)
		end)
	end)
end)

local expression_utils = require("cond_expression_utils")
describe('utils', function()
	describe("union", function()
		it("dummy", function()
			expect.truthy(true)
		end)
	end)
end)

local expression = require("cond_expression")
describe('expr', function()
	describe("union", function()
		it("new", function()
			expect.truthy(true)
		end)
	end)
end)

lester.report() -- Print overall statistic of the tests run.
lester.exit() -- Exit with success if all tests passed.
