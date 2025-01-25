---Something that either has been bought or could yet be bought in the shop.
---This code is responsible for:
---* knowing whether this item has been bought,
---* hiding/showing itself in the levels where it is present,
---* answering others' queries as to whether it has been bought.
---@type Game
local game = LoadFacility('Game')['game']

local Log = require('Log')
local log = Log.new()

local TableUtils = require('TableUtils')

---@type MapMobile
local owner = owner or error('No owner?!')
---@type Pos
local spawnPosition = spawnPosition or owner.gridPosition
---@type boolean
local isActive = false
---@type string
local boughtItem = boughtItem or error("Buyable MUST HAVE a 'boughtItem' supplied as data")

---Whether to toggle the visibility on purchase so they might bounce in.
local toggleVisibilityOnActivation = true
---Whether to look for all other items in the same square as the bought item and toggle their visibility (to have them bounce in).
local toggleOtherItemsInSquare = true

---Send 'visible' message to show/hide certain view elements (does not require listeners in case no view is present)
---@param target MapObjectType
---@param visible boolean
---@return void
local function setVisibilityOf(target, visible)
	target.bus.send({ visible = visible }, nil, false)
end

---@param target MapObjectType
---@return void
local function toggleVisibilityOf(target)
	log:debug('toggling visibility of ', target)
	setVisibilityOf(target, false)
	setVisibilityOf(target, true)
end

--TODO-20230801 Switch this to using SpawnsInGrid (once finished)
---@return void
local function setActive(beActive)
	-- TODO-20231005: In future, this will check what level of item is bought and spawn only the correct one
	if isActive == beActive then
		log:debug('already ', (isActive and "active" or "inactive"))
		return
	end
	log:debug('setActive:', beActive)

	-- record new state
	isActive = beActive

	--Spawn the boughtItem

	--Let's try getting the loader only when we know we need it
	---@type Game
	local game = LoadFacility('Game')['game'] or error('No game')
	---@type Loader
	local loader = game.loader or error('No loader')

	log:debug('Attempting to create ', boughtItem, ' at ', spawnPosition)
	local newInstance = --[[---@type MapMobile]] loader.instantiate(boughtItem, spawnPosition)

	-- Prompt bounce in and/or make things visible (bounceIn prompted when things go from invisible to visible)
	if beActive and toggleOtherItemsInSquare then
		local bounceItems = TableUtils.iteratorToArray(owner.map.getAllTagged(spawnPosition, 'bounceIn'))

		-- Go through all and set invisible
		for item in bounceItems do
			setVisibilityOf(item, false)
		end

		-- Now make original object visible
		setVisibilityOf(newInstance, true)

		-- And all others
		for item in bounceItems do
			if item.id ~= newInstance.id then
				setVisibilityOf(item, true)
			end
		end
	elseif beActive and toggleVisibilityOnActivation then
		toggleVisibilityOf(newInstance)
	else
		log:debug('sending visible:', beActive)
		setVisibilityOf(newInstance, beActive)
	end

	log:debug('Created ', newInstance, ' at ', spawnPosition)

	log:debug('setActive:', beActive, ': DONE')
end

--MAIN

local function checkBought()
	---@type boolean
	local bought = (0 ~= game.saveData.getNumber(owner.name)) or false
	log:debug('item:', owner.name, '@', owner.gridPosition, ' = bought:', bought)
	setActive(bought)
end

local function onPurchase(_)
	checkBought()
end

local function onSpawnedFromVote(_)
	-- This item won the management phase vote, so should always appear in the level
	setActive(true)
end

owner.bus.subscribe('purchase', onPurchase)
owner.bus.subscribe('spawnedFromVote', onSpawnedFromVote)

checkBought()
