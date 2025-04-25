-- CoOperation Bed mod
-- Bring in the ability to subscribe to the GameManager's message bus for game phase changes
---@type Game
local game = LoadFacility('Game')['game']
---@type MapObject
local owner = owner or error('No owner')

local Log = require('Log')
local log = Log.new()

---@type Loader
local loader = game.loader or error('No loader')

local MessageHelpers = require('MessageHelpers')

---@type number
local spawnClipboards = spawnClipboards or 1

---@type string
local acceptsPatientTagged = acceptsPatientTagged or "adultPatient"

---@type boolean
local updatingClipboards = false

---@type boolean
local isVisible = true

-- Called externally to check if the bed is visible
---@return boolean
function getIsVisible()
    return isVisible
end

--- Called externally by CarryHelper.endIntoAcceptorMapObject
--- to check if a MapObject can be placed into this bed
---@return boolean
---@param mapObject MapObject
function canAccept(mapObject)
    if not mapObject.tags.hasTag('patient') then
        -- Beds only accept patients
        return false
    end
    return mapObject.tags.hasTag(acceptsPatientTagged)
end

---@return MapObject|nil
local function getPatientInBed()
    -- Returns first active patient in the same tile as this bed (or nil)
    local patients = owner.map.getAllTagged(owner.gridPosition, 'Patient')
    for patient in patients do
        if patient['isActive']() then --TODO: Switch to patient.callFunc('isActive')
            return patient
        end
    end
    return nil
end

local function destroyAllClipboards()
    local clipboards = owner.map.getAllTagged(owner.gridPosition, 'Clipboard')
    for clipboard in clipboards do
        clipboard.destroyObject()
    end
end

---@param patientAdded boolean
local function updateClipboards(patientAdded)
    updatingClipboards = true

    -- Destroy any existing clipboards before adding new one
    destroyAllClipboards()

    if spawnClipboards == 0 then
        return
    end

    if not patientAdded then
        -- No patient, no clipboard needed
        return
    end

    local patientInBed = getPatientInBed()
    if patientInBed ~= nil then
        -- Patient in bed, add a clipboard showing their needed medicine type
        local patientNeed = patientInBed['getNeed']()
        local newClipboard = loader.instantiate('ui_' .. patientNeed, owner.gridPosition)
        newClipboard['setVisible'](true)
        --TODO: Switch above 3 lines to:
        --local patientNeed = patientInBed.callFunc('getNeed')
        --local newClipboard = loader.instantiate('ui_' .. patientNeed, owner.gridPosition)
        --newClipboard.callAction('setVisible', true)
    end

    updatingClipboards = false
end

---@param _ Message
local function onUpdateClipboards(_)
    updateClipboards(true)
end

---@param newVisible boolean
local function setVisible(newVisible)
    log:debug('Bed set visible:', newVisible)
    owner.bus.send({visible = newVisible}, nil, false)
    isVisible = newVisible
end

-- Called externally by Shrinkable to check if this object can be shrunk
---@return boolean
function canBeShrunk()
    -- Beds can only be shrunk when not occupied
    return getPatientInBed() == nil
end

---@param message Message
local function onSiblingAdded(message)
    local addedObj = MessageHelpers.getMapObjectViaIdFromMessage(message, 'siblingAdded')
    if addedObj.tags.hasTag('patient') then
        -- Patient added to the same tile as this bed
        local player = owner.map.getFirstTagged(owner.gridPosition, 'player')
        if player ~= nil then
            -- Patient is with player, not in bed
            return
        end
        log:debug('Bed patient added - updating clipboards')
        updateClipboards(true)
    end
end

---@param message Message
local function onSiblingRemoved(message)
    if not updatingClipboards then
        log:debug('Bed sibling removed - updating clipboards')
        updateClipboards(false)
    end
end

---@param _ Message
local function onPatientCuredInBed(_)
    -- Bed becomes not visible when a patient is cured in it
    -- (patient cannot be placed in invisible bed)
    setVisible(false)
end

---@param message Message
local function onGamePhaseChanged(message)
    local phase = message.data.gamePhase;
    log:debug('Game phase: "', phase, '"')
    if phase == 'planning' then
        -- Ensure bed is visible at the beginning of each round
        setVisible(true)
        return
    end
end

owner.bus.subscribe('patientCured', onPatientCuredInBed)
owner.bus.subscribe('siblingAdded', onSiblingAdded)
owner.bus.subscribe('siblingRemoved', onSiblingRemoved)
owner.bus.subscribe('updateClipboards', onUpdateClipboards)
game.bus.subscribe('gamePhase', onGamePhaseChanged)
