-- Bring in the ability to subscribe to the GameManager's message bus for game phase changes
---@type Game
local game = LoadFacility('Game')['game']
---@type MapMobile
local owner = owner or error('No owner')

print('Scoreboard lua script started')

local patientIterator = game.map.getAllObjectsTagged('patient')
-- This gives an iterator so we iterate it and count how many there are
local patientsAtStart = 0
for _ in patientIterator do
	patientsAtStart = patientsAtStart + 1
end

-- Counters
-- The number of patients who lost all health
local patientsDied = 0
-- The number of patients waiting to be cured/yet to appear
local patientsWaiting = patientsAtStart
-- The number of patients who were cured
local patientsCured = 0

print('Scoreboard - patients waiting at start: ' .. patientsWaiting)

local addDiedCounterMsg = { metadata = { 'addCounter' }, data = { counterName = "died", value = patientsDied } }
local addWaitingCounterMsg = { metadata = { 'addCounter' }, data = { counterName = "waiting", value = patientsWaiting } }
local addCuredCounterMsg = { metadata = { 'addCounter' }, data = { counterName = "cured", value = patientsCured } }
owner.bus.send(addDiedCounterMsg, nil, false)
owner.bus.send(addWaitingCounterMsg, nil, false)
owner.bus.send(addCuredCounterMsg, nil, false)

local function onPatientCured(message)
	local patientPos = message.data.position;

	print('Scoreboard onPatientCured')

	patientsCured = patientsCured + 1
	patientsWaiting = patientsWaiting - 1

	local setCuredCounterMsg = { metadata = { 'setCounter' }, data = { counterName = 'cured', value = patientsCured, originPos = patientPos } }
	owner.bus.send(setCuredCounterMsg, nil, false)

	local setWaitingCounterMsg = { metadata = { 'setCounter' }, data = { counterName = 'waiting', value = patientsWaiting } }
	owner.bus.send(setWaitingCounterMsg, nil, false)
end

local function onPatientDied(message)
	local patientPos = message.data.position;

	print('Scoreboard onPatientDied with pos ' .. tostring(patientPos))

	patientsDied = patientsDied + 1
	patientsWaiting = patientsWaiting - 1

	local setDiedCounterMsg = { metadata = { 'setCounter' }, data = { counterName = 'died', value = patientsDied, originPos = patientPos } }
	owner.bus.send(setDiedCounterMsg, nil, false)

	local setWaitingCounterMsg = { metadata = { 'setCounter' }, data = { counterName = 'waiting', value = patientsWaiting } }
	owner.bus.send(setWaitingCounterMsg, nil, false)
end

local function onGamePhaseChanged(message)
    local phase = message.data.gamePhase
	if phase == 'finished' then
		return
	end

	-- Hide scoreboard in management results phase
    if phase == 'managementResults' then
		owner.bus.send({ visible = false }, nil, false)
    else
        owner.bus.send({ visible = true }, nil, false)
    end
end

-- subscribe to know when a patient is cured/loses all health
owner.bus.subscribe('patientCured', onPatientCured)
owner.bus.subscribe('patientDied', onPatientDied)
game.bus.subscribe('gamePhase', onGamePhaseChanged)
