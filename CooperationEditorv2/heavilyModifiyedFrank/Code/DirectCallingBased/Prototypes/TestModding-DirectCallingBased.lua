-- Used to test mod loading and running
LoadFacility('Messaging')
print 'TestModding: Hi!'
-- LoadFacility('Movement')
LoadFacility('Throw')
LoadFacility('Action')

-- require('DirectionUtils')
-- print('Direction West =', Direction.West)

-- TODO: This is no longer used -- I'm in the process of moving all this to separate scripts!

if 'throw' == action then
    print('Modding throwing', direction)
    -- TODO: Switch from throw(direction) to below:
    local thrower = owner.getFirstComponentTagged("thrower", SearchType.SelfOnly)
    print('Found thrower ', thrower)
    -- thrower.throwIn(direction)
    throw(direction) -- TODO: Remove and switch to above
else
    print('Unknown message', json.serialize(msg))
end
