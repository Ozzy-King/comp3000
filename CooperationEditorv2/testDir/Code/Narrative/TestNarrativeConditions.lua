SharedNarrativeConditions = require('SharedNarrativeConditions')

---@type MapMobile
local owner = owner or error('No owner')

-- Set in mod data for tests
---@type number
local level1Speech1ConditionsMet = level1Speech1ConditionsMet or 0
---@type number
local level1Speech2ConditionsMet = level1Speech2ConditionsMet or 0
---@type number
local level2Speech1ConditionsMet = level2Speech1ConditionsMet or 0
---@type number
local level2Speech2ConditionsMet = level2Speech2ConditionsMet or 0
---@type number
local arc1Chapter1ConditionsMet = arc1Chapter1ConditionsMet or 0
---@type number
local arc1Chapter2ConditionsMet = arc1Chapter2ConditionsMet or 0
---@type number
local arc2Chapter1ConditionsMet = arc2Chapter1ConditionsMet or 0
---@type number
local arc2Chapter2ConditionsMet = arc2Chapter2ConditionsMet or 0

-- Functions for testing SharedNarrativeConditions
-- ===============================================

---@param characterName string
---@param chapterId string
---@return boolean
function testCondition_chapterWasAlreadyShown(characterName, chapterId)
    return SharedNarrativeConditions.chapterWasAlreadyShown(characterName, chapterId)
end

---@return boolean
function testCondition_playerBumpedInLastRound()
    return SharedNarrativeConditions.playerBumpedInLastRound()
end
---@param timesBumped number
---@return boolean
function testCondition_playersHaveBumpedXTimes(timesBumped)
    return SharedNarrativeConditions.playersHaveBumpedXTimes(timesBumped)
end

---@return boolean
function testCondition_playerCaughtInLastRound()
    return SharedNarrativeConditions.playerCaughtInLastRound()
end
---@param timesCaught number
---@return boolean
function testCondition_playersHaveCaughtXTimes(timesCaught)
    return SharedNarrativeConditions.playersHaveCaughtXTimes(timesCaught)
end

---@return boolean
function testCondition_playerThrewToUncaughtInLastRound()
    return SharedNarrativeConditions.playerThrewToUncaughtInLastRound()
end
---@return boolean
function testCondition_playerDroppedPillsInLastRound()
    return SharedNarrativeConditions.playerDroppedPillsInLastRound()
end

---@return boolean
function testCondition_playerActedAtSofaInLastRound()
    return SharedNarrativeConditions.playerActedAtSofaInLastRound()
end

---@return boolean
function testCondition_playerIsHoldingPills()
    return SharedNarrativeConditions.playerIsHoldingPills()
end

---@return boolean
function testCondition_patientCuredInLastRound()
    return SharedNarrativeConditions.patientCuredInLastRound()
end
---@return boolean
function testCondition_patientLeftInLastRound()
    return SharedNarrativeConditions.patientLeftInLastRound()
end

---@param patientMapObj MapObject
---@return boolean
function testCondition_patientNeedsPills(patientMapObj)
    return SharedNarrativeConditions.patientNeedsPills(patientMapObj)
end

---@param patientMapObj MapObject
---@param health number
---@return boolean
function testCondition_patientHealthEquals(patientMapObj, health)
    return SharedNarrativeConditions.patientHealthEquals(patientMapObj, health)
end

---@param patientMapObj MapObject
---@param healthPercentDecimal number
---@return boolean
function testCondition_patientHealthLessThanPercentage(patientMapObj, healthPercentDecimal)
    return SharedNarrativeConditions.patientHealthLessThanPercentage(patientMapObj, healthPercentDecimal)
end

---@return number
function testCondition_getHighestWardNumberWithAllPatientsCured()
    return SharedNarrativeConditions.getHighestWardNumberWithAllPatientsCured()
end

---@return number
function testCondition_getNumberOfLevelsCompletedWithAllCured()
    return SharedNarrativeConditions.getNumberOfLevelsCompletedWithAllCured()
end

---@param levelNumber number
---@param currentLevelNumber number
---@return boolean
function testCondition_levelHasBeenPlayedThrough(levelNumber, currentLevelNumber)
    return SharedNarrativeConditions.levelHasBeenPlayedThrough(levelNumber, currentLevelNumber)
end

-- LEVEL SPEECH CONDITIONS
-- =======================
-- > LEVEL 1
-- =========

---@return table
local function level1Speech1Conditions()
    local chapterId = 'level1_speech1'
    if level1Speech1ConditionsMet ~= 0 then
        return {
            conditionsMet = true,
            id = chapterId,
            speech = {
                { text = 'speech_test_level1_speech1_option1' },
                { text = 'speech_test_level1_speech1_option2' },
                { text = 'speech_test_level1_speech1_option3' },
                { text = 'speech_test_level1_speech1_option4' }
            }
        }
    end
    return { conditionsMet = false, id = chapterId }
end

---@return table
local function level1Speech2Conditions()
    local chapterId = 'level1_speech2'
    if level1Speech2ConditionsMet ~= 0 then
        return {
            conditionsMet = true,
            id = chapterId,
            speech = {
                { text = 'speech_test_level1_speech2_option1' },
                { text = 'speech_test_level1_speech2_option2' },
                { text = 'speech_test_level1_speech2_option3' },
                { text = 'speech_test_level1_speech2_option4' }
            }
        }
    end
    return { conditionsMet = false, id = chapterId }
end

-- > LEVEL 2
-- =========

---@return table
local function level2Speech1Conditions()
    local chapterId = 'level2_speech1'
    if level2Speech1ConditionsMet ~= 0 then
        return {
            conditionsMet = true,
            id = chapterId,
            speech = {
                { text = 'speech_test_level2_speech1_option1' },
                { text = 'speech_test_level2_speech1_option2' },
                { text = 'speech_test_level2_speech1_option3' },
                { text = 'speech_test_level2_speech1_option4' }
            }
        }
    end
    return { conditionsMet = false, id = chapterId }
end

---@return table
local function level2Speech2Conditions()
    local chapterId = 'level2_speech2'
    if level2Speech2ConditionsMet ~= 0 then
        return {
            conditionsMet = true,
            id = chapterId,
            speech = {
                { text = 'speech_test_level2_speech2_option1' },
                { text = 'speech_test_level2_speech2_option2' },
                { text = 'speech_test_level2_speech2_option3' },
                { text = 'speech_test_level2_speech2_option4' }
            }
        }
    end
    return { conditionsMet = false, id = chapterId }
end

-- ARC 1 SPEECH CONDITIONS
-- =======================

---@return table
local function arc1Chapter1Conditions()
    local chapterId = 'arc1_chapter1'
    if arc1Chapter1ConditionsMet ~= 0 then
        return {
            conditionsMet = true,
            id = chapterId,
            speech = {
                { text = 'speech_test_arc1_chapter1_option1' },
                { text = 'speech_test_arc1_chapter1_option2' },
                { text = 'speech_test_arc1_chapter1_option3' },
                { text = 'speech_test_arc1_chapter1_option4' }
            }
        }
    end
    return { conditionsMet = false, id = chapterId }
end

---@return table
local function arc1Chapter2Conditions()
    local chapterId = 'arc1_chapter2'
    if arc1Chapter2ConditionsMet ~= 0 then
        return {
            conditionsMet = true,
            id = chapterId,
            speech = {
                { text = 'speech_test_arc1_chapter2_option1' },
                { text = 'speech_test_arc1_chapter2_option2' },
                { text = 'speech_test_arc1_chapter2_option3' },
                { text = 'speech_test_arc1_chapter2_option4' }
            }
        }
    end
    return { conditionsMet = false, id = chapterId }
end

-- ARC 2 SPEECH CONDITIONS
-- =======================

---@return table
local function arc2Chapter1Conditions()
    local chapterId = 'arc2_chapter1'
    if arc2Chapter1ConditionsMet ~= 0 then
        return {
            conditionsMet = true,
            id = chapterId,
            speech = {
                { text = 'speech_test_arc2_chapter1_option1' },
                { text = 'speech_test_arc2_chapter1_option2' },
                { text = 'speech_test_arc2_chapter1_option3' },
                { text = 'speech_test_arc2_chapter1_option4' }
            }
        }
    end
    return { conditionsMet = false, id = chapterId }
end

---@return table
local function arc2Chapter2Conditions()
    local chapterId = 'arc2_chapter2'
    if arc2Chapter2ConditionsMet ~= 0 then
        return {
            conditionsMet = true,
            id = chapterId,
            speech = {
                { text = 'speech_test_arc2_chapter2_option1' },
                { text = 'speech_test_arc2_chapter2_option2' },
                { text = 'speech_test_arc2_chapter2_option3' },
                { text = 'speech_test_arc2_chapter2_option4' }
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
            level1Speech2Conditions
        }
    elseif levelNumber == 2 then
        return {
            level2Speech1Conditions,
            level2Speech2Conditions
        }
    end
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
        -- Arc 1
        {
            arc1Chapter1Conditions,
            arc1Chapter2Conditions
        },
        -- Arc 2
        {
            arc2Chapter1Conditions,
            arc2Chapter2Conditions
        }
    }
end

--- Name of the character, used in keys for character-related narrative save data
--- and for getting localized character name from string table
--- Called externally by NarrativeCharacter
---@return string
function getCharacterName()
    return 'testCharacter'
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

tags.addTag('CharacterNarrativeConditions')
owner.tags.addTag('CharacterNarrativeConditions')