---Provides static methods to do DIY (restyle tiles, walls, floors, etc).

---@type Game
local game = LoadFacility('Game')['game'] or error('No game')

local Regex = LoadFacility('Regex')['Regex'] or error('No Regex')

---@type Loader
local loader = game.loader or error('No loader')

local TableUtils = require('TableUtils')

local Log = require('Log')
local log = Log.new()

local PatternToAffect = Regex('floor|wall|tile', 1) -- case insensitive

local ColourRegex = Regex('White|Black|Blue|Green|Red|Purple', 1)

---Returns an updated name and whether succeeded.
---@param origName string @ The original name from the `objectDefinitions`, e.g. "f_White_Tile".
---@param newColour string @ The updated name, e.g. "f_Blue_Tile".
---@return string, boolean
local function changeColour(origName, newColour)
	local newName = ColourRegex.Replace(origName, newColour)
	--log:debug('Changed colour from ', origName, ' to ', newName)
	if origName ~= newName then
		return newName, true
	end

	--TODO: Try other things to change colour
	return origName, false
end

---@class DIYUtils
local DIYUtils = {}

---Restyles all applicable objects at the given position.
---Externally called.
---@param pos Pos
---@param colour string
---@return boolean @ Whether anything was changed.
function DIYUtils.restyle(pos, colour)
	local all = TableUtils.iteratorToArray(owner.map.getAllAt(pos))
	local matchFound = false
	for o in all do
		log:debug('Checking ', o)
		if PatternToAffect.IsMatch(o.name) then
			log:debug('Matched on ', o)
			local newName, succeeded = changeColour(o.name, colour)
			if succeeded then
				log:debug('Swapping ', o, ' for ', newName)
				if loader.hasObject(newName) then
					matchFound = true
					local newInstance = loader.instantiate(newName, pos)
					log:debug('Created ', newInstance, ' with id:', newInstance.id, '. Destroying old ', o)
					o.destroyObject()
				else
					log:debug('No objectDefinition for "', newName, '"')
				end
			else
				log:debug('No style change for ', o)
			end
		end
	end
	if not matchFound then
		log:debug('No match found')
		return false
	else
		return true
	end
end

return DIYUtils
