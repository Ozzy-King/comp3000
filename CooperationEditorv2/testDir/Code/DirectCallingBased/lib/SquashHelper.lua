---Utilities for squashing

local SquashHelper = {}

---@param owner MapObject
---@param tag string
---@param funcName string
local function callFuncOnAllWithTagAtOwnerPos(owner, tag, funcName)
    local squashables = owner.map.getAllTagged(owner.gridPosition, tag)
    for squashable in squashables do
        -- Don't call func on self!
        if squashable ~= owner then
            if squashable.hasFunc(funcName) then
                squashable.callAction(funcName)
            else
                print("No '" .. funcName .. "' found on " .. tostring(squashable))
            end
        end
    end
end

---@param owner MapObject
function SquashHelper.squashSquashablesAtOwnerPosition(owner)
    -- Call squash() on all MapObjects tagged as 'squashable' on the same tile as the owner MapObject
    callFuncOnAllWithTagAtOwnerPos(owner, 'squashable', 'squash')
end

---@param owner MapObject
function SquashHelper.respawnSquashedAtOwnerPosition(owner)
    -- Call respawnFromSquashed() on all MapObjects tagged as 'squashed' on the same tile as the owner MapObject
    callFuncOnAllWithTagAtOwnerPos(owner, 'squashed', 'respawnFromSquashed')
end

return SquashHelper
