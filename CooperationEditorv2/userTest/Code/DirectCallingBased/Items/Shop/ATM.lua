---ATM dispenses ShopCoin when interacted with if ShowMoneyManager says sufficient funds
local FieldHelper = require('FieldHelper')

local Log = require('Log')
local log = Log.new()

---@type Loader
local loader = LoadFacility('Game')['game'].loader

---@type number
local denomination = denomination or 5

---@type string
local item = item or coin

--Mark self as able to be interacted with
owner.tags.addTag('Interact')

---Allow player to interact with this.
---Externally called.
---@return MapMobile|boolean @ Returns the `MapObject` created (when sufficient funds) or false (otherwise).
function interact()
	-- Withdraw without persisting change so money only exists in-world (doesn't get lost if level/game quit).
	-- Coin destroy behaviour same.  Only persisted when purchases complete.
	local result = FieldHelper.callFuncOnFirstMapObjectTagged('ShopMoneyManager', 'tryToWithdraw', denomination)
	log:debug('Withdraw result:', result)
	if not result then
		log:log('Not enough funds to withdraw ', denomination)
		return false
	end

	log:debug('Attempting to create coin at ', owner.gridPosition)
	local coinMapObject = --[[---@type MapMobile]] loader.instantiate(item, owner.gridPosition)
	coinMapObject.callFunc('setValue', denomination)
	log:log('Created ', coinMapObject, ' with value ', denomination, ' at ', owner.gridPosition)
	return coinMapObject
end
