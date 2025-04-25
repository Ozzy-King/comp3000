local game = LoadFacility('Game')['game']
local owner = owner or error('No owner');
local vector = require('Vector')
require("table")

--stack based operations
--index 0 is used for the stack pointer
local function createStack()
    local newstack = {[0] = 0}
    return newstack
end
local function pushStack(stack, item)
    stack[0] = stack[0] + 1; -- adds one to new position
    stack[stack[0]] = item; -- inserts at new position
end
local function popStack(stack)
    if stack[0] == 0 then return nil end
    local item = stack[stack[0]]
    stack[0] = stack[0] - 1;
    return item;
end
local function stackEmpty(stack)
    if stack[0] == 0 then
        return true
    else
        return false
    end
end
local function stackLen(stack)
    return stack[0]
end

local function positionToString(x, y)
    return tostring(x) .. ',' .. tostring(y);
end

--converts iterators to array
local function myIteratorToStack(iterator)
    local array = createStack()
    for item in iterator do
        if item ~= nil then
            pushStack(array, item)
        else
            return array
        end
    end
    return array
end

local function checkIndex(indexList, index)
    for i = stackLen(indexList), 1, -1 do
        if(indexList[i] == index) then
            return true
        end
    end
    return false
end

local function canMoveOffConvayor(position)
    local tileItem = owner.map.getAllAt(position);
    for item in tileItem do
        if item ~= nil then
            if not item.tags.hasTag('floor') then --if the item isnt the floor
                return false
            end
        else
            goto IterToArrScarySecond
        end
    end
    ::IterToArrScarySecond::
    return true
end

local mapsConveyors
local newPositionsArray
local arrayIndexs
local objectList

local function onGamePhaseChanged(message)

    mapsConveyors = myIteratorToStack(owner.map.getAllObjectsTagged('conv'))
    newPositionsArray = {}
    arrayIndexs = createStack()
    objectList = createStack()
    --create object list based on whats in the conveyors positions
    for i = stackLen(mapsConveyors), 1, -1 do
        --prioritise players incse thier holding items
        local TEMPobj = owner.map.getFirstTagged(mapsConveyors[i].gridPosition, 'player')
        --if no player try find body part to move
        if nil == TEMPobj then
            TEMPobj = owner.map.getFirstTagged(mapsConveyors[i].gridPosition, 'part')
        end

        -- if a object was found
        if nil ~= TEMPobj then
            --create a new table obejct with old and new positions as well as the obect it self
            pushStack(objectList,TEMPobj)
            print('object stack size = ', #objectList)
            local new = {
                ["CONVPos"] = i,
                ["OBJPos"] = stackLen(objectList)
            }
            new["OLD"] = TEMPobj.gridPosition; --sets old position
            new["NEW"] = mapsConveyors[i]["getUpdatedPosForItem"](new["OLD"]) --gets updated position

            if nil == owner.map.getFirstTagged(new["NEW"], 'conv') or nil ~= owner.map.getFirstTagged(new["NEW"], 'WallDown') then
                new.NEW = new.OLD
            end

            --create table at new position to hold duplicates if needed
            local INDEX = positionToString(new.NEW[1], new.NEW[2])
            print(INDEX)
            if not newPositionsArray[INDEX] then
                newPositionsArray[INDEX] = { [0] = 0 }
                pushStack(newPositionsArray[INDEX], new);
                pushStack(arrayIndexs, INDEX)
                print ('added new index << ' .. INDEX)
            else
                pushStack(newPositionsArray[INDEX], new);
            end

            print('add the OBJ')
            print(new["OBJPos"], new["OLD"][1],  new["OLD"][2], new["NEW"][1], new["NEW"][2]); --for debugging
        end
    end

    --if there is nothing return
    print (stackLen(arrayIndexs))
    if(stackLen(arrayIndexs) == 0)then
        return
    end

    --finaly sort out the positions
    local sorted = 0
    while sorted < stackLen(arrayIndexs)*2 do
        print(sorted)
        for i = stackLen(arrayIndexs),1, -1 do
            local aStack = newPositionsArray[arrayIndexs[i]]
            if stackLen(aStack) ~= 1 then
                sorted = sorted - 1
                for p = stackLen(aStack), 2, -1 do
                    local pushToNew = popStack(aStack)
                    local repush = popStack(aStack)

                    --if push to new cant be pushed to a new potions swap with re push to be repushed to same stack
                    if pushToNew.NEW[1] == pushToNew.OLD[1] and pushToNew.NEW[2] == pushToNew.OLD[2] then
                        local temp = pushToNew;
                        pushToNew = repush
                        repush = temp
                    end
                    pushToNew.NEW = pushToNew.OLD


                    local INDEX = positionToString(pushToNew.NEW[1], pushToNew.NEW[2])
                    if not newPositionsArray[INDEX] then
                        newPositionsArray[INDEX] = { [0] = 0 }
                        pushStack(arrayIndexs, INDEX)
                        print ('added new index << ' .. INDEX)
                    end

                    pushStack(newPositionsArray[INDEX], pushToNew);
                    pushStack(aStack, repush);
                end
            else
                sorted = sorted + 1
            end
        end
        if sorted < 0 then
            sorted = 0
        end
    end
    for i = stackLen(arrayIndexs),1, -1 do
        local aStack = newPositionsArray[arrayIndexs[i]]
        for p = stackLen(aStack), 1, -1 do
            print('updateing the OBJ')
            local temp = popStack(aStack)
            if temp.NEW[1] ~= temp.OLD[1] or temp.NEW[2] ~= temp.OLD[2] then
                mapsConveyors[temp.CONVPos]["replaceWithMoving"](mapsConveyors, temp.CONVPos)
                objectList[temp.OBJPos].repositionTo(temp.NEW);
                mapsConveyors[temp.CONVPos]["replaceWithStatic"]( mapsConveyors, temp.CONVPos)
            end
            print(temp.OBJPos, temp.OLD[1],temp.OLD[2],temp.NEW[1],temp.NEW[2])
        end
    end
end

local function conveyorReplaceMethod()
    mapsConveyors[temp.CONVPos]["replaceWithMoving"](mapsConveyors, temp.CONVPos)
    mapsConveyors[temp.CONVPos]["replaceWithStatic"](mapsConveyors, temp.CONVPos)
end

game.bus.subscribe('gamePhase', onGamePhaseChanged);