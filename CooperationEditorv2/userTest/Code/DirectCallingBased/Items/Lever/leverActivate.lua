-- LoadFacility('Game')
---@type MapMobile
---@type MapObject
---@type Game
local owner = owner or error('No owner')
local gameManager = LoadFacility('Game')['game'] or error('No GameManager')

local lever
local name
local colour
local orientation
local finished

-- checks colour of lever and sets name accordingly
if owner.tags.hasTag("Yellow") then
    colour = 'Yellow'
    name = "leverYFloorN"
elseif owner.tags.hasTag("Red") then
    colour = 'Red'
    name = "leverRFloorN"
else
    name = "leverFloorN"
end

local function swapLever(object, Action)
    if (object.tags.hasTag('Down')) then
        lever = gameManager.loader.instantiate(name .. Action, owner.gridPosition)
        object.destroyObject()
    else
        lever = gameManager.loader.instantiate(name .. 'Down' .. Action, owner.gridPosition)
        object.destroyObject()
    end
end

local function leverFloorN()
    local tables = owner.map.getAllObjectsTagged("Monster_Tab") -- Get all the tables (every table is tagged "Monster_Tab")
    local tables_num = 0

    for table in tables do -- Count them
        tables_num = tables_num + 1
    end

    local completed = owner.map.getAllObjectsTagged("completed") -- Get all objects tagged completed
    local completed_num = 0

    for complete in completed do -- Count them
        completed_num = completed_num + 1
    end

    if completed_num == tables_num then -- Check if the number of completed objects is the same as the number of tables
        print('Completed the level!')
        local table = owner.map.getFirstObjectTagged("completed")
        table.callFunc('monsterDance')
        swapLever(lever, '')
        waitMilliSeconds(3000)
        finished = true
        game.bus.send({'level.next'})
    else
        print(tables_num - completed_num .. ' tables have not been completed!')
    end
end

local function swapWall(Object, Action)

    if Object == nil then
        return
    end

    if Object.tags.hasTag("South") then
        orientation = "S"
    else
        orientation = "E"
    end

    if Object.tags.hasTag("Down") then
        gameManager.loader.instantiate('metalWall' .. orientation .. colour .. Action, Object.gridPosition)
        Object.destroyObject()
    else
        gameManager.loader.instantiate('metalWall' .. orientation .. colour .. 'Down' .. Action, Object.gridPosition)
        Object.destroyObject()
    end
end

local function moveWall(Object, Action, Move)

    if Object == nil then
        return
    end

    if Object.tags.hasTag("South") then
        if Object.tags.hasTag("Left") then
            gameManager.loader.instantiate('metalWallShortSRight' .. Action,
                {Object.gridPosition[1] - Move, Object.gridPosition[2]})
            Object.destroyObject()
        else
            gameManager.loader.instantiate('metalWallShortSLeft' .. Action,
                {Object.gridPosition[1] + Move, Object.gridPosition[2]})
            Object.destroyObject()
        end
    else
        if Object.tags.hasTag("Left") then
            gameManager.loader.instantiate('metalWallShortERight' .. Action,
                {Object.gridPosition[1], Object.gridPosition[2] - Move})
            Object.destroyObject()
        else
            gameManager.loader.instantiate('metalWallShortELeft' .. Action,
                {Object.gridPosition[1], Object.gridPosition[2] + Move})
            Object.destroyObject()
        end
    end

end

function interact()

    print(name)
    -- Starts lever animation
    swapLever(owner, 'Animated')

    if name ~= "leverFloorN" then -- for wall levers
        -- starts wall animations

        swapWall(owner.map.getFirstObjectTagged(colour .. "Wall"), 'Animated')
        swapWall(owner.map.getFirstObjectTagged(colour .. "WallDown"), 'Animated')

        if(colour == "Yellow") then
            moveWall(owner.map.getFirstObjectTagged("ShortRight"), 'Animated', 0)
            moveWall(owner.map.getFirstObjectTagged("ShortLeft"), 'Animated', 0)
        end
        -- waits for animation to finish
        waitMilliSeconds(1150)

        -- ends wall animations
        swapWall(owner.map.getFirstObjectTagged(colour .. "WallAnimated"), '')
        swapWall(owner.map.getFirstObjectTagged(colour .. "WallDownAnimated"), '')

        if colour == "Yellow" then
            moveWall(owner.map.getFirstObjectTagged("ShortRightAnimated"), '', 1)
            moveWall(owner.map.getFirstObjectTagged("ShortLeftAnimated"), '', 1)
        end

        -- ends lever animations
        swapLever(lever, '')
    end

    if name == "leverFloorN" then -- for table levers
        -- waits for animation to finish
        waitMilliSeconds(1150)

        -- ends animation and runs lever code
        leverFloorN()

        if(finished ~= true) then
            -- starts animation for lever to go back up
            swapLever(lever, 'Animated')
            waitMilliSeconds(1150)
            swapLever(lever, '')
        end
        
    end

end
