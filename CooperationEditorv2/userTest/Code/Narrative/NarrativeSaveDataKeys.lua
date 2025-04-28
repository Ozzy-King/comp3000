local NarrativeSaveDataKeys = {}

-- Global narrative save data (used across all levels)
-- ===================================================

---@param levelNumber number
---@return string
function NarrativeSaveDataKeys.global_levelXCompleted(levelNumber)
    return 'narrative_global_level' .. tostring(levelNumber) .. 'Completed'
end
---@param levelNumber number
---@return string
function NarrativeSaveDataKeys.global_levelXAllCured(levelNumber)
    return 'narrative_global_level' .. tostring(levelNumber) .. 'AllCured'
end

---@return string
function NarrativeSaveDataKeys.global_playerBumpCount()
    return 'narrative_global_playerBumpCount'
end
---@return string
function NarrativeSaveDataKeys.global_mostRecentBumpPlayer()
    return 'narrative_global_mostRecentBumpPlayer'
end
---@return string
function NarrativeSaveDataKeys.global_mostRecentBumpedObject()
    return 'narrative_global_mostRecentBumpedObject'
end

---@return string
function NarrativeSaveDataKeys.global_playerCatchCount()
    return 'narrative_global_playerCatchCount'
end
---@return string
function NarrativeSaveDataKeys.global_mostRecentCaughtObject()
    return 'narrative_global_mostRecentCaughtObject'
end

---@return string
function NarrativeSaveDataKeys.global_mostRecentPillDropPlayer()
    return 'narrative_global_mostRecentPillDropPlayer'
end

---@return string
function NarrativeSaveDataKeys.global_mostRecentActedAtSofaPlayer()
    return 'narrative_global_mostRecentActedAtSofaPlayer'
end

-- Round-specific narrative save data
-- IMPORTANT: When adding a new key, also add it to getAllKeysToClearOnNewRound() below
-- ====================================================================================

---@return string
function NarrativeSaveDataKeys.thisRound_didPlayerBump()
    return 'narrative_thisRound_didPlayerBump'
end

---@return string
function NarrativeSaveDataKeys.thisRound_didPlayerThrowToUncaught()
    return 'narrative_thisRound_didPlayerThrowToUncaught'
end
---@return string
function NarrativeSaveDataKeys.thisRound_didPlayerCatch()
    return 'narrative_thisRound_didPlayerCatch'
end

---@return string
function NarrativeSaveDataKeys.thisRound_didPlayerDropPills()
    return 'narrative_thisRound_didPlayerDropPills'
end
---@return string
function NarrativeSaveDataKeys.thisRound_playerActedAtSofa()
    return 'narrative_thisRound_playerActedAtSofa'
end

---@return string
function NarrativeSaveDataKeys.thisRound_wasPatientCured()
    return 'narrative_thisRound_wasPatientCured'
end
---@return string
function NarrativeSaveDataKeys.thisRound_didPatientLeave()
    return 'narrative_thisRound_didPatientLeave'
end

--- Keys for any narrative-related save data that should be cleared at the start of each acting phase
--- (See: NarrativeManager.clearRoundSpecificNarrativeSaveData())
---@return string[]
function NarrativeSaveDataKeys.getAllKeysToClearOnNewRound()
    return {
        NarrativeSaveDataKeys.thisRound_didPlayerBump(),
        NarrativeSaveDataKeys.thisRound_didPlayerThrowToUncaught(),
        NarrativeSaveDataKeys.thisRound_didPlayerCatch(),
        NarrativeSaveDataKeys.thisRound_didPlayerDropPills(),
        NarrativeSaveDataKeys.thisRound_playerActedAtSofa(),
        NarrativeSaveDataKeys.thisRound_wasPatientCured(),
        NarrativeSaveDataKeys.thisRound_didPatientLeave()
    }
end

--- Keys for any narrative-related save data that should be cleared at the start of each level
--- (See: NarrativeManager.clearLevelSpecificNarrativeSaveData())
---@return string[]
function NarrativeSaveDataKeys.getAllKeysToClearOnNewLevel()
    return {
    }
end

-- Localization helper functions
-- =============================

---@param tags Tags
---@return string
function NarrativeSaveDataKeys.getStringTableKeyForNameOfObjectFromTags(tags)
    if tags.hasTag('Player') then
        return 'objectName_teammate'
    elseif tags.hasTag('Patient') then
        return 'objectName_patient'
    elseif tags.hasTag('pills') then
        return 'objectName_pill'
    elseif tags.hasTag('syringe') then
        return 'objectName_syringe'
    elseif tags.hasTag('apple') then
        return 'objectName_apple'
    end
    return 'objectName_furniture'
end

---@param mapObject MapObject
---@return string
function NarrativeSaveDataKeys.getStringTableKeyForNameOfObject(mapObject)
    return NarrativeSaveDataKeys.getStringTableKeyForNameOfObjectFromTags(mapObject.tags)
end

return NarrativeSaveDataKeys
