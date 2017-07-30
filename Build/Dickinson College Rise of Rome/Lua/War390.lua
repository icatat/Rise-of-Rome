-- War390
-- Author: ionescuc
-- DateCreated: 7/12/2017 1:24:55 PM
--------------------------------------------------------------

--global varibales use for the entire file
pPlayer = Game.GetActivePlayer();
player = Players[pPlayer];
--gauls = Players[6];
teamGauls = Teams[6];--get the gauls ( cannot do it as a player must be done as a team)
teamRome = Teams[1];--get Rome
bWar = false;--boolean that checks whether the war happened, so that we avoid additional invasions
		--mostly used to make sure that w have a war around 390BCE, in case the speed that we are playingt the game at does not allow us to reach exactly -390

--the indexes can change in the game if they get changed in world builder.
--there is a risk, when playing without our map and scenario, that some teams might declare war on anothers
--I did not consider this a big problem, since we are suppossed to play it with the map
--there is also a risk that it might make it crash hen played without the map

--Geese po-up
function HideGeese()
	Controls.Geese:SetHide(true);
end

function ShowGeese()
	Controls.Geese:SetHide(false);
end

--hide the geese pop-up initially
HideGeese();

--this method gets called 
function war()
	local year = Game.GetGameTurnYear();
	print(year);

	if(year >= -390 and bWar == false)then
		--for testing purposes only
		print(teamGauls:CanDeclareWar(1));
		print(teamGauls:GetName());
		print(teamRome:GetName());
		---------------------------
		bWar = true;--make the boolean true so that we don't have multiple invasions
		if(Players[Game.GetActivePlayer()]:GetName() == "L. Iunius Brutus") then--check if we are playing Rome; if we are not playing rome the Geese pop-up won't show up at all
			ShowGeese();
		end;

		teamGauls:DeclareWar(1);--Gauls delcare war om Rome

		--Place the units the the specified indexes ( I assigned them somehow random)
		--in the future I can get fancy and create a random function that I can call multiple times an do someath and  place them there--some other time
		local unit1 = gauls : InitUnit(GameInfoTypes["UNIT_SENONES_PHALANX_WARRIOR"], 23, 28);
		local unit2 = gauls : InitUnit(GameInfoTypes["UNIT_SENONES_PHALANX_WARRIOR"], 22, 27);
		local unit3 = gauls : InitUnit(GameInfoTypes["UNIT_SENONES_PHALANX_WARRIOR"], 21, 27);
		local unit4 = gauls : InitUnit(GameInfoTypes["UNIT_SENONES_PHALANX_WARRIOR"], 20, 26);

	end

end


Controls.GeeseOK:RegisterCallback(Mouse.eLClick,HideGeese);--the geese button does not do anything but closing the pop-up
Events.ActivePlayerTurnStart.Add(war);--we want to check whether is the Year of war every turn
