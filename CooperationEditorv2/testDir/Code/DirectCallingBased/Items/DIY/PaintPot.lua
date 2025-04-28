local V2 = require('Vector')
local DIYUtils = require('DIYUtils')

local Log = require('Log')
local log = Log.new()

---@type MapMobile
local owner = owner or error('No owner')

local DIYManagerMapObject = owner.map.getFirstObjectTagged('DIYManager') or error("No object tagged DIYManager")

---The colour change that will occur (like changing the colour or the material).
---@type string
local colour = colour or 'Blue'

-- local material = material or 'HardCarpet' -- TODO: Material!

---Number of times the item can be used.
---@type number
local uses = uses or 1

---@param pos Pos
---@param colour string
local function persistUpdate(pos, colour)
	log:debug('sending updateTile: ', pos, ', ', colour, ' to ', DIYManagerMapObject)
	--TODO: Had to use bus sending instead of calling directly to avoid errors about method ownership (other script owns the method).
	--TODO: Had to break-out pos as 2 components to avoid errors about ownership (this script owns the tuple).
	DIYManagerMapObject.bus.send( {'updateTile'}, { x = pos[1], y = pos[2], colour = colour} )
end

---External function called when acting with carried item
---@param carrierOwner MapMobile
---@param carrier Carrier
---@param actDirection DirectionName
function actWhenCarried(carrierOwner, carrier, actDirection)
	assert(nil ~= carrierOwner, 'No carrierOwner')
	assert(nil ~= carrier, 'No carrier')
	assert(nil ~= actDirection, 'No actDirection')

	--Find target position
	local targetPos = V2.new(carrierOwner.gridPosition) + V2.directionNameToVector(actDirection)

	--Apply the change
	local success = DIYUtils.restyle(targetPos, colour)
	if not success then
		return false
	end

	--Persist for reload
	persistUpdate(targetPos, colour)

	--Handle uses
	uses = uses - 1
	if 0 >= uses then
		log:debug('Used up = Destroying self')
		owner.destroyObject()
	end

	return true
end
