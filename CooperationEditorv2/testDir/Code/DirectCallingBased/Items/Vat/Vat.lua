--local AdamPowerChecker = require('AdamPowerChecker') --Gives access to the powerLevel variable
local CarryHelper = require('CarryHelper')

---@type Game
local game = LoadFacility('Game')['game']
---@type MapObject
local owner = owner or error('No owner')

---@param powerBucket MapObject
function addPowerBucket(powerBucket)
    print('Sibling added to Vat.')
    if powerBucket ~= nil and powerBucket.tags.hasTag('powerBucket') then
        local adamManagerObj = owner.map.getFirstObjectTagged('am')
        local directCallResult = adamManagerObj['addToPower']()
        powerBucket.destroyObject()
        adamManagerObj['updateVatModel']()
        --powerLevel = powerLevel + 1 --Possibly need CarryHelper.powerLevel
    end
end