---Utilities for dealing with the player's money.

local Log = require('Log')
local log = Log.new()

---@type Game
local game = LoadFacility('Game')['game']

---@type string
local BalanceUpdatedEvent = 'moneyBalanceUpdated'

---@class MoneyUtils
---@field BalanceUpdatedEvent string @ Event fired when the balance changes.
---@field balance number @ The current balance.
---@field updateDisplay fun(balanceToDisplay:number):void @ Override to have actual display update when the balance changes.  Will be passed the balance to display.
local MoneyUtils = {
	BalanceUpdatedEvent = BalanceUpdatedEvent,
	balance = 0,
	updateDisplay = function() end -- do nothing
}

---@param self MoneyUtils
---@return void
local function sanityCheck(self)
	if log.level < Log.LevelDebug then
		return
	end
	local own = self.balance
	local data = game.saveData.getNumber('credit')
	if own ~= data then
		log:debug('<color=yellow>not necessarily problem (balance:', own, ' ~= data:', data, ')</color>')
	else
		log:debug('all good (balance:', own, ')')
	end
end

local function notifyBalanceUpdated()
	game.bus.send({BalanceUpdatedEvent}, nil, false)
end

---Update the balance from storage.
---@return void
function MoneyUtils:updateBalance()
	log:debug('MoneyUtils.updateBalance()')
	self.balance = game.saveData.getNumber('credit') or 0
	log:debug('balance refreshed from data:', self.balance)
end

---@param balanceToDisplay number @ New balance to show
---@return void
local function updateDisplayDefault(balanceToDisplay)
	-- Display balance in UI (optional)
	log:debug('Displaying balance: ', balanceToDisplay)
	game.bus.send({
		displayText = 'Balance: ' .. balanceToDisplay,
		displayType = 'messageDisplayUI.bottom'
	}, nil, false)

	-- Using ticker for announcements now
	---- Display balance in ticker
	--game.bus.send({
	--	displayText = '       Balance: ' .. balanceToDisplay .. '                    ... ',
	--	displayType = 'ticker'
	--}, nil, false)
end

---Try to withdraw the amount specified and return true on success.
---@param amount number
---@param doSync? boolean @ Whether to load and save the new balance from/to storage (default true)
---@return boolean
function MoneyUtils:tryToWithdraw(amount, doSync)
	if nil == doSync then
		doSync = true
	end
	log:log('tryToWithdraw:', amount)
	sanityCheck(self)
	if doSync then
		self:updateBalance()
	end
	if amount > self.balance then
		log:log('tryToWithdraw:', amount, ' failed')
		return false
	end

	self.balance = self.balance - amount
	self.updateDisplay(self.balance)
	if doSync then
		self:finalisePayment(true)
	end
	log:log('tryToWithdraw:', amount, ' succeeded')
	sanityCheck(self)
	return true
end

---Add amount to balance (for when coin dropped).
---@param amount number
---@param doSync? boolean @ whether to save the new balance to storage (default true)
---@return void
function MoneyUtils:payIn(amount, doSync)
	if nil == doSync then
		doSync = true
	end
	log:log('payIn:', amount, ' (doSync:', doSync, ')')
	sanityCheck(self)
	if doSync then
		self:updateBalance()
	end
	self.balance = self.balance + amount
	self.updateDisplay(self.balance)
	if doSync then
		local result = self:finalisePayment(true)
		sanityCheck(self)
		log:log('after payIn, balance:', self.balance)
		return result
	end
	sanityCheck(self)
end

---Persist balance to storage.
---Money taken out as coin while still in the level *DOES NOT COUNT AS SPENT*.
---This is to protect against level quit while still holding coins (or game crash etc).
---When something is purchased and the storage updated, this persists the payment.
---Pass `doSync` true to cause data to be persisted (default) or false (if doing elsewhere).
---Beware that it's still possible some other `saveData` user in the level might persist the data.
---@param doSync boolean @ whether to save the new balance to storage (default true)
---@return void
function MoneyUtils:finalisePayment(doSync)
	if nil == doSync then
		doSync = true
	end
	log:debug('finalisePayment:', doSync)
	sanityCheck(self)
	game.saveData.setNumber('credit', self.balance)
	if doSync then
		game.saveData.save()
		notifyBalanceUpdated()
	end
	self.updateDisplay(self.balance)
	sanityCheck(self)
	log:debug('Finalised payment')
end

---Update the on-screen display of the balance.
---@param doSync boolean @ Whether to reload the balance from storage (default true)
function MoneyUtils:redrawBalance(doSync)
	if nil == doSync then
		doSync = true
	end
	if doSync then
		self:updateBalance()
	end
	self.updateDisplay(self.balance)
	sanityCheck(self)
end

MoneyUtils.updateDisplay = updateDisplayDefault
MoneyUtils:updateBalance()

return MoneyUtils
