--have not tested but should work
--need to update images too so thier inthe correct place

---@type MapMobile
local owner = owner or error('No owner')

---@type Game
local game = LoadFacility('Game')['game']

function AdamOnGameEnd(win)
	local temp = {0, 0};

	if(win == 0) then
		game.loader.instantiate('AdamEndBillBoardLose', owner.gridPosition);
	else
		game.loader.instantiate('AdamEndBillBoardWin', owner.gridPosition);
	end
	
	waitMilliSeconds(2000);
	--this should end the level and move on to the next one
	game.bus.send({'level.next'});
end

--in other scripts use:
	--require('AdamGameEnd')

--and use this function to end game:
	-- 0 = lose, 1 = win
	--AdamOnGameEnd(<win state>);