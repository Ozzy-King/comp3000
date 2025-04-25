print('Testing component access')
LoadFacility('ComponentAccess')
local avatar = getFirstComponentTyped('PlayerDoctor')
if avatar == nil then
    error("No Avatar (PlayerDoctor)")
end
print('Calling doAction')
avatar.doAction()
