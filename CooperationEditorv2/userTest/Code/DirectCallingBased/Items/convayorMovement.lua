-- Bring in the ability to subscribe to the GameManager's message bus for game phase changes
---@type Game
local game = LoadFacility('Game')['game']
local owner = owner or error('No owner');
local vectors = require('Vectors')
require('TableUtils')
require('DirectionUtils')


local conveyorDIR;
local CurrentPos
local DIRVector;


function getUpdatedPosForItem()
    --if CurrentPos == nil then --check to see if this is the first call
    conveyorDIR = owner.facing
    CurrentPos =  owner.gridPosition;
    DIRVector = vectors.directionToVector(conveyorDIR)
    --end
    return vectors.add(CurrentPos, DIRVector)
end

function replaceWithMoving(objectListOut, index)
    conveyorDIR = owner.facing
    local replaceWith = 'conveyor' .. tostring(conveyorDIR) .. 'Dynamic'
    game.loader.instantiate(replaceWith, owner.gridPosition)
    objectListOut[index] = game.map.getFirstTagged(owner.gridPosition, 'convDyn')
    owner.destroyObject()
end
function replaceWithStatic(objectListOut, index)
    conveyorDIR = owner.facing
    local replaceWith = 'conveyor' .. tostring(conveyorDIR)
    game.loader.instantiate(replaceWith, owner.gridPosition)
    objectListOut[index]  = game.map.getFirstTagged(owner.gridPosition, 'convDyn')
    waitSeconds(0.3)
    owner.destroyObject()
end



