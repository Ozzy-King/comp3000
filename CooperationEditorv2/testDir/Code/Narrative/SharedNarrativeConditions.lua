---@type Game
local game = LoadFacility('Game')['game']

local SaveDataKeys = require('NarrativeSaveDataKeys')

local SharedNarrativeConditions = {}

function SharedNarrativeConditions.saveDataKeys()
    return SaveDataKeys;
end

---@param characterName string
---@param chapterId string
---@return string
local function getChapterAlreadyShownKey(characterName, chapterId)
    return 'narrative_chapterShown_' .. characterName .. '_' .. chapterId
end

--- Check if a chapter was already displayed to players in this save slot
---@param characterName string
---@param chapterId string
---@return boolean
function SharedNarrativeConditions.chapterWasAlreadyShown(characterName, chapterId)
    local chapterShownKey = getChapterAlreadyShownKey(characterName, chapterId)
    return (game.saveData.getNumber(chapterShownKey) ~= 0)
end

--- Mark a chapter as having been displayed to players in this save slot
---@param characterName string
---@param chapterId string
function SharedNarrativeConditions.setChapterAsShown(characterName, chapterId)
    local chapterShownKey = getChapterAlreadyShownKey(characterName, chapterId)
    game.saveData.setNumber(chapterShownKey, 1)
end

-- PLAYER-RELATED CONDITIONS
-- =========================

---@return boolean
function SharedNarrativeConditions.playerBumpedInLastRound()
    local playerBumpedInRound = game.saveData.getNumber(SaveDataKeys.thisRound_didPlayerBump())
    return (playerBumpedInRound ~= 0)
end
---@param timesBumped number
---@return boolean
function SharedNarrativeConditions.playersHaveBumpedXTimes(timesBumped)
    local playerBumpCount = game.saveData.getNumber(SaveDataKeys.global_playerBumpCount())
    return (playerBumpCount >= timesBumped)
end

---@return boolean
function SharedNarrativeConditions.playerCaughtInLastRound()
    local playerCaughtInRound = game.saveData.getNumber(SaveDataKeys.thisRound_didPlayerCatch())
    return (playerCaughtInRound ~= 0)
end
---@param timesCaught number
---@return boolean
function SharedNarrativeConditions.playersHaveCaughtXTimes(timesCaught)
    local playerCatchCount = game.saveData.getNumber(SaveDataKeys.global_playerCatchCount())
    return (playerCatchCount >= timesCaught)
end

---@return boolean
function SharedNarrativeConditions.playerThrewToUncaughtInLastRound()
    local threwToUncaught = game.saveData.getNumber(SaveDataKeys.thisRound_didPlayerThrowToUncaught())
    return (threwToUncaught ~= 0)
end
---@return boolean
function SharedNarrativeConditions.playerDroppedPillsInLastRound()
    local droppedPills = game.saveData.getNumber(SaveDataKeys.thisRound_didPlayerDropPills())
    return (droppedPills ~= 0)
end

---@return boolean
function SharedNarrativeConditions.playerActedAtSofaInLastRound()
    local actedAtSofa = game.saveData.getNumber(SaveDataKeys.thisRound_playerActedAtSofa())
    return (actedAtSofa ~= 0)
end

--- Returns true if any player is currently holding pills
---@return boolean
function SharedNarrativeConditions.playerIsHoldingPills()
    local players = owner.map.getAllObjectsTagged('Player')
    for player in players do
        local pillAtPlayerPos = owner.map.getFirstTagged(player.gridPosition, 'pills')
        if pillAtPlayerPos ~= nil then
            return true
        end
    end
    return false
end

-- PATIENT-RELATED CONDITIONS
-- ==========================

---@return boolean
function SharedNarrativeConditions.patientCuredInLastRound()
    local patientCured = game.saveData.getNumber(SaveDataKeys.thisRound_wasPatientCured())
    return (patientCured ~= 0)
end
---@return boolean
function SharedNarrativeConditions.patientLeftInLastRound()
    local patientLeft = game.saveData.getNumber(SaveDataKeys.thisRound_didPatientLeave())
    return (patientLeft ~= 0)
end

--- Returns true if the given patient is in bed and needs pills to be cured
---@param patientMapObj MapObject
---@return boolean
function SharedNarrativeConditions.patientNeedsPills(patientMapObj)
    local bedAtPatientPos = owner.map.getFirstTagged(patientMapObj.gridPosition, 'bed')
    if bedAtPatientPos == nil then
        -- Patient isn't in bed, so can't take any medicine
        return false
    end
    return (patientMapObj.callFunc('getNeed') == 'pill')
end

---@param patientMapObj MapObject
---@param health number
---@return boolean
function SharedNarrativeConditions.patientHealthEquals(patientMapObj, health)
    return (patientMapObj.callFunc('getHealth') == health)
end

---@param patientMapObj MapObject
---@param healthPercentDecimal number
---@return boolean
function SharedNarrativeConditions.patientHealthLessThanPercentage(patientMapObj, healthPercentDecimal)
    local patientHealth = patientMapObj.callFunc('getHealth')
    local patientStartHealth = patientMapObj.callFunc('getStartingHealth')
    local healthAmount = patientHealth / patientStartHealth
    return healthAmount < healthPercentDecimal
end

-- LEVEL-RELATED CONDITIONS
-- ========================

---@return number
function SharedNarrativeConditions.getHighestWardNumberWithAllPatientsCured()
    local highestLevelNum = 0
    for levelNum = 1, game.totalNumberOfLevels, 1 do
        if game.saveData.getNumber(SaveDataKeys.global_levelXAllCured(levelNum)) ~= 0 then
            highestLevelNum = levelNum
        end
    end
    return highestLevelNum
end

---@return number
function SharedNarrativeConditions.getNumberOfLevelsCompletedWithAllCured()
    local allCuredCount = 0
    for levelNum = 1, game.totalNumberOfLevels, 1 do
        if game.saveData.getNumber(SaveDataKeys.global_levelXAllCured(levelNum)) ~= 0 then
            allCuredCount = allCuredCount + 1
        end
    end
    return allCuredCount
end

--- Returns true the level with the given levelNumber has been completed,
--- and currentLevelNumber is greater than levelNumber (the level being played comes after the one that was completed)
---@param levelNumber number
---@param currentLevelNumber number
---@return boolean
function SharedNarrativeConditions.levelHasBeenPlayedThrough(levelNumber, currentLevelNumber)
    local levelCompleted = (game.saveData.getNumber(SaveDataKeys.global_levelXCompleted(levelNumber)) ~= 0)
    return levelCompleted and (currentLevelNumber > levelNumber)
end

tags.addTag('SharedNarrativeConditions')

return SharedNarrativeConditions
