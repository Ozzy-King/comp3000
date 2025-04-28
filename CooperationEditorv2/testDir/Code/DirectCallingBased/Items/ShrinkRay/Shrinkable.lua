-- Something that can be shrunk, regrow after X rounds, and squash

-- Bring in the ability to subscribe to the GameManager's message bus for game phase changes
---@type Game
local game = LoadFacility('Game')['game']

local SquashHelper = require('SquashHelper')
local CarryHelper = require('CarryHelper')
local ShrinkUtils = require('ShrinkUtils')
local SpawnsInGrid = require('SpawnsInGrid')

local Log = require('Log')
local log = Log.new()

---@type MapMobile
local owner = owner or error('No owner')

---@type boolean
local isShrunk = false

---@type boolean
local destroyed = false

--- Number of rounds to to stay shrunk before regrowing
---@type number
local stayShrunkRounds = stayShrunkRounds or 1
--- Number of rounds since this object was shrunk
---@type number
local shrunkRoundCount = 0
---@type number
local turnsTillRegrow = 0
---@type number
local turnNumber = 0

---@type boolean
local blocksMoveDefault = owner.tags.hasTag('blocksMove')
---@type boolean
local blocksThrowDefault = owner.tags.hasTag('blocksThrow')

---@type Direction
local initialFacing = owner.facing

---@return boolean
function getIsShrunk()
    return isShrunk
end

local function setShrunkTags()
    owner.tags.addTag('shrunk')
    owner.tags.addTag('carryable')
    owner.tags.addTag('throwable')
    owner.tags.removeTag('blocksMove')
    owner.tags.removeTag('blocksThrow')
end

local function setDefaultTags()
    owner.tags.removeTag('shrunk')
    owner.tags.removeTag('carryable')
    owner.tags.removeTag('throwable')
    if blocksMoveDefault then
        -- If the owner blocked moves on start, restore this
        owner.tags.addTag('blocksMove')
    end
    if blocksThrowDefault then
        -- If the owner blocked throws on start, restore this
        owner.tags.addTag('blocksThrow')
    end
end

local function stopBeingCarried()
    -- Being carried, end carry at the current position
    local carrier = CarryHelper.getCarrierAtPosition(owner.gridPosition)
    if carrier == nil then
        error('Trying to stop carry but no carrier was found at position for ' .. tostring(owner))
    end
    local ended = CarryHelper.endCarryWithoutPlacing(carrier)
    if not ended then
        error('Carry not ended in Shrinkable!')
    end
end

---@return boolean
local function createNonStaticShrunkDuplicateAndDestroySelf()
    log:debug('Requesting own definition: ', owner.name)
    local levelObject = game.loader.getDefinition(owner.name)
    log:debug('levelObject:', levelObject)
    if nil == levelObject then
        log:warn('No levelObject found for ', owner.name, ' - cannot shrink')
        return false
    end

    log:debug('removing static from levelObject.tags:', levelObject.tags)
    for i, v in ipairs(levelObject.tags) do
        if v == 'static' then
            table.remove(levelObject.tags, i)
            break
        end
    end

    log:debug('Creating replacement for ', owner.name, ' at ', owner.gridPosition, ' from ', levelObject)
    local replacement = game.loader.instantiate(levelObject, owner.gridPosition)
    if nil == replacement then
        log:warn('No replacement created for ', owner.name, ' - cannot shrink')
        return false
    end

    log:debug('Destroying self ', owner)
    destroyed = true
    owner.destroyObject()

    -- Ensure replacement has current turn number
    replacement.callFunc('setTurnNumber', turnNumber)

    log:debug('Shrinking replacement ', replacement)
    return replacement.callFunc('shrink')
end

-- Called externally when this object is shrunk
---@return boolean
function shrink()
    if not ShrinkUtils.objectCanBeShrunk(owner) then
        -- Not allowed to be shrunk
        return false
    end

    log:debug('shrinking ', owner)
    -- Determine whether static.  If so, duplicate as non-static and recall `shrink()` on that and destroy self.
    if owner.tags.hasTag('static') then
        return createNonStaticShrunkDuplicateAndDestroySelf()
    end

    isShrunk = true

    -- Shrink object
    owner.bus.send({ 'shrinkable.shrink' }, nil, false)
    setShrunkTags()

    -- Notify siblings of shrinking
    -- (First, pull all into an array since modifying enumerable will cause exception)
    local siblingsArray = {}
    for siblingObj in owner.map.getAllAt(owner.gridPosition) do
        table.insert(siblingsArray, siblingObj)
    end
    for siblingObj in siblingsArray do
        siblingObj.bus.send({ 'sibling.shrunk' }, nil, false)
    end

    -- Msg for anything that should happen *after* shrinking
    owner.bus.send({ 'shrinkable.shrinkDone' }, nil, false)

    turnsTillRegrow = (stayShrunkRounds * 4) - turnNumber - 1
    if turnsTillRegrow > 0 then
        -- Show countdown UI so players can see num. turns till regrow
        owner.bus.send({
            metadata = { 'objectCountdown.show' },
            data = {
                value = turnsTillRegrow,
                maxValue = (stayShrunkRounds * 4),
                positionOffset = { x = -0.3, z = 0.3 }
            }
        }, nil, false)
    end

    -- Reset counter for number of rounds spent shrunk
    shrunkRoundCount = 0
    return true
end

---@type fun():boolean
local function regrow()
    if not isShrunk then
        -- Already grown/not shrunk
        return false
    end

    log:debug('Regrowing ', owner)
    isShrunk = false

    -- Reset facing direction to what it was before being shrunk
    owner.setFacing(initialFacing)

    -- Return object to normal size/behaviour
    owner.bus.send({ 'shrinkable.grow' }, nil, false)
    setDefaultTags()

    -- Hide turn countdown UI
    owner.bus.send({ 'objectCountdown.hide' }, nil, false)

    local carryable = owner.getFirstComponentTagged('carryable')
    assert(nil ~= carryable, 'No carryable component found on ' .. tostring(owner) ..' Should have been present from start!')
    local growingWhenCarried = (not carryable.isAvailableToBeCarried)
    if growingWhenCarried then
        -- This object is being carried, end the carry
        stopBeingCarried()
        -- Then squash & respawn any squashable things on the same tile
        SquashHelper.squashSquashablesAtOwnerPosition(owner)
        owner.bus.send({ 'shrinkable.squashing' }, nil, false)
        SquashHelper.respawnSquashedAtOwnerPosition(owner)
    end

    -- Notify siblings of growing
    -- (First, pull all into an array since modifying enumerable will cause exception)
    local siblingsArray = {}
    for siblingObj in owner.map.getAllAt(owner.gridPosition) do
        table.insert(siblingsArray, siblingObj)
    end
    for siblingObj in siblingsArray do
        siblingObj.bus.send({ 'sibling.grew' }, nil, false)
    end

    -- Msg for anything that should happen *after* regrowing
    owner.bus.send({ 'shrinkable.growDone' }, nil, false)

    return true
end

---External function called when acting with carried item
function actWhenCarried(carrierOwner, carrier, actDirection)
    assert(nil ~= carrierOwner, 'No carrierOwner')
    assert(nil ~= carrier, 'No carrier')
    assert(nil ~= actDirection, 'No actDirection')

    -- If there is empty floor with nothing blocking us, drop
    if CarryHelper.placeDownIfClearInFront(carrierOwner, carrier, actDirection) then
        -- Objects are placed facing the same direction they started
        -- (Direction may have been changed during carry)
        owner.setFacing(initialFacing)
        return true
    end
    return false
end

---@param turnNum number
function setTurnNumber(turnNum)
    turnNumber = turnNum
end

---@param _ Message
---@return void
local function onThrownButDropped(_)
    -- Objects land facing the same direction they started
    -- (Direction may have been changed during carry)
    owner.setFacing(initialFacing)

    local spring = owner.map.getFirstTagged(owner.gridPosition, 'spring')
    if spring ~= nil then
        -- Thrown to a spring, call springing() to trigger its animation
        if not spring.hasFunc('springing') then
            error('Object tagged as "spring" does not have springing() function: ' .. tostring(spring))
        end
        spring.callFunc('springing')
    end
end

---@param message Message
---@return void
local function onGamePhaseChanged(message)
    if destroyed then
        return
    end

    local phase = message.data.gamePhase
    if phase ~= 'planning' then
        return
    end

    if not isShrunk then
        -- Not shrunk, nothing to do here
        return
    end

    -- Regrow in planning phase if shrunkRoundCount is reached
    shrunkRoundCount = shrunkRoundCount + 1
    if shrunkRoundCount >= stayShrunkRounds then
        regrow()
    end
end

---@param message Message
local function onTurnStart(message)
    if destroyed then
        return
    end

    if message.data.turnNumber == nil then
        error('No turnNumber data in turnStart message')
    end
    setTurnNumber(message.data.turnNumber)

	if not isShrunk then
        return
    end

    turnsTillRegrow = turnsTillRegrow - 1
    owner.bus.send({
        metadata = { 'objectCountdown.show' },
        data = { value = turnsTillRegrow }
    }, nil, false)
end

local function onInactive() end
local function onActive() end

---@return boolean
local function canBecomeActive()
    local spawnPos = SpawnsInGrid.getSpawnPosition()

    -- Try to set spawn position to an unblocked tile, first trying our initial spawn pos,
    -- then adjacent tiles, and then, if all else fails, any unblocked floor
    return SpawnsInGrid.trySetSpawnToValidPositionNearTarget(spawnPos, nil, false)
end

---@param _ Message
local function onHitSpring(_)
    SpawnsInGrid.setInactive(onInactive, nil, true)

    if not SpawnsInGrid.trySetActive(canBecomeActive, onActive, nil) then
        error('Failed to respawn shrinkable/set as active (this should never be allowed to happen as there should always be an unoccupied grid space somewhere in the level)')
    end
end

assert(owner.tags.hasTag('carryable'), 'Shrinkable must also be carryable at start (to ensure they can be carried when shrunk)')
owner.tags.addTag('shrinkable')
setDefaultTags()

-- subscribe to get informed when game rounds start
owner.bus.subscribe('landed', onThrownButDropped)
owner.bus.subscribe('spring', onHitSpring)
game.bus.subscribe('gamePhase', onGamePhaseChanged)
game.bus.subscribe('turnStart', onTurnStart)
