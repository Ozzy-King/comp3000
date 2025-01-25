---@type MapMobile
local owner = owner or error('No owner')
---@type Game
local game = LoadFacility('Game')['game']
local CarryHelper = require('CarryHelper')

-- backup

local function placeDownMonsterPart(carryingOwner, carrier, direction)
    -- If there is empty floor with nothing blocking us, place carried item down
    -- the test for Monster_Tab("allows part to be placed on monster table")
    if (carryingOwner.getFirstFacingObjectTagged('blocksMove') == nil and
        carryingOwner.getFirstFacingObjectTagged('floor') ~= nil) then
        local dropPos = Vector.new(carryingOwner.gridPosition[1], carryingOwner.gridPosition[2]) +
                            Vector.directionNameToVector(direction)
        return carrier.endCarry(dropPos) -- success or not
    end

    return false
end

-- Monster_Tab

---External function called when acting with carried item
function actWhenCarried(carrierOwner, carrier, actDirection)
    assert(nil ~= carrierOwner, 'No carrierOwner')
    assert(nil ~= carrier, 'No carrier')
    assert(nil ~= actDirection, 'No actDirection')

    -- If there is empty floor with nothing blocking us, drop the medicine
    if CarryHelper.placeMonster(carrierOwner, carrier, actDirection) then
        return true
    end

    return false
end
