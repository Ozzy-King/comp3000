LoadFacility('Messaging') -- for subscribe() and send()
LoadFacility('Objects') -- for GetObjectById()
LoadFacility('Entities') -- for (2) getBusById()
LoadFacility('Map') -- for finding neighbours by listener (for listeners listening for 'administer')

remedy = 'Pills'

function onResponse(responseMsg)
    if 'success' == responseMsg.data.result then
        print('I was successfully applied and was consumed') -- TODO: Be consumed!
        destroyObject() -- TODO: destroyObject()
    end
end

function applyRemedyTo(recipientId)
    -- A few options on how this could 'feel'

    -- 1. direct function calling
    local recipient = getModById(recipientId)
    local result = recipient.administer(remedy) -- TODO: Figure out how viable this is (calling arbitrary methods on arbitrary objects)
    print('administering '.. remedy ..' resulted in', result)
    if result then
        -- TODO: Be consumed!
        owner.destroyObject()
    end

    -- 2. targeted message sending: (DONE)
    recipient = getBusById(recipientId)
    recipient.send({ action = 'administer', remedy = remedy }, onResponse)

    -- 3. global bus:
    -- bus.send({ to = recipientId, action = 'administer', remedy = remedy }, onResponse)
end

function onAction(msg)
    if 'act' == msg.data.action then
        local idOfNeighbourNeedingCuring = getFirstNeighbourListeningFor('administer') -- TODO: Get neighbouring tiles
        if nil ~= idOfNeighbourNeedingCuring then
            applyRemedyTo(idOfNeighbourNeedingCuring)
        end
    end
end

bus.subscribe('action', onAction)
