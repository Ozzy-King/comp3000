---Item in the shop, yet to be bought.

local FieldHelper = require('FieldHelper')

---@type MapObject
local owner = owner or error('No owner')
---@type Game
local game = LoadFacility('Game')['game']
---@type string
local buyableName = buyableName or error("ShopItem MUST HAVE a 'buyableName' supplied as data")
---@type number
local cost = cost or 5

local CoinDisplay = require('DisplayCostByCoinsLogic')
local V3 = require('Vector3')

local Log = require('Log')
local log = Log.new()

---@type boolean
local bought = (0 ~= game.saveData.getNumber(buyableName)) or false

local function announce(txt)
    log:debug('announce:"', txt, '"')
    game.bus.send({
        displayText = '       '.. txt ..'                   ... ',
        displayType = 'ticker'
    }, nil, false)
end

local function notifyAllBuyables()
    log:debug('notifying')

    -- First, pull all into an array since modifying enumerable will cause exception
    local array = {}
    for o in owner.map.getAllObjectsTagged('buyable') do
        table.insert(array, o)
    end

    -- Now notify everything
    for o in array do
        o.bus.send({'purchase'})
    end
end

---Coins previously displayed (which need tidying before redisplaying)
---@type MapObject?
local coinsDisplayed

---@param orig table
---@return table
local function cloneCoin(orig)
    ---@type table
    local clone = {}
    for k, v in pairs(orig) do
        clone[k] = v
    end
    return clone
end

---@return void
local function updateCoinDisplay()
    --Remove any previously displayed coins
    if nil ~= coinsDisplayed then
        log:debug('Destroying old coins: ', coinsDisplayed)
        coinsDisplayed.destroyObject()
    end
    coinsDisplayed = nil

    if 0 >= cost then
        return
    end

    --Determine new coins to display
    local coinIndices = CoinDisplay:getIndicesFromCost(cost)
    log:debug('coin indices required:', coinIndices)

    ---Get the definitions and extract the art parts.
    ---Each entry is an array of models.
    ---@type any[][]
    local arts = {}
    for i = 1, #CoinDisplay.numToCoinPrefabMap do
        local prefabName = CoinDisplay:getPrefabByIndex(i)
        local levelObject = game.loader.getDefinition(prefabName)
        table.insert(arts, --[[---@type any[] ]] levelObject.art3d)
    end

    --Add them
    local positions = CoinDisplay:getPositionForNumberOfCoins(#coinIndices)
    local artParts = {}
    for i, prefabNumber in ipairs(coinIndices) do
        -- For each element of the array, we need to add our position
        for _, artPrefab in ipairs(arts[prefabNumber]) do
            local art = cloneCoin(artPrefab)
            local posOrig = V3.new(art.pos);
            -- TODO: Make this work without workaround: art.pos = posOrig + positions[i]
            local pos = posOrig + positions[i]
            art.pos = { x = pos.x, y = pos.y, z = pos.z }
            table.insert(artParts, art)
        end
    end
    local levelObject = {
        mapObject = "Custom",
        art3d = artParts,
        name = 'CoinsDisplay=' .. cost,
        --tags = { 'billboard' },
        --data = { billboardType = 'VerticalOnly' }
        tags = { 'rotate' },
        data = { eulerSpeeds = { y = 45 } }
    }

    log:debug('Creating coins for ', owner.name, ' at ', owner.gridPosition, ' from ', levelObject)
    coinsDisplayed = game.loader.instantiate(levelObject, owner.gridPosition)
    log:debug('Created ', coinsDisplayed)
end

---Externally called function, called from ShopCoin.tryPay()
---@param value number
---@return boolean true if fully paid, false if still more to pay.
function pay(value)
    log:log('paid ', value,' for ', buyableName)
    cost = cost - value
    if 0 >= cost then
        log:log('all paid!')
        owner.destroyObject()
        updateCoinDisplay() -- removes coin display
        game.saveData.setNumber(buyableName, 1)
        FieldHelper.callFuncOnFirstMapObjectTagged('ShopMoneyManager', 'finalisePayment', true)
        ---announce('Use the: ' .. buyableName .. ' to shrink objects in an adjacent tile!')
        announce('Use the: Shrink-Prod to shrink objects in an adjacent tile!')
        notifyAllBuyables()
        return true
    end

    -- else update the "remaining cost" indicator
    ---announce('Withdraw ' .. cost .. ' and interact with the '.. buyableName ..'. It can shrink objects in an adjacent tile!')
    announce('Withdraw ' .. cost .. ' and interact with the Shrink-Prod. It can shrink objects in an adjacent tile!')
    updateCoinDisplay()
    return false
end

if bought then
    owner.destroyObject()
else
    updateCoinDisplay()
end
