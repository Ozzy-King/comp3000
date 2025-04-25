---Query all modifiers, apply them all and return the result.

local Log = require('Log')
local log = Log.new()

---@type Game
local game = LoadFacility('Game')['game']

---@shape MoneyModifiers
---@field add number
---@field mul number

---@class MoneyModifierApplier
local MoneyModifierApplier = {}

---@param pos Pos
---@param baseAmount number
---@return number
function MoneyModifierApplier.applyAllModifiers(pos, baseAmount)
	---@type MoneyModifiers[]
	local modifiers = {}

	log:log('Getting money modifiers for pos:', pos)
	local modifierMapObjects = game.map.getAllTagged(pos, 'MoneyModifier') or {}

	log:debug('Setting-up response handler')
	local function onResponse(response)
		log:debug('GetMoneyModifier got response: ', response)
		local add = --[[---@type number]] response.data['add']
		local mul = --[[---@type number]] response.data['mul']
		if nil == add and nil == mul then
			error('No "add" nor "mul" in response: ' .. json.serialize(response))
		end
		log:debug('GetMoneyModifier received add:', add, ' mul:', mul)
		table.insert(modifiers, { add = add, mul = mul })
	end

	log:debug('Got modifiers for pos:', pos, '. Iterating')
	for modifierMapObject in modifierMapObjects do
		local mapObj = --[[---@type MapObjectType]] modifierMapObject
		log:debug('Sending GetMoneyModifier to:', mapObj)
		--TODO: Bug here when used mapObj.owner.bus.send({'GetMoneyModifier'}, onResponse, false)
		mapObj.bus.send({ 'GetMoneyModifier' }, onResponse, false)
	end

	---@type number
	local addTotal = 0
	---@type number
	local mulTotal = 1
	log:debug('Processing ', #modifiers, ' modifiers: ', modifiers)
	for i = 1, #modifiers do
		local modifier = modifiers[i]
		addTotal = addTotal + (modifier.add or 0)
		mulTotal = mulTotal * (modifier.mul or 1)
	end

	log:debug('addTotal:', addTotal, ' mulTotal:', mulTotal)
	local result = baseAmount * mulTotal + addTotal -- Should add or mul be first?
	local resultRounded = math.floor(result + 0.5)
	log:debug('result:', result, ' resultRounded:', resultRounded)

	log:log('amount:', baseAmount, ' * ', mulTotal, ' + ', addTotal, ' = ', resultRounded)
	return resultRounded
end

return MoneyModifierApplier
