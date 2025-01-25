---@type Game
local game = LoadFacility('Game')['game']

local NarrativeSaveDataKeys = require('NarrativeSaveDataKeys')

local Log = require('Log')
local log = Log.new()

---@type MapMobile
local owner = owner or error('No owner')

local function clearRoundSpecificNarrativeSaveData()
    local keys = NarrativeSaveDataKeys.getAllKeysToClearOnNewRound()
    for key in keys do
        log:log('Deleting round-specific save data with key "' .. key .. '"')
        game.saveData.delete(key)
    end
end

local function clearLevelSpecificNarrativeSaveData()
    local keys = NarrativeSaveDataKeys.getAllKeysToClearOnNewLevel()
    for key in keys do
        log:log('Deleting level-specific save data with key "' .. key .. '"')
        game.saveData.delete(key)
    end
end

local function onGamePhaseChanged(message)
    local phase = message.data.gamePhase
	if phase == nil then
		error('No phase data in gamePhase message!')
	end
    if phase == 'acting' then
        clearRoundSpecificNarrativeSaveData()
    end
end

-- MAIN

-- Configure text notification UI, ready to be used for displaying narrative text
-- (Sets the max. pieces of text that will be shown at once before scrolling, and the delay when scrolling between text)
game.bus.send({
    metadata = { 'textNotificationUI.configureDisplay' },
    data = {
        onScreenLimit = 2,
        scrollDelay = 3
    }
}, nil, false)

-- Clear any leftover narrative-related save data from a previous level
clearRoundSpecificNarrativeSaveData()
clearLevelSpecificNarrativeSaveData()

tags.addTag('NarrativeManager')
owner.tags.addTag('NarrativeManager')

log:log('NarrativeManager lua started')

game.bus.subscribe('gamePhase', onGamePhaseChanged)