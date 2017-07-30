-- Year264
-- Author: ionescuc
-- DateCreated: 7/27/2017 11:20:57 AM
--------------------------------------------------------------
--264BCE pop-up
function HideEnd()
	Controls.RomanVictory:SetHide(true);
end

function ShowEnd()
	Controls.RomanVictory:SetHide(false);
end
HideEnd();
bShown = false;--boolean value to make sure that around264BCe there will be a pop-up, even though the game skips the year because of teh speed
				--helps so that if I put >= it won't pop-up multiple times after that 
function checkYear()

	if(Game.GetGameTurnYear() >= -264 and bShown == false) then
		bShown = true;
		ShowEnd();
	end;
end

Events.ActivePlayerTurnStart.Add(checkYear);
Controls.EndOK:RegisterCallback(Mouse.eLClick,HideEnd);