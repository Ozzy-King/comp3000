--- Logic for players squashing, being squashed, and respawning
local Log = require('Log')
local log = Log.new()

local SquashHelper = require('SquashHelper')
local SpawnsInGrid = require('SpawnsInGrid')

---@type MapMobile
local owner = owner or error('No owner')

log:debug('PlayerSquashAndRespawn lua started')

---@return boolean
local function respawnConditions()
    local spawnPos = SpawnsInGrid.getSpawnPosition()

    -- Try to set spawn position to an unblocked tile, first trying our initial spawn pos,
    -- then adjacent tiles, and then, if all else fails, any unblocked floor
    return SpawnsInGrid.trySetSpawnToValidPositionNearTarget(spawnPos, SpawnsInGrid.bypassSquashableBlocker, false)
end

---@param event string
---@return void
local function notifyCarriedIfCarrying(event)
    local carrier = owner.getFirstComponentTagged('carrier');
    if carrier ~= nil and carrier.isCarrying then
        local carried = carrier.getCurrentlyCarried()
        carried.owner.bus.send({event}, nil, false)
    end
end

---@return void
local function onActive()
    owner.tags.addTag('blocksMove')
    owner.tags.addTag('blocksThrow')

    SquashHelper.squashSquashablesAtOwnerPosition(owner)
end

---@return void
local function onVisibleFromRespawn()
    notifyCarriedIfCarrying('carrier.respawned')
    owner.bus.send({visible = true}, nil, false)

    SquashHelper.respawnSquashedAtOwnerPosition(owner)

    -- We don't become squashable again until anything that we squashed
    -- has respawned, to prevent potential infinite loops of squashing
    owner.tags.addTag('squashable')
end

---Called externally when squashed
---@return void
function squash()
    log:log('Player squashed! ', owner)

    -- Remove squashable tag, will become squashable again after respawning
    owner.tags.removeTag('squashable')
    -- Have been squashed
    owner.tags.addTag('squashed')

    notifyCarriedIfCarrying('carrier.squashed')
    owner.bus.send({'squashed'}, nil, false)
end

---Called externally when told to respawn
---@return void
function respawnFromSquashed()
    -- No longer squashed
    owner.tags.removeTag('squashed')

    if SpawnsInGrid.trySetActive(respawnConditions, onActive, onVisibleFromRespawn) == false then
        error('Failed to respawn player/set active - this should never be allowed to happen')
    end
end

---@param _ Message
---@return void
local function onSiblingGrew(_)
    -- Sibling object grew - player is launched into the air & respawns
    notifyCarriedIfCarrying('carrier.launched')
    owner.bus.send({ 'player.launched' }, nil, false)
    if SpawnsInGrid.trySetActive(respawnConditions, onActive, onVisibleFromRespawn) == false then
        error('Failed to respawn player/set active - this should never be allowed to happen')
    end
end

-- Squashable at start
owner.tags.addTag('squashable')

owner.bus.subscribe('sibling.grew', onSiblingGrew)
