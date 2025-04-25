---A coin in a shop with a denomination that, when applied to a ShopItem pays some of its value.

local FieldHelper = require('FieldHelper')
local CarryHelper = require('CarryHelper')

local Log = require('Log')
local log = Log.new()

---@type MapMobile
local owner = owner or error('No owner')

---@type number
local value = value or 5
log:debug('Coin of value:', value, ' created')

---Whether the coin has been used (paid with).
---@type boolean
local used = false

---Tries to pay a 'payable' ShopItem via its `pay()` using own value
---@return boolean @ Whether successfully paid (not whether thing fully bought).
local function tryPay()
	local payableObject = owner.getFirstFacingObjectTagged('payable')
	if nil == payableObject then
		log:log('No payable in-front of us')
		return false
	end

	if not payableObject.hasFunc('pay') then
		log:error('Payable object has no `pay` function exposed! ', payableObject)
		return false
	end

	-- (so we don't return the money when destroyed)
	used = true
	-- Destroy (hide) the coin before paying
	owner.destroyObject()

	log:debug('Paying ', value, ' money to ', payableObject)
	local success = payableObject.callFunc('pay', value)
	log:log('Paying result:', success)
	-- success indicates whether fully bought (true) or not (false)
	return true
end

---@param msg Message
local function onStateChange(msg)
	if used then
		-- Money already paid with so don't return it to the balance
		return
	end

	local newState = msg.data['state.MapObject']
	log:debug('new state:', newState)
	if 2 == newState or 'Destroyed' == newState then
		log:debug('destroyed so returning ', value, ' money')
		-- Return without persisting change so money only exists in-world (doesn't get lost if level/game quit).
		-- ATM dispensing behaviour same.  Only persisted when purchases complete.
		FieldHelper.callFuncOnFirstMapObjectTagged('ShopMoneyManager', 'payIn', value, false)
	end
end

---External function called when acting with carried item
function actWhenCarried(carrierOwner, carrier, actDirection)
	assert(nil ~= carrierOwner, 'No carrierOwner')
	assert(nil ~= carrier, 'No carrier')
	assert(nil ~= actDirection, 'No actDirection')

	-- If there is empty floor with nothing blocking us, drop the coin
	if CarryHelper.placeDownIfClearInFront(carrierOwner, carrier, actDirection) then
		-- Coins return to balance when dropped on the ground
		log:debug('Placed down = money will be returned by onStateChange (not returning ', value, ' to balance now)')
		-- No need to destroy since tagged "destroyIfPutDown"
		-- No need to return money to balance since we'll do it in state change event handler
		return true -- TODO-20230701 will this also disappear on drop and how do we return money?
	end

	-- There's no empty floor or could not put down, try administering the medicine instead
	return tryPay()
end

---External function called to assign new value to the coin.
---Temporary until API allows providing variables during instantiation. = TODO-20230724
function setValue(newValue)
	value = newValue
	log:debug('value set to ', value)

end

owner.bus.subscribe('state.MapObject', onStateChange)
