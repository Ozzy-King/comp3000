-- CoOperation Clipboard mod

local Log = require('Log')
local log = Log.new()

---@type MapObject
local owner = owner or error('No owner')

owner.tags.addTag('Clipboard')

---@type boolean
local isVisible = true

---Set the visibility of this clipboard.
---Externally called.
---@param newVisible boolean
function setVisible(newVisible)
    if isVisible == newVisible then
        return
    end

    isVisible = newVisible
    log:debug('Clipboard set visible: ', newVisible)
    owner.bus.send({visible = newVisible}, nil, false)
end

---Externally called.
function wrongMedicineAdministered()
    if isVisible then
        owner.bus.send({'highlightWrongMedicine'}, false) -- Do not require receiver since not present without View
    end
end

setVisible(false)
