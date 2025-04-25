-- Patient health and ailment
LoadFacility('Messaging')

need = 'pills'
health = 5
print('Patient ' ..self.. ' has ' ..health.. ' health and needs ' ..need)

function onAdminister(msg)
    remedy = msg.data.remedy
    if remedy == need then
        print('Cured')
        return {result='cured'}
    else
        print('Wrong remedy!')
        return {result='wrong'}
    end
end

bus.subscribe('administer', onAdminister)
