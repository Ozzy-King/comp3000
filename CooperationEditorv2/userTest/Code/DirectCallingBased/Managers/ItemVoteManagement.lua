---@type Game
local game = LoadFacility('Game')['game']
---@type Loader
local loader = game.loader or error('No loader')

local Log = require('Log')
local log = Log.new()

---@type MapMobile
local owner = owner or error('No owner')

---@class PlaceableObject
---@field objectDefinition string
---@field displayName string

---@type PlaceableObject[]
local allPlaceableObjects = allPlaceableObjects or { }

--- Amount of time (seconds) to stay in the managementResults phase
---@type number
local managementResultsDuration = managementResultsDuration or 15

---@type number
local requirePurchasedItems = requirePurchasedItems or 1 -- (1 = true, 0 or other value = false)

---@type string[]
local alphabet = { 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z' }

--- Every gridPosition where voted items can be placed in the level
---@type number[][]
local placementPositions

--- Definition names for every item in allPlaceableObjects that can be voted on
---  (only purchased items when requirePurchasedItems = true)
---@type string[]
local votableObjectDefinitions
--- Display names for every item in allPlaceableObjects that can be voted on
---@type string[]
local votableDisplayNames

---@type table<number, table>
local votesForPositions = {}

---@return table<number, number>
local function getPlayerNumbersForCharacters()
    local playerNums = {}
    local players = owner.map.getAllObjectsTagged('Player')
    for player in players do
        local playerComponent = player.getFirstComponentTagged('Player')
        playerNums[playerComponent.characterNumber] = playerComponent.playerNumber
    end
    return playerNums
end

--- Gets the item with the most votes from a tally table containing number for each item name
---@param voteTally table
---@param rulingPlayerChoice string
---@return string
local function getWinningItem(voteTally, rulingPlayerChoice)
    local itemsWithMostVotes = {}
    for item in pairs(voteTally) do
        if #itemsWithMostVotes == 0 then
            log:log('getWinningItem - Winning item becomes first item: ' .. tostring(item))
            -- First item
            itemsWithMostVotes = { item }
        elseif voteTally[item] == voteTally[itemsWithMostVotes[1]] then
            log:log('getWinningItem - Item with ' .. tostring(voteTally[item]) .. ' votes draws with the winning item: ' .. tostring(item))
            -- item has the same number of votes as the current winner(s)
            table.insert(itemsWithMostVotes, item)
        elseif voteTally[item] > voteTally[itemsWithMostVotes[1]] then
            log:log('getWinningItem - Item with ' .. tostring(voteTally[item]) .. ' votes becomes the winning item: ' .. tostring(item))
            -- item has more votes, so replaces the current winner
            itemsWithMostVotes = { item }
        end
    end
    
    if #itemsWithMostVotes == 0 then
        return '' -- No winning item found, so '' (i.e. place nothing) wins
    elseif #itemsWithMostVotes == 1 then
        return itemsWithMostVotes[1]
    else
        -- It's a draw, multiple items had the same winning number of votes! Ruling player's choice takes it
        return rulingPlayerChoice
    end
end

local function onManagementPhase()
    if #votableObjectDefinitions == 0 then
        -- No items to be voted for
        log:error('No items to be voted for in management phase')
        return
    end

    -- Find & add item landing positions
    placementPositions = {}
    for landingPos in owner.map.getAllObjectsTagged('ItemVoteLandingPos') do
        Log:log('Adding item landing position (for voting/management phase): ' .. tostring(landingPos.gridPosition))
        table.insert(placementPositions, landingPos.gridPosition)
    end

    if #placementPositions == 0 then
        -- Nowhere for players to place objects in this level
        log:error('No positions where items can be placed in management phase')
        return
    end

    -- Ensure table that will contain voting results is empty
    votesForPositions = {}

    -- Send item management data on game bus, which will be sent to
    --  controllers along with images (icons/previews) for each item
    game.bus.send({
        metadata = { 'management.dataForControllers' },
        data = {
            placementPositions = placementPositions,
            itemNames = votableDisplayNames,
            itemDefinitionNames = votableObjectDefinitions
        }
    }, nil, false)

    -- UI message to tell players to vote on devices
    game.bus.send({
        displayText = 'Which items should be placed and where? Vote on your devices!',
        displayType = 'messageDisplayUI.top'
    }, nil, false)

    -- UI indicators for each item placement position
    local count = 1
    for placementPos in placementPositions do
        local labelText = alphabet[count]
        game.bus.send({
            metadata = { 'itemIndicator.show' },
            data = { position = placementPos, label = labelText }
        }, nil, false)
        count = count + 1
    end
end

local function doManagementResultsDelay()
    owner.bus.send({
        metadata = { 'delayTimer.start' },
        data = {
            duration = managementResultsDuration,
            displayType = 'countdown'
        }
    }, nil, false)
end

local function addOrUpdateFloatingResultsUI(targetObject, playerNum, characterNum, votedItem)
    game.bus.send({
        metadata = { 'floatingUI.createOrUpdate' },
        data = {
            targetObject = targetObject.id,
            displayData = 'playerVote',
            playerNumber = playerNum,
            characterNumber = characterNum,
            icon = (votedItem ~= '') and ('Icon_LevelItem_' .. votedItem) or 'Icon_LevelItem_None'
        }
    }, nil, false)
end

local function hideAllFloatingResultsUI()
    for posIndex = 1, #placementPositions do
        local landingPosObj = owner.map.getFirstTagged(placementPositions[posIndex], 'ItemVoteLandingPos')
        game.bus.send({
            metadata = { 'floatingUI.destroy' },
            data = {
                targetObject = landingPosObj.id
            }
        }, nil, false)
    end
end

local function getObjectDefinitionNameFromDisplayName(displayName)
    for itemDefAndName in allPlaceableObjects do
        if itemDefAndName.displayName == displayName then
            return itemDefAndName.objectDefinition
        end
    end
    return ''
end

local function placeWinningItemsInLevel(winningItems)
    if (winningItems == nil) or (#winningItems == 0) or (#winningItems ~= #placementPositions) then
        log:error('nil or unexpected number of winning items when trying to instantiate in level')
        return
    end
    for posIndex = 1, #placementPositions do
        local winningItemAtPos = winningItems[posIndex]
        if winningItemAtPos ~= '' then
            -- Spawn object that won the vote for this position!
            local spawnedObj = loader.instantiate(winningItemAtPos, placementPositions[posIndex])
            if spawnedObj ~= nil then
                spawnedObj.bus.send({ 'spawnedFromVote' }, nil, false)
            end
        else
            -- No object was voted for this position, so spawn the backup object
            --  that was set in the ItemVoteLandingPos object's mod data (if any)
            local landingPosObj = owner.map.getFirstTagged(placementPositions[posIndex], 'ItemVoteLandingPos')
            landingPosObj.bus.send({ 'spawnBackupObject' }, nil, false)
        end
    end
end

local function onManagementResultsPhase()
    if placementPositions == nil then
        log:error('In management results phase, but there is nowhere to place player-voted items')
        return
    end
    if votesForPositions == nil then
        log:error('In management results phase, but there are no (nil) votesForPositions')
        return
    end
    if #votesForPositions ~= #placementPositions then
        log:error('In management results phase with unexpected number of votesForPositions (' .. tostring(#votesForPositions) .. ') - does not equal the number of placementPositions (' .. tostring(#placementPositions) .. ')')
        return
    end

    -- Hide UI from management phase
    game.bus.send({ 'itemIndicator.hideAll' }, nil, false)
    game.bus.send({
        displayText = '', displayType = 'messageDisplayUI.top'
    }, nil, false)

    -- Array for getting player number from character number
    local charToPlayerNum = getPlayerNumbersForCharacters()

    -- Winning item for each position
    local winningItems = {}

    -- Loop through each potential item placement position
    for posIndex = 1, #placementPositions do
        -- Check player votes for this position
        local votesForThisPosition = votesForPositions[posIndex]
        local rulingPlayerChoice = ''
        local voteTally = {}

        -- Loop through each vote (character number & chosen item) for the current position
        for voteCharacterIndexAndItem in votesForThisPosition do
            local votingCharacter = voteCharacterIndexAndItem[1]
            local votingPlayer = charToPlayerNum[votingCharacter]
            local votedItemDef = getObjectDefinitionNameFromDisplayName(voteCharacterIndexAndItem[2])
            if votingPlayer == 0 then
                rulingPlayerChoice = votedItemDef
            end
            voteTally[votedItemDef] = (voteTally[votedItemDef] or 0) + 1

            local landingPosObj = owner.map.getFirstTagged(placementPositions[posIndex], 'ItemVoteLandingPos')
            -- Display vote with floating UI (ignoring 'nothing' votes)
            if votedItemDef ~= '' then
                addOrUpdateFloatingResultsUI(landingPosObj, votingPlayer, votingCharacter, votedItemDef)
            end
        end

        local winningItem = getWinningItem(voteTally, rulingPlayerChoice)
        winningItems[posIndex] = winningItem
        log:log('Winning player-voted item for position ' .. tostring(posIndex) .. ' is: ' .. (winningItem or '(nothing)'))

        -- Winning item indicator
        local labelText = alphabet[posIndex]
        game.bus.send({
            metadata = { 'itemIndicator.show' },
            data = {
                position = placementPositions[posIndex],
                label = labelText,
                icon = (winningItem ~= '') and ('Icon_LevelItem_' .. winningItem) or 'Icon_LevelItem_None',
            }
        }, nil, false)
    end

    -- Delay so players can take in results, displays UI countdown
    doManagementResultsDelay()

    -- Hide all results UI
    hideAllFloatingResultsUI()
    game.bus.send({ 'itemIndicator.hideAll' }, nil, false)

    placeWinningItemsInLevel(winningItems)

    game.bus.send({
        metadata = { 'level.nextPhase' }
    })
end

local function onItemVoteResults(message)
    log:log('Got item vote results from controller')

    local resultsData = message.data['controller.itemVoteResults']
    if resultsData == nil then
        error('No results data in itemVoteResults message')
    end
    local characterIndex = message.data['characterIndex']
    if characterIndex == nil then
        error('No characterIndex data in itemVoteResults message')
    end

    for posCount = 1, #placementPositions do
        if votesForPositions[posCount] == nil then
            votesForPositions[posCount] = {}
        end

        local itemAtPos = message.data['placementPos' .. tostring((posCount - 1))] -- 0 indexed!
        table.insert(votesForPositions[posCount], { characterIndex, (itemAtPos or '') })
    end
end

local function onGamePhaseChanged(message)
    local phase = message.data.gamePhase
    if phase == 'management' then
        onManagementPhase()
    elseif phase == 'managementResults' then
        onManagementResultsPhase()
    end
end

---@return boolean
function canEnterManagementPhase()
    local landingPos = owner.map.getFirstObjectTagged('ItemVoteLandingPos')
    if landingPos == nil then
        -- There are no positions where players can vote for items to be placed,
        --  don't enter the management phase
        return false
    end
    if #votableObjectDefinitions == 0 then
        -- No items to vote on, don't enter the management phase
        return false
    end
    -- There are purchased items and places where they can go, let's enter the management phase!
    return true
end

---MAIN

-- Add all purchased items (i.e. items that can be voted for) to array
votableObjectDefinitions = {}
votableDisplayNames = {}
for itemNameAndObjectDef in allPlaceableObjects do
    local objectDef = itemNameAndObjectDef.objectDefinition
    local itemPurchased = (0 ~= game.saveData.getNumber(objectDef))
    if itemPurchased or (requirePurchasedItems ~= 1) then
        log:log('Item "' .. objectDef .. '" was purchased OR non-purchased items are valid, so can be placed based on player votes (management phase)')
        table.insert(votableObjectDefinitions, objectDef )
        table.insert(votableDisplayNames, itemNameAndObjectDef.displayName )
    else
        log:log('Item "' .. objectDef .. '" was not purchased, and purchased items are required so it will not be part of management phase')
    end
end

owner.tags.addTag('ItemVoteManagement')
tags.addTag('ItemVoteManagement')

-- subscribe to get informed when game rounds start
game.bus.subscribe('gamePhase', onGamePhaseChanged)
game.bus.subscribe('controller.itemVoteResults', onItemVoteResults)