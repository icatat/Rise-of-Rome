-- Conquering
-- Author: ionescuc
-- DateCreated: 7/21/2017 2:13:56 PM
--------------------------------------------------------------
--------------------------------------------------------------

--Global Variables needed for the entire file
pPlayer = Game.GetActivePlayer(); -- givs the index of the active player
player = Players[pPlayer];--gets the actual active player object


--------------------------------------------------------------

--Hide the Puppet Pop-Up( the one that appears at the end of the turn when you conquer a city)
function HidePuppet()
	Controls.puppet:SetHide(true);
end
--Show Puppet Popup
function ShowPuppet()
	Controls.puppet:SetHide(false);
end


--Hide Municipium Popup (the one that appears 10 years after a municipium has been created)
function HideMunicipium()
	Controls.Municipium:SetHide(true);
end
--Show Municipium Popup
function ShowMunicipium()
	Controls.Municipium:SetHide(false);
end

--Initially both must be Hidden
HidePuppet();
HideMunicipium();






---------------------------------------------------------------
---------------------------------------------------------------
--this function gets called ONLY after you have conquered a city
--When a conquring happened, save the turn number into iTurn->this will make sure that the conditions in the Conquer() function don't get executed multiple times
--helps you check whether the player chose to annex the city or chose to puppet it(this is why the Conquered() function must be called at the end of a turn)
--accordingly to what the player chose, the consequences will be different
function Check()
--globar variables to keep track of how mnay times the rest of the functions get executed
	iTurn = Game.GetGameTurn();--start turn ( used for comparison further on)
	Events.ActivePlayerTurnEnd.Add(Conquer);--at the end of the turn call conquer()
end

--conquering function
--Even hough is called at the end of every turn, it has an effect only if the player conquered the city in the specific turn, otherwis, this function will basically do nothing
--checks everyturnwhether a conquering happened
function Conquer()

	local iCities = player:GetNumCities();--get total number of cities: need this values o that we always tackle the last city added to Cities(), which would be the last once taken over by the active player
	local tempTurn = Game.GetGameTurn();--get the current turn 
	pCity = player:GetCityByID(iCities - 1);--last city added;make it a global variable so that we can use it in other functions: Municipium(), Civitas(), Colonie()
	
	--for testing purposes only ( it cheks to see the status of the newly conquered city
	print("last city: ",pCity : GetName(), " is puppet: " ,  pCity:IsPuppet());
	print("last city: ",pCity : GetName(), " is annexed: " ,  pCity:IsOccupied());
	print("last city: ",pCity : GetName(), " is razing: " ,  pCity:IsRazing());


	--check the state of the most recently conquered city(pCity)
	--if the turn in which is conquered is the same as the current turn, then we want the POP-UP at the end of the turn
	--this check helps us avoid the window popping-up at the end of every turn
	--since iTurn is a globalvariable, it will get modified ONLY when another conquering occurs, thus preventing the puppet from appearing if there is no conquering in that turn
	--thus it is very important that iTurn is the same as the current turn ( so basically, that I conquered something this exact turn), otherwise, if they are not equal, nothing will come up
	--this is important because the function Conquer() gets called at the end of every turn, and if we don't check this, we will have a pop up every time
	if(pCity : IsPuppet() and tempTurn == iTurn ) then
			local cityName = pCity:GetName();--get the name of the most recently conquered city

			--this section puts the name of the city into the pop-up
			--look into the GameText.XML. You will find all thos tags in there. The tags name does not have to match with the ones in the Conquering.xml, because they basically replace them
			--in the GameText.xml you will see that the text assign to this tags contains {1_cityName}. As a General rule, wehave cityNAme between{} because they have to match the name of the variable
			Controls.Conquered:LocalizeAndSetText("TXT_KEY_TEST_DIALOG_PUPPET_CONQUERED", cityName);--change the text name
			Controls.Victory:LocalizeAndSetText("TXT_KEY_TEST_DIALOG_PUPPETTING_CONQUERED", cityName);--change the title
			Controls.Puppet1:LocalizeAndSetText("TXT_KEY_TEST_DIALOG_PUPPET_1_MUNI",cityName);--first button(Municipium)
			Controls.Puppet2:LocalizeAndSetText("TXT_KEY_TEST_DIALOG_MUNICIPIUM_CIVITAS_CITY",cityName);--second button(Civitas...)
			Controls.Puppet3:LocalizeAndSetText("TXT_KEY_TEST_DIALOG_MUNICIPIUM_COLONIZE_CITY",cityName);--third button(Colonie)
			
			Controls.puppet:SetHide(false);--show up the window so that the player can choose between the above options

	elseif(pCity:IsOccupied() and tempTurn == iTurn) then -- this cheks whether the city was annexed this current turn
			Annexed(pCity);--annex the city ( does not actually annex the city but modifes it's name so that we keep everything consisttent)
			dropEconomy(4);--drops the economy.Basically builds 4 temple of Mars ( -5 production and -5 gold, totals up to -20 production and -20 gold each turn if the player annexes early). You can change the value if you think that is too much or to little. You can also change the Yields for the temple of Mars( be careful that there are 2, for dropping the economy, change the yield of the first one)
	end
	
end

--this function will run at the beginning of every single turn
--it runs thorugh all the cities that a player owns, then it checksthe status of it , and the year in which the city's status was last modified
--if it meets any of the required conditions, it might get modified again, if not, nothing happens
function checkCities()
	local cityName;--delcard here so that we don't have to declare it all the time ( sometimes I try to be efficient...theoretically :D )
	local currentYear = Game.GetGameTurnYear();--gets the current year of the turn. It will be useful when comparing the status of each city and the year it was last modified
	local myCity = player:GetCapitalCity();--gets the capital of my civilization. It is helpful when placing a building, modifieding Yieldds. Especially useful for Civitas, when gifting units

	--iterate through the entire cities that a player owns
	for cityIndex = 0, player : GetNumCities() - 1 do
		
		local city = player : GetCityByID(cityIndex);--get the city at the specified index( there might be a way of getting the exact city without indexing, but it was giving me some null pointers
		cityName = city:GetName();--get the name of each city in the game
		words = {};--initialize an empty table
		--NOTE: when a city is conquered, its name gets changed under the following scheme: city name*STATUS*YEAR
		--the following function breaks the name when it meets the symbol "*"
		--it will store all the words to word{} array declared above
		--for each "*" the function will assign an empty space in the array ( this is why the indexes that have actual words are all odd numbers)
		for w in cityName:gmatch("([^*]*)") do table.insert(words, w) end
		--the structure will be as it follows: words[1] - original name(works whether it is 1,2,..n words) 
											--words[3]-the status ( Municipium, Civitas, COnquered)
											--words[5]-the year
		--for each city, checks the status
		print(words[3]);
		if(city:IsPuppet()) then --if the computer sees the city as a puppet, then it must have either a Municipium attached to the name, or a Civitas + the year when it became the form of governing
			if(words[3] == "Municipium" and tonumber(words[5]) <= ((currentYear) - 10)) then --if the puppet is a municipium, and the year when it became a Municipium 10 or more years ago ( <= because at certain speeds we might not have the exact year, and then, when the status changes it won't matter anymore)
				--iTurn  = Game.GetGameTurn();
				pCity = city;--make city a global variable, so that it can be called from other functions that can't have a paramtere( or I just didn't know how to make it with a parameter)
				pCity : ChangeBaseYieldRateFromBuildings(GameInfoTypes.YIELD_GOLD, -2);--change the base ield from (overall) buildings by -2 ( when a city becomes a municipium,it gets extra 2, so now we want to erase the benefits)
				MunicipiumHelper(words[1]);--municipium helper will just make he Municipium pop-up show, with the name of the current city(words[1]) in it
			elseif(words[3] == "Civitas")then--if it is a civitas, then we call the helper with the current year and the last year in which it was modfied, so that we see whethe it is the rigt time to be gifted a unit or not
				CivitasSineSuffragioHelper(currentYear,tonumber(words[5]),city, tonumber(words[7]));--tonumber converts a string into a number ( since the word{} is a table formed with strings, we need to convert them into numbers)
			end
		elseif(city:IsOccupied()) then--if it is occupied, we want to see whether it was like this from earlier on, or the player chose to annex it later(this is for when the player clicks on the city)
			if(words[3] ~="Conquered") then--if the name does not contain "conquered" means that it is a recently added city that must have been a Municipium or a Civitas ( if it was annexed from the very beginning, the name would have changed right away)
				if(words[3] == "Civitas") then--if it were a civitas
					saveEconomy(1);--we delete the temple of mars because we don't want any additional punishments(and we want to wncourage the player to choose annexing later on)
					Annexed(city);--we change the name
				elseif(words[3] == "Municipium") then--if it's a municipium
					city:ChangeBaseYieldRateFromBuildings(GameInfoTypes.YIELD_GOLD, -2);--we take the bonus back-sorry
					Annexed(city);--change the name
				end
			end
		end
	end
end



------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------

--Creating a Municipium
--Gets called when the player clicks on the Municipium button in the Puppet pop-up

function Municipium()
	HidePuppet();--hide puppet
	local municipiumName = pCity:GetName().."*Municipium*"..Game.GetGameTurnYear();--create the new name of the municipium : helps us identify the type of conquering
	pCity : SetName(municipiumName,true);--set the new name of the conquered city
	pCity : ChangeBaseYieldRateFromBuildings(GameInfoTypes.YIELD_GOLD, 2);--give a gold bonus from the buildings in the conquered city(they will have a bonus every single turn, until their status changes)

end


--Municipium Helper
-- it gets called only when the population of a city got angry(triggered in the checkCities() function)
function MunicipiumHelper(cityName)
		print(cityName);--for testing purposes
		--As explained above (see Conquer() function) it puts the name of the city in the pop-up boxes
		Controls.MunicipiumCivitas:LocalizeAndSetText("TXT_KEY_TEST_DIALOG_MUNICIPIUM_CIVITAS_CITY",cityName);
		Controls.MunicipiumColonize:LocalizeAndSetText("TXT_KEY_TEST_DIALOG_MUNICIPIUM_COLONIZE_CITY",cityName);
		Controls.MunicipiumFree:LocalizeAndSetText("TXT_KEY_TEST_DIALOG_MUNICIPIUM_FREE_CITY",cityName);
		Controls.Question:LocalizeAndSetText("TXT_KEY_TEST_DIALOG_MUNICIPIUM_CITY", cityName);
		ShowMunicipium();--shows the municipium with the customized names
end

--Creating Civitas Sine Suffragio
--Gets called when the player presss the button Civitas
function CivitasSineSuffragio()
	HidePuppet();--hide puppet (first) pop-up in case this is the player's first option
	HideMunicipium();--hide municipium (second) pop-up in case this is the player's second option, after a Municipium
	local words = {};--empty array that will store the words separated by "*" in the name 
	local cityName = pCity:GetName();--get cities name
	for w in cityName:gmatch("([^*]*)") do table.insert(words, w) end--get the words in the name separated by "*";
	local units = 0;--this is additional for civitas, so that we keep track of how many cities we gifted; this will be alternat from 0 to 1; the point is to avoid giving two units in case two turns have the same year; after a a unit if gifted, at the end of the name it will be a 1; the 1 will change into a zero when the year changes	
				
	local civitasName = words[1].."*Civitas*"..Game.GetGameTurnYear().."*"..tonumber(units);--create the new name of the municipium : helps us identify the type of conquering
	pCity : SetName(civitasName,true);--set the new name of the conquered city
	dropEconomy(1);--drop the economy by placing 1 temple of mars in my capital(mars has -5 production and -5 gold )
end

--Gets called only from the Conquer() function
--since Civitas SIne Suffragio is efined by giving the the capital one unit, this is help check whether ther have been 10 years since the last time
--a unit was gifted and whether there are more then 30 year cinve the city is mine
--current years: tells the year of the turn

function CivitasSineSuffragioHelper(currentYear, civitasYear, city, gifts)

--gets the name
	words = {};
	local cityName = city:GetName();
	for w in cityName:gmatch("([^*]*)") do table.insert(words, w) end
	local playerInitPlot = player : GetCapitalCity():Plot();--get the capital plot, where I will place my new unit
	
	if(currentYear - civitasYear <= 30 and (currentYear - civitasYear) % 10 == 0 and gifts == 0 ) then--check if it's been 10 years since the last gift and whether it's been 30 years since it became a civitas
		local unit = player : InitUnit(GameInfoTypes["UNIT_ROMAN_LEGION"], playerInitPlot : GetX(), playerInitPlot : GetY());--place a roman legion in the capital
		local gift = 1;--set the last number to 1, sothat we know we gifted something this year
		local civitasName = words[1].."*Civitas*"..words[5].."*"..gift;--create the new name of the municipium : helps us identify the type of conquering
		city : SetName(civitasName,true);--set the new name of the conquered city
	elseif(currentYear - civitasYear > 30 or (currentYear - civitasYear) % 2 ~= 0 and gifts == 1) then--if the year changed, then we change the value from 1 to 0, so that w can gift later
		local gift = 0;--set the last number back to 0 if the year changed
		local civitasName = words[1].."*Civitas*"..words[5].."*"..gift;--create the new name of the municipium : helps us identify the type of conquering
		city : SetName(civitasName,true);--set the new name of the conquered city

	end
end


--Creating a Colonie
function Colonie()
	HidePuppet();--hide puppet pop-up in case this is the player's first option
	--procedure listed above
	local words = {};
	local cityName = pCity:GetName();
	for w in cityName:gmatch("([^*]*)") do table.insert(words, w) end
	--colonie helper they are separate because the colonie helper get's called in the Conquer()function as well) when the second window pops-up, though I am not surewhether it is a neccesirty or not anymore
	ColonieHelper(pCity, words[1]);
end



--Helper for the Colonie Helper
function ColonieHelper(pColonie, cityName)
	HideMunicipium();--hide municipium (second) pop-up in case this is the player's first option
	
	
	local colonieName = cityName.."*Colonia*"..Game.GetGameTurnYear();--create the new name of the municipium : helps us identify the type of conquering
	local cityPlot = pColonie:Plot();--get the location of the city so that we can establish a settler
	player: Disband(pColonie);--get rid of the city from the map
	player: AddCityName(colonieName);--we add the clonie name in the game, so that when we create a colonie, this is the one that will show up ( otherwise, we would get a city that has no name)
	local city = player : InitCity(cityPlot : GetX(), cityPlot : GetY());--initialize the new city
	dropEconomy(2);--drops the economy ( I was not sure whether it is a mistake or not)
	--local unit = player : InitUnit(GameInfoTypes["UNIT_SETTLER"], cityPlot : GetX(), cityPlot : GetY());--set a settler
end




--Creating an Annexed City
--bassically just changes the name of the city so that it contains conquered i it
function Annexed(city)
	--NOTE: used "Conquered" just because it sounds better in this context
	--same procedure as above
	local words = {};
	local cityName = city:GetName();
	for w in cityName:gmatch("([^*]*)") do table.insert(words, w) end
	local annexedName = words[1].."*Conquered*"..Game.GetGameTurnYear();--create the new name of the municipium : helps us identify the type of conquering
	city : SetName(annexedName);--rename the city accordingly
end

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

--Helper function
--drops the economy by the specified amount( the amount tells how many temples of mars will be built in the city
function dropEconomy(amount)
		local myCity = player : GetCapitalCity();--get the capital
		--local turn = Game.GetGameTurn();
		--if(iTurn == turn) then
			myCity:SetNumRealBuilding(GameInfoTypes["BUILDING_TEMPLE_MARS"], amount);--place the specifice number of buildings in the city
		--end
end

--Balances the dropEconomy function, restoring the total production of teh capital
--just opposite the dropEconomy function
--helps one regain the losts ( used when going from Civitas to Annexed)
function saveEconomy(amount)
		local myCity = player : GetCapitalCity();--get the capital
		--local turn = Game.GetGameTurn();
		myCity:SetNumRealBuilding(GameInfoTypes["BUILDING_TEMPLE_MARS_SAVE"], amount);
		
end



--------------------------------------------------------------------------------------------------------------------------

--frees the municipium
--if the original owner of the icty is still alive, it will give it back as a NEW city(so lower production and population etc for them as well)
--if the original owner is not alive anymore, than it will just disband the city ( it won't be on the map anymore)
--NOTE:could not force a razing

function MunicipiumFree()
	HideMunicipium();
	local owner = pCity:GetOriginalOwner();--get the original owner index
	local pOwner = Players[owner];--get the original owner

	--same procedure(we don't want to give them back a city that ha s"Municipium" in the name( NOTE:this will happen though when the city gets conquered)
	local cityName = pCity:GetName();
	local words = {};
	for w in cityName:gmatch("([^*]*)") do table.insert(words, w) end
	local ownerName = pOwner:GetName();--get the name of the original owner
	local cityPlot = pCity:Plot();--get the city's plot so that we can place a new one on the same place
	player: Disband(pCity);--get rid of the city

	if (pOwner : IsAlive()) then -- of the original owner is still alve, than give him a new cty with the same name NOTE:could not make it wrk without disbanding the city first
		pOwner:AddCityName(words[1]);--add the name of the city to that player's list, so that when we create a city, it will have the same name (othewise it will just be an empty name)
		local city = pOwner : InitCity(cityPlot : GetX(), cityPlot : GetY());--place the city in the original position
	end

	
end




--assign a function to the UI elements
Controls.Puppet1:RegisterCallback(Mouse.eLClick, Municipium);--first option
Controls.Puppet2:RegisterCallback(Mouse.eLClick, CivitasSineSuffragio);--second option
Controls.Puppet3:RegisterCallback(Mouse.eLClick, Colonie);--third option

Controls.MunicipiumCivitas:RegisterCallback(Mouse.eClick, CivitasSineSuffragio);
Controls.MunicipiumColonize:RegisterCallback(Mouse.eClick, Colonie);
Controls.MunicipiumFree:RegisterCallback(Mouse.eClick, MunicipiumFree);


--register events
GameEvents.CityCaptureComplete.Add(Check);--when a city is captured, check to see whether it was puppetted or annexed ( maybe even razed, but that's kind of ignored)

Events.ActivePlayerTurnStart.Add(checkCities);