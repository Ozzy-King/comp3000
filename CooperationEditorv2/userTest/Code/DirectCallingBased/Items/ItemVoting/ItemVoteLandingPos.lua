---@type Game
local game = LoadFacility('Game')['game']

---@type MapMobile
local owner = owner or error('No owner')
---@type Loader
local loader = game.loader or error('No loader')

---@type string
local backupObject = backupObject or ''

function onSpawnBackupObject(_)
    if backupObject == '' then
        -- No backup object specified in mod data, nothing to spawn
        return
    end
    loader.instantiate(backupObject, owner.gridPosition)
end

---MAIN

owner.tags.addTag('ItemVoteLandingPos')
tags.addTag('ItemVoteLandingPos')

owner.bus.subscribe('spawnBackupObject', onSpawnBackupObject)