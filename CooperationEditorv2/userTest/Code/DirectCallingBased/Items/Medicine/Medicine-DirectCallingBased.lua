---Medicine mod.
---Handles administering medicine to a patient in the direction that the player is facing

-- Bring in the ability to use the GameManager's message bus
---@type MapMobile
local owner = owner or error('No owner')
---@type Game
local game = LoadFacility('Game')['game']
local CarryHelper = require('CarryHelper')
local NarrativeSaveDataKeys = require('NarrativeSaveDataKeys')

-- Set-up the remedy if not supplied by JSON data
---@type string
local remedy = remedy or 'pills'

owner.tags.addTag('medicine')

---@param patientMapObject MapMobile | MapObject
---@return boolean
local function applyRemedyTo(patientMapObject)
    -- Call directly or get the component tagged 'patient' then directly call 'canAdministerRemedy'
    local patient = --[[---@type Mod]] patientMapObject.getFirstComponentTagged('patient')
    if nil == patient then
        print('No patient on patient')
        return false
    end

    -- 1. IDEAL but DOES NOT _YET_ WORK (might with future Lua runtime modifications)
    -- local result = patient.canAdministerRemedy(remedy)

    -- 2. What we started with = works but leaks abstractions like a sieve
    local canAdminister = patient.callFunc('canAdministerRemedy', remedy)

    -- 3. works and looks a little wonky -- disabled 2023/11
    --local canAdminister = patient['canAdministerRemedy'](remedy)

    -- 4. Also works which is quite nice. N.b. MapObject rather than Component
    -- local result = patientMapObject['canAdministerRemedy'](remedy)

    print('trying to administer ' .. remedy .. ' resulted in', json.serialize(canAdminister))
    if canAdminister and canAdminister.result == 'success' then
        -- TODO: Be consumed! (or could have multiple uses by keeping local count)
        local ownerPos = owner.gridPosition;
        owner.destroyObject()
        -- We can administer our remedy - cure the patient!
        patient.callAction('cure', ownerPos)
        print('I was successfully applied and was consumed')
        return true
    else
        print('I was not the right thing to apply here')

        -- Play 'Wrong Medicine' sound effect
        game.bus.send({ metadata = { 'playSound' }, data = { soundName = 'WrongMedicine' } }, false)

        -- Notify clipboards on the same tile as the patient that wrong medicine was given
        local clipboards = owner.map.getAllTagged(patientMapObject.gridPosition, 'Clipboard')
        for clipboard in clipboards do
            clipboard.callAction('wrongMedicineAdministered')
        end

        patient.callAction('givenWrongRemedy')

        return false
    end
end

local function administer()
    -- Try administering to first active patient in facing tile
    local patientsInFacingDir = owner.getFacingObjectsTagged('patient')
    for patient in patientsInFacingDir do
        if patient ~= nil and patient.hasFunc('isActive') and patient.callFunc('isActive') then
            return applyRemedyTo(patient)
        end
    end
    return false
end

---External function called when acting with carried item
function actWhenCarried(carrierOwner, carrier, actDirection)
    assert(nil ~= carrierOwner, 'No carrierOwner')
    assert(nil ~= carrier, 'No carrier')
    assert(nil ~= actDirection, 'No actDirection')

    -- If there is empty floor with nothing blocking us, drop the medicine
    if CarryHelper.placeDownIfClearInFront(carrierOwner, carrier, actDirection) then
        if remedy == 'pills' then
            -- Smashed pills!
            -- Save data - used for conditional narrative text
            local playerComponent = carrierOwner.getFirstComponentTagged('Player')
            assert(playerComponent ~= nil, 'No Player component on player owner MapObject')
            game.saveData.setNumber(NarrativeSaveDataKeys.thisRound_didPlayerDropPills(), 1)
            game.saveData.setString(NarrativeSaveDataKeys.global_mostRecentPillDropPlayer(), playerComponent.playerName)
            game.saveData.save()
        end
        -- Medicine is destroyed when dropped on the ground
        owner.destroyObject()
        return true
    end

    -- There's no empty floor or could not put down, try administering the medicine instead
    return administer()
end

---Shrunk by a Shrink Ray
local function onSiblingShrunk(_)
    -- Medicine breaks/is destroyed when a sibling (dispenser) shrinks
    owner.bus.send({ 'medicine.smashed' }, nil, false)
    owner.destroyObject()
end

owner.bus.subscribe('sibling.shrunk', onSiblingShrunk)
