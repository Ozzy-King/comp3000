-- Used to test mod loading and running
print 'TestModding: Hi!'
-- require('messaging') -- TODO: Switch from LoadFacility to require once loading available
LoadFacility('Messaging')
LoadFacility('Movement')
LoadFacility('Throw')
LoadFacility('Action')

-- require('DirectionUtils')
-- print('Direction West =', Direction.West)

function onAction(msg)
    action = msg.data.action
    direction = msg.data.direction
    if 'move' == action then
        print('Modding moving', direction)
        move(direction)
    elseif 'throw' == action then
        print('Modding throwing', direction)
        throw(direction)
    elseif 'action' == action then
        print('Modding action')
        doAction()
    else
        print('Unknown message', json.serialize(msg))
    end
end

bus.subscribe('action', onAction)
