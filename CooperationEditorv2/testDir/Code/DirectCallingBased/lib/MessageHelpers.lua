---Helpers for working with messages (sent over the bus)

require('CoOpTypes')

---@type Entities
local entitiesFacility = LoadFacility('Entities')
local getComponentById = entitiesFacility['getComponentById']
local getMapObjectById = entitiesFacility['getMapObjectById']

---@class MessageHelpers
local MessageHelpers = {}

---@param msg Message
---@field field string
---@return any
function MessageHelpers.getFieldViaIdFromMessage(msg, field)
	local value = msg.data[field]
	assert(nil ~= value, "No '" .. field .. "' field in msg")
	return value
end

---@param msg Message
---@field field string
---@return Component
function MessageHelpers.getComponentViaIdFromMessage(msg, field)
	local id = msg.data[field]
	assert(nil ~= id, "No '" .. field .. "' field in msg")

	local o = getComponentById(id)
	assert(nil ~= o, "No component with id '" .. id .. "' from field " .. field)

	return o
end

---Get a MapObject from a message field which contains the id of the MapObject.
---@public
---@param field string
---@param msg Message
---@return MapObject
function MessageHelpers.getMapObjectViaIdFromMessage(msg, field)
	local id = msg.data[field]
	assert(nil ~= id, "No '" .. field .. "' field in msg")

	local o = getMapObjectById(id)
	assert(nil ~= o, "No MapObject with id '" .. id .. "' from field " .. field)

	return o
end

return MessageHelpers
