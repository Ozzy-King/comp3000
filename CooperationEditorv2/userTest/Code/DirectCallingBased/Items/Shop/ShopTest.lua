---A test script that runs shop classes and level through its paces.
local FieldHelper = require('FieldHelper')

---@type Game
local game = LoadFacility('Game')['game']

local Direction = require('DirectionUtils')

--setLogDebug(true)

local p1MapObj = game.map.getFirstTagged(13, 14, 'player')
assert(nil ~= p1MapObj and p1MapObj.typeName == 'MapMobile', 'Could not find player 1 at expected coordinates. Found ' .. tostring(p1MapObj) .. ' which is a ' .. tostring(p1MapObj.typeName))
local p1 = --[[---@type MapMobile]] p1MapObj
assert(nil ~= p1, 'Could not find player 1 at expected coordinates')
print('p1:', tostring(p1))

local function doTest()
	print("Little pause so everything's ready")
	waitMilliSeconds(30)
	print("Beginning test")

	local move1 = p1['move']
	assert(nil ~= move1, 'no move')
	local act1 = p1['act']
	assert(nil ~= act1, 'no act')

	print('Move 2 west + 1 south')
	move1(Direction.West)
	move1(Direction.West)
	move1(Direction.South)
	print('Pick up coin')
	act1(Direction.South)
	print('Move 5 north')
	move1(Direction.North)
	move1(Direction.North)
	move1(Direction.North)
	move1(Direction.North)
	move1(Direction.North)
	print('Pay with coin')
	act1(Direction.North)

	print('Test done')
end

local unBuy = {
	'buyable_shrinkRay_dispenser',
	'buyable_flowers_white',
	'buyable_paintPot_blue',
	'buyable_paintPot_red',
	'buyable_paintPot_green',
	'buyable_paintPot_purple',
}
print('Forcing <i>some</i> things to unbought: ', json.serialize(unBuy))
for _,name in ipairs(unBuy) do
	game.saveData.setNumber(name, 0)
end

--print('Forcing credit to 40')
--FieldHelper.callFuncOnFirstMapObjectTagged('ShopMoneyManager', 'setBalanceDuringTest', 40)

--if 0 == game.saveData.getNumber('White flowers') then
--	doTest()
--else
--	print('Not running since "White flowers" already bought')
--end
