---LuaUnit tests for DisplayCostByCoins
--Tests defined as global functions.
--Return used by filtering.
local luaunit = require('luaunit')

-- Set the package as "CoOperation" so we will find our tests.
local origPackageIdentifier = packageIdentifier
packageIdentifier = 'CoOperation'
local DisplayCostByCoinsLogic = require('DirectCallingBased.Items.Shop.DisplayCostByCoinsLogic')
packageIdentifier = origPackageIdentifier

function testGetIndicesFromCost()
	---@type {cost: number, expected: number[]}[]
	local testData = {
		{ cost = 10, expected = { 1 } },
		{ cost =  5, expected = { 2 } },
		{ cost =  1, expected = { 3 } },
		{ cost =  2, expected = { 3, 3 } },
		{ cost =  6, expected = { 2, 3 } },
		{ cost = 11, expected = { 1, 3 } },
		{ cost = 16, expected = { 1, 2, 3 } },
		{ cost = 20, expected = { 1, 1 } },
	}
	io.write('\n')
	for i, v in ipairs(testData) do
		io.write(string.format('      testGetIndicesFromCost[%2d] cost:%2d, expect:%10s:\t', i, v.cost, table.concat(v.expected, ',')))
		local actual = DisplayCostByCoinsLogic:getIndicesFromCost(v.cost)
		luaunit.assertEquals(actual, v.expected)
		io.write('ok\n')
	end
end

return {
	-- Untested
	testGetIndicesFromCost = testGetIndicesFromCost,
}
