-- GameManagerLua
-- Monitors for `patient.cured`, counts patients remaining and finishes the level once all done.
-- Finishes the level by sending the `level.won` message.

-- Bring in the ability to subscribe to the GameManager's message bus for game phase changes
-- local gameFacility = LoadFacility('Game')
----print('loading gameFacility via require')
----local gameFacility = require('Game')
--print('gameFacility:', gameFacility)
--print('gameFacility[game]:', gameFacility['game'])
--local game = gameFacility['game']
---@type Game
local game = LoadFacility('Game')['game']

local subscriptionHelper = require('SubscriptionHelper').new(game.bus)

local NarrativeSaveDataKeys = require('NarrativeSaveDataKeys')

local Log = require('Log')
local log = Log.new()

-- Start music
game.bus.send({ metadata = { 'playMusic' }, data = { soundName = 'CoOperationLevelMusic' } }, false)

local numPatientsAtStart = 0
local numPatientsCured = 0
local numPatientsDied = 0

local sentEndingMessage = false

---@type string
local currentGamePhase

---@type boolean
local managementPhaseChecked = false

local function getNumPatientsRemaining()
	local iterator = game.map.getAllObjectsTagged('patient')
	-- This gives an iterator so we iterate it and count how many there are
	local count = 0
	for _ in iterator do
		count = count + 1
	end
	return count
end

local function checkEnding()
	if numPatientsAtStart == 0 then
		return
	end

	local numPatientsRemaining = getNumPatientsRemaining()
	local allPatientsCuredOrDied = ((numPatientsDied + numPatientsCured) >= numPatientsAtStart)

	log:log('Checking for level end: Found ', numPatientsRemaining, ' patients remaining. All were cured/died: ', allPatientsCuredOrDied)
	if 0 >= numPatientsRemaining and allPatientsCuredOrDied then

		-- Save data that will need to be accessed by lua scripts in the results level
		game.saveData.setNumber('patientsDied', numPatientsDied)
		game.saveData.setNumber('patientsCured', numPatientsCured)
		-- Mark level as completed in save data, used by narrative system to determine whether certain dialogue will be shown
		game.saveData.setNumber(NarrativeSaveDataKeys.global_levelXCompleted(game.levelNumber), 1)
		if numPatientsDied == 0 then
			-- Level completed with all patients cured!
			game.saveData.setNumber(NarrativeSaveDataKeys.global_levelXAllCured(game.levelNumber), 1)
		end
		game.saveData.save()

		-- Note: There is currently no distinction between 'winning' or 'losing' a level.
		--	either way, a results level will be loaded where players can choose whether to replay or continue to the next level
		if false == sentEndingMessage then
			sentEndingMessage = true
			--Ensure no more messages are received
			subscriptionHelper:unsubscribeAll()
			local wonMessage = { metadata = { 'level.won' }, data = { patientsCured = numPatientsCured, patientsTotal = numPatientsAtStart } }
			local lostMessage = { metadata = { 'level.lost' }, data = { patientsCured = numPatientsCured, patientsTotal = numPatientsAtStart } }
			local didWin = numPatientsCured > numPatientsDied;
			local endingMessage = didWin and wonMessage or lostMessage
			log:log('All patients done: ', numPatientsCured, ' cured, ', numPatientsDied, ' died = Finishing the level with ', endingMessage)
			game.bus.send(endingMessage)
			-- Trigger loading of the results level after win/loss
			log:log('GameManager.lua sending `level.results`!')
			game.bus.send({'level.results'})
		else
			error('GameManager.lua tried to send `level.won` twice!') --This was causing the level end soft hang! Implication is Lua VM is not reentrant under async!
		end
	else
		log:log('Level still in-progress')
	end
end

local function onPatientCured()
	numPatientsCured = numPatientsCured + 1
	checkEnding()
end

local function onPatientDied()
	numPatientsDied = numPatientsDied + 1
	checkEnding()
end

local function onGamePhaseChanged(message)
	local phase = message.data.gamePhase
	if phase == nil then
		error('No phase data in gamePhase message!')
	end
	log:debug('currentGamePhase:(', currentGamePhase, '->', phase, ')')
	currentGamePhase = phase
end

local function onGetNextGamePhase(_)
	if not managementPhaseChecked then
		managementPhaseChecked = true
		-- Check if we should enter the management phase on level start
		local itemVoteManagement = owner.map.getFirstObjectTagged('ItemVoteManagement')
		if itemVoteManagement and itemVoteManagement.hasFunc('canEnterManagementPhase') and itemVoteManagement.callFunc('canEnterManagementPhase') then
			-- Management (item voting) phase should take place!
			log:log('GameManager lua says: to go management phase!')
			return { gamePhase = 'management' }
		end
	end

	if currentGamePhase == 'management' then
		-- We're in the management phase, so switch to management results next
		log:log('GameManager lua says: to go managementResults phase!')
		return { gamePhase = 'managementResults' }
	end

	-- Otherwise, game phases continue with the default planning/acting loop
	log:log('GameManager lua giving no response to getNextGamePhase (continue with default planning/acting loop)')
end

numPatientsAtStart = getNumPatientsRemaining()
log:log('Found ', numPatientsAtStart,' patients at start')

subscriptionHelper:registerSubscription('patient.cured', onPatientCured)
subscriptionHelper:registerSubscription('patient.died', onPatientDied)
subscriptionHelper:registerSubscription('gamePhase', onGamePhaseChanged)
subscriptionHelper:registerSubscription('getNextGamePhase', onGetNextGamePhase)

--Do all the subscriptions
subscriptionHelper:subscribeAll()
