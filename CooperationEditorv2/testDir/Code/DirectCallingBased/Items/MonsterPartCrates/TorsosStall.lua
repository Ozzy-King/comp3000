local game = LoadFacility('Game')['game'] or error('No game')
local loader = game.loader or error('No loader')
local owner = owner or error('No owner')

local item = 'monsterTorso'

-- Crates new item in same place as crate
local function dispenseArm()
	loader.instantiate(item, owner.gridPosition)
	print("spawned new  " .. item)
end

--Creates new item when removed
local function onSiblingRemoved()
	print(item .. " removed from dispenser")
	dispenseArm()
end

-- Tells game to run this code when owned item has transferred ownership
owner.bus.subscribe('siblingRemoved', onSiblingRemoved)

--Crates item when game is first run
dispenseArm()