---Move mod

local Log = require('Log')
local log = Log.new()
local Vector = require('Vector')

local DirectionUtils = require('DirectionUtils')

---@type Game
local game = LoadFacility('Game')['game']

local MessageHelpers = require('MessageHelpers')
local NarrativeSaveDataKeys = require('NarrativeSaveDataKeys')

---@type MapMobile
local owner = owner or error('No owner')

local carrier = owner.getFirstComponentTagged('carrier');
assert(nil ~= carrier and 'Carrier' == carrier.typeName, 'Player lacks carrier component')

owner.bus.send({['state.player'] = (carrier.isCarrying and 'IdleCarry' or 'Idle')}, nil, false)

---onMoveObstructed
---@param message Message
---@return void
local function onMoveObstructed(message)
    -- Tell objects tagged as 'wobble' in the tile the player is facing (but could not move into) to wobble
    local mapObjsToWobble = owner.getFacingObjectsTagged('wobbleWhenBumped')
    for mapObj in mapObjsToWobble do
        mapObj.bus.send({ 'wobble' }, nil, false)
    end

    local playerComponent = owner.getFirstComponentTagged('Player')
    assert(playerComponent ~= nil)

    owner.bus.send({['state.player'] = (carrier.isCarrying and 'BumpCarry' or 'Bump')}, nil, false)
    local obstructionId = message.data.obstructionId
    if obstructionId == nil or obstructionId == -1 then
        -- No obstruction object, e.g. edge of map
        log:log('onMoveObstructed with no obstruction object')
        return
    end

    local obstructionObj = MessageHelpers.getMapObjectViaIdFromMessage(message, 'obstructionId')
    local objNameKey = NarrativeSaveDataKeys.getStringTableKeyForNameOfObject(obstructionObj)

    -- Save data - used for conditional narrative text
    game.saveData.setNumber(NarrativeSaveDataKeys.thisRound_didPlayerBump() , 1)
    game.saveData.setString(NarrativeSaveDataKeys.global_mostRecentBumpPlayer(), playerComponent.playerName)
    game.saveData.setString(NarrativeSaveDataKeys.global_mostRecentBumpedObject(), objNameKey)
    -- +1 player bumped!
    local playerBumpCount = game.saveData.getNumber(NarrativeSaveDataKeys.global_playerBumpCount())
    game.saveData.setNumber(NarrativeSaveDataKeys.global_playerBumpCount(), (playerBumpCount + 1))
    game.saveData.save()
end

-- Called from framework with text from the controller
function move(direction)
    log:log('Modding moving ', direction, ' with owner ', owner)

    if nil == direction or not DirectionUtils.isDirection(direction) then
        log:error('Invalid direction supplied: ', direction)
        return false
    end

    owner.bus.send({['state.player'] = (carrier.isCarrying and 'RunCarry' or 'Run')}, nil, false)

    --local result = false;
    -- Cannot do own movement by checking target space because resolution is more complex
    --local newloc = Vector.new(owner.gridPosition[1], owner.gridPosition[2]) + Vector.directionNameToVector(direction)
    --if (owner.map.getFirstTagged(newloc,'blocksMove') ~= nil) then
    --    onMoveObstructed({ ["metadata"]={}, ["data"]={["mapMobile.moveObstructed"]=0, ["obstructionId"]=-1}} )
    --    return false
        --result = false
   -- else
        local result = owner.move1SpaceIfPossible(direction)
    --end


    owner.bus.send({['state.player'] = (carrier.isCarrying and 'IdleCarry' or 'Idle')}, nil, false)

    -- only return a value if we succeeded (so other things can be tried otherwise)
    if result then
        log:log('Modding moved direction ', direction, ' with owner ', owner, ' SUCCEEDED')
        return true
    else
        log:log('Modding moved direction ', direction, ' with owner ', owner, ' FAILED')
        return false
    end
end




owner.bus.subscribe('mapMobile.moveObstructed', onMoveObstructed)

-- print('Move mod ready for', owner)
