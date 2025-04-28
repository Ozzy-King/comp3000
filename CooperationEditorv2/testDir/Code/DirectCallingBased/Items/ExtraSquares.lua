---Allows an object to block extra squares when appropriate (not shrunk).

---Offsets from own position to affect.
---@type Vector2Int[]
local offsets = offsets or error('Need `offsets` to affect')

---Prefab to place on the affected squares
---@type string
local item = item or error('Need an `item` to place on affected squares')

local DirectionUtils = require('DirectionUtils')
local V2 = require('Vector')

---@type Loader
local loader = LoadFacility('Game')['game'].loader

local Log = require('Log')
local log = Log.new()

---The instances created by `occupyPositions()` to remove when not appropriate (shrunk)
---@type MapObjectType[]
local instances = {}

---@return void
local function occupyPositions()
	log:debug('Creating ', #offsets, ' instances of ', item, ' around ', owner.gridPosition)
	local ownerPos = V2.new(owner.gridPosition)
	local ownerDir = --[[---@type DirectionName]] owner.facing
	assert(nil ~= ownerDir, 'No owner direction (facing)')
	local dirNum = DirectionUtils.nameToNum(ownerDir) -- includes error checking
	-- ownerDir might be "south" so as dirNum 2 minus north (0) = 2
	local rotation = dirNum - DirectionUtils.NameToNumber['north']
	--log:debug('dirNum:', dirNum, 'north:', DirectionUtils.NameToNumber['north'])
	for _, offset in ipairs(offsets) do
		local base = V2.new(offset)
		local targetPos = ownerPos + V2.rotateClockwise(base, rotation)
		--log:debug('Creating ', item, ' at ', targetPos, ' having rotated ', base, ' by ', rotation, ' to get ', targetPos)
		local newInstance = loader.instantiate(item, targetPos)
		table.insert(instances, newInstance)
	end
end

local function unoccupyPositions()
	log:debug('Destroying ', #instances, ' instances of ', item, ' around ', owner.gridPosition)
	for _, instance in ipairs(instances) do
		instance.destroyObject()
	end
end

local function onDestroy(msg)
	if msg.data['state.MapObject'] ~= 'Destroyed' then
		return
	end
	unoccupyPositions()
end

--Subscribe to destroy message to remove
owner.bus.subscribe('state.MapObject', onDestroy)

--Subscribe to shrunk message to remove
owner.bus.subscribe('shrinkable.shrink', unoccupyPositions) -- 'shrinkable.shrink' or 'shrinkable.shrinkDone'?

--Subscribe to grow message to recreate
owner.bus.subscribe('shrinkable.grow', occupyPositions)

occupyPositions()
