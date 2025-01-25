---@type Game
local game = LoadFacility('Game')['game']

local SharedNarrativeConditions = require('SharedNarrativeConditions')

local SaveDataKeys = SharedNarrativeConditions.saveDataKeys()

local Log = require('Log')
local log = Log.new()

---@type MapMobile
local owner = owner or error('No owner')

---@type boolean
local inBed = false

-- ARC 1 (MISSING HIS FAMILY) SPEECH CONDITIONS
-- =============================================

--- In bed AND current level > 2 AND health < 80%
---@return table
local function arc1Chapter1Conditions()
    local chapterId = 'arc1_chapter1'
    if inBed and (game.levelNumber > 2) and SharedNarrativeConditions.patientHealthLessThanPercentage(owner, 0.8) then
        return {
            conditionsMet = true,
            id = chapterId,
            speech = {
                { text = 'speech_chris_arc1_chapter1_option1' },
                { text = 'speech_chris_arc1_chapter1_option2' },
                { text = 'speech_chris_arc1_chapter1_option3' },
                { text = 'speech_chris_arc1_chapter1_option4' }
            }
        }
    end
    return { conditionsMet = false, id = chapterId }
end

--- In bed AND current level > 2 AND health < 70%
---@return table
local function arc1Chapter2Conditions()
    local chapterId = 'arc1_chapter2'
    if inBed and (game.levelNumber > 2) and SharedNarrativeConditions.patientHealthLessThanPercentage(owner, 0.7) then
        return {
            conditionsMet = true,
            id = chapterId,
            speech = {
                { text = 'speech_chris_arc1_chapter2_option1' },
                { text = 'speech_chris_arc1_chapter2_option2' },
                { text = 'speech_chris_arc1_chapter2_option3' },
                { text = 'speech_chris_arc1_chapter2_option4' }
            }
        }
    end
    return { conditionsMet = false, id = chapterId }
end

--- Player caught in the last round AND successful catches > 3 AND current level > 3
---@return table
local function arc1Chapter3Conditions()
    local chapterId = 'arc1_chapter3'
    if SharedNarrativeConditions.playerCaughtInLastRound() and SharedNarrativeConditions.playersHaveCaughtXTimes(3) and (game.levelNumber > 3) then
        local mostRecentCaughtObject = game.saveData.getString(SaveDataKeys.global_mostRecentCaughtObject())
        return {
            conditionsMet = true,
            id = chapterId,
            speech = {
                { text = 'speech_chris_arc1_chapter3_option1', args = { mostRecentCaughtObject } },
                { text = 'speech_chris_arc1_chapter3_option2', args = { mostRecentCaughtObject } },
                { text = 'speech_chris_arc1_chapter3_option3', args = { mostRecentCaughtObject } },
                { text = 'speech_chris_arc1_chapter3_option4', args = { mostRecentCaughtObject } }
            }
        }
    end
    return { conditionsMet = false, id = chapterId }
end

--- Current level > 4 AND health < 60% 
---@return table
local function arc1Chapter4Conditions()
    local chapterId = 'arc1_chapter4'
    if (game.levelNumber > 4) and SharedNarrativeConditions.patientHealthLessThanPercentage(owner, 0.6) then
        return {
            conditionsMet = true,
            id = chapterId,
            speech = {
                { text = 'speech_chris_arc1_chapter4_option1' },
                { text = 'speech_chris_arc1_chapter4_option2' },
                { text = 'speech_chris_arc1_chapter4_option3' },
                { text = 'speech_chris_arc1_chapter4_option4' }
            }
        }
    end
    return { conditionsMet = false, id = chapterId }
end

--- Player caught in the last round AND successful catches > 9 AND current level > 4
---@return table
local function arc1Chapter5Conditions()
    local chapterId = 'arc1_chapter5'
    if SharedNarrativeConditions.playerCaughtInLastRound() and SharedNarrativeConditions.playersHaveCaughtXTimes(9) and (game.levelNumber > 4) then
        return {
            conditionsMet = true,
            id = chapterId,
            speech = {
                { text = 'speech_chris_arc1_chapter5_option1' },
                { text = 'speech_chris_arc1_chapter5_option2' },
                { text = 'speech_chris_arc1_chapter5_option3' },
                { text = 'speech_chris_arc1_chapter5_option4' }
            }
        }
    end
    return { conditionsMet = false, id = chapterId }
end

-- FUNCTIONS REQUIRED BY NARRATIVECHARACTER
-- ========================================

--- Called externally by NarrativeCharacter
---@param levelNumber number
---@return table|nil
function getAllLevelSpecificChapters(levelNumber)
    return nil
end

--- Called externally by NarrativeCharacter
---@param levelNumber number
---@param specialCondition string
---@return table|nil
function getSpecialConditionLevelChapters(levelNumber, specialCondition)
    return nil
end

--- Called externally by NarrativeCharacter
---@return table
function getAllNarrativeArcChapters()
    return {
        -- Arc 1: Missing his family
        {
            arc1Chapter1Conditions,
            arc1Chapter2Conditions,
            arc1Chapter3Conditions,
            arc1Chapter4Conditions,
            arc1Chapter5Conditions
        }
    }
end

--- Name of the character, used in keys for character-related narrative save data
--- and for getting localized character name from string table
--- Called externally by NarrativeCharacter
---@return string
function getCharacterName()
    return 'chris'
end

--- Called externally by NarrativeCharacter
--- See: SharedNarrativeConditions.chapterWasAlreadyShown
---@param chapterId string
---@return boolean
function chapterWasAlreadyShown(chapterId)
    return SharedNarrativeConditions.chapterWasAlreadyShown(getCharacterName(), chapterId)
end

--- Called externally by NarrativeCharacter
--- See: SharedNarrativeConditions.setChapterAsShown
---@param chapterId string
function setChapterAsShown(chapterId)
    SharedNarrativeConditions.setChapterAsShown(getCharacterName(), chapterId)
end

-- ========================================

---@param message Message
local function onPatientStateChanged(message)
    local newState = message.data['state.patient']
    if newState == nil then
        error('nil state in state.patient message')
    end
    inBed = (newState == 'InBed')
end

tags.addTag('CharacterNarrativeConditions')
owner.tags.addTag('CharacterNarrativeConditions')

log:log("ChrisNarrativeConditions lua started")

owner.bus.subscribe('state.patient', onPatientStateChanged)