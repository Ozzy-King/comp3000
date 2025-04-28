---Automatically restocks to the expected number of items.
---Set `items` to the list of items (objectDefinition entries) to create.

local Log = require('Log')
---Default to normal 'log' level unless
local logLevel = --[[---@type number]] (logLevel or Log.LevelLog)
local log = Log.new(logLevel)
log:debug("Dispenser loaded")

---@type MapMobile
local owner = owner or error('No owner')

---@type Game
local game = LoadFacility('Game')['game'] or error('No game')

---@type Loader
local loader = game.loader or error('No loader')

---Names of items to dispense (e.g. 'pill1_e', 'pill2_e', 'pill3_e')
---Dispenses more than one type to position correctly.
---The values supplied should be names of items as defined in the Level Map's `objectDefinitions` section.
---@type string[]
local items = items or {'pill1_e', 'pill2_e', 'pill3_e'}

---Map of prefab id (instance number) instantiated to item name requested.
---Built as items are first created.
---Used to determine which items are removed (thus need replacing) after sibling removal.
---@type table<number, string>
local prefabToNameMap = {}

---@type boolean
local shouldDispense = true

---Create a new item at own position as described by an entry in the `objectDefinitions`.
---@return MapMobile @ The `MapMobile` created or nil if problems.
local function dispenseItem(item)
	log:debug('Attempting to create ', item, ' at ', owner.gridPosition)
	local newInstance = --[[---@type MapMobile]] loader.instantiate(item, owner.gridPosition)
	-- Record the instance id so we can map it back to the item name when removed.
	prefabToNameMap[newInstance.id] = item
	log:debug('Created ', newInstance, ' (mapped "', newInstance.id, '" to "', item, '")')
	return newInstance
end

local function addAllItems()
	log:debug('Adding all items:', items)
	---@type number
	local i = 0
	for _,name in pairs(items) do
		i = i + 1
		log:debug('Creating #', i, ': ', name)
		dispenseItem(name)
	end
	log:debug('Created ', i, ' items')
end

---@param id number
local function addMissingItem(id)
	log:debug('Trying to dispense replacement for removed item id:', id)
	local missingItem = prefabToNameMap[id]
	if not missingItem then
		log:warn('No item found for missing id:', id, ' amongst:', prefabToNameMap, ', items:', items, '.\n<color=red>Could there have been other carryable items in same square?</color>')
		return
	end
	log:log('Dispensing replacement for removed item id:', id, ' = ', missingItem)
	local dispensed = dispenseItem(missingItem)
	log:debug('Created:', dispensed)
end

---When a sibling is removed, instantiate a new one.
---@param msg Message
local function onSiblingRemoved(msg)
	if not shouldDispense then
		log:debug('Not presently dispensing so ignoring sibling removal.')
		return
	end

	log:debug('Sibling removed:', json.serialize(msg))
	local removedId = msg.data['siblingRemoved']
	-- TODO: Consider stashing the id and *actually* adding at turn end (and animate them in)
	addMissingItem(removedId)
end

---Record when level finished to know not to respawn things any longer.
local function onGamePhase(msg)
	local phase = msg.data.gamePhase;
	log:debug('Game phase: "', phase, '"')
	if phase ~= 'finished' then
		return
	end

	log:debug('Level finished:', json.serialize(msg))
	shouldDispense = false
end

---Record when destroyed to know not to respawn things any longer.
local function onDestroyed(msg)
	log:debug('Dispenser destroyed:', json.serialize(msg))
	shouldDispense = false
end

--- Shrunk by a Shrink Ray
---@param _ Message
---@return void
local function onShrunk(_)
	-- Don't dispense anything when shrunk
	shouldDispense = false
end

---@param _ Message
---@return void
local function onGrownFromShrunk(_)
	-- Back to normal unshrunk state, restore items
	shouldDispense = true
	addAllItems()
end

owner.tags.addTag('dispenser')

owner.bus.subscribe('siblingRemoved', onSiblingRemoved)
game.bus.subscribe('gamePhase', onGamePhase)
owner.bus.subscribe('state.MapObject', onDestroyed)
owner.bus.subscribe('shrinkable.shrink', onShrunk)
owner.bus.subscribe('shrinkable.growDone', onGrownFromShrunk)

addAllItems()
