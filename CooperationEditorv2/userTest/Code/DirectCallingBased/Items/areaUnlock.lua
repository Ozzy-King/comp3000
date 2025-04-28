-- Bring in the ability to subscribe to the GameManager's message bus for game phase changes
---@type Game
local game = LoadFacility('Game')['game']
---@type MapObject
local owner = owner or error('No owner')
local pos2 = {16, 16}
local gameManagerForInst = LoadFacility('Game')['game'] or error('No GameManager')

local function onSiblingAdded(message)
    -- check whether there's a player in the same square as our owner
    local player = owner.map.getFirstTagged(owner.gridPosition, 'Player')
    if nil == player then
        return
    end

    local itemTeleporter = owner.map.getFirstObjectTagged('teleporter')

    if itemTeleporter ~= nil then
        -- Should show new floor but doesnt
        itemTeleporter.tags.addTag('cameraTarget')
        print("Area unlocked")
    end
    return
    -- gameManagerForInst.loader.instantiate('unlockArea', pos2)
end

-- Subscribe to be told when something enters the same square we're on
owner.bus.subscribe('siblingAdded', onSiblingAdded)
