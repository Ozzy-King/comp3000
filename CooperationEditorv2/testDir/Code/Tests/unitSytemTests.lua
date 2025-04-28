local game = LoadFacility('Game')['game'] or error('No game');
local owner = owner or error('No owner');

local Log = require('Log')
local log = Log.new()

local function vatPowerToNumber() 
	local tempVatOBJ = owner.map.getFirstObjectTagged('PowerVAT');
	local tempVatOBJNum = tonumber(string.sub(tempVatOBJ.name, 4, #tempVatOBJ.name))/10;
	return tempVatOBJNum;
end



--to check that the lever gets changed on interaction
local yellowLeverState = owner.map.getFirstObjectTagged('Yellow').name;
local redLeverState = owner.map.getFirstObjectTagged('Red').name;
local LeverCheckRed = false;
local LeverCheckYellow = false;

--check the down doors get checked when lever interacts
local yellowDoor1State = owner.map.getFirstObjectTagged('YellowWallDown').gridPosition;
local redDoor1State = owner.map.getFirstObjectTagged('RedWallDown').gridPosition;
local DoorCheckDownRed = false;
local DoorCheckDownYellow = false;

--check the up doord get changed when lever interacts
local yellowDoor2State = owner.map.getFirstObjectTagged('YellowWall').gridPosition;
local redDoor2State = owner.map.getFirstObjectTagged('RedWall').gridPosition ;
local DoorCheckUpRed = false;
local DoorCheckUpYellow = false;

--testing conveyor belts throuhg un carriable test obj
local exHeadPos = owner.map.getFirstObjectTagged('testingHead').gridPosition;
exHeadPos[1] = exHeadPos[1] + 1; 
local headInPlace =false;

local exArmPos = owner.map.getFirstObjectTagged('testingLeg').gridPosition;
exArmPos[1] = exArmPos[1] - 1; 
local armInPlace =false;

local exLegPos = owner.map.getFirstObjectTagged('testingArm').gridPosition;
exLegPos[1] = exLegPos[1] + 1; 
local legInPlace =false;

local exTorsoPos = owner.map.getFirstObjectTagged('testingTorso').gridPosition;
exTorsoPos[1] = exTorsoPos[1] - 1;
local torsoInPlace =false;

--testing power bucket functionality
local powerAfterBucket = vatPowerToNumber() + 2
local powerBuckAddCheck = false;

--crates dispense arms
local headCrate = owner.map.getFirstObjectTagged('headCrate');
local headDispenseCheck = (nil ~= owner.map.getFirstTagged(headCrate.gridPosition, 'head'));

local torsoCrate = owner.map.getFirstObjectTagged('torsoCrate');
local torsoDispenseCheck = (nil ~= owner.map.getFirstTagged(torsoCrate.gridPosition, 'torso'));

local armCrate = owner.map.getFirstObjectTagged('armCrate');
local armDispenseCheck = (nil ~= owner.map.getFirstTagged(armCrate.gridPosition, 'arm'));

local legCrate = owner.map.getFirstObjectTagged('legCrate');
local legDispenseCheck = (nil ~= owner.map.getFirstTagged(legCrate.gridPosition, 'leg'));

-- teleport testing check if item is on other teleporter -- teleporter1
local teleporter1 = owner.map.getFirstObjectTagged('teleporter1')
local teleport1Check = false; --teleport 1 got to teleport 2;
local teleporter2 = owner.map.getFirstObjectTagged('teleporter2')
local teleport2Check = false; --teleport 2 got to teleport 1;

--check all vat levels get changed
local vatcheck = {
	[0]=false,
	[1]=false,
	[2]=false,
	[3]=false,
	[4]=false,
	[5]=false,
	[6]=false,
	[7]=false,
	[8]=false,
	[9]=false,
	[10]=false,
	[11]=false,
	[12]=false,
	[13]=false,
	[14]=false,
	[15]=false,
	[16]=false,
	[17]=false,
	[18]=false,
	[19]=false,
	[20] = false
}

--Unit tests
local function bodyPartCrateDispense() 
	torsoDispenseCheck = (nil ~= owner.map.getFirstTagged(headCrate.gridPosition, 'torso'));

	torsoDispenseCheck = (nil ~= owner.map.getFirstTagged(torsoCrate.gridPosition, 'torso'));

	armDispenseCheck = (nil ~= owner.map.getFirstTagged(armCrate.gridPosition, 'arm'));

	legDispenseCheck = (nil ~= owner.map.getFirstTagged(legCrate.gridPosition, 'leg'));
end

local function yellowLeverPullTest()
	local newLeverDown = owner.map.getFirstObjectTagged('Yellow');
	if nil ~= newLeverDown then
		if newLeverDown.name ~= yellowLeverState then
			LeverCheckYellow = true;
		end
	end
end

local function redLeverPullTest()
	local newLeverDown = owner.map.getFirstObjectTagged('Red');
	if nil ~= newLeverDown then
		if newLeverDown.name ~= redLeverState then
			LeverCheckRed = true;
		end
	end
end

local function vatDepletTest()
	local tempVatNum = vatPowerToNumber();
	vatcheck[tempVatNum] = true;
end

local function conveyorMoveTest()
	local tempObj1 = owner.map.getFirstObjectTagged('testingArm').gridPosition;
	local tempObj2 = owner.map.getFirstObjectTagged('testingLeg').gridPosition;
	local tempObj3 = owner.map.getFirstObjectTagged('testingHead').gridPosition;
	
	--test torso new pos
	local newTorso = owner.map.getFirstObjectTagged('testingTorso').gridPosition;
	if tostring(newTorso[1]) == tostring(exTorsoPos[1]) and tostring(newTorso[2]) == tostring(exTorsoPos[2]) then
		torsoInPlace = true;
	end
	
	--test head new pos
	local newHead = owner.map.getFirstObjectTagged('testingHead').gridPosition;
	if tostring(newHead[1]) == tostring(exHeadPos[1]) and tostring(newHead[2]) == tostring(exHeadPos[2]) then
		headInPlace = true;
	end
	
	--test leg new pos
	local newLeg = owner.map.getFirstObjectTagged('testingLeg').gridPosition;
	if tostring(newLeg[1]) == tostring(exLegPos[1]) and tostring(newLeg[2]) == tostring(exLegPos[2]) then
		legInPlace = true;
	end
	
	--test arm new pos
	local newArm = owner.map.getFirstObjectTagged('testingArm').gridPosition;
	if tostring(newArm[1]) == tostring(exArmPos[1]) and tostring(newArm[2]) == tostring(exArmPos[2]) then
		armInPlace = true;
	end
end

--system tests

local function powerBucketAddsPower()
	--have to add backet in planning phase to properly test that 2 power points do get added
	if vatPowerToNumber() == powerAfterBucket then
		powerBuckAddCheck = true;
	end
	
	--update what it should be next if the power depleted without power bucket beign added
	powerAfterBucket = vatPowerToNumber() + 2
end

local function yellowLeverDoorTest()
--yellowDoor1State
	if nil ~= owner.map.getFirstTagged(yellowDoor1State, "YellowWall") then
		DoorCheckDownYellow = true;
	end

	if nil ~= owner.map.getFirstTagged(yellowDoor2State, "YellowWallDown") then
		DoorCheckUpYellow = true;
	end
end

local function redLeverDoorTest()
	if nil ~= owner.map.getFirstTagged(redDoor1State, "RedWall") then
		DoorCheckDownRed = true;
	end
	if nil ~= owner.map.getFirstTagged(redDoor2State, "RedWallDown") then
		DoorCheckUpRed = true;
	end
end

local function teleportTest()
	if nil ~= owner.map.getFirstTagged(teleporter1.gridPosition, 'part') then
		teleport2Check = true;
	end
	if nil ~= owner.map.getFirstTagged(teleporter2.gridPosition, 'part') then
		teleport1Check = true;
	end
end


local function onGamePhaseChanged()
	waitMilliSeconds(2500);
	
	bodyPartCrateDispense();
	
	conveyorMoveTest();
	yellowLeverPullTest();
	redLeverPullTest();
	
	yellowLeverDoorTest();
	redLeverDoorTest();
	
	powerBucketAddsPower();
	vatDepletTest();
	
	teleportTest();
	
	log:log('tester >> yellow lever pulls \t\t>>>>\t ' .. tostring(LeverCheckYellow));
	log:log('tester >> down yellow door goes up \t\t>>>>\t ' .. tostring(DoorCheckDownYellow));
	log:log('tester >> up yellow door goes down \t\t>>>>\t ' .. tostring(DoorCheckUpYellow));		
	
	log:log('tester >> red lever pulls \t\t\t>>>>\t ' .. tostring(LeverCheckRed));
	log:log('tester >> down red door goes up \t\t>>>>\t ' .. tostring(DoorCheckDownRed));
	log:log('tester >> up red door goes down \t\t>>>>\t ' .. tostring(DoorCheckUpRed));

	for i = 0, 20, 1 do
		log:log('tester >> can vat reach power level ' .. i .. ' \t>>>>\t ' .. tostring(vatcheck[i]));
	end

	log:log('tester >> conveyor east worked \t\t>>>>\t ' .. tostring(headInPlace));
	log:log('tester >> conveyor north worked  \t\t>>>>\t ' .. tostring(armInPlace));
	log:log('tester >> conveyor west worked  \t\t>>>>\t ' .. tostring(torsoInPlace));
	log:log('tester >> conveyor south worked  \t\t>>>>\t ' .. tostring(legInPlace));
	log:log('tester >> power bucket added to power  \t>>>>\t ' .. tostring(powerBuckAddCheck));
	
	log:log('tester >> torso crate dispenses  \t\t>>>>\t ' .. tostring(torsoDispenseCheck));
	log:log('tester >> head crate dispenses  \t\t>>>>\t ' .. tostring(headDispenseCheck));
	log:log('tester >> arm crate dispenses  \t\t>>>>\t ' .. tostring(armDispenseCheck));
	log:log('tester >> leg crate dispenses  \t\t>>>>\t ' .. tostring(legDispenseCheck));
	
	log:log('tester >> teleport 1 can teleport  \t\t>>>>\t ' .. tostring(teleport2Check));
	log:log('tester >> teleport 2 can teleport  \t\t>>>>\t ' .. tostring(teleport1Check));
	
end

game.bus.subscribe('gamePhase', onGamePhaseChanged);
