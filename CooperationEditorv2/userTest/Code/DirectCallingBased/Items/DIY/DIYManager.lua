---Centralises all DIY customisations, persisting as they are done and restoring on returning to a DIY'd map.

local DIYUtils = require('DIYUtils')
local Log = require('Log')
local log = Log.new()

---@type Game
local game = LoadFacility('Game')['game']

---Maps position to customisation name at that position.
---@type table<string, string>
local posToCustomisationMap = {}

---@param doSync boolean @ Defaults to true
local function persist(doSync)
	local customisations = json.serialize(posToCustomisationMap)
	log:debug('Persisting customisations: ', customisations)
	game.saveData.setString('DIY', customisations)
	if nil == doSync or doSync then
		game.saveData.save()
	end
end

---@param pos Pos
---@param name string
---@param doSync? boolean @ Defaults to true
local function updateAndPersist(pos, name, doSync)
	--N.b. Was intended to be externally called but had problems so switched to bus-based
	posToCustomisationMap[json.serialize(pos)] = name
	log:debug('Updated posToCustomisationMap: ', posToCustomisationMap)
	persist(doSync)
end

---Decodes message, updates the tile and persists.
---@param message Message
---@return void
local function onUpdateTile(message)
	log:debug('onUpdateTile: ', message)

	--Decode pos
	local pos = message.data['pos']
	if nil == pos then
		local x = message.data['x']
		local y = message.data['y']
		if nil == x or nil == y then
			log:error('No pos or x/y in message: ', message)
			return
		end

		pos = { x, y }
	end

	--Retrieve colour from message
	local colour = message.data['colour']
	log:debug('Updating tile at ', pos, ' to ', colour)

	--Do actual work
	updateAndPersist(pos, colour)
end

---@return boolean @ Whether customisations were loaded
local function loadCustomisations()
	local customisationsJson = game.saveData.getString('DIY')
	if nil == customisationsJson or '' == customisationsJson then
		log:debug('No customisations to apply')
		return false
	end

	log:debug('Loaded customisations: "', customisationsJson, '"')
	posToCustomisationMap = --[[---@type table<string, string>]] json.parse(customisationsJson)
	return true
end

---Loads customisations saved in previous visits to this map and re-applies them.
local function restoreCustomisations()
	if not loadCustomisations() then
		return
	end

	---@type Pos, string
	for posString, name in pairs(posToCustomisationMap) do
		log:debug('Applying customisation ', name, ' at ', posString)
		local pos = --[[---@type Pos]] json.parse(posString);
		DIYUtils.restyle(pos, name)
	end
end

--MAIN

--Set-up tag for others to find us
owner.tags.addTag('DIYManager')
tags.addTag('DIYManager')

--Listen to persist messages from others
owner.bus.subscribe('updateTile', onUpdateTile)

--Apply previously saved customisations
restoreCustomisations()
