--- Throw mod
local Log = require('Log')
local log = Log.new()

local SearchType = require('SearchType')

local DirectionUtils = require('DirectionUtils')

---@type MapMobile
local owner = owner or error('No owner')

-- Bring in the ability to subscribe to the GameManager's message bus for game phase changes
local game = LoadFacility('Game')['game']

-- Action called by the 'throw' action from the 'phone' controller
function throw(throwDirection)
    log:debug('Throwing getting actor from owner:', owner)
    ---@type CoOpActor
    local coOpActor = owner.getFirstComponentTagged('CoOpActor', SearchType.SelfOnly)
    log:log('Modding throwing ', throwDirection, ' for owner:', owner, ' with actor:', coOpActor)

    if nil == throwDirection or not DirectionUtils.isDirection(throwDirection) then
        log:error('Invalid direction supplied: ', throwDirection)
        return false
    end

    local carrier = owner.getFirstComponentTagged('carrier');
    local carriedObj = carrier.getCurrentlyCarried()
    --print(carriedObj);
    if nil ~= carriedObj then
        if carriedObj.owner.tags.hasTag('heavy') then
            game.bus.send({ metadata = { 'player.actionFailed' }, data = { position = owner.gridPosition, direction = throwDirection } }, false)
            game.bus.send({ metadata = { 'playSound' }, data = { soundName = 'InvalidAction' } }, false)
            owner.bus.send({ 'player.actionFailed' }, false)
            return false
        end
    end

    local result = coOpActor.throwInDirection(throwDirection)
    -- only return a value if we succeeded (so other things can be tried otherwise)
    -- This is provisional = not yet finalised approach -- might change to false means try others
    if result then
        return true -- TODO-20221104: Needs updating to check whether carrying first, if so, always handled by this since can now throw to no-catcher
    else
        game.bus.send({ metadata = { 'player.actionFailed' }, data = { position = owner.gridPosition, direction = throwDirection } }, false)
        game.bus.send({ metadata = { 'playSound' }, data = { soundName = 'InvalidAction' } }, false)
        owner.bus.send({ 'player.actionFailed' }, false)
    end
end

log:debug('Throw mod ready')
