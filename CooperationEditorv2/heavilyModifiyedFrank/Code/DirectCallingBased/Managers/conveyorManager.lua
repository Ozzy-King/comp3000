local game = LoadFacility('Game')['game']
local owner = owner or error('No owner');
local vector = require('Vector')
require("table")

--stack based operations
--index 0 is used for the stack pointer
local function createStack()
    return {[0] = 0}
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

--converts iterators to array
local function myIteratorToArray(iterator)
    local array = {
        [1]= nil
    }
    local counter = 1
    for item in iterator do
        if item ~= nil then
            array[counter] = item
            counter = counter + 1
        else
            goto IterToArrScary
        end
    end
    ::IterToArrScary::
    return array
end

--make sure the item can get off the conveyor belt okay (they just need a bit of help)
local function canMoveOffConvayor(position)
    local tileItem = myIteratorToArray(owner.map.getAllAt(position));
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

--one of the items are disappearing even though it works the first round the second round onwards seems to show issues
--ive spelt conveyor wrong almost every where
--crazy function just to make sure that the items on the conveyor belt update properly so they dont zoooooom through the track like a biker down hill
local function onGamePhaseChanged(message)
    --get all conveyors and thier items
    local mapsConveyors = myIteratorToArray(owner.map.getAllObjectsTagged('conv'))

    --get rid of converyor that have a blocking tag
    for i = #mapsConveyors,1,-1 do
        
    
    end


    local newArrayConvayor = createStack()
    local arrayToFix = createStack()
    local objectList = createStack()

    print("before check and update")

    --create object list based on whats in the conveyors positions
    for i = #mapsConveyors,1,-1 do
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
            local new = {
                ["OBJPos"] = objectList[0]
            }
            new["OLD"] = TEMPobj.gridPosition; --sets old position
            new["NEW"] = mapsConveyors[i]["getUpdatedPosForItem"](new["OLD"]) --gets updated position
            pushStack(newArrayConvayor, new) --isert the new table object on to the newArayConveyer stack

            print(new["OBJPos"], new["OLD"][1],  new["OLD"][2], new["NEW"][1], new["NEW"][2]); --for debugging
        end
    end

    --if there is no object just return
    if newArrayConvayor[0] == 0 then
        print('nothing to move :(')
        return
    end

    --also include floors that are at the end of conveyors dosent have floor, or conv cant move
    --inital test to see if any object move off a Conveyor
    for i = #newArrayConvayor,1,-1 do --O(n)
        --if the new position doesnt have a conveyor and cant move there set new position the old so it cant move
        if nil == owner.map.getFirstTagged(newArrayConvayor[i]["NEW"], 'conv') then
            print('inside position revert <--------------------------------------------------------------')
            newArrayConvayor[i].NEW = newArrayConvayor[i].OLD
        else if  nil ~= owner.map.getFirstTagged(newArrayConvayor[i]["NEW"], 'YellowWallDown') then
            print('inside position revert <--------------------------------------------------------------')
            newArrayConvayor[i].NEW = newArrayConvayor[i].OLD
        end
    end



    --start fixing all the positions
    local tempStack = createStack()
    local SortedOut = 0 --will be used to check when to end
    ::begin::
    while SortedOut ~= newArrayConvayor[0] do
        --;gets new pos to sortout;
        print('before select array size ====== ', newArrayConvayor[0])
        local chosePos = newArrayConvayor[newArrayConvayor[0]].NEW
        for i = newArrayConvayor[0], 1, -1 do -- O(n)
            local tempItem = popStack(newArrayConvayor)
            if tempItem ~= nil then
                if tempItem.NEW[1] == chosePos[1] and tempItem.NEW[2] == chosePos[2] then
                    pushStack(arrayToFix, tempItem)
                else
                    pushStack(tempStack, tempItem) --push onto newArrayConvayor last so new items get picked
                end
            end
        end

        print('after select array size ====== ', newArrayConvayor[0])
        print('before single check array size ====== ', newArrayConvayor[0])

        if arrayToFix[0] > 1 then
            --;reset sortedout if duplicate occurres;
            SortedOut = 0
        end
        print('before sort check array size ====== ', newArrayConvayor[0])
        --first check that non duplicates cant go anywhere (if one cant go anywhere it is chosen and the rest also revert)
        local randomFound = false
        for iu = arrayToFix[0], 1, -1 do -- O(n)
            local tempitem = popStack(arrayToFix)
            if tempitem.NEW[1] == tempitem.OLD[1] and tempitem.NEW[2] == tempitem.OLD[2] then --if the item cant actually go anywhere
                randomFound = true
                break
            else
                if iu == 1 and not randomFound then
                    randomFound = true
                else
                    tempitem.NEW = tempitem.OLD--;reset all other duplicates new positions to old and continue;
                end
            end
            pushStack(newArrayConvayor, tempitem)
        end

        print('after single check array size ====== ', newArrayConvayor[0])

        -- repush temp stack back onto newArrayConveyor
        for i = tempStack[0], 1, -1 do --add the other items on to the end -- O(n)
            local tempitem = popStack(tempStack)
            pushStack(newArrayConvayor, tempitem)
        end
        SortedOut = SortedOut + 1
        print("still running \t: sorted ", SortedOut)
        --for ip = newArrayConvayor[0], 1, -1 do
        --    print(newArrayConvayor[ip]["OBJ"], newArrayConvayor[ip]["OLD"][1],  newArrayConvayor[ip]["OLD"][2], newArrayConvayor[ip]["NEW"][1], newArrayConvayor[ip]["NEW"][2]);
        --end
    end

    print("\nafter check and update")
    for i = newArrayConvayor[0], 1, -1 do
        local tempitem = popStack(newArrayConvayor)
        objectList[tempitem["OBJPos"]].repositionTo(tempitem["NEW"])
        print(tempitem["OBJPos"], tempitem["OLD"][1],  tempitem["OLD"][2], tempitem["NEW"][1], tempitem["NEW"][2]);
    end


end

game.bus.subscribe('gamePhase', onGamePhaseChanged);