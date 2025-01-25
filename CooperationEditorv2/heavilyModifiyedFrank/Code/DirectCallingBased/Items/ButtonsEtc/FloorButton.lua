---Floor button which sends messages to recipient indicated by data.

local V2 = require('Vector')
local Log = require('Log')
local log = Log.new()

local TableUtils = require('TableUtils')
local messageHelpers = require('MessageHelpers')

---@type MapMobile
local owner = owner or error('No owner')

---@type boolean
local playersOnly = playersOnly or false

---@type Vector2Int
local targetPosRelative = targetPosRelative or error('No targetPosRelative')
targetPosRelative = V2.new(targetPosRelative)

---@type string
local messageToSend = messageToSend or error('No messageToSend to send on activation')

local ownPos = V2.new(owner.gridPosition)
log:debug('owner.gridPosition: ', ownPos)
log:debug('targetPosRelative: ', targetPosRelative)
local targetPos = ownPos + targetPosRelative
log:debug('When stepped-upon, will send messageToSend "', messageToSend, '" to all objects at ', targetPos)

---@return MapObject[]
local function getTargets()
	--Using the iterator would be fine but we convert to an array.
	--Cause:
	--We're gathering the targets to send a message to them.
	--That message might modify the list of items.
	--If that happens, the iterator will fail with error:
	-- "Collection was modified; enumeration operation may not execute"
	return TableUtils.iteratorToArray(owner.map.getAllAt(targetPos))
end

local function activate()
	local targets = getTargets()
	for target in targets do
		log:debug('Sending "', messageToSend, '" to ', target); -- semi-colon to avoid Lua error
		(--[[---@type MapObject]] target).bus.send({ messageToSend }, false)
	end
end

local function onSiblingAdded(message)
	if not playersOnly then
		activate()
		return
	end

	-- only players = check
	local addedMapObj = messageHelpers.getMapObjectViaIdFromMessage(message, 'siblingAdded')
	if not addedMapObj.tags.hasTag('Player') then
		return
	end

	activate()
end

-- MAIN
owner.bus.subscribe('siblingAdded', onSiblingAdded)
