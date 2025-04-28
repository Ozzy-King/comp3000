-- [ ] tags or functions to run when becomes active / inactive

---Something that spawns into the grid at start or later in the game.
---Includes code for avoiding appearing in the same space as other things.

local log = print

---@type MapMobile
local owner = owner or error('No owner')

---@type Pos
local spawnPosition = spawnPosition or owner.gridPosition
---@type Pos
local initialSpawnPosition = spawnPosition

---@type boolean
local isActive = true

---Positions relative to the its own grid position that are checked
---in order when trying to set as active to see if the object can spawn there.
---@type table<number, V2>
local spawnOffsets = {
	{  0,  0 }, -- Default spawn position (no offset),
	{  0, -1 }, -- North,
	{  1, -1 }, -- North-east,
	{  1,  0 }, -- East,
	{  1,  1 }, -- South-east,
	{  0,  1 }, -- South,
	{ -1,  1 }, -- South-west,
	{ -1,  0 }, -- West,
	{ -1, -1 }  -- North-west
}

local SpawnsInGrid = {}

---@return Pos
function SpawnsInGrid.getSpawnPosition()
	return spawnPosition
end

---@return boolean
function SpawnsInGrid.getActive()
    return isActive
end

---@param coords Pos
---@return string
local function coordsToString(coords)
    return '('.. tostring(coords[1]) .. ', ' .. tostring(coords[2]) ..')'
end

local function moveOwnerToSpawnPosition()
    if spawnPosition[1] ~= owner.gridPosition[1] or spawnPosition[2] ~= owner.gridPosition[2] then
        -- Spawn pos differs from current grid pos, reposition
        owner.repositionTo(spawnPosition)
    end
end

--- When used as the bypassBlockerCheck function in SpawnsInGrid.blockedAtPosition,
--- allows a MapObject to spawn on the same tile as a squashable
---@param blockerObj MapObject
---@return boolean
function SpawnsInGrid.bypassSquashableBlocker(blockerObj)
    if blockerObj == nil then
        return false
    end
    if blockerObj.tags.hasTag('squashable') then
        -- Blocker is something we can squash
        return true
    end
    return false
end

---@param position Pos
---@param bypassBlockerCheck? nil|fun(mapObject:MapObject):boolean
local function blockedAtPosition(position, bypassBlockerCheck)
    -- TODO-@type Vector2Int
    log('Checking if object can spawn at position ' .. coordsToString(position))
    if not owner.map.isValidMapPos(position) then
        -- Invalid map position, can't spawn here
        return true
    end

    local blockersAtPos = owner.map.getAllTagged(position, 'blocksMove or shrunk or spring')
    local positionBlocked = false
    -- Loop through potential blockers to see if they actually block us
    for potentialBlocker in blockersAtPos do
        local bypassBlocker = bypassBlockerCheck ~= nil and bypassBlockerCheck(potentialBlocker)
        if bypassBlocker == false and potentialBlocker ~= owner then
            -- Can't bypass blocker object - definitely can't spawn at this position
            positionBlocked = true
            break
        end
    end
    return positionBlocked
end

---@param targetPosition Pos
---@param bypassBlockerCheck? nil|fun(mapObject:MapObject):boolean
---@param onlyAllowAdjacent boolean
function SpawnsInGrid.trySetSpawnToValidPositionNearTarget(targetPosition, bypassBlockerCheck, onlyAllowAdjacent)
    for _, offset in pairs(spawnOffsets) do
        local possibleSpawnPos = { targetPosition[1] + offset[1], targetPosition[2] + offset[2] }
        if not blockedAtPosition(possibleSpawnPos, bypassBlockerCheck) then
             -- Found nothing to block us, we can spawn at this position!
             spawnPosition = possibleSpawnPos
             log('Set spawn position to target or adjacent: '.. coordsToString(spawnPosition))
             return true
        end
    end

    log('No valid place to appear at target or adjacent tiles')
    if onlyAllowAdjacent then
        return false
    end

    -- If no valid positions are found adjacent to the target, we just iterate through all floor tiles
    local allFloor = owner.map.getAllObjectsTagged('floor')
    for floorObj in allFloor do
        if not blockedAtPosition(floorObj.gridPosition, bypassBlockerCheck) then
            -- Found nothing to block us, we can spawn at this position!
            spawnPosition = floorObj.gridPosition
            log('Set spawn position to first non-blocked floor: '.. coordsToString(spawnPosition))
            return true
       end
    end

    -- No valid positions *anywhere* in the level!
    log('No valid place to appear in the level map')
    return false
end

---@param spawnConditionsCheck fun():boolean
---@param onActive? fun()|nil
---@param onVisible? fun()|nil
---@return boolean
function SpawnsInGrid.trySetActive(spawnConditionsCheck, onActive, onVisible)
    log('Trying to set object as active: ' .. tostring(owner))
	spawnPosition = initialSpawnPosition

    if spawnConditionsCheck() == false then
        log('Spawn conditions check failed so not setting as active')
        return false
    end

    isActive = true

    moveOwnerToSpawnPosition()

    onActive = onActive or function()
        owner.tags.addTag('blocksMove')
        owner.tags.addTag('blocksThrow')
    end
    onActive()

    onVisible = onVisible or function()
        -- Send 'visible' message to show certain view elements
        owner.bus.send({visible = true}, nil, false)
    end
    onVisible()

    log('Set as active')
    return true
end

---@param onInactive? fun()|nil
---@param onInvisible? fun()|nil
---@param moveToSpawnPos boolean
---@return void
function SpawnsInGrid.setInactive(onInactive, onInvisible, moveToSpawnPos)
    log('Setting object as inactive: ' .. tostring(owner))

    isActive = false

    if moveToSpawnPos then 
        moveOwnerToSpawnPosition()
    end
    
    onInactive = onInactive or function()
        owner.tags.removeTag('blocksMove')
        owner.tags.removeTag('blocksThrow')
    end
    onInactive()

    onInvisible = onInvisible or function()
        -- Send 'visible' message to hide certain view elements
        owner.bus.send({visible = false}, nil, false)
    end
    onInvisible()
end

return SpawnsInGrid
