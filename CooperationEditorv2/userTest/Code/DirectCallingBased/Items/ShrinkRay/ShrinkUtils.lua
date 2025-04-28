local Log = require('Log')
local log = Log.new()

---@class ShrinkUtils
local ShrinkUtils = {}

---@param mapObject MapObject
---@return boolean
function ShrinkUtils.objectCanBeShrunk(mapObject)
	if not mapObject.tags.hasTag('shrinkable') then
        -- Object is not shrinkable
        return false
    end
    if mapObject.callFunc('getIsShrunk') then
        -- Object is already shrunk
        return false
    end
    if mapObject.hasFunc('canBeShrunk') and (not mapObject.callFunc('canBeShrunk')) then
        -- canBeShrunk() returned false on object, so shrinking is not allowed
        return false
    end
    return true
end

return ShrinkUtils
