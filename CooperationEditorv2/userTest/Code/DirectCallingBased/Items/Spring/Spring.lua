---Called externally when springing a patient into the air
---Externally called.
---@type fun()
function springing()
    -- View plays bounce animation on receiving springing msg
    owner.bus.send({'springing'}, nil, false)
end
