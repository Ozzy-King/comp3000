-- Bring in the ability to subscribe to the GameManager's message bus for game phase changes
---@type Game
local game = LoadFacility('Game')['game']
---@type MapObject
local owner = owner or error('No owner')
---@type MapObject 
local bodyParts = {}
---@type MapObject 
local bodyPartHead

local gameManagerForInst = LoadFacility('Game')['game'] or error('No GameManager')

local hasHead = false
local hasLLeg = false
local hasRLeg = false
local hasLArm = false
local hasRArm = false
local hasTorso = false

local function checkIfFinished()
    if hasHead and hasLLeg and hasRLeg and hasLArm and hasRArm and hasTorso then
        print('Frank is completed')
        owner.tags.addTag("completed")
        local tableObject = owner.map.getFirstObjectTagged("Monster_Tab")
        gameManagerForInst.loader.instantiate('frankTable_green_n', tableObject.gridPosition)
        tableObject.destroyObject()
    end
end

-- Call this to start the dance
function monsterDance()

    local lleg = owner.map.getFirstObjectTagged('lleg')
    local rleg = owner.map.getFirstObjectTagged('rleg')
    local larm = owner.map.getFirstObjectTagged('larm')
    local rarm = owner.map.getFirstObjectTagged('rarm')
    local torso = owner.map.getFirstObjectTagged('tableTorso')
    local head = owner.map.getFirstObjectTagged('tableHead')

    local theTable = owner.map.getFirstObjectTagged('tableGreen')
    gameManagerForInst.loader.instantiate('monster_dance_1', theTable.gridPosition)

    lleg.destroyObject()
    rleg.destroyObject()
    larm.destroyObject()
    rarm.destroyObject()
    torso.destroyObject()
    head.destroyObject()

end

-- Called externally by CarryHelper.placeMonster
function addBodyPart(bodyPart)
    if bodyPart ~= nil then
        if bodyPart.tags.hasTag('head') == true and hasHead == false then
            print('Frank head added')
            hasHead = true
            bodyPart.destroyObject()
            gameManagerForInst.loader.instantiate('monsterHeadOnTable', owner.gridPosition)
        end
        if bodyPart.tags.hasTag('leg') == true and hasLLeg == false then
            print('Frank left leg added')
            hasLLeg = true
            bodyPart.destroyObject()
            gameManagerForInst.loader.instantiate('monsterLLegOnTable', owner.gridPosition)
        elseif bodyPart.tags.hasTag('leg') == true and hasRLeg == false then
            print('Frank right leg added')
            hasRLeg = true
            bodyPart.destroyObject()
            gameManagerForInst.loader.instantiate('monsterRLegOnTable', owner.gridPosition)
        end
        if bodyPart.tags.hasTag('arm') == true and hasLArm == false then
            print('Frank left arm added')
            hasLArm = true
            bodyPart.destroyObject()
            gameManagerForInst.loader.instantiate('monsterLArmOnTable', owner.gridPosition)
        elseif bodyPart.tags.hasTag('arm') == true and hasRArm == false then
            print('Frank right arm added')
            hasRArm = true
            bodyPart.destroyObject()
            gameManagerForInst.loader.instantiate('monsterRArmOnTable', owner.gridPosition)
        end
        if bodyPart.tags.hasTag('torso') == true and hasTorso == false then
            print('Frank torso added')
            hasTorso = true
            bodyPart.destroyObject()
            gameManagerForInst.loader.instantiate('monsterTorsoOnTable', owner.gridPosition)
        end
    end

    checkIfFinished()
end

local function onSiblingRemoved(message)
    print('Bed sibling removed - updating clipboards')
end

local function setVisible(newVisible)
    print('Table set visible:', newVisible)
    owner.bus.send({
        visible = newVisible
    }, nil, false)
end

-- owner.bus.subscribe('siblingAdded', onSiblingAdded) --This also seems to cause an error at the start, because "onSiblingAdded" doesn't exist as a function in this file
owner.bus.subscribe('siblingRemoved', onSiblingRemoved)
-- game.bus.subscribe('gamePhase', onGamePhaseChanged) --this cause the errors at the start
