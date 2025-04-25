local V3 = require('Vector3')

local DisplayCostByCoinsLogic = {
	---Map of coin values to coin prefabs.
	---Ordered from greatest to least value.
	---@type {value: number, prefab: string}[]
	numToCoinPrefabMap = {
		{ value = 50, prefab = "coinDisplay50" },
		{ value = 10, prefab = "coinDisplay10" },
		{ value =  1, prefab = "coinDisplay1" },
	}
}

---Get a list of indicies to instantiate to make up the supplied cost.
---@param cost number
---@return number[]
function DisplayCostByCoinsLogic:getIndicesFromCost(cost)
	---@type number[]
	local indicies = {}
	for index, v in ipairs(self.numToCoinPrefabMap) do
		local numCoins = math.floor(cost / v.value)
		cost = cost - (numCoins * v.value)
		for _ = 1, numCoins do
			table.insert(indicies, index)
		end
	end
	return indicies
end

---@param index number
---@return string
function DisplayCostByCoinsLogic:getPrefabByIndex(index)
	if index < 1 or index > #DisplayCostByCoinsLogic.numToCoinPrefabMap then
		error('index ' .. index .. ' out of range. Should be between 1 and ' .. #DisplayCostByCoinsLogic.numToCoinPrefabMap .. ' inclusive.')
	end
	return DisplayCostByCoinsLogic.numToCoinPrefabMap[index].prefab
end

local basePos = V3.new(0, 1.5, 0)

---@param numCoins number
---@return Vector3[]
function DisplayCostByCoinsLogic:getPositionForNumberOfCoins(numCoins)
	if 1 == numCoins then
		-- point
		return { basePos }
	elseif 2 == numCoins then
		-- line
		return {
			basePos + V3.new(-0.5, 0, 0),
			basePos + V3.new( 0.5, 0, 0),
		}
	elseif 3 == numCoins then
		-- triangle
		return {
			basePos + V3.new(-0.5,   0, 0),
			basePos + V3.new( 0.5,   0, 0),
			basePos + V3.new(   0, 0.5, 0),
		}
	elseif 4 == numCoins then
		-- square
		return {
			basePos + V3.new(-0.5,   0, 0),
			basePos + V3.new( 0.5,   0, 0),
			basePos + V3.new(-0.5, 0.5, 0),
			basePos + V3.new( 0.5, 0.5, 0),
		}
	else
		error('numCoins ' .. numCoins .. ' not supported')
	end
end

return DisplayCostByCoinsLogic
