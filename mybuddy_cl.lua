local showbotmenu = true
mybot = nil --LIER A LA BASE DE DONNEES...
local mybothashmodel = GetHashKey('player_zero') --LIER A LA BASE DE DONNEES...
local currentcar --LIER A LA BASE DE DONNEES...
local driveorder = false
local trytoseat = true
skinmenu = false
local bliproute = nil
local closestshop = nil

Citizen.CreateThread(function ()
	while true do
	Citizen.Wait(0)
		if IsControlJustPressed(1,288) then --F1
			if showbotmenu then
				BotMenu()
				Menu.hidden = false
				showbotmenu = false
			else
				Menu.hidden = true
				showbotmenu = true
			end
		elseif IsControlJustPressed(1, 202) then --BACKSPACE
			if (showbotmenu == false) then
				BotMenu()
			end
		end
		Menu.renderGUI()
	end
end)

function drawNotification(text)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(text)
	DrawNotification(true, true)
end

Menu = {}
Menu.GUI = {}
Menu.TitleGUI = {}
Menu.buttonCount = 0
Menu.titleCount = 0
Menu.selection = 0
Menu.hidden = true
MenuTitle = "Menu"

-------------------
posXMenu = 0.1
posYMenu = 0.05
width = 0.15
height = 0.05

posXMenuTitle = 0.1
posYMenuTitle = 0.05
widthMenuTitle = 0.1
heightMenuTitle = 0.05
-------------------

function Menu.addTitle(name)

	local yoffset = 0.3
	local xoffset = 0
	
	local xmin = posXMenuTitle
	local ymin = posYMenuTitle
	local xmax = widthMenuTitle
	local ymax = heightMenuTitle

	
	Menu.TitleGUI[Menu.titleCount +1] = {}
	Menu.TitleGUI[Menu.titleCount +1]["name"] = name
	Menu.TitleGUI[Menu.titleCount+1]["xmin"] = xmin + xoffset
	Menu.TitleGUI[Menu.titleCount+1]["ymin"] = ymin * (Menu.titleCount + 0.01) +yoffset
	Menu.TitleGUI[Menu.titleCount+1]["xmax"] = xmax 
	Menu.TitleGUI[Menu.titleCount+1]["ymax"] = ymax 
	Menu.titleCount = Menu.titleCount+1
end

function Menu.addButton(name, func,args)

	local yoffset = 0.3
	local xoffset = 0
	
	local xmin = posXMenu
	local ymin = posYMenu
	local xmax = width
	local ymax = height

	
	Menu.GUI[Menu.buttonCount +1] = {}
	Menu.GUI[Menu.buttonCount +1]["name"] = name
	Menu.GUI[Menu.buttonCount+1]["func"] = func
	Menu.GUI[Menu.buttonCount+1]["args"] = args
	Menu.GUI[Menu.buttonCount+1]["active"] = false
	Menu.GUI[Menu.buttonCount+1]["xmin"] = xmin + xoffset
	Menu.GUI[Menu.buttonCount+1]["ymin"] = ymin * (Menu.buttonCount + 0.01) +yoffset
	Menu.GUI[Menu.buttonCount+1]["xmax"] = xmax 
	Menu.GUI[Menu.buttonCount+1]["ymax"] = ymax 
	Menu.buttonCount = Menu.buttonCount+1
end


function Menu.updateSelection() 
	if IsControlJustPressed(1, 8) then --RECULER
		if(Menu.selection < Menu.buttonCount -1  )then
			Menu.selection = Menu.selection +1
		else
			Menu.selection = 0
		end
	elseif IsControlJustPressed(1, 32) then --AVANCER
		if(Menu.selection > 0)then
			Menu.selection = Menu.selection -1
		else
			Menu.selection = Menu.buttonCount-1
		end
	elseif IsControlJustPressed(1, 201)  then --ENTREE
			MenuCallFunction(Menu.GUI[Menu.selection +1]["func"], Menu.GUI[Menu.selection +1]["args"])
	end
	local iterator = 0
	for id, settings in ipairs(Menu.GUI) do
		Menu.GUI[id]["active"] = false
		if(iterator == Menu.selection ) then
			Menu.GUI[iterator +1]["active"] = true
		end
		iterator = iterator +1
	end
end

function Menu.renderGUI()
	if not Menu.hidden then
		Menu.renderTitle()
		Menu.renderButtons()
		Menu.updateSelection()
	end
end

function Menu.renderBox(xMin,xMax,yMin,yMax,color1,color2,color3,color4)
	DrawRect(xMin, yMin,xMax, yMax, color1, color2, color3, color4);
end

function Menu.renderTitle()
	local yoffset = 0.3
	local xoffset = 0

	local xmin = posXMenuTitle
	local ymin = posYMenuTitle
	local xmax = widthMenuTitle
	local ymax = heightMenuTitle
	for id, settings in pairs(Menu.TitleGUI) do
		local screen_w = 0
		local screen_h = 0
		screen_w, screen_h =  GetScreenResolution(0, 0)
--		boxColor = {20,30,10,255}
		boxColor = {0,0,0,128}

		SetTextFont(0)
		SetTextScale(0.0,0.35)
		SetTextColour(255, 255, 255, 255)
		SetTextCentre(true)
		SetTextDropShadow(0, 0, 0, 0, 0)
		SetTextEdge(0, 0, 0, 0, 0)
		SetTextEntry("STRING") 
		AddTextComponentString(string.upper(settings["name"]))
		DrawText(settings["xmin"], (settings["ymin"] - heightMenuTitle - 0.0125))
		Menu.renderBox(settings["xmin"] ,settings["xmax"], settings["ymin"] - heightMenuTitle, settings["ymax"],boxColor[1],boxColor[2],boxColor[3],boxColor[4])
	end	
end

function Menu.renderButtons()
		
	for id, settings in pairs(Menu.GUI) do
		local screen_w = 0
		local screen_h = 0
		screen_w, screen_h =  GetScreenResolution(0, 0)
--		boxColor = {42,63,17,255}
		boxColor = {128,128,128,128}
		
		if(settings["active"]) then
--			boxColor = {107,158,44,255}
			boxColor = {38,38,38,255}
		end
		SetTextFont(0)
		SetTextScale(0.0,0.35)
		SetTextColour(255, 255, 255, 255)
		SetTextCentre(true)
		SetTextDropShadow(0, 0, 0, 0, 0)
		SetTextEdge(0, 0, 0, 0, 0)
		SetTextEntry("STRING") 
		AddTextComponentString(settings["name"])
		DrawText(settings["xmin"], (settings["ymin"] - 0.0125 )) 
		Menu.renderBox(settings["xmin"] ,settings["xmax"], settings["ymin"], settings["ymax"],boxColor[1],boxColor[2],boxColor[3],boxColor[4])
	 end     
end


--------------------------------------------------------------------------------------------------------------------

function ClearMenu()
	--Menu = {}
	Menu.GUI = {}
	Menu.buttonCount = 0
	Menu.titleCount = 0
	Menu.selection = 0
end

function MenuCallFunction(fnc, arg)
	_G[fnc](arg)
end

function botskin()
	skinmenu = true
	Menu.hidden = true
	showbotmenu = true
end
--------------------------------------------------------------------------------------------------------------------
function BotMenu()
	ClearMenu()
	Menu.addTitle("MyBuddy")
	Menu.addButton("Spawn","spawnbot",nil)
	Menu.addButton("Changer de skin","botskin",nil)
	Menu.addButton("Me suivre","followme",nil)
	Menu.addButton("Rester ici","stopbot",nil)
	Menu.addButton("En voiture (conducteur)","driverbot",nil)
	Menu.addButton("En voiture (passager)","passengerbot",nil)
	Menu.addButton("Conduire","DriveToMenu",nil)
	-- ...
end

function DriveToMenu()
	ClearMenu()
	Menu.addTitle("MyBuddy")
	Menu.addButton("Resto le plus proche","drivetoresto",nil) ------------------------------------------------------
	Menu.addButton("Garage le plus proche","drivetocarshop",nil) ------CREER UNE FONCTION UNIQUE "DriveTo"...-------
	Menu.addButton("Hopital","drivetohopital",nil)------------------------------------------------------------------
	-- ...
end
--------------------------------------------------------------------------------------------------------------------
--SPAWN BOT
function spawnbot()
	if bliproute ~= nil and DoesBlipExist(bliproute) then
		Citizen.InvokeNative(0x86A652570E5F25DD,Citizen.PointerValueIntInitialized(bliproute)) --SUPPRIME LA ROUTE GPS EN COURS (CREER FONCTION)
		bliproute = nil
	end
	closestshop = nil
	if DoesEntityExist(mybot) then
		Citizen.InvokeNative(0x9614299DCB53E54B, Citizen.PointerValueIntInitialized(mybot)) --SUPPRIME LE BOT ACTUELLEMENT SPAWN (CREER FONCTION)
		driveorder = false
	end
	local ploff = GetOffsetFromEntityInWorldCoords(GetPlayerPed(-1), 0.0, 2.0, 0.0)
	RequestModel(mybothashmodel)
	while not HasModelLoaded(mybothashmodel) do
		Citizen.Wait(0)
	end
	mybot = CreatePed(4, mybothashmodel, ploff.x, ploff.y, ploff.z, 10.0, true, false)
	local blip = AddBlipForEntity(mybot)
	SetBlipSprite(blip, 280)
	SetPedAsGroupMember(mybot, GetPedGroupIndex(GetPlayerPed(-1)))
	SetPedRelationshipGroupHash(mybot, GetHashKey("PLAYER")) --TEST
	SetPedNeverLeavesGroup(mybot, true)
	SetGroupSeparationRange(GetPedGroupIndex(GetPlayerPed(-1)), 4000.0)
	SetGroupFormation(GetPedGroupIndex(GetPlayerPed(-1)), 4)
	SetPedPathCanUseClimbovers(mybot, true)
	SetPedPathCanUseLadders(mybot, true)
	SetPedPathPreferToAvoidWater(mybot, false)
	SetPedCombatAttributes(mybot, 46, true)
	SetPedFleeAttributes(mybot, 0, 0) --PAS TOUJOURS VRAI...
	SetPedCanRagdoll(mybot, true)
	SetPedDiesWhenInjured(mybot, true)
	SetEntityAsMissionEntity(mybot)
--	SetPedRandomProps(mybot)
--	SetGroupFormationSpacing(groupId, p1, p2, p3)
--	TaskTurnPedToFaceEntity(mybot, GetPlayerPed(-1), -1)
	SetModelAsNoLongerNeeded(mybothashmodel)
end
--ORDERS
function followme() --A REFAIRE...
	if bliproute ~= nil and DoesBlipExist(bliproute) then
		Citizen.InvokeNative(0x86A652570E5F25DD,Citizen.PointerValueIntInitialized(bliproute))
		bliproute = nil
	end
	closestshop = nil
	driveorder = false
	ClearPedTasks(mybot)
end

function stopbot() --A REFAIRE...
	if bliproute ~= nil and DoesBlipExist(bliproute) then
		Citizen.InvokeNative(0x86A652570E5F25DD,Citizen.PointerValueIntInitialized(bliproute))
		bliproute = nil
	end
	closestshop = nil
	driveorder = false
	ClearPedTasks(mybot)
	TaskTurnPedToFaceEntity(mybot, GetPlayerPed(-1), -1)
end

function driverbot() --A REFAIRE...
	if bliproute ~= nil and DoesBlipExist(bliproute) then
		Citizen.InvokeNative(0x86A652570E5F25DD,Citizen.PointerValueIntInitialized(bliproute))
		bliproute = nil
	end
	closestshop = nil
	driveorder = true
	currentcar = GetVehiclePedIsUsing(GetPlayerPed(-1))
	if (DoesEntityExist(currentcar)) then
		Citizen.CreateThread(function ()
			TaskLeaveVehicle(mybot, currentcar, 1)
			TaskLeaveVehicle(GetPlayerPed(-1), currentcar, 1)
			Citizen.Wait(3000)
			TaskEnterVehicle(mybot, currentcar, -1, -1, 10.0001, 1)
			while true do
			Citizen.Wait(0)
				if (IsPedSittingInVehicle(mybot, GetVehiclePedIsUsing(mybot))) then
					TaskEnterVehicle(GetPlayerPed(-1), currentcar, -1, 0, 10.0001, 1)
					break
				end
			end
		end)
	end
end

function passengerbot() --A REFAIRE...
	if bliproute ~= nil and DoesBlipExist(bliproute) then
		Citizen.InvokeNative(0x86A652570E5F25DD,Citizen.PointerValueIntInitialized(bliproute))
		bliproute = nil
	end
	closestshop = nil
	driveorder = false
	TaskEnterVehicle(mybot, GetVehiclePedIsUsing(GetPlayerPed(-1)), -1, 0, 10.0001, 1)
end
--DRIVE TO...
function drivetoresto() --CREER UNE FONCTION UNIQUE "DriveTo"...
	if bliproute ~= nil and DoesBlipExist(bliproute) then
		Citizen.InvokeNative(0x86A652570E5F25DD,Citizen.PointerValueIntInitialized(bliproute))
		bliproute = nil
	end
	SetDriverAbility(mybot, 100)
	closestshop = getclosestshop(mybotshops)
	TaskVehicleDriveToCoordLongrange(mybot, currentcar, closestshop.x, closestshop.y, closestshop.z, 100.0, 1074528293, 10)
	bliproute = AddBlipForCoord(closestshop.x, closestshop.y, closestshop.z)
	N_0x80ead8e2e1d5d52e(bliproute)
	SetBlipRoute(bliproute, true)
	local currentdestination = closestshop
	Citizen.CreateThread(function ()
		while true do
		Citizen.Wait(0)
			mybotcoord = GetEntityCoords(mybot, 1)
			Texte("Distance= ~g~".. math.floor(Vdist(mybotcoord.x, mybotcoord.y, mybotcoord.z, closestshop.x, closestshop.y, closestshop.z)) .."~s~m", 5000)
			if (Vdist(mybotcoord.x, mybotcoord.y, mybotcoord.z, closestshop.x, closestshop.y, closestshop.z) < 25.0) then
				closestshop = nil
				if bliproute ~= nil and DoesBlipExist(bliproute) then
					Citizen.InvokeNative(0x86A652570E5F25DD,Citizen.PointerValueIntInitialized(bliproute))
					bliproute = nil
				end
				driveorder = false
				SetDriveTaskCruiseSpeed(mybot, 0)
				Texte("Nous sommes arrivés", 5000)
				break
			elseif (DoesEntityExist(mybot) == false) or (IsPedFatallyInjured(mybot)) then
				closestshop = nil
				if bliproute ~= nil and DoesBlipExist(bliproute) then
					Citizen.InvokeNative(0x86A652570E5F25DD,Citizen.PointerValueIntInitialized(bliproute))
					bliproute = nil
				end
				driveorder = false
				break
			elseif (currentdestination ~= closestshop) then
				break
			end
		end
	end)
end

function drivetocarshop() --CREER UNE FONCTION UNIQUE "DriveTo"...
	if bliproute ~= nil and DoesBlipExist(bliproute) then
		Citizen.InvokeNative(0x86A652570E5F25DD,Citizen.PointerValueIntInitialized(bliproute))
		bliproute = nil
	end
	SetDriverAbility(mybot, 100)
	closestshop = getclosestshop(mybotcarshops)
	TaskVehicleDriveToCoordLongrange(mybot, currentcar, closestshop.x, closestshop.y, closestshop.z, 100.0, 1074528293, 10)
	bliproute = AddBlipForCoord(closestshop.x, closestshop.y, closestshop.z)
	N_0x80ead8e2e1d5d52e(bliproute)
	SetBlipRoute(bliproute, true)
	local currentdestination = closestshop
	Citizen.CreateThread(function ()
		while true do
		Citizen.Wait(0)
			mybotcoord = GetEntityCoords(mybot, 1)
			Texte("Distance= ~g~".. math.floor(Vdist(mybotcoord.x, mybotcoord.y, mybotcoord.z, closestshop.x, closestshop.y, closestshop.z)) .."~s~m", 5000)
			if (Vdist(mybotcoord.x, mybotcoord.y, mybotcoord.z, closestshop.x, closestshop.y, closestshop.z) < 25.0) then
				if bliproute ~= nil and DoesBlipExist(bliproute) then
					Citizen.InvokeNative(0x86A652570E5F25DD,Citizen.PointerValueIntInitialized(bliproute))
					bliproute = nil
				end
				driveorder = false
				SetDriveTaskCruiseSpeed(mybot, 0)
				Texte("Nous sommes arrivés", 5000)
				break
			elseif (DoesEntityExist(mybot) == false) or (IsPedFatallyInjured(mybot)) then
				if bliproute ~= nil and DoesBlipExist(bliproute) then
					Citizen.InvokeNative(0x86A652570E5F25DD,Citizen.PointerValueIntInitialized(bliproute))
					bliproute = nil
				end
				driveorder = false
				break
			elseif (currentdestination ~= closestshop) then
				break
			end
		end
	end)
end

function drivetohopital() --CREER UNE FONCTION UNIQUE "DriveTo"...
	if bliproute ~= nil and DoesBlipExist(bliproute) then
		Citizen.InvokeNative(0x86A652570E5F25DD,Citizen.PointerValueIntInitialized(bliproute))
		bliproute = nil
	end
	SetDriverAbility(mybot, 100)
	closestshop = 301.720581054688, -1439.02856445313, 29.7993106842041
	local currentdestination = closestshop
	TaskVehicleDriveToCoordLongrange(mybot, currentcar, 301.720581054688,-1439.02856445313,29.7993106842041, 100.0, 1074528293, 10)-- | 262144, 20)
	Citizen.CreateThread(function ()
		while true do
		Citizen.Wait(0)
			mybotcoord = GetEntityCoords(mybot, 1)
			Texte("Distance= ~g~".. math.floor(Vdist(mybotcoord.x, mybotcoord.y, mybotcoord.z, 301.720581054688,-1439.02856445313,29.7993106842041)) .."~s~m", 5000)
			if (Vdist(mybotcoord.x, mybotcoord.y, mybotcoord.z, 301.720581054688,-1439.02856445313,29.7993106842041) < 25.0) then
				driveorder = false
				SetDriveTaskCruiseSpeed(mybot, 0)
				Texte("Nous sommes arrivés", 5000)
				break
			elseif (DoesEntityExist(mybot) == false) or (IsPedFatallyInjured(mybot)) then
				driveorder = false
				break
			elseif (currentdestination ~= closestshop) then
				break
			end
		end
	end)
end
--RAYCAST TEST
function getVehicleInDirection(coordFrom, coordTo) --PEUT SERVIR PLUS TARD...
	local rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z, 10, GetPlayerPed(-1), 0)
	local a, b, c, d, vehicle = GetRaycastResult(rayHandle)
	return vehicle
end
--TEXTE
function Texte(_texte, showtime)
    ClearPrints()
	SetTextEntry_2("STRING")
	AddTextComponentString(_texte)
	DrawSubtitleTimed(showtime, 1)
end
--CLOSEST DESTINATION FUNCTION
function getclosestshop(shopdestination)
	local closestdistance = -1
	mybotcoord = GetEntityCoords(mybot, 1)
	for index,value in ipairs(shopdestination) do
		local distance = GetDistanceBetweenCoords(mybotcoord["x"], mybotcoord["y"], mybotcoord["z"], value["x"], value["y"], value["z"], true)
		if(closestdistance == -1 or closestdistance > distance) then
			closestshop = value
			closestdistance = distance
		end
	end
	return closestshop
end
--AUTO FIND FREE SEAT
Citizen.CreateThread(function () --DONNE MAL AUX YEUX... A REFAIRE
	while true do
	Citizen.Wait(0)
		if DoesEntityExist(mybot) and (IsPedFatallyInjured(mybot) == false) and IsPedSittingInVehicle(GetPlayerPed(-1), GetVehiclePedIsUsing(GetPlayerPed(-1))) and (IsPedSittingInVehicle(mybot, GetVehiclePedIsUsing(GetPlayerPed(-1))) == false) and (driveorder == false) then
			if IsVehicleSeatFree(GetVehiclePedIsUsing(GetPlayerPed(-1)), 0) and (IsPedSittingInVehicle(mybot, GetVehiclePedIsUsing(GetPlayerPed(-1))) == false) and (trytoseat == true) then
				drawNotification("~g~MyBuddy cherche une place dans le véhicule.")
				trytoseat = false
				TaskEnterVehicle(mybot, GetVehiclePedIsUsing(GetPlayerPed(-1)), -1, 0, 10.0001, 1)
			elseif IsVehicleSeatFree(GetVehiclePedIsUsing(GetPlayerPed(-1)), 1) and (IsPedSittingInVehicle(mybot, GetVehiclePedIsUsing(GetPlayerPed(-1))) == false) and (trytoseat == true) then
				drawNotification("~g~MyBuddy cherche une place dans le véhicule.")
				trytoseat = false
				TaskEnterVehicle(mybot, GetVehiclePedIsUsing(GetPlayerPed(-1)), -1, 1, 10.0001, 1)
			elseif IsVehicleSeatFree(GetVehiclePedIsUsing(GetPlayerPed(-1)), 2) and (IsPedSittingInVehicle(mybot, GetVehiclePedIsUsing(GetPlayerPed(-1))) == false) and (trytoseat == true) then
				drawNotification("~g~MyBuddy cherche une place dans le véhicule.")
				trytoseat = false
				TaskEnterVehicle(mybot, GetVehiclePedIsUsing(GetPlayerPed(-1)), -1, 2, 10.0001, 1)
			elseif IsVehicleSeatFree(GetVehiclePedIsUsing(GetPlayerPed(-1)), 3) and (IsPedSittingInVehicle(mybot, GetVehiclePedIsUsing(GetPlayerPed(-1))) == false) and (trytoseat == true) then
				drawNotification("~g~MyBuddy cherche une place dans le véhicule.")
				trytoseat = false
				TaskEnterVehicle(mybot, GetVehiclePedIsUsing(GetPlayerPed(-1)), -1, 3, 10.0001, 1)
			elseif IsVehicleSeatFree(GetVehiclePedIsUsing(GetPlayerPed(-1)), 4) and (IsPedSittingInVehicle(mybot, GetVehiclePedIsUsing(GetPlayerPed(-1))) == false) and (trytoseat == true) then
				drawNotification("~g~MyBuddy cherche une place dans le véhicule.")
				trytoseat = false
				TaskEnterVehicle(mybot, GetVehiclePedIsUsing(GetPlayerPed(-1)), -1, 4, 10.0001, 1)
			elseif IsVehicleSeatFree(GetVehiclePedIsUsing(GetPlayerPed(-1)), 5) and (IsPedSittingInVehicle(mybot, GetVehiclePedIsUsing(GetPlayerPed(-1))) == false) and (trytoseat == true) then
				drawNotification("~g~MyBuddy cherche une place dans le véhicule.")
				trytoseat = false
				TaskEnterVehicle(mybot, GetVehiclePedIsUsing(GetPlayerPed(-1)), -1, 5, 10.0001, 1)
			elseif IsVehicleSeatFree(GetVehiclePedIsUsing(GetPlayerPed(-1)), 6) and (IsPedSittingInVehicle(mybot, GetVehiclePedIsUsing(GetPlayerPed(-1))) == false) and (trytoseat == true) then
				drawNotification("~g~MyBuddy cherche une place dans le véhicule.")
				trytoseat = false
				TaskEnterVehicle(mybot, GetVehiclePedIsUsing(GetPlayerPed(-1)), -1, 6, 10.0001, 1)
			end
		elseif DoesEntityExist(mybot) and (IsPedFatallyInjured(mybot) == false) and (IsPedSittingInVehicle(mybot, GetVehiclePedIsUsing(GetPlayerPed(-1))) == false) then
			trytoseat = true
		end
		if DoesEntityExist(mybot) and (IsPedFatallyInjured(mybot)) or (IsPedFatallyInjured(GetPlayerPed(-1))) then
			if bliproute ~= nil and DoesBlipExist(bliproute) then
				Citizen.InvokeNative(0x86A652570E5F25DD,Citizen.PointerValueIntInitialized(bliproute))
				bliproute = nil
			end
			closestshop = nil
			Citizen.InvokeNative(0x9614299DCB53E54B, Citizen.PointerValueIntInitialized(mybot))
			driveorder = false
			drawNotification("~g~MyBuddy est mort.")
		end
	end
end)