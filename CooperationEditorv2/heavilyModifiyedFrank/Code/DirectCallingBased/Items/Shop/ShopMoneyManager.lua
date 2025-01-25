---Central code for accessing money.
---Used by ATM, ShopCoin and ShopItem to access money rather than going directly to save state.
---Also responsible for displaying balance.

---@type MoneyUtils
local MoneyUtils = require('MoneyUtils')

local Log = require('Log')
local log = Log.new(Log.LevelAll)

---@type Game
local game = LoadFacility('Game')['game']
---@type MapMobile
local owner = owner or error('No owner')
---@type Tags
local tags = tags or error('No tags')

-- ---@type number
--local balance = game.saveData.getNumber('credit') or 0
--log:log('balance:', balance)

---Called when either THIS or someone else updates the balance.
---We use this to ensure our knowledge of the balance is up to date.
---Most likely case is when a patient (or other money earning opportunity) is in the Shop scene.
---@param msg Message
---@return void
local function onBalanceUpdated(msg)
	log:debug('onBalanceUpdated:', msg)
	MoneyUtils:updateBalance()
end

---Try to withdraw the amount specified and return true on success.
---Externally called.
---@param amount number
---@return boolean
function tryToWithdraw(amount)
	log:debug('tryToWithdraw(', amount, ')')
	return MoneyUtils:tryToWithdraw(amount, false)
end

---Add amount to balance (for when coin dropped).
---Externally called.
---@param amount number
---@param doSync? boolean @ whether to save the new balance to storage (default true)
---@return void
function payIn(amount, doSync)
	log:debug('payIn(', amount, ', ', doSync, ')')
	return MoneyUtils:payIn(amount, doSync)
end

---Persist balance to storage.
---Money taken out as coin while still in the level *DOES NOT COUNT AS SPENT*.
---This is to protect against level quit while still holding coins (or game crash etc).
---When something is purchased and the storage updated, this persists the payment.
---Externally called.
---Pass `doSync` true to cause data to be persisted (default) or false (if doing elsewhere).
---@param doSync boolean
---@return void
function finalisePayment(doSync)
	log:debug('finalisePayment(', doSync, ')')
	return MoneyUtils:finalisePayment(doSync)
end

---@param newBalance number @ New balance to set
function setBalanceDuringTest(newBalance)
	log:warn('**DURING TEST** Setting balance to ', newBalance, ' **DURING TEST**')
	local balance = MoneyUtils.balance
	local diff = newBalance - balance
	MoneyUtils:payIn(diff, true)
end

---MAIN

owner.tags.addTag('ShopMoneyManager') --always do sync actions (e.g. tags) before async ones
tags.addTag('ShopMoneyManager')

game.bus.subscribe(MoneyUtils.BalanceUpdatedEvent, onBalanceUpdated)

--Update balance shown (as last action)
MoneyUtils:redrawBalance(false) --potentially async actions (e.g. redraw and message bus stuff)

--Alternative: explicit await
--setAutoAwait(false) --disable auto-await for this script (so we can choose to use await() on returned tasks *or* not to allow tasks to run in the background)
--local task = MoneyUtils:redrawBalance(false) --potentially async actions (e.g. redraw and message bus stuff)
--log:log('task:', task)
-- setAutoAwait(true) --disable auto-await for this script (so we can choose to use await() on returned tasks *or* not to allow tasks to run in the background)
