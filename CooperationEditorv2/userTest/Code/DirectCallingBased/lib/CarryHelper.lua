---Utilities for carrying
---
local Vector = require('Vector')

local CarryHelper = {}

---Place down the currently carried item in the direction and return whether succeeded.
---@param carryingOwner MapMobile
---@param carrier Carrier
---@param direction DirectionName
---@return boolean
function CarryHelper.placeDownIfClearInFront(carryingOwner, carrier, direction)
    -- If there is empty floor with nothing blocking us, place carried item down
    local noMoveBlocker = carryingOwner.getFirstFacingObjectTagged('blocksMove') == nil
    -- (Shrunk things don't block movement, but do not allow things to be placed on top of them, to prevent e.g. multiple beds/cabinets in a single tile)
    local noShrunkObject = carryingOwner.getFirstFacingObjectTagged('shrunk') == nil
    local hasFloor = carryingOwner.getFirstFacingObjectTagged('floor') ~= nil
    local hasConv = carryingOwner.getFirstFacingObjectTagged('conv') ~= nil
    if noMoveBlocker and noShrunkObject and (hasFloor or hasConv) then
        local dropPos = Vector.new(carryingOwner.gridPosition) + Vector.directionNameToVector(direction)
        return carrier.endCarry(dropPos) -- success or not
    end

    return false
end

function CarryHelper.placeMonster(carryingOwner, carrier, direction)

    -- If there's a table in front of us, add the carried body part to it (this will cause the carried item to be destroyed)
    local monsterTabMapObj = carryingOwner.getFirstFacingObjectTagged('Monster_Tab')
    local itemTeleporter1 = carryingOwner.getFirstFacingObjectTagged('teleporter1')
    local itemTeleporter2 = carryingOwner.getFirstFacingObjectTagged('teleporter2')
    local vatObject = carryingOwner.getFirstFacingObjectTagged('PowerVAT')

    if monsterTabMapObj ~= nil then
        local directCallResult = monsterTabMapObj['addBodyPart'](owner)
        -- monsterTabMapObj.monsterTabMapObj['addBodyPart'](owner)
        -- monsterTabMapObj.callAction('addBodyPart', owner)
        return true
    end

    if nil ~= vatObject then
        local directCallResult = vatObject['addPowerBucket'](owner)
        print("ADED TO VAT")
        return true
    end

    if itemTeleporter1 ~= nil then
        print("Teleporter exists!!")
        if owner.tags.hasTag('player') then
            local directCallResult = itemTeleporter1['teleportItem'](owner, 'player')
        else
            local directCallResult = itemTeleporter1['teleportItem'](owner, 'item')
        end
        -- monsterTabMapObj.monsterTabMapObj['addBodyPart'](owner)
        -- monsterTabMapObj.callAction('addBodyPart', owner)
        return true
    end

    if itemTeleporter2 ~= nil then
        print("Teleporter exists!!")
        if owner.tags.hasTag('player') then
            local directCallResult = itemTeleporter2['teleportItem'](owner, 'player')
        else
            local directCallResult = itemTeleporter2['teleportItem'](owner, 'item')
        end
        -- monsterTabMapObj.monsterTabMapObj['addBodyPart'](owner)
        -- monsterTabMapObj.callAction('addBodyPart', owner)
        return true
    end

    -- If there is empty floor with nothing blocking us, place carried item down
    if (carryingOwner.getFirstFacingObjectTagged('blocksMove') == nil and
        carryingOwner.getFirstFacingObjectTagged('floor') ~= nil) then
        local dropPos = Vector.new(carryingOwner.gridPosition[1], carryingOwner.gridPosition[2]) +
                            Vector.directionNameToVector(direction)
        return carrier.endCarry(dropPos) -- success or not
    end

    return false
end

---Place down the currently carried item on carrier's position and return whether succeeded.
---@param carrier Carrier
---@return boolean
function CarryHelper.endCarryWithoutPlacing(carrier)
    return carrier.endCarry()
end

---Attempt to get the carrier at the given position (or nil).
---@param position Pos
---@return Carrier|nil
function CarryHelper.getCarrierAtPosition(position)
    local carrierObjs = owner.map.getAllTagged(position, 'carrier')
    for carrierObj in carrierObjs do
        local carrierComp = carrierObj.getFirstComponentTagged('carrier')
        if carrierComp ~= nil then
            return carrierComp
        end
    end
    return nil
end

---Cease carrying by passing it to the supplied 'acceptor'.
---@param carrier Carrier
---@param acceptorMapObject MapObject @ Should have an acceptor component which accepts the item currently carried.
---@return boolean
function CarryHelper.endIntoAcceptorMapObject(carrier, acceptorMapObject)
    if acceptorMapObject.hasFunc('canAccept') then
        if not acceptorMapObject.callFunc('canAccept', owner) then
            return false
        end
    end
    local acceptor = acceptorMapObject.getFirstComponentTagged('acceptor')
    assert(nil ~= acceptor, "No acceptor on " .. tostring(acceptorMapObject))
    return carrier.endCarryInto(acceptor)
end

return CarryHelper
