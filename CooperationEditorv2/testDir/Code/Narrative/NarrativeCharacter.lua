---@type Game
local game = LoadFacility('Game')['game']

local Log = require('Log')
local log = Log.new()

---@type MapMobile
local owner = owner or error('No owner')

---@type boolean
local destroyed = false

-- Small delay to avoid the odd occasion where CharacterNarrativeConditions script has not started when trying to get the component
waitMilliSeconds(10)
---@type Mod
local characterConditions = owner.getFirstComponentTagged('CharacterNarrativeConditions') or error("No mod tagged CharacterNarrativeConditions on NarrativeCharacter owner")

---@type string
local arcsChaptersFuncName = 'getAllNarrativeArcChapters';
if not characterConditions.hasFunc(arcsChaptersFuncName) then
    error('Script tagged as "CharacterNarrativeConditions" should have function: ' .. arcsChaptersFuncName)
end
---@type string
local levelChaptersFuncName = 'getAllLevelSpecificChapters';
if not characterConditions.hasFunc(levelChaptersFuncName) then
    error('Script tagged as "CharacterNarrativeConditions" should have function: ' .. levelChaptersFuncName)
end
---@type string
local levelSpecialConditionChaptersFuncName = 'getSpecialConditionLevelChapters';
if not characterConditions.hasFunc(levelSpecialConditionChaptersFuncName) then
    error('Script tagged as "CharacterNarrativeConditions" should have function: ' .. levelSpecialConditionChaptersFuncName)
end

---@type string
local getChapterShownFuncName = 'chapterWasAlreadyShown';
if not characterConditions.hasFunc(getChapterShownFuncName) then
    error('Script tagged as "CharacterNarrativeConditions" should have function: ' .. getChapterShownFuncName)
end
---@type string
local setChapterShownFuncName = 'setChapterAsShown';
if not characterConditions.hasFunc(setChapterShownFuncName) then
    error('Script tagged as "CharacterNarrativeConditions" should have function: ' .. setChapterShownFuncName)
end

---@type string
local characterNameFunc = 'getCharacterName';
if not characterConditions.hasFunc(characterNameFunc) then
    error('Script tagged as "CharacterNarrativeConditions" should have function: ' .. characterNameFunc)
end
---@type string
local characterName = characterConditions.callFunc(characterNameFunc)

---@type boolean
local showingSpeech = false

---@type table<boolean>
local chaptersShownThisLevelForIds = {}

---@param textKey string
---@return string
local function getTextAlreadyShownKey(textKey)
    return 'narrative_textShown_' .. textKey
end

--- Randomly selects speech from the chapter, prioritising dialogue that has never been shown
---@param chapter table
---@return table
local function chooseRandomSpeechFromChapter(chapter)
    local unshownSpeech = {}
    local shownSpeech = {}

    if chapter.speech == nil then
        error('Missing character dialogue: chapter table with id "' .. chapter.id .. '" does not contain speech when trying to display narrative text for ' .. characterName)
    end
    if #chapter.speech == 0 then
        error('Missing character dialogue: chapter table with id "' .. chapter.id .. '" has an empty speech table when trying to display narrative text for ' .. characterName)
    end
    for textAndArgs in chapter.speech do
        if (textAndArgs.text == nil) or (#textAndArgs.text == 0) then
            error('chapter.speech table does not contain text when trying to display narrative text for ' .. characterName .. '(chapter.id: "' .. chapter.id .. '")')
        end
        if game.saveData.getNumber(getTextAlreadyShownKey(textAndArgs.text)) == 0 then
            -- Text has never been shown before
            table.insert(unshownSpeech, textAndArgs)
        elseif #unshownSpeech == 0 then
            -- Text has previously been shown (in this save slot)
            -- (Only bother adding shown text to the table if no unshown text was found yet)
            table.insert(shownSpeech, textAndArgs)
        end
    end

    if #unshownSpeech > 0 then
        return unshownSpeech[math.random(#unshownSpeech)]
    else
        return shownSpeech[math.random(#shownSpeech)]
    end
end

--- Returns true if the dialogue text was displayed
---@param chapter table
local function displaySpeechFromChapter(chapter)
    if chapter.id == nil then
        error('chapter table does not contain id field when trying to display narrative text for ' .. characterName)
    end

    local textAndArgsToShow = chooseRandomSpeechFromChapter(chapter)
    if textAndArgsToShow == nil then
        return
    end

    -- Mark chapter as shown in save data (using key: chapter.id)
    characterConditions.callFunc(setChapterShownFuncName, chapter.id)
    -- Mark speech as shown for this current level
    chaptersShownThisLevelForIds[chapter.id] = true

    -- Mark the specific dialogue line being displayed as shown in save data
    game.saveData.setNumber(getTextAlreadyShownKey(textAndArgsToShow.text), 1)
    game.saveData.save()

    game.bus.send({
        metadata = { 'textNotificationUI.createOrUpdate' },
        data = {
            id = tostring(owner.id),
            titleTextKey = 'characterName_' .. characterName,
            mainTextKey = textAndArgsToShow.text,
            mainTextArgs = textAndArgsToShow.args,
            iconName = 'Icon_Avatar_' .. characterName
        }
    }, nil, false)
    showingSpeech = true
end

---@param allArcsWithChapters table
---@return table|nil
local function getHighestPriorityValidChapterFromNarrativeArcs(allArcsWithChapters)
    local highestValidChapterNumber = -1
    local chosenChapter = nil
    for arcWithChapters in allArcsWithChapters do
        for chapterNumber, chapterConditionsFunc in pairs(arcWithChapters) do
            local chapter = chapterConditionsFunc()
            if chapter.id == nil then
                error('chapter table for chapter number ' .. tostring(chapterNumber) .. ' does not contain id field on character ' .. characterName)
            end
            local chapterAlreadyShown = characterConditions.callFunc(getChapterShownFuncName, chapter.id)
            if (chapter.conditionsMet) and (chapterNumber > highestValidChapterNumber) and (not chapterAlreadyShown) then
                -- Conditions for showing this chapter were passed,
                -- AND it has a higher index in its narrative arc (i.e. chapter number) then the current highest,
                -- (Higher chapter numbers take priority to increase likelihood of finishing arcs before showing new ones)
                -- AND this chapter has not already been shown
                -- So it's in the running to be shown!
                highestValidChapterNumber = chapterNumber
                chosenChapter = chapter
                break
            elseif not chapterAlreadyShown then
                -- This chapter hasn't been shown yet, so no subsequent chapters in the same arc should be checked
                -- (We don't want to e.g. show chapter 2 before chapter 1, even if chapter 2's conditions are met)
                break
            end
        end
    end
    return chosenChapter
end

---@param levelChapters table
---@return table|nil
local function getHighestPriorityValidLevelChapter(levelChapters)
    local validUnshownChapters = {}
    local validChaptersShownThisLevel = {}

    for chapterConditionsFunc in levelChapters do
        local chapter = chapterConditionsFunc()
        if chapter.conditionsMet then
            -- Conditions passed, check if this chapter was aready shown this level
            if chaptersShownThisLevelForIds[chapter.id] == nil then
                -- This chapter has never been shown
                log:log(chapter.id .. ' - conditions were met for this chapter, AND it was not yet shown in the current level')
                table.insert(validUnshownChapters, chapter)
            elseif #validUnshownChapters == 0 then
                -- Chapter was already shown in this level
                -- (Only bother adding shown chapters to the table if no unshown chapter was found yet)
                log:log(chapter.id .. ' - conditions were met for this chapter, but was already shown in this level')
                table.insert(validChaptersShownThisLevel, chapter)
            end
        end
    end

    if #validUnshownChapters > 0 then
        return validUnshownChapters[math.random(#validUnshownChapters)]
    elseif #validChaptersShownThisLevel > 0 then
        return validChaptersShownThisLevel[math.random(#validChaptersShownThisLevel)]
    end
    return nil
end

local function showConditionalSpeech()
    if owner.hasFunc('canShowNarrativeText') and (not owner.callFunc('canShowNarrativeText')) then
        log:log('canShowNarrativeText() returned false on owner, so skipping showing any character dialogue for ' .. characterName)
        return
    end

    -- 1. Check for valid dialogue from narrative arcs
    local allArcsWithChapters = characterConditions.callFunc(arcsChaptersFuncName)
    local chosenChapterFromArcs = nil
    if allArcsWithChapters ~= nil then
        chosenChapterFromArcs = getHighestPriorityValidChapterFromNarrativeArcs(allArcsWithChapters)
    end
    if chosenChapterFromArcs ~= nil then
        -- Got valid speech from one of the character's narrative arcs! Display it
        displaySpeechFromChapter(chosenChapterFromArcs)
        return
    end

    -- 2. Check for valid level-specific dialogue
    log:log(characterName .. ' has no valid dialogue from narrative arcs, so checking for level-specific dialogue (level: ' .. tostring(game.levelNumber) .. ')')
    local levelChapters = characterConditions.callFunc(levelChaptersFuncName, game.levelNumber)
    local chosenLevelChapter = nil
    if levelChapters ~= nil then
        chosenLevelChapter = getHighestPriorityValidLevelChapter(levelChapters)
    end
    if chosenLevelChapter ~= nil then
        -- Got valid speech from one of the character's narrative arcs! Display it
        displaySpeechFromChapter(chosenLevelChapter)
        return
    end
end

local function hideSpeechUI()
    if not showingSpeech then
        return
    end
    showingSpeech = false

    game.bus.send({
        metadata = { 'textNotificationUI.destroy' },
        data = {
            id = tostring(owner.id)
        }
    }, nil, false)
end

---@param message Message
local function onMapObjectStateChanged(message)
	if message.data['state.MapObject'] ~= 'Destroyed' then
		return
	end
	destroyed = true
    -- Ensure speech UI goes away when owner is destroyed
    if showingSpeech then
        hideSpeechUI()
    end
end

---@param message Message
local function onPatientStateChanged(message)
	if message.data['state.patient'] ~= 'Cured' then
        return
	end

    -- Patient was cured! Show cured dialogue
    local curedChapters = characterConditions.callFunc(levelSpecialConditionChaptersFuncName, game.levelNumber, 'cured')
    if curedChapters ~= nil then
        local chosenCuredChapter = getHighestPriorityValidLevelChapter(curedChapters)
        if chosenCuredChapter ~= nil then
            displaySpeechFromChapter(chosenCuredChapter)
        end
    end
end

---@param message Message
local function onGamePhaseChanged(message)
    if destroyed then
        return
    end

    local phase = message.data.gamePhase
	if phase == nil then
		error('No phase data in gamePhase message!')
	end
    if phase == 'planning' then
        -- If this character has something to say, say it!
        -- The chosen dialogue will depend on the text and conditions defined in the characterConditions Mod script
        showConditionalSpeech()
    else
        hideSpeechUI()
    end
end

log:log('NarrativeCharacter lua started with character conditions: ' .. tostring(characterConditions))

tags.addTag('NarrativeCharacter')
owner.tags.addTag('NarrativeCharacter')

owner.bus.subscribe('state.MapObject', onMapObjectStateChanged)
owner.bus.subscribe('state.patient', onPatientStateChanged)
game.bus.subscribe('gamePhase', onGamePhaseChanged)