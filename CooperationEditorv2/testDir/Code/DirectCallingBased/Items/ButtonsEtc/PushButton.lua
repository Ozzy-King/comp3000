---Button which players interact with to send messages to recipient indicated by data.

local V2 = require('Vector')
local Log = require('Log')
local log = Log.new()

local TableUtils = require('TableUtils')

---@type MapMobile
local owner = owner or error('No owner')

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

--Mark self as able to be interacted with
owner.tags.addTag('Interact')

---Allow player to interact with this.
---Externally called.
---@return boolean @ Returns true to indicate interaction was successful.
function interact()
	activate()
	return true
end
