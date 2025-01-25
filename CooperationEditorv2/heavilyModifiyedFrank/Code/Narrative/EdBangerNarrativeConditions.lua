---@type Game
local game = LoadFacility('Game')['game']

local SharedNarrativeConditions = require('SharedNarrativeConditions')

local SaveDataKeys = SharedNarrativeConditions.saveDataKeys()

local Log = require('Log')
local log = Log.new()

---@type MapMobile
local owner = owner or error('No owner')

---@type boolean
local invalidActionWithMeThisRound = false
---@type string
local invalidActionPlayerName

-- LEVEL SPEECH CONDITIONS
-- =======================
-- > LEVEL 1
-- =========

--- Shown as soon as patient spawns/becomes active (if not already shown)
---@return table
local function level1Speech1Conditions()
    local chapterId = 'level1_speech1'
    if not chapterWasAlreadyShown(chapterId) then
        return {
            conditionsMet = true,
            id = chapterId,
            speech = {
                { text = 'speech_edBanger_level1_speech1_option1' },
                { text = 'speech_edBanger_level1_speech1_option2' },
                { text = 'speech_edBanger_level1_speech1_option3' },
                { text = 'speech_edBanger_level1_speech1_option4' }
            }
        }
    end
    return { conditionsMet = false, id = chapterId }
end

--- Health = 6
---@return table
local function level1Speech2Conditions()
    local chapterId = 'level1_speech2'
    -- Check for health = 7, because patients lose 1 health at the beginning of the planning phase
    if SharedNarrativeConditions.patientHealthEquals(owner, 7) then
        return {
            conditionsMet = true,
            id = chapterId,
            speech = {
                { text = 'speech_edBanger_level1_speech2_option1' },
                { text = 'speech_edBanger_level1_speech2_option2' },
                { text = 'speech_edBanger_level1_speech2_option3' },
                { text = 'speech_edBanger_level1_speech2_option4' }
            }
        }
    end
    return { conditionsMet = false, id = chapterId }
end

--- Health = 4
---@return table
local function level1Speech3Conditions()
    local chapterId = 'level1_speech3'
    -- Check for health = 5, because patients lose 1 health at the beginning of the planning phase
    if SharedNarrativeConditions.patientHealthEquals(owner, 5) then
        return {
            conditionsMet = true,
            id = chapterId,
            speech = {
                { text = 'speech_edBanger_level1_speech3_option1' },
                { text = 'speech_edBanger_level1_speech3_option2' },
                { text = 'speech_edBanger_level1_speech3_option3' },
                { text = 'speech_edBanger_level1_speech3_option4' }
            }
        }
    end
    return { conditionsMet = false, id = chapterId }
end

--- Health = 2
---@return table
local function level1Speech4Conditions()
    local chapterId = 'level1_speech4'
    -- Check for health = 3, because patients lose 1 health at the beginning of the planning phase
    if SharedNarrativeConditions.patientHealthEquals(owner, 3) then
        return {
            conditionsMet = true,
            id = chapterId,
            speech = {
                { text = 'speech_edBanger_level1_speech4_option1' },
                { text = 'speech_edBanger_level1_speech4_option2' },
                { text = 'speech_edBanger_level1_speech4_option3' },
                { text = 'speech_edBanger_level1_speech4_option4' }
            }
        }
    end
    return { conditionsMet = false, id = chapterId }
end

--- Any player bumped in the last round (AND not already shown)
---@return table
local function level1Speech5Conditions()
    local chapterId = 'level1_speech5'
    if SharedNarrativeConditions.playerBumpedInLastRound() and (not chapterWasAlreadyShown(chapterId)) then
        return {
            conditionsMet = true,
            id = chapterId,
            speech = {
                { text = 'speech_edBanger_level1_speech5_option1' },
                { text = 'speech_edBanger_level1_speech5_option2' },
                { text = 'speech_edBanger_level1_speech5_option3' },
                { text = 'speech_edBanger_level1_speech5_option4' }
            }
        }
    end
    return { conditionsMet = false, id = chapterId }
end

--- Pills were dropped (AND not already shown)
---@return table
local function level1Speech6Conditions()
    local chapterId = 'level1_speech6'
    if (SharedNarrativeConditions.playerDroppedPillsInLastRound()) and (not chapterWasAlreadyShown(chapterId)) then
        local mostRecentPillDropPlayer = game.saveData.getString(SaveDataKeys.global_mostRecentPillDropPlayer())
        return {
            conditionsMet = true,
            id = chapterId,
            speech = {
                { text = 'speech_edBanger_level1_speech6_option1', args = { mostRecentPillDropPlayer } },
                { text = 'speech_edBanger_level1_speech6_option2', args = { mostRecentPillDropPlayer } },
                { text = 'speech_edBanger_level1_speech6_option3', args = { mostRecentPillDropPlayer } },
                { text = 'speech_edBanger_level1_speech6_option4', args = { mostRecentPillDropPlayer } }
            }
        }
    end
    return { conditionsMet = false, id = chapterId }
end

--- Any patient left/lost all health (AND not already shown)
---@return table
local function level1Speech7Conditions()
    local chapterId = 'level1_speech7'
    if (SharedNarrativeConditions.patientLeftInLastRound()) and (not chapterWasAlreadyShown(chapterId)) then
        return {
            conditionsMet = true,
            id = chapterId,
            speech = {
                { text = 'speech_edBanger_level1_speech7_option1' },
                { text = 'speech_edBanger_level1_speech7_option2' },
                { text = 'speech_edBanger_level1_speech7_option3' },
                { text = 'speech_edBanger_level1_speech7_option4' }
            }
        }
    end
    return { conditionsMet = false, id = chapterId }
end

--- Any player bumped in the last round (AND not already shown)
---@return table
local function level1Speech8Conditions()
    local chapterId = 'level1_speech8'
    if SharedNarrativeConditions.playerBumpedInLastRound() and (not chapterWasAlreadyShown(chapterId)) then
        local mostRecentBumpPlayer = game.saveData.getString(SaveDataKeys.global_mostRecentBumpPlayer())
        return {
            conditionsMet = true,
            id = chapterId,
            speech = {
                { text = 'speech_edBanger_level1_speech8_option1', args = { mostRecentBumpPlayer } },
                { text = 'speech_edBanger_level1_speech8_option2', args = { mostRecentBumpPlayer } },
                { text = 'speech_edBanger_level1_speech8_option3', args = { mostRecentBumpPlayer } },
                { text = 'speech_edBanger_level1_speech8_option4', args = { mostRecentBumpPlayer } }
            }
        }
    end
    return { conditionsMet = false, id = chapterId }
end

--- I was healed!
---@return table
local function level1SpeechHealed()
    local chapterId = 'level1_speechHealed'
    return {
        conditionsMet = true,
        id = chapterId,
        speech = {
            { text = 'speech_edBanger_level1_speechHealed_option1' },
            { text = 'speech_edBanger_level1_speechHealed_option2' },
            { text = 'speech_edBanger_level1_speechHealed_option3' },
            { text = 'speech_edBanger_level1_speechHealed_option4' }
        }
    }
end

-- > LEVEL 2
-- =========

--- Shown as soon as patient spawns/becomes active (if not already shown)
---@return table
local function level2Speech1Conditions()
    local chapterId = 'level2_speech1'
    if not chapterWasAlreadyShown(chapterId) then
        return {
            conditionsMet = true,
            id = chapterId,
            speech = {
                { text = 'speech_edBanger_level2_speech1_option1' },
                { text = 'speech_edBanger_level2_speech1_option2' },
                { text = 'speech_edBanger_level2_speech1_option3' },
                { text = 'speech_edBanger_level2_speech1_option4' }
            }
        }
    end
    return { conditionsMet = false, id = chapterId }
end

--- Health = 5
---@return table
local function level2Speech2Conditions_UNFINISHED()
    local chapterId = 'level2_speech2'
    -- Check for health = 6, because patients lose 1 health at the beginning of the planning phase
    if SharedNarrativeConditions.patientHealthEquals(owner, 6) then
        return {
            conditionsMet = true,
            id = chapterId,
            speech = {
                { text = 'speech_edBanger_level2_speech2_option1' },
                { text = 'speech_edBanger_level2_speech2_option2' },
                { text = 'speech_edBanger_level2_speech2_option3' },
                { text = 'speech_edBanger_level2_speech2_option4' }
            }
        }
    end
    return { conditionsMet = false, id = chapterId }
end

--- Health = 3
---@return table
local function level2Speech3Conditions_UNFINISHED()
    local chapterId = 'level2_speech3'
    -- Check for health = 4, because patients lose 1 health at the beginning of the planning phase
    if SharedNarrativeConditions.patientHealthEquals(owner, 4) then
        return {
            conditionsMet = true,
            id = chapterId,
            speech = {
                { text = 'speech_edBanger_level2_speech3_option1' },
                { text = 'speech_edBanger_level2_speech3_option2' },
                { text = 'speech_edBanger_level2_speech3_option3' },
                { text = 'speech_edBanger_level2_speech3_option4' }
            }
        }
    end
    return { conditionsMet = false, id = chapterId }
end

--- Health = 1
---@return table
local function level2Speech4Conditions_UNFINISHED()
    local chapterId = 'level2_speech4'
    -- Check for health = 2, because patients lose 1 health at the beginning of the planning phase
    if SharedNarrativeConditions.patientHealthEquals(owner, 6) then
        return {
            conditionsMet = true,
            id = chapterId,
            speech = {
                { text = 'speech_edBanger_level2_speech4_option1' },
                { text = 'speech_edBanger_level2_speech4_option2' },
                { text = 'speech_edBanger_level2_speech4_option3' },
                { text = 'speech_edBanger_level2_speech4_option4' }
            }
        }
    end
    return { conditionsMet = false, id = chapterId }
end

--- Invalid interaction with this patient (AND not already shown)
---@return table
local function level2Speech5Conditions()
    local chapterId = 'level2_speech5'
    if invalidActionWithMeThisRound and (not chapterWasAlreadyShown(chapterId)) then
        return {
            conditionsMet = true,
            id = chapterId,
            speech = {
                { text = 'speech_edBanger_level2_speech5_option1', args = { invalidActionPlayerName } },
                { text = 'speech_edBanger_level2_speech5_option2', args = { invalidActionPlayerName } },
                { text = 'speech_edBanger_level2_speech5_option3', args = { invalidActionPlayerName } },
                { text = 'speech_edBanger_level2_speech5_option4' }
            }
        }
    end
    return { conditionsMet = false, id = chapterId }
end

--- Invalid interaction with this patient (AND not already shown)
---@return table
local function level2Speech6Conditions()
    local chapterId = 'level2_speech6'
    if invalidActionWithMeThisRound and (not chapterWasAlreadyShown(chapterId)) then
        return {
            conditionsMet = true,
            id = chapterId,
            speech = {
                { text = 'speech_edBanger_level2_speech6_option1', args = { invalidActionPlayerName } },
                { text = 'speech_edBanger_level2_speech6_option2', args = { invalidActionPlayerName } },
                { text = 'speech_edBanger_level2_speech6_option3' },
                { text = 'speech_edBanger_level2_speech6_option4', args = { invalidActionPlayerName } }
            }
        }
    end
    return { conditionsMet = false, id = chapterId }
end

--- Invalid interaction with sofa (AND not already shown)
---@return table
local function level2Speech7Conditions()
    local chapterId = 'level2_speech7'
    if SharedNarrativeConditions.playerActedAtSofaInLastRound() and (not chapterWasAlreadyShown(chapterId)) then
        local mostRecentSofaActPlayer = game.saveData.getString(SaveDataKeys.global_mostRecentActedAtSofaPlayer())
        return {
            conditionsMet = true,
            id = chapterId,
            speech = {
                { text = 'speech_edBanger_level2_speech7_option1', args = { mostRecentSofaActPlayer } },
                { text = 'speech_edBanger_level2_speech7_option2', args = { mostRecentSofaActPlayer } },
                { text = 'speech_edBanger_level2_speech7_option3', args = { mostRecentSofaActPlayer } },
                { text = 'speech_edBanger_level2_speech7_option4', args = { mostRecentSofaActPlayer } }
            }
        }
    end
    return { conditionsMet = false, id = chapterId }
end

--- Any player bumped in the last round (AND not already shown)
---@return table
local function level2Speech8Conditions()
    local chapterId = 'level2_speech8'
    if SharedNarrativeConditions.playerBumpedInLastRound() and (not chapterWasAlreadyShown(chapterId)) then
        return {
            conditionsMet = true,
            id = chapterId,
            speech = {
                { text = 'speech_edBanger_level2_speech8_option1' },
                { text = 'speech_edBanger_level2_speech8_option2' },
                { text = 'speech_edBanger_level2_speech8_option3' },
                { text = 'speech_edBanger_level2_speech8_option4' }
            }
        }
    end
    return { conditionsMet = false, id = chapterId }
end

--- I was healed!
---@return table
local function level2SpeechHealed_UNFINISHED()
    local chapterId = 'level2_speechHealed'
    return {
        conditionsMet = true,
        id = chapterId,
        speech = {
            { text = 'speech_edBanger_level2_speechHealed_option1' },
            { text = 'speech_edBanger_level2_speechHealed_option2' },
            { text = 'speech_edBanger_level2_speechHealed_option3' },
            { text = 'speech_edBanger_level2_speechHealed_option4' }
        }
    }
end

-- ARC 1 (BUMPING/MOSHING) SPEECH CONDITIONS
-- =========================================

--- Any player bumped in the last round
---@return table
local function arc1Chapter1Conditions()
    local chapterId = 'arc1_chapter1'
    if SharedNarrativeConditions.playerBumpedInLastRound() then
        local mostRecentBumpPlayer = game.saveData.getString(SaveDataKeys.global_mostRecentBumpPlayer())
        return {
            conditionsMet = true,
            id = chapterId,
            speech = {
                { text = 'speech_edBanger_arc1_chapter1_option1', args = { mostRecentBumpPlayer } },
                { text = 'speech_edBanger_arc1_chapter1_option2', args = { mostRecentBumpPlayer } },
                { text = 'speech_edBanger_arc1_chapter1_option3' },
                { text = 'speech_edBanger_arc1_chapter1_option4', args = { mostRecentBumpPlayer } }
            }
        }
    end
    return { conditionsMet = false, id = chapterId }
end

--- Any player bumped in the last round
---@return table
local function arc1Chapter2Conditions()
    local chapterId = 'arc1_chapter2'
    if SharedNarrativeConditions.playerBumpedInLastRound() then
        local mostRecentBumpPlayer = game.saveData.getString(SaveDataKeys.global_mostRecentBumpPlayer())
        local mostRecentBumpedObject = game.saveData.getString(SaveDataKeys.global_mostRecentBumpedObject())
        return {
            conditionsMet = true,
            id = chapterId,
            speech = {
                { text = 'speech_edBanger_arc1_chapter2_option1', args = { mostRecentBumpPlayer, mostRecentBumpedObject } },
                { text = 'speech_edBanger_arc1_chapter2_option2', args = { mostRecentBumpPlayer, mostRecentBumpedObject } },
                { text = 'speech_edBanger_arc1_chapter2_option3', args = { mostRecentBumpPlayer, mostRecentBumpedObject } },
                { text = 'speech_edBanger_arc1_chapter2_option4', args = { mostRecentBumpedObject, mostRecentBumpPlayer } }
            }
        }
    end
    return { conditionsMet = false, id = chapterId }
end

--- Any player has bumped 6 times OR any player bumped in the last round
--- AND level 1 has been played through
---@return table
local function arc1Chapter3Conditions()
    local chapterId = 'arc1_chapter3'
    local level1Played = SharedNarrativeConditions.levelHasBeenPlayedThrough(1, game.levelNumber)
    if (SharedNarrativeConditions.playersHaveBumpedXTimes(6) or SharedNarrativeConditions.playerBumpedInLastRound()) and level1Played then
        return {
            conditionsMet = true,
            id = chapterId,
            speech = {
                { text = 'speech_edBanger_arc1_chapter3_option1' },
                { text = 'speech_edBanger_arc1_chapter3_option2' },
                { text = 'speech_edBanger_arc1_chapter3_option3' },
                { text = 'speech_edBanger_arc1_chapter3_option4' }
            }
        }
    end
    return { conditionsMet = false, id = chapterId }
end

--- Any player has bumped 8 times OR any player bumped in the last round
--- AND level 1 has been played through
---@return table
local function arc1Chapter4Conditions()
    local chapterId = 'arc1_chapter4'
    local level1Played = SharedNarrativeConditions.levelHasBeenPlayedThrough(1, game.levelNumber)
    if (SharedNarrativeConditions.playersHaveBumpedXTimes(8) or SharedNarrativeConditions.playerBumpedInLastRound()) and level1Played then
        return {
            conditionsMet = true,
            id = chapterId,
            speech = {
                { text = 'speech_edBanger_arc1_chapter4_option1' },
                { text = 'speech_edBanger_arc1_chapter4_option2' },
                { text = 'speech_edBanger_arc1_chapter4_option3' },
                { text = 'speech_edBanger_arc1_chapter4_option4' }
            }
        }
    end
    return { conditionsMet = false, id = chapterId }
end

--- Any player has bumped 12 times OR any player bumped in the last round
--- AND level 2 has been played through
---@return table
local function arc1Chapter5Conditions()
    local chapterId = 'arc1_chapter5'
    local level2Played = SharedNarrativeConditions.levelHasBeenPlayedThrough(2, game.levelNumber)
    if (SharedNarrativeConditions.playersHaveBumpedXTimes(12) or SharedNarrativeConditions.playerBumpedInLastRound()) and level2Played then
        return {
            conditionsMet = true,
            id = chapterId,
            speech = {
                { text = 'speech_edBanger_arc1_chapter5_option1' },
                { text = 'speech_edBanger_arc1_chapter5_option2' },
                { text = 'speech_edBanger_arc1_chapter5_option3' },
                { text = 'speech_edBanger_arc1_chapter5_option4' }
            }
        }
    end
    return { conditionsMet = false, id = chapterId }
end

-- ARC 2 (ED REVEALS HE IS AN ACCOUNTANT) SPEECH CONDITIONS
-- ========================================================

--- Ed needs pills AND any player is holding pills AND current level > 2
---@return table
local function arc2Chapter1Conditions()
    local chapterId = 'arc2_chapter1'
    if (SharedNarrativeConditions.patientNeedsPills(owner)) and (SharedNarrativeConditions.playerIsHoldingPills()) and (game.levelNumber > 2) then
        return {
            conditionsMet = true,
            id = chapterId,
            speech = {
                { text = 'speech_edBanger_arc2_chapter1_option1' },
                { text = 'speech_edBanger_arc2_chapter1_option2' },
                { text = 'speech_edBanger_arc2_chapter1_option3' },
                { text = 'speech_edBanger_arc2_chapter1_option4' }
            }
        }
    end
    return { conditionsMet = false, id = chapterId }
end

--- >0 levels had 100% of patients saved AND a patient was saved on the previous round AND current level > 2
---@return table
local function arc2Chapter2Conditions()
    local chapterId = 'arc2_chapter2'
    if (SharedNarrativeConditions.getNumberOfLevelsCompletedWithAllCured() > 0) and (SharedNarrativeConditions.patientCuredInLastRound()) and (game.levelNumber > 2) then
        local highestWardNumberWithAllPatientsCured = tostring(SharedNarrativeConditions.getHighestWardNumberWithAllPatientsCured())
        return {
            conditionsMet = true,
            id = chapterId,
            speech = {
                { text = 'speech_edBanger_arc2_chapter2_option1', args = { highestWardNumberWithAllPatientsCured } },
                { text = 'speech_edBanger_arc2_chapter2_option2', args = { highestWardNumberWithAllPatientsCured } },
                { text = 'speech_edBanger_arc2_chapter2_option3', args = { highestWardNumberWithAllPatientsCured } },
                { text = 'speech_edBanger_arc2_chapter2_option4', args = { highestWardNumberWithAllPatientsCured } }
            }
        }
    end
    return { conditionsMet = false, id = chapterId }
end

--- >1 level had 100% of patients saved AND a patient was saved on the previous round AND current level > 3
---@return table
local function arc2Chapter3Conditions()
    local chapterId = 'arc2_chapter3'
    if (SharedNarrativeConditions.getNumberOfLevelsCompletedWithAllCured() > 1) and (SharedNarrativeConditions.patientCuredInLastRound()) and (game.levelNumber > 3) then
        local highestWardNumberWithAllPatientsCured = tostring(SharedNarrativeConditions.getHighestWardNumberWithAllPatientsCured())
        return {
            conditionsMet = true,
            id = chapterId,
            speech = {
                { text = 'speech_edBanger_arc2_chapter3_option1', args = { highestWardNumberWithAllPatientsCured } },
                { text = 'speech_edBanger_arc2_chapter3_option2', args = { highestWardNumberWithAllPatientsCured } },
                { text = 'speech_edBanger_arc2_chapter3_option3', args = { highestWardNumberWithAllPatientsCured } },
                { text = 'speech_edBanger_arc2_chapter3_option4', args = { highestWardNumberWithAllPatientsCured } }
            }
        }
    end
    return { conditionsMet = false, id = chapterId }
end

--- A thrown object is not caught OR a patient dies, AND current level > 3
---@return table
local function arc2Chapter4Conditions()
    local chapterId = 'arc2_chapter4'
    if (SharedNarrativeConditions.playerThrewToUncaughtInLastRound() or SharedNarrativeConditions.patientLeftInLastRound()) and (game.levelNumber > 3) then
        return {
            conditionsMet = true,
            id = chapterId,
            speech = {
                { text = 'speech_edBanger_arc2_chapter4_option1' },
                { text = 'speech_edBanger_arc2_chapter4_option2' },
                { text = 'speech_edBanger_arc2_chapter4_option3' },
                { text = 'speech_edBanger_arc2_chapter4_option4' }
            }
        }
    end
    return { conditionsMet = false, id = chapterId }
end

--- >2 levels had 100% of patients saved AND a patient was saved on the previous round AND current level > 4
---@return table
local function arc2Chapter5Conditions()
    local chapterId = 'arc2_chapter5'
    if (SharedNarrativeConditions.getNumberOfLevelsCompletedWithAllCured() > 2) and (SharedNarrativeConditions.patientCuredInLastRound()) and (game.levelNumber > 4) then
        return {
            conditionsMet = true,
            id = chapterId,
            speech = {
                { text = 'speech_edBanger_arc2_chapter5_option1' },
                { text = 'speech_edBanger_arc2_chapter5_option2' },
                { text = 'speech_edBanger_arc2_chapter5_option3' },
                { text = 'speech_edBanger_arc2_chapter5_option4' }
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
    if levelNumber == 1 then
        return {
            level1Speech1Conditions,
            level1Speech2Conditions,
            level1Speech3Conditions,
            level1Speech4Conditions,
            level1Speech5Conditions,
            level1Speech6Conditions,
            level1Speech7Conditions,
            level1Speech8Conditions,
        }
    elseif levelNumber == 2 then
        return {
            level2Speech1Conditions,
            level2Speech5Conditions,
            level2Speech6Conditions,
            level2Speech7Conditions,
            level2Speech8Conditions
        }
    end
    return nil
end

--- Called externally by NarrativeCharacter
---@param levelNumber number
---@param specialCondition string
---@return table|nil
function getSpecialConditionLevelChapters(levelNumber, specialCondition)
    if specialCondition == 'cured' then
        if levelNumber == 1 then
            return { level1SpeechHealed }
        end
    end
    return nil
end

--- Called externally by NarrativeCharacter
---@return table
function getAllNarrativeArcChapters()
    return {
        -- Arc 1: Bumping/moshing
        {
            arc1Chapter1Conditions,
            arc1Chapter2Conditions,
            arc1Chapter3Conditions,
            arc1Chapter4Conditions,
            arc1Chapter5Conditions
        },
        -- Arc 2: Ed reveals he is an accountant
        {
            arc2Chapter1Conditions,
            arc2Chapter2Conditions,
            arc2Chapter3Conditions,
            arc2Chapter4Conditions,
            arc2Chapter5Conditions
        }
    }
end

--- Name of the character, used in keys for character-related narrative save data
--- and for getting localized character name from string table
--- Called externally by NarrativeCharacter
---@return string
function getCharacterName()
    return 'edBanger'
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
local function onHadInvalidInteraction(message)
    if message.data.playerName == nil then
		error('No playerName data in patient.hadInvalidInteraction message')
	end
    -- A player performed an invalid action in the direction of this patient
    invalidActionWithMeThisRound = true
    invalidActionPlayerName = message.data.playerName
end

---@param message Message
local function onGamePhaseChanged(message)
    local phase = message.data.gamePhase
	if phase == nil then
		error('No phase data in gamePhase message!')
	end
    if phase == 'acting' then
        -- Reset for each round
        invalidActionWithMeThisRound = false
        invalidActionPlayerName = ''
    end
end

tags.addTag('CharacterNarrativeConditions')
owner.tags.addTag('CharacterNarrativeConditions')

log:log("EdBangerNarrativeConditions lua started")

owner.bus.subscribe('patient.hadInvalidInteraction', onHadInvalidInteraction)
game.bus.subscribe('gamePhase', onGamePhaseChanged)