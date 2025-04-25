-- Shrinks things tagged as 'shrinkable' in adjacent tiles when acted with

---@type Game
local game = LoadFacility('Game')['game']

---@type MapMobile
local owner = owner or error('No owner')
local CarryHelper = require('CarryHelper')
local ShrinkUtils = require('ShrinkUtils')

--- Number of uses before the device is destroyed
---@type number
local charge = charge or 1

---@return MapObject[]
local function getValidShrinkableObjectsInFront()
    local validShrinkables = {}
    local shrinkableObjsInFront = owner.getFacingObjectsTagged('shrinkable')
    for shrinkable in shrinkableObjsInFront do
        if ShrinkUtils.objectCanBeShrunk(shrinkable) then
            table.insert(validShrinkables, shrinkable)
        end
    end
    return validShrinkables
end

---@param shrinkables MapObject[]
local function shrinkValidShrinkableObjects(shrinkables)
    for shrinkableObj in shrinkables do
        if not shrinkableObj.callFunc('shrink') then
            error('Expected shrink() to return true but got false on ' .. tostring(shrinkableObj))
        end
    end
end

---External function called when acting with carried item
function actWhenCarried(carrierOwner, carrier, actDirection)
    assert(nil ~= carrierOwner, 'No carrierOwner')
    assert(nil ~= carrier, 'No carrier')
    assert(nil ~= actDirection, 'No actDirection')

    -- If there is empty floor with nothing blocking us, drop the device
    if CarryHelper.placeDownIfClearInFront(carrierOwner, carrier, actDirection) then
        -- Destroyed when dropped on the ground
        owner.destroyObject()
        return true
    end

    -- Get all objects that can currently be shrunk
    local validShrinkables = getValidShrinkableObjectsInFront()
    local shrinkSuccess = false
    if #validShrinkables > 0 then
        -- One or more things can be shrunk in front of the owner
        -- Play sound effect
        game.bus.send({ metadata = { 'playSound' }, data = { soundName = 'ShrinkProdZap' } }, false)
        -- Show the shrinking 'zap' visual effect
        owner.bus.send({ 'shrinkRay.zap' }, nil, false)
        -- Actually do the shrinking by calling shrink() on all valid shrinkables
        shrinkValidShrinkableObjects(validShrinkables)
        shrinkSuccess = true
    end

    charge = charge - 1
    if charge <= 0 then
        -- Destroy if all charges were used
        owner.bus.send({ 'shrinkRay.chargeDead' }, nil, false)
        owner.destroyObject()
    end

    -- True if at least one object was shrunk
    return shrinkSuccess
end

owner.tags.addTag('shrinkRay')

print('ShrinkRay lua started')
