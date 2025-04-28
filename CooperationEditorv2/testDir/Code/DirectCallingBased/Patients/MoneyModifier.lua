---Modifies the money earnt by an action in this square.

---@type MapMobile
local owner = owner or error('No owner')

---@type number
local add = add or 0

---@type number
local mul = mul or 1

---@param _ Message
---@return MoneyModifiers
local function onGetMoneyModifier(_)
	return {add = add, mul = mul}
end

owner.bus.subscribe('GetMoneyModifier', onGetMoneyModifier)
owner.tags.addTag('MoneyModifier')
