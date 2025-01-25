-- Bring in the ability to subscribe to the GameManager's message bus for game phase changes
---@type Game
local game = LoadFacility('Game')['game']
---@type MapObject
local owner = owner or error('No owner')

local pos2 = {10, 10}
local gameManagerForInst = LoadFacility('Game')['game'] or error('No GameManager')

function teleportItem(itemToTeleport, tpMode)
    if tpMode == 'item' then
        if owner.tags.hasTag('teleporter1') then
            local itemToTeleportName = itemToTeleport.name
            local tempTeleporter = gameManagerForInst.loader.instantiate('item_teleporter_anim', owner.gridPosition)
            itemToTeleport.destroyObject()
            local tempItem = gameManagerForInst.loader.instantiate(itemToTeleport.name, owner.gridPosition)
            waitSeconds(1)
            tempTeleporter.destroyObject()
            tempItem.destroyObject()
            gameManagerForInst.loader.instantiate('item_teleporter_1', owner.gridPosition)

            local teleporterOutObject = owner.map.getFirstObjectTagged("teleporter2")
            local tempOut = gameManagerForInst.loader.instantiate('item_teleporter_anim',
                teleporterOutObject.gridPosition)
            waitSeconds(1)
            tempOut.destroyObject()
            gameManagerForInst.loader.instantiate('item_teleporter_2', teleporterOutObject.gridPosition)
            gameManagerForInst.loader.instantiate(itemToTeleportName, teleporterOutObject.gridPosition)
        end
        if owner.tags.hasTag('teleporter2') then
            local itemToTeleportName = itemToTeleport.name
            local tempTeleporter = gameManagerForInst.loader.instantiate('item_teleporter_anim', owner.gridPosition)
            itemToTeleport.destroyObject()
            local tempItem = gameManagerForInst.loader.instantiate(itemToTeleport.name, owner.gridPosition)
            waitSeconds(1)
            tempTeleporter.destroyObject()
            tempItem.destroyObject()
            gameManagerForInst.loader.instantiate('item_teleporter_2', owner.gridPosition)

            local teleporterOutObject = owner.map.getFirstObjectTagged("teleporter1")
            local tempOut = gameManagerForInst.loader.instantiate('item_teleporter_anim',
                teleporterOutObject.gridPosition)
            waitSeconds(1)
            tempOut.destroyObject()
            gameManagerForInst.loader.instantiate('item_teleporter_1', teleporterOutObject.gridPosition)
            gameManagerForInst.loader.instantiate(itemToTeleportName, teleporterOutObject.gridPosition)
        end
    end
end

