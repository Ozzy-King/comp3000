---Receives message from buttons and changes the item dispensed.

local V2 = require('Vector')

---@type Game
local game = LoadFacility('Game')['game'] or error('No game')

---@type Loader
local loader = game.loader or error('No loader')

local Log = require('Log')
local log = Log.new()
log:debug("DIYStall loaded")

local owner = owner or error('No owner')

---Names of items to dispense (e.g. 'pill1_e', 'pill2_e', 'pill3_e')
---Dispenses more than one type to position correctly.
---The values supplied should be names of items as defined in the Level Map's `objectDefinitions` section.
---@type string[]
local items = items or { 'PaintPot-blue', 'PaintPot-green' }

local currentSlot = 1

---Last item instantiated.  Used to destroy if still in slot when the selection is changed.
---@type MapMobile
local lastCreated = nil

local ownerPos = V2.new(owner.gridPosition)

---@type boolean
local changeInProgress = false

---Create a new item at own position as described by an entry in the `objectDefinitions`.
---@return void
local function dispenseCurrentItem()
	if nil ~= lastCreated then
		if ownerPos ~= lastCreated.gridPosition then
			log:debug('Destroying last created item: ', lastCreated); -- semi-colon to avoid Lua error
			changeInProgress = true
			lastCreated.destroyObject()
			lastCreated = nil
			changeInProgress = false
		else
			log:debug('Not destroying last item as last created no longer in slot: ', lastCreated)
		end
	end

	local item = items[currentSlot]
	log:log('Attempting to create number ', currentSlot, ':', item, ' at ', owner.gridPosition)
	local newInstance = --[[---@type MapMobile]] loader.instantiate(item, owner.gridPosition)
	lastCreated = newInstance
	log:log('Created ', newInstance, ' with id:', newInstance.id)
end

local function onSelectLeft(_)
	print('select left')
	currentSlot = currentSlot - 1
	if currentSlot < 1 then
		currentSlot = #items
	end
	dispenseCurrentItem()
end

local function onSelectRight(_)
	print('select right')
	currentSlot = currentSlot + 1
	if currentSlot > #items then
		currentSlot = 1
	end
	dispenseCurrentItem()
end

---When a sibling is removed, instantiate a new one.
---@param msg Message
local function onSiblingRemoved(msg)
	if changeInProgress then
		log:debug('Change in progress = swapping offering so skipping sibling removal response')
		return
	end

	log:debug('Sibling removed: ', msg)
	local removedId = msg.data['siblingRemoved']

	if nil == removedId or nil == lastCreated or removedId ~= lastCreated.id then
		log:debug('Some other thing removed from this square = ignoring')
		return
	end

	log:debug('lastCreated has been removed, instantiating new')
	lastCreated = nil -- record that we no longer own lastCreated

	-- TODO: Consider stashing the id and *actually* adding at turn end (and animate them in)
	dispenseCurrentItem()
end

owner.bus.subscribe('siblingRemoved', onSiblingRemoved)
owner.bus.subscribe('selectLeft', onSelectLeft)
owner.bus.subscribe('selectRight', onSelectRight)

dispenseCurrentItem()
