---CoOperation Act mod.
---Handles the `act` verb to handle picking-up and placing-down carryable items in a direction.
---This initially includes patients and medicine.

local Log = require('Log')
local log = Log.new()

local DirectionUtils = require('DirectionUtils')

---@type MapMobile
local owner = owner or error('No owner')

-- Bring in the ability to subscribe to the GameManager's message bus for game phase changes
---@type Game
local game = LoadFacility('Game')['game']

local NarrativeSaveDataKeys = require('NarrativeSaveDataKeys')

-- Check whether carrying
local carrier = owner.getFirstComponentTagged('carrier');
assert(nil ~= carrier and 'Carrier' == carrier.typeName, 'Player lacks carrier component')

---Attempt to carry in the direction facing.
local function carry()
    local mapObject = owner.getFirstFacingObjectTagged('carryable')
    if nil == mapObject then
        return false
    end

    local resultantCarryable = mapObject.getFirstComponentTagged('carryable')
    if nil == resultantCarryable then
        return false
    end

    -- carry it!
    local success = carrier.carry(resultantCarryable)
    log:log('Carrying ', mapObject, (success and ' succeeded' or ' failed'))
    return success
end

---Check tile in-front for an `Interact`-tagged object and
---attempt to call an `interact()` method on it.
---Result of that function is either `false`/`nil` (for failure) or `true`/a `MapObject` to carry on success.
---When a `MapObject` is returned, it's checked for `carryable` flag and carried if present.
---@param actDirection Direction
---@return boolean @ Whether successfully interacted.
local function interactInDirection(actDirection)
    log:log('Trying to interact in ', actDirection)
    local interactable = owner.getFirstFacingObjectTagged('Interact')
    if nil == interactable then
        log:log('No interactable')
        return false
    end

    if not interactable.hasFunc('interact') then
        log:log('No interact function on ', interactable)
        return false
    end

    -- Interact with the target.
    -- false = failure, nil = fine, mapObject = do something with it (carry it)
    local result = interactable.callFunc('interact')
    log:debug('Interacted with', interactable, 'result:', result, 'type:', type(result))
    if false == result then
        -- false result means failure
        log:log('Interacted with ', interactable, ' but failed')
        return false
    end
    if nil == result or true == result then
        -- nil result is fine, just means all done (as does true)
        log:log('Successfully interacted with ', interactable)
        return true
    end

    -- Cast result to remove boolean and nil types
    local resultMapObject = (--[[---@not boolean|nil]] result)

    local resultantCarryable = resultMapObject.getFirstComponentTagged('carryable')
    if nil ~= resultantCarryable then
        -- carry it!
        local success = carrier.carry(resultantCarryable)
        if not success then
            log:log('Got ', resultantCarryable, ' but failed to carry it')
        else
            log:log('Successfully picked-up ', resultantCarryable)
        end
        return true
    end

    -- not a carryable result = TODO
    return true
end

---Act for the doctor.
---Called externally (from framework).
---If not carrying, tries to pick something up.
---If carrying patient, tries to place in bed (or another acceptable place if not).
---If carrying medicine, calls 'administer' on the medicine lua script
function act(actDirection)
    log:log('acting in direction:', actDirection)

    if nil == actDirection or not DirectionUtils.isDirection(actDirection) then
        log:error('Invalid direction supplied: ', actDirection)
        return false
    end

    -- Face in direction of action
    owner.setFacing(actDirection)

    local isCarrying = carrier.isCarrying
    log:log('Lua isCarrying:', isCarrying)

    local success = false

    if isCarrying then
        local carried = carrier.getCurrentlyCarried() -- gives us a Carryable component
        log:log('current carried:', carried)

        ---Ask what we're carrying to act for us (medicine, patient etc)
        if carried.owner.hasFunc('actWhenCarried') then
            log:log('Calling actWhenCarried on carried object')
            success = carried.owner.callFunc('actWhenCarried', owner, carrier, actDirection)
        else
            log:log("No 'actWhenCarried' on ", carried.owner, " so cannot act with it!")
            success = false
        end
    else
        if interactInDirection(actDirection) then
            success = true
        else
            -- Not carrying, look for something to pick up
            success = carry()
        end
    end

    if not success then
        -- Acting failed/we did nothing
        log:log('Failed to act in direction ', actDirection)
        game.bus.send({ metadata = { 'player.actionFailed' }, data = { position = owner.gridPosition, direction = actDirection } }, false)
        game.bus.send({ metadata = { 'playSound' }, data = { soundName = 'InvalidAction' } }, false)
        owner.bus.send({ 'player.actionFailed' }, false)

        local sofaInteractedWith = owner.getFirstFacingObjectTagged('sofa')
        if sofaInteractedWith ~= nil then
            local playerComponent = owner.getFirstComponentTagged('Player')
            assert(playerComponent ~= nil)
            -- Save data - used for conditional narrative text
            game.saveData.setNumber(NarrativeSaveDataKeys.thisRound_playerActedAtSofa(), 1)
            game.saveData.setString(NarrativeSaveDataKeys.global_mostRecentActedAtSofaPlayer(), playerComponent.playerName)
            game.saveData.save()
        end
    end

    return success
end

--- This player threw something, and it was caught by another player
---@param message Message
local function onThrewToCaught(message)
    local throwableTags = message.data.threwToCaught;
    if throwableTags == nil then
        error('onThrewToCaught with no tags data')
    end

    local playerComponent = owner.getFirstComponentTagged('Player')
    assert(playerComponent ~= nil)

    -- Save data - used for conditional narrative text
    local thrownObjNameKey = NarrativeSaveDataKeys.getStringTableKeyForNameOfObjectFromTags(throwableTags)
    game.saveData.setNumber(NarrativeSaveDataKeys.thisRound_didPlayerCatch(), 1)
    game.saveData.setString(NarrativeSaveDataKeys.global_mostRecentCaughtObject(), thrownObjNameKey)
    -- +1 successful catch!
    local playerCatchCount = game.saveData.getNumber(NarrativeSaveDataKeys.global_playerCatchCount())
    game.saveData.setNumber(NarrativeSaveDataKeys.global_playerCatchCount(), (playerCatchCount + 1))
    game.saveData.save()
end

--- This player threw something, but it was not caught and landed/smashed
---@param message Message
local function onThrewToUncaught(message)
    local throwableTags = message.data.threwToUncaught;
    if throwableTags == nil then
        error('onThrewToUncaught with no tags data')
    end

    local playerComponent = owner.getFirstComponentTagged('Player')
    assert(playerComponent ~= nil)

    -- Save data - used for conditional narrative text
    if throwableTags.hasTag('pills') then
        -- Smashed pills!
        game.saveData.setNumber(NarrativeSaveDataKeys.thisRound_didPlayerDropPills(), 1)
        game.saveData.setString(NarrativeSaveDataKeys.global_mostRecentPillDropPlayer(), playerComponent.playerName)
    end
    game.saveData.setNumber(NarrativeSaveDataKeys.thisRound_didPlayerThrowToUncaught(), 1)
    game.saveData.save()
end

--- Message received at the start of each turn with the
--- turn number and all player actions for the current round
---@param message Message
local function onTurn(message)
    if carrier.isCarrying then
        -- Nothing needs to be done if carrying
        return
    end

    local turnNum = message.data.turnNumber
    if turnNum == nil then
        error('No turnNumber data in player.turn message')
    end
    if turnNum ~= 0 then
        -- Only interested in the first turn, i.e. turn 0
        return
    end

    local actions = message.data.actions
    if actions == nil then
        error('No actions data in player.turn message')
    end

    -- This is the first turn, check actions for all turns
    for i = 1, #actions do
		if actions[i] ~= '' then
            -- We're looking for a round with only blank actions
            return
        end
	end
    -- Player performs special 'wait' animation when waiting for a whole turn and not carrying
    owner.bus.send({['state.player'] = 'WaitSpecial'}, nil, false)
end

owner.bus.subscribe('threwToCaught', onThrewToCaught)
owner.bus.subscribe('threwToUncaught', onThrewToUncaught)
owner.bus.subscribe('player.turn', onTurn)

log:debug('Act mod ready')
