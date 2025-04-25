-- game manager script
---@type MapMobile
---@type Game
local game = LoadFacility('Game')['game'] or error('No game');
local owner = owner or error('No owner');

local Log = require('Log')
local log = Log.new()

--get the current vata value on map
-- set to 11 as one get removed at the begining
local tempVatOBJ = owner.map.getFirstObjectTagged('PowerVAT');
local tempVatOBJNum = tonumber(string.sub(tempVatOBJ.name, 4, #tempVatOBJ.name))/10;
---@type number
local powerLevel = tempVatOBJNum; --get vat number
local start = true;

powerLevelModels = {
    [1] = "VAT0",
    [2] = "VAT10",
    [3] = "VAT20",
    [4] = "VAT30",
    [5] = "VAT40",
    [6] = "VAT50",
    [7] = "VAT60",
    [8] = "VAT70",
    [9] = "VAT80",
    [10] = "VAT90",
    [11] = "VAT100",
    [12] = "VAT110",
    [13] = "VAT120",
    [14] = "VAT130",
    [15] = "VAT140",
    [16] = "VAT150",
    [17] = "VAT160",
    [18] = "VAT170",
    [19] = "VAT180",
    [20] = "VAT190",
    [21] = "VAT200"
};

local function CreateText(theText)
    game.bus.send({
        metadata = {'textNotificationUI.createOrUpdate'},
        data = {
            id = "test",
            titleTextKey = "frankenstien",
            mainTextKey = theText,
            iconName = 'Icon_Avatar_Player1'
        }
    }, nil, false)
end

-- adds power to scoreboard
local addPowerCounterMsg = {
    metadata = {'addCounter'},
    data = {
        counterName = "powerIcon",
        value = powerLevel
    }
}
owner.bus.send(addPowerCounterMsg, nil, false)

function addToPower()
    powerLevel = powerLevel + 2
end

function getPower()
    return powerLevel;
end

local function onGamePhaseChanged(message)

    -- checks and checks the message of current phase
    local phase = message.data.gamePhase;
    log:log('inside the calling of adma charge manager phase: ' .. phase);
	
	--if start of game dont decrememtn counter
	if start == true then
		start = false;
		return
	end
    -- if acting then return
    if phase ~= 'planning' then
        -- if not in planning return
        return
    end

    -- remove power update scoreboard count and update model
    powerLevel = powerLevel - 1;

    updateVatModel()

    if powerLevel <= 0 then
        -- this goes to the next level, found by myles
		log:log('ended levelss');
        game.bus.send({'level.reload'});
        log:log('game reloaded');
    end

    -- reduce power number by one
    return
end

function updateVatModel()
    log:log('the power level is' .. powerLevel);
    CreateText('the power is at ' .. tostring(powerLevel))
    -- set the power message to new value
	log:log('seting power message')
    local setPowerCounterMsg = {
        metadata = {'setCounter'},
        data = {
            counterName = 'powerIcon',
            value = powerLevel
        }
    }
    owner.bus.send(setPowerCounterMsg, nil, false)
	
	log:log('checking power level')
    -- checks and correct number if in or out of bounds
    local newModelIndex = powerLevel + 1
    if newModelIndex > #powerLevelModels then
        newModelIndex = #powerLevelModels
    end
    if newModelIndex <= 0 then
        newModelIndex = 1
    end
	
	log:log('changeing vat model')
    -- the the vat models gridPosition
    local VATOnMap = owner.map.getFirstObjectTagged('PowerVAT');
    if owner.map.getFirstObjectTagged('PowerVAT') ~= nil then
        local modelPos = VATOnMap.gridPosition
        game.loader.instantiate(powerLevelModels[newModelIndex], modelPos)
        VATOnMap.destroyObject()
    end
end

game.bus.subscribe('gamePhase', onGamePhaseChanged);
