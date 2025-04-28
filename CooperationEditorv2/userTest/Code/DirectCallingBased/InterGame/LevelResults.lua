-- Bring in the ability to subscribe to the GameManager's message bus for game phase changes
local game = LoadFacility('Game')['game']

local Log = require('Log')
local log = Log.new()

log:log('LevelResults lua script started')

-- Play 'Menu' music in results levels
game.bus.send({ metadata = { 'playMusic' }, data = { soundName = 'MenuMusic' } }, false)

-- Get saved values from the level that was just played
local patientsDied = game.saveData.getNumber('patientsDied')
local patientsCured = game.saveData.getNumber('patientsCured')
local totalPatients = patientsDied + patientsCured

-- Display some text in the UI letting players know their 'score' (number of patients cured)
game.bus.send({
	displayText = 'You helped\n' .. patientsCured .. ' out of ' .. totalPatients .. '\npatients!\n\nMove your characters to choose what to do next.',
	displayType = 'messageDisplayUI.left'
}, nil, false)

-- Also show some info on the 'ticker' that displays scrolling text
game.bus.send({displayText = '- Move to make your choice. Majority wins! -', displayType = 'ticker'}, nil, false)

local function onGamePhaseChanged(message)
	local phase = message.data.gamePhase;
	if phase ~= 'planning' then
        return
    end

	log:log('LevelResults - planning phase: Checking player positions')

	local nextLevelVotes = 0
	local replayLevelVotes = 0
	local players = owner.map.getAllObjectsTagged('player')

	for player in players do
		if owner.map.getFirstTagged(player.gridPosition, 'NextLevel') ~= nil then
			nextLevelVotes = nextLevelVotes + 1
		elseif owner.map.getFirstTagged(player.gridPosition, 'ReplayLevel') ~= nil then
			replayLevelVotes = replayLevelVotes + 1
		end
	end

	log:log('(next: ', nextLevelVotes, ', replay: ', replayLevelVotes, ')')
	if 2 > nextLevelVotes and 2 > replayLevelVotes then
		log:log('Need more than 2 players to vote for the same option (next: ', nextLevelVotes, ', replay: ', replayLevelVotes, ')')
		return
	end

	if nextLevelVotes > replayLevelVotes then
		log:log('Majority of players want to continue, loading next level')
		game.bus.send({'level.next'})
	elseif replayLevelVotes > nextLevelVotes then
		log:log('Majority of players want to replay, reloading level')
		game.bus.send({'level.reload'})
	else
		log:log('Players have not yet reached a consensus')
	end
end

-- subscribe to get informed when game rounds start
game.bus.subscribe('gamePhase', onGamePhaseChanged)
