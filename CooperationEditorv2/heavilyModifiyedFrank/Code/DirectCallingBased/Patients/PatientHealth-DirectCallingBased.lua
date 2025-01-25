---Patient health and ailment.
---Sends 'state.patient' messages when changing state (things like 'IdleWaitingForDoctor' and 'Cured').

-- Bring in the ability to subscribe to the GameManager's message bus for game phase changes
---@type Game
local game = LoadFacility('Game')['game']
local CarryHelper = require('CarryHelper')
local SquashHelper = require('SquashHelper')
local SpawnsInGrid = require('SpawnsInGrid')
local NarrativeSaveDataKeys = require('NarrativeSaveDataKeys')
local moneyModifierApplier = require('MoneyModifierApplier')
local V2 = require('Vector')

---@type MoneyUtils
local MoneyUtils = require('MoneyUtils')

local Log = require('Log')
local log = Log.new()

--local allNeeds = allNeeds or { 'pill', 'syringe' }

---@type string
local need = need or 'pill'
-- Or assign from random selection with:
-- need = allNeeds[math.random(#allNeeds)]

---@type MapMobile
local owner = owner or error('No owner')

---Health of patient.  Explicitly *NOT* a local so tests can retrieve the value!
---@type number
health = health or 5
---@type number
local healthOnStart = health

---@type number
local healthLostWhenDropped = healthLostWhenDropped or 1
---@type number
local healthLostWhenSprungFromOutside = healthLostWhenSprungFromOutside or 2
---@type number
local healthLostWhenGivenWrongMedicine = healthLostWhenGivenWrongMedicine or 1
---@type number
local healthLostWhenHitByMedicine = healthLostWhenHitByMedicine or 1
---@type number
local healthLostWhenHitByPatient = healthLostWhenHitByPatient or 1
---@type number
local healthLostWhenSquashed = healthLostWhenSquashed or 1
---@type number
local healthLostOnNewRound = healthLostOnNewRound or 1

---@type number
local healthDisplayOffset = healthDisplayOffset or 0.7
---@type number
local healthDisplayCarryOffset = healthDisplayCarryOffset or 1.25

---@type number @ Turn to appear on (counted from 1)
local appearOnTurn = appearOnTurn or 0
log:log('appearOnTurn:', appearOnTurn)

---Number of turns until active
---@type number
local numTurnsTillActive = -1

---@type boolean
local spawnedFirstTime = false

---@type boolean
local inPlanningPhase = false

---@type boolean
local beingSquashed = false

---Whether this has been destroyed.
---@type boolean
local destroyed = false

---@type number
local healthToLoseOnActive = 0

---Called externally
---@return number
function getHealth()
    return health
end
---Called externally
---@return number
function getStartingHealth()
    return healthOnStart
end

---Called externally
---@return string
function getNeed()
    return need
end

---Called externally
---@return boolean
function isActive()
    return SpawnsInGrid.getActive()
end

local function sendState(newState)
    if newState == nil then
        log:warn('Skipping sending patient state because newState is nil')
        return
    end
    log:log('Setting state:', newState)
    owner.bus.send({['state.patient'] = newState})
end

---@param withDelay boolean
local function showHealthIndicator(withDelay)
    if destroyed or beingSquashed or health <= 0 then
        return
    end
    local carryable = owner.getFirstComponentTagged('carryable')
    local posYOffset = carryable.isAvailableToBeCarried and healthDisplayOffset or healthDisplayCarryOffset
    owner.bus.send({
        metadata = { 'objectCountdown.show' },
        data = {
            displayType = "health",
            value = health,
            positionOffset = { y = posYOffset },
            delay = (withDelay and 1.5 or 0)
        }
    }, nil, false)
end

local function hideHealthIndicator()
    if destroyed then
        return
    end
    owner.bus.send({ 'objectCountdown.hide' }, nil, false)
end

local function loseHealth(delta, alertPlayers)
    if 0 < health then
        log:log('Active so reducing health by '.. delta .. ' from ' .. health .. ' to ' .. health - delta)
        health = health - delta

        if alertPlayers then
            local alertHealthLossMsg = { metadata = { 'patient.alertHealthLoss' }, data = { healthLost = delta, position = owner.gridPosition } }
            game.bus.send(alertHealthLossMsg, nil, false)
        end

        if inPlanningPhase then
            showHealthIndicator(true)
        end

        if 0 >= health then
            -- Save data - patient left the ward this round! Used for conditional narrative text
            game.saveData.setNumber(NarrativeSaveDataKeys.thisRound_didPatientLeave(), 1)

            -- Set patient state to 'Dead', triggering a fade out animation
            sendState('Dead')
            owner.destroyObject()
            destroyed = true

            -- Notify the scoreboard that a patient died (sent as a separate message on the Scoreboard MapObject's bus before sending
            --  'patient.died' on the main bus to ensure the scoreboard animation starts & completes before checking if the game was won/lost).
            --  We also supply the patient's gridPosition in this message which the Scoreboard requires for its animation.
            local scoreboard = owner.map.getFirstObjectTagged('scoreboard')
            if nil ~= scoreboard then
                scoreboard.bus.send({ metadata = { 'patientDied' }, data = { position = owner.gridPosition } })
            end

            -- Notify GameManager lua that a patient died
            game.bus.send({ 'patient.died' })
        end
    else
        log:log('Health 0 = the patient has passed out but keep playing')
    end
end

local function patientCanBecomeActive()
    if numTurnsTillActive > 0 then
        -- Not ready to spawn
        return false
    end

    local spawnPos = SpawnsInGrid.getSpawnPosition()

    local bed = owner.map.getFirstTagged(spawnPos, 'Bed')
    if nil ~= bed then
        -- Patient is in same tile as bed
        if bed.accept(owner) then
            -- Hide patient until they are set as active (so they don't appear in bed before 'falling into bed' animation)
            owner.bus.send({visible = false}, nil, false)
            -- Patient was accepted by the bed, can become active
            return true
        else
            -- Patient was not accepted by the bed
            -- If trying to spawn for the first time in a bed, the patient must wait for the bed to be available
            if not spawnedFirstTime then
                return false
            end
            -- Otherwise, also try other methods of spawning (adjacent tiles)
        end
    end

    -- Try to set spawn position to an unblocked tile at or adjacent to our initial spawn pos
    return SpawnsInGrid.trySetSpawnToValidPositionNearTarget(spawnPos, SpawnsInGrid.bypassSquashableBlocker, true)
end

local function onActive()
    spawnedFirstTime = true

    owner.tags.addTag('blocksMove')
    owner.tags.addTag('blocksThrow')
    owner.tags.addTag('carryable')

    SquashHelper.squashSquashablesAtOwnerPosition(owner)

    local bed = owner.map.getFirstTagged(owner.gridPosition, 'Bed')
    if bed ~= nil then
        -- Active in bed, tell bed to show clipboard for new patient
        bed.bus.send({ 'updateClipboards' }, nil, false)
    end

    local newState = bed and 'InBed' or 'IdleWaitingForDoctor'
    sendState(newState)
end
local function onVisibleFromActive()
    owner.bus.send({'patient.falling'}, nil, false)
    owner.bus.send({visible = true}, nil, false)

    SquashHelper.respawnSquashedAtOwnerPosition(owner)

    -- We don't become squashable again until anything that we squashed
    -- has respawned, to prevent potential infinite loops of squashing
    owner.tags.addTag('squashable')

    -- Lose some health if previously set, then reset value
    if healthToLoseOnActive > 0 then
        loseHealth(healthToLoseOnActive, true)
    end
    healthToLoseOnActive = 0

    if inPlanningPhase then
        showHealthIndicator(false)
    end
end

local function onInactive()
    owner.tags.removeTag('blocksMove')
    owner.tags.removeTag('blocksThrow')
    owner.tags.removeTag('carryable')

    sendState('OffScreen')

    -- Record how long until appearance (if appropriate).
    -- Measured from 1, i.e. a value of 2 means appear on the 2'nd turn!
    numTurnsTillActive = appearOnTurn
end

-- If `appearOnTurn` is 0, we are active at start (else we go inactive)
if (0 >= appearOnTurn) then
    -- active at start
    SpawnsInGrid.trySetActive(patientCanBecomeActive, onActive, onVisibleFromActive)
    -- 1 extra health so initial reduction doesn't start us one too few!
    health = health + 1
else
    -- Disabled at start
    log:log('Disabled at start since '.. appearOnTurn ..' turns until active')
    SpawnsInGrid.setInactive(onInactive, nil, true)
end

---Called externally when squashed
---@type fun()
function squash()
    local carryable = owner.getFirstComponentTagged('carryable')
    if not carryable.isAvailableToBeCarried then
        -- Don't squash if being carried, the carrier (player) will be squashed
        -- and we'll stay in sync with their position (currently done in C# model code)
        return
    end

    beingSquashed = true

    hideHealthIndicator()

    -- Remove squashable tag, will become squashable again after respawning
    owner.tags.removeTag('squashable')
    -- Have been squashed
    owner.tags.addTag('squashed')

    log:log('Squashed! ' .. tostring(owner))
    owner.bus.send({'squashed'}, nil, false)
end

---Called externally when told to respawn
---@type fun()
function respawnFromSquashed()
    -- No longer squashed
    owner.tags.removeTag('squashed')

    beingSquashed = false

    if SpawnsInGrid.trySetActive(patientCanBecomeActive, onActive, onVisibleFromActive) then
        log:log('Returning back to original spawn pos and losing health after being squashed')
        loseHealth(healthLostWhenSquashed, true)
    else
        -- Nowhere to respawn after being squashed, become inactive and try again each round
        SpawnsInGrid.setInactive(onInactive, nil, false)
        healthToLoseOnActive = healthLostWhenSquashed
    end
end

-- Called externally by NarrativeCharacter
---@return boolean
function canShowNarrativeText()
    if not SpawnsInGrid.getActive() then
        -- Don't show dialogue when inactive
        return false
    end
    if health <= healthLostOnNewRound then
        -- Skip showing dialogue if about to die
        return false
    end
    if beingSquashed then
        return false
    end
    return true
end

---Called externally
function canAdministerRemedy(remedy)
    local isActive = SpawnsInGrid.getActive()
    if not isActive then
        log:log('Not yet active')
        return {result='not yet active'}
    end

    local bed = owner.map.getFirstTagged(owner.gridPosition, 'Bed')
    if nil == bed then
        log:log('Must be in bed to be cured!')
        return {result='not in bed'}
    end

    log:log('Need remedy ' .. remedy)
    if remedy == need then
        log:log('Correct remedy!')
        return {result='success'}
    else
        log:log('Wrong remedy!')
        return {result='wrong'}
    end
end

---Called externally when correct medicine is given
function cure(positionOfCurer)
    log:log('Cured me with '.. health .. ' health remaining')
    local moneyToEarn = health
    local modifiedMoney = moneyModifierApplier.applyAllModifiers(owner.gridPosition, moneyToEarn)
    log:log('Earnt '.. modifiedMoney .. ' money')
    MoneyUtils:payIn(modifiedMoney)

    -- Save data - patient was cured this round! Used for conditional narrative text
    game.saveData.setNumber(NarrativeSaveDataKeys.thisRound_wasPatientCured(), 1)
    log:log('set thisRound_wasPatientCured to 1')

    -- Set patient state to 'Cured', triggering the cure animation, then destroy
    owner.bus.send({['state.patient'] = 'Cured', curerPos = positionOfCurer})

    local bed = owner.map.getFirstTagged(owner.gridPosition, 'Bed')
    if bed ~= nil then
        -- Notify bed that patient was cured in it
        bed.bus.send({ 'patientCured' }, nil, false)
    end

    owner.destroyObject()
    destroyed = true

    -- Notify the scoreboard that a patient was cured (sent as a separate message on the Scoreboard MapObject's bus before sending
    --  'patient.cured' on the main bus to ensure the scoreboard animation starts & completes before checking if the game was won/lost).
    --  We also supply the patient's gridPosition in this message which the Scoreboard requires for its animation.
    local scoreboard = owner.map.getFirstObjectTagged('scoreboard')
    if nil ~= scoreboard then
        scoreboard.bus.send({ metadata = { 'patientCured' }, data = { position = owner.gridPosition } })
    end

    -- Notify GameManager Lua that a patient was cured
    -- game.bus.send({ gameManager = 'patient.cured' })
    -- Preferred approach is to announce the event so any interested listener can act
    game.bus.send({ 'patient.cured' })
end

---Called externally when wrong medicine is given
function givenWrongRemedy()
    log:log('Given wrong remedy, losing ' .. healthLostWhenGivenWrongMedicine .. ' health')
    loseHealth(healthLostWhenGivenWrongMedicine, true);
end

---@param message Message
local function onMapObjectStateChanged(message)
	if message.data['state.MapObject'] ~= 'Destroyed' then
		return
	end
	destroyed = true
    hideHealthIndicator()
end

local function onGamePhaseChanged(message)
    if destroyed then
        return
    end

    local phase = message.data.gamePhase
    inPlanningPhase = (phase == 'planning')

    log:log('Game phase: "'.. phase ..'"')
    if not inPlanningPhase then
        hideHealthIndicator()
        log:log('acting phase so doing nothing more')
        return
    end

    local isActive = SpawnsInGrid.getActive()
    log:log('isActive:', isActive)
    if not isActive then
        -- countdown
        log:log('numTurnsTillActive:('.. numTurnsTillActive ..'->'.. numTurnsTillActive - 1 ..')')
        numTurnsTillActive = numTurnsTillActive - 1

        if SpawnsInGrid.trySetActive(patientCanBecomeActive, onActive, onVisibleFromActive) then
            log:log('Became active so doing nothing more')
            return
        end

        log:log('Not yet active so doing nothing more')
        return
    end

    -- Only show health loss alert if health is not greater than its starting value
    -- This prevents the alert from showing on patients present at level start (as patients that appear on start get 1 heath added)
    local notifyHealthLoss = health <= healthOnStart
    loseHealth(healthLostOnNewRound, notifyHealthLoss)
end

local function onThrownButDropped(_)
    local spring = owner.map.getFirstTagged(owner.gridPosition, 'spring')
    if spring ~= nil then
        -- Try to call springing() on spring object
        if spring.hasFunc('springing') then
            spring.callAction('springing')
        end
        -- Dropped on the same tile as a spring, health loss will be handled in onHitSpring instead
        return
    end

    loseHealth(healthLostWhenDropped, true)
end

local function onHitSpring(_)
    SpawnsInGrid.setInactive(onInactive, nil, true)

    -- Reset ready to spawn back at initial position
    numTurnsTillActive = 0

    if SpawnsInGrid.trySetActive(patientCanBecomeActive, onActive, onVisibleFromActive) then
        log:log('Returning back to original spawn pos and losing health after being sprung into the air')
        loseHealth(healthLostWhenSprungFromOutside, true)
    else
        healthToLoseOnActive = healthLostWhenSprungFromOutside
    end
end

local function onHitByThrowable(message)
    local throwableTags = message.data.hitByThrowable;
    if throwableTags == nil then
        error('onHitByThrowable with no tags data')
    end
    log:log('Hit by throwable with tags: ' .. tostring(throwableTags))

    if throwableTags.hasTag('medicine') then
        log:log('Hit by thrown medicine so losing ' .. healthLostWhenHitByMedicine .. ' health')
        loseHealth(healthLostWhenHitByMedicine, true)
    elseif throwableTags.hasTag('patient') then
        log:log('Hit by thrown patient so losing ' .. healthLostWhenHitByPatient .. ' health')
        loseHealth(healthLostWhenHitByPatient, true)
    end
end

---@param _ Message
local function onCarrierSquashed(_)
    beingSquashed = true
    hideHealthIndicator()
end

---@param _ Message
local function onCarrierRespawned(_)
    beingSquashed = false
    if inPlanningPhase then
        showHealthIndicator(true)
    end
end

local function onPlayerActionFailed(message)
    if not SpawnsInGrid.getActive() then
        return
    end
    if message.data.position == nil then
        error('No position data in player.actionFailed message')
    end
    if message.data.direction == nil then
        error('No direction data in player.actionFailed message')
    end
    local actPosition = V2.new(message.data.position) + V2.directionNameToVector(message.data.direction)
    if actPosition ~= V2.new(owner.gridPosition) then
        return
    end

    -- A player had an invalid interaction with this patient!
    local actingPlayer = owner.map.getFirstTagged(message.data.position, 'Player').getFirstComponentTagged('Player')
    local actingPlayerName = actingPlayer.playerName

    log:log('Player ' .. actingPlayerName .. ' had invalid interaction with ' .. tostring(owner))
    owner.bus.send({ metadata = { 'patient.hadInvalidInteraction' }, data = { playerName = actingPlayerName } }, false)
end

---External function called when acting with carried item
function actWhenCarried(carrierOwner, carrier, actDirection)
    assert(nil ~= carrierOwner, 'No carrierOwner')
    assert(nil ~= carrier, 'No carrier')
    assert(nil ~= actDirection, 'No actDirection')

    ---- If there is empty floor with nothing blocking us, place the patient down
    if CarryHelper.placeDownIfClearInFront(carrierOwner, carrier, actDirection) then
        return true
    end

    -- If carrying and no empty floor, look for a bed or player in the direction the player is facing
    -- Priority goes to beds then players
    local bestAcceptorMapObject
    for acceptorMapObject in carrierOwner.getFacingObjectsTagged('bed or player') do
        log:log('Acceptor:', acceptorMapObject)
        if acceptorMapObject.tags.hasTag('bed') then
            if not acceptorMapObject.hasFunc('getIsVisible') then
                error('No getIsVisible() on bed, so cannot check if patient can be placed there')
            end
            if acceptorMapObject.callFunc('getIsVisible') then
                -- Bed is visible, see if it accepts us
                local dropSuccess = CarryHelper.endIntoAcceptorMapObject(carrier, acceptorMapObject)
                log:log('Plopped', owner, 'into bed')
                if dropSuccess then
                    return true
                end
            end
        elseif nil == bestAcceptorMapObject then -- it's a player
            bestAcceptorMapObject = acceptorMapObject
        end
    end

    if nil ~= bestAcceptorMapObject then
        return CarryHelper.endIntoAcceptorMapObject(carrier, bestAcceptorMapObject)
    end

    -- No return value since we're a subscriber
    return false
end

-- make sure we're tagged 'patient' so Medicine knows to heal us!
-- Tag the MapObject
owner.tags.addTag('patient')

-- Tagging self (component) too.  This allows Medicine Lua to find us later
tags.addTag('patient')

log:log('Patient ' ..tostring(owner).. ' has ' ..health.. ' health and needs ' ..need.. ' and '.. (SpawnsInGrid.getActive() and 'is active' or 'is not yet active'))

-- subscribe to get informed when game rounds start
game.bus.subscribe('gamePhase', onGamePhaseChanged)
game.bus.subscribe('player.actionFailed', onPlayerActionFailed)
owner.bus.subscribe('landed', onThrownButDropped)
owner.bus.subscribe('spring', onHitSpring)
owner.bus.subscribe('hitByThrowable', onHitByThrowable)
owner.bus.subscribe('state.MapObject', onMapObjectStateChanged)
owner.bus.subscribe('carrier.squashed', onCarrierSquashed)
owner.bus.subscribe('carrier.respawned', onCarrierRespawned)
