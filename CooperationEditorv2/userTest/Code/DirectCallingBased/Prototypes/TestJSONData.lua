
-- A variable you want to overwrite from settings JSON
patientNumber = patientNumber or 1
print('patient number is ', patientNumber)

theAnswer = theAnswer or "unknown"
otherStuff = otherStuff or {subValue = "also unset"}

print('The answer is ', theAnswer)
print('other stuff is "' .. tostring(otherStuff) ..'"')
-- print('which as JSON is: ' .. json.serialize(otherStuff) ..'"')
print('other stuff.subValue is "' .. tostring(otherStuff.subValue) ..'"')
