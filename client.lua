--- Script by Neotastisch


local vehicles = "" -- let empty
local tesla = nil
local tesla_blip = nil
local tesla_pilot = false
local tesla_pilot_ped = nil
local pilot = false
local dance = false
local lines = false

TriggerEvent('chat:addSuggestion', '/autopilot', 'Autopilot features', {{name="toggle|mark|waypoint|follow", help="Activate Autopilot"}})
RegisterCommand("autopilot", function(source, args)
	if(args[1] == "author") then
		minimap("The author is Neotastisch")
	end
	if(args[1] == "waypoint") then
		if(tesla_pilot) then
			
			if(tesla_pilot_ped) then
				RemovePedElegantly(tesla_pilot_ped)
			end
			tesla_pilot = false
			tesla_pilot_ped = nil
			SetVehicleEngineOn(tesla, false, false, false)
			minimap("Auto-Pilot deactivated.")
		else
			RequestModel(225514697)
			while not HasModelLoaded(225514697) do
				Wait(5)
			end
			for i = 0, 6 do
				SetVehicleDoorShut(tesla, i, false) -- will close all doors from 0-6
			end
			minimap("Auto-Pilot activated.")
			tesla_pilot = true
			tesla_pilot_ped = CreatePed(0, 225514697, GetEntityCoords(tesla)["x"], GetEntityCoords(tesla)["y"], GetEntityCoords(tesla)["z"], 0.0, false, true)
			SetEntityAsMissionEntity(tesla_pilot_ped, true, true)
			SetPedIntoVehicle(tesla_pilot_ped, tesla, -1)
			SetEntityInvincible(tesla_pilot_ped, true)
			SetEntityVisible(tesla_pilot_ped, false, 0)
			waypoint = Citizen.InvokeNative(0xFA7C7F0AADF25D09, GetFirstBlipInfoId(8), Citizen.ResultAsVector())
			
			TaskVehicleDriveToCoord(tesla_pilot_ped, tesla, waypoint["x"], waypoint["y"], waypoint["z"], 25.0, 0.0, GetHashKey(tesla), 795452, 1.0, 1)
			Citizen.CreateThread(function()
				while tesla_pilot do
					Wait(100)
					if(GetDistanceBetweenCoords(GetEntityCoords(tesla)["x"], GetEntityCoords(tesla)["y"], GetEntityCoords(tesla)["z"], waypoint["x"], waypoint["y"], waypoint["z"], 0) < 10.0) then
						while GetEntitySpeed(tesla) - 1.0 > 0.0 do
							SetVehicleForwardSpeed(tesla, GetEntitySpeed(tesla) - 1.0)
							Wait(100)
						end
						tesla_pilot = false
						RemovePedElegantly(tesla_pilot_ped)
						tesla_pilot_ped = nil
						SetVehicleEngineOn(tesla, false, false, false)
						minimap("Auto-Pilot arrived.")
					end
				end
			end)
		end
		return
	end
	
	if(args[1] == "follow") then
		if(tesla_pilot) then
			if(tesla_pilot_ped) then
				RemovePedElegantly(tesla_pilot_ped)
			end
			tesla_pilot = false
			tesla_pilot_ped = nil
			SetVehicleEngineOn(tesla, false, false, false)
			minimap("Auto-Pilot deactivated.")
		else
			RequestModel(225514697)
			while not HasModelLoaded(225514697) do
				Wait(5)
			end
			for i = 0, 6 do
				SetVehicleDoorShut(tesla, i, false) -- will close all doors from 0-6
			end
			minimap("Auto-Pilot activated.")
			tesla_pilot = true
			tesla_pilot_ped = CreatePed(0, 225514697, GetEntityCoords(tesla)["x"], GetEntityCoords(tesla)["y"], GetEntityCoords(tesla)["z"], 0.0, false, true)
			SetEntityAsMissionEntity(tesla_pilot_ped, true, true)
			SetPedIntoVehicle(tesla_pilot_ped, tesla, -1)
			SetEntityInvincible(tesla_pilot_ped, true)
			SetEntityVisible(tesla_pilot_ped, false, 0)
			
			Citizen.CreateThread(function()
				while tesla_pilot do
					Wait(1000)
					player_coords = GetEntityCoords(GetPlayerPed(-1))
					speed = GetEntitySpeed(GetPlayerPed(-1));
					if(speed > 1)then speed = 19 end
					
					TaskVehicleDriveToCoord(tesla_pilot_ped, tesla, player_coords.x, player_coords.y, player_coords.z, speed+8, 0.0, GetHashKey(tesla), 525116, 1.0, 1)
				end
			end)
		end
		return
	end
	--
	if(args[1] == "dance") then
		if(dance) then
			dance = false
			SetVehicleDoorsShut(GetVehiclePedIsIn(GetPlayerPed(-1), false), false)
			minimap("Dance mode stopped.")
			for i = 0, 6 do
				SetVehicleDoorShut(tesla, i, false) -- will close all doors from 0-6
			end
			return
		else
			dance = true
			minimap("Dance mode started.")
			Citizen.CreateThread(function()
				SetVehRadioStation(GetVehiclePedIsIn(GetPlayerPed(-1), false), 'OFF')
				while dance do
					Wait(100)
					SetVehicleDoorOpen(GetVehiclePedIsIn(GetPlayerPed(-1), false), math.random(0, 6), false, false)
					SetVehicleDoorShut(GetVehiclePedIsIn(GetPlayerPed(-1), false), math.random(0, 6), false)
				end
			end)
			return
		end
	end
if(args[1] == "taxi") then
		minimap("Set as nearest vehicle")
		local pos = GetEntityCoords(GetPlayerPed(-1),true)
		local veh = GetClosestVehicle(pos.x,pos.y,pos.z,100000.00,0)
		if IsEntityAVehicle(veh) then
			tesla = veh
			SetEntityAsMissionEntity(veh, true, true)
			TaskVehicleDriveToCoord(GetPlayerPed(-1), GetVehiclePedIsIn(GetPlayerPed(-1), 0), waypoint["x"], waypoint["y"], waypoint["z"], 30.0, 0.0, GetHashKey(GetVehiclePedIsIn(GetPlayerPed(-1), 0)), 525116, 0, true)
			return
		else
			minimap("No vehicles in distance.")
			return
		end
	end
	if(args[1] == "lines") then
		if(lines) then
			minimap("Reverse lines deactivated.")
			lines = false
		else
			minimap("Reverse lines activated.")
			lines = true
			Citizen.CreateThread(function()
				while lines do
					Wait(5)
					if(IsPedInAnyVehicle(GetPlayerPed(-1)) and GetPedInVehicleSeat(GetVehiclePedIsIn(GetPlayerPed(-1), false), -1) == GetPlayerPed(-1)) then
						if(GetVehicleCurrentGear(GetVehiclePedIsIn(GetPlayerPed(-1), false)) == 0) then
							DrawLine(GetOffsetFromEntityInWorldCoords(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1.0, -2.0, 0.0).x, GetOffsetFromEntityInWorldCoords(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1.0, -2.0, 0.0).y, GetOffsetFromEntityInWorldCoords(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1.0, -2.0, 0.0).z, GetOffsetFromEntityInWorldCoords(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1.0 - (GetVehicleSteeringAngle(GetVehiclePedIsIn(GetPlayerPed(-1), false)) / GetVehicleHandlingFloat(GetVehiclePedIsIn(GetPlayerPed(-1), false), "CHandlingData", "fSteeringLock")), -6.0, 0.0).x, GetOffsetFromEntityInWorldCoords(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1.0 - (GetVehicleSteeringAngle(GetVehiclePedIsIn(GetPlayerPed(-1), false)) / GetVehicleHandlingFloat(GetVehiclePedIsIn(GetPlayerPed(-1), false), "CHandlingData", "fSteeringLock")), -6.0, 0.0).y, GetOffsetFromEntityInWorldCoords(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1.0 - (GetVehicleSteeringAngle(GetVehiclePedIsIn(GetPlayerPed(-1), false)) / GetVehicleHandlingFloat(GetVehiclePedIsIn(GetPlayerPed(-1), false), "CHandlingData", "fSteeringLock")), -6.0, 0.0).z, 255, 255, 255, 255)
							DrawLine(GetOffsetFromEntityInWorldCoords(GetVehiclePedIsIn(GetPlayerPed(-1), false), -1.0, -2.0, 0.0).x, GetOffsetFromEntityInWorldCoords(GetVehiclePedIsIn(GetPlayerPed(-1), false), -1.0, -2.0, 0.0).y, GetOffsetFromEntityInWorldCoords(GetVehiclePedIsIn(GetPlayerPed(-1), false), -1.0, -2.0, 0.0).z, GetOffsetFromEntityInWorldCoords(GetVehiclePedIsIn(GetPlayerPed(-1), false), -1.0 - (GetVehicleSteeringAngle(GetVehiclePedIsIn(GetPlayerPed(-1), false)) / GetVehicleHandlingFloat(GetVehiclePedIsIn(GetPlayerPed(-1), false), "CHandlingData", "fSteeringLock")), -6.0, 0.0).x, GetOffsetFromEntityInWorldCoords(GetVehiclePedIsIn(GetPlayerPed(-1), false), -1.0 - (GetVehicleSteeringAngle(GetVehiclePedIsIn(GetPlayerPed(-1), false)) / GetVehicleHandlingFloat(GetVehiclePedIsIn(GetPlayerPed(-1), false), "CHandlingData", "fSteeringLock")), -6.0, 0.0).y, GetOffsetFromEntityInWorldCoords(GetVehiclePedIsIn(GetPlayerPed(-1), false), -1.0 - (GetVehicleSteeringAngle(GetVehiclePedIsIn(GetPlayerPed(-1), false)) / GetVehicleHandlingFloat(GetVehiclePedIsIn(GetPlayerPed(-1), false), "CHandlingData", "fSteeringLock")), -6.0, 0.0).z, 255, 255, 255, 255)
						end
					else
						lines = false
					end
				end
			end)
		end
	end
	if(args[1] == "mark") then
		if IsPedInAnyVehicle(PlayerPedId(), false) then
			--Is in a vehicle
		else
		minimap("Set as nearest vehicle")
		local pos = GetEntityCoords(GetPlayerPed(-1),true)
		local veh = GetClosestVehicle(pos.x,pos.y,pos.z,100000.00,0)
		if IsEntityAVehicle(veh) then
			tesla = veh
			SetEntityAsMissionEntity(veh, true, true)
			if(DoesBlipExist(tesla_blip)) then
				RemoveBlip(tesla_blip)
			end
			tesla_blip = AddBlipForEntity(veh)
			SetBlipSprite(tesla_blip, 79)
			SetBlipColour(tesla_blip, 25)
			BeginTextCommandSetBlipName("STRING")
      		AddTextComponentString("Car")
			EndTextCommandSetBlipName(tesla_blip)
			return
		else
			minimap("No vehicles in distance.")
			return
		end
	end

		if(IsPedInAnyVehicle(GetPlayerPed(-1)) and GetPedInVehicleSeat(GetVehiclePedIsIn(GetPlayerPed(-1), false), -1) == GetPlayerPed(-1) and (vehicles:find(GetDisplayNameFromVehicleModel(GetEntityModel(GetVehiclePedIsIn(GetPlayerPed(-1), false)))) or vehicles == "")) then
			tesla = GetVehiclePedIsIn(GetPlayerPed(-1), false)
			SetEntityAsMissionEntity(tesla, true, true)
			minimap("Your vehicle was marked.")
			if(DoesBlipExist(tesla_blip)) then
				RemoveBlip(tesla_blip)
			end
			tesla_blip = AddBlipForEntity(tesla)
			SetBlipSprite(tesla_blip, 79)
			SetBlipColour(tesla_blip, 25)
			BeginTextCommandSetBlipName("STRING")
      		AddTextComponentString("Car")
			EndTextCommandSetBlipName(tesla_blip)
		else
			tesla = nil
			minimap("Your vehicle was removed from your map.")
			if(DoesBlipExist(tesla_blip)) then
				RemoveBlip(tesla_blip)
			end
			tesla_blip = nil
		end
	else
		if(IsPedInAnyVehicle(GetPlayerPed(-1), false) and GetPedInVehicleSeat(GetVehiclePedIsIn(GetPlayerPed(-1), false), -1) == GetPlayerPed(-1) and (vehicles:find(GetDisplayNameFromVehicleModel(GetEntityModel(GetVehiclePedIsIn(GetPlayerPed(-1), false)))) or vehicles == "")) then
			if(args[1] == "toggle" or args[1] == "on" or args[1] == nil) then
				waypoint = Citizen.InvokeNative(0xFA7C7F0AADF25D09, GetFirstBlipInfoId(8), Citizen.ResultAsVector())
				if(IsWaypointActive()) then
					if(pilot) then
						pilot = false
						SetVehicleDoorOpen(tesla, 0, false)
						minimap("Auto-Pilot disabled.")
						ClearPedTasks(GetPlayerPed(-1))
					else
						pilot = true
						minimap("Auto-Pilot activated.")
						TaskVehicleDriveToCoord(GetPlayerPed(-1), GetVehiclePedIsIn(GetPlayerPed(-1), 0), waypoint["x"], waypoint["y"], waypoint["z"], 30.0, 0.0, GetHashKey(GetVehiclePedIsIn(GetPlayerPed(-1), 0)), 525116, 0, true)
						SetDriveTaskDrivingStyle(GetPlayerPed(-1),795452)
						Citizen.CreateThread(function()
							while pilot do
								Wait(100)
								if(GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1))["x"], GetEntityCoords(GetPlayerPed(-1))["y"], GetEntityCoords(GetPlayerPed(-1))["z"], waypoint["x"], waypoint["y"], waypoint["z"], 0) < 10.0) then
									while GetEntitySpeed(GetVehiclePedIsIn(GetPlayerPed(-1), 0)) - 1.0 > 0.0 do
										SetVehicleForwardSpeed(GetVehiclePedIsIn(GetPlayerPed(-1), 0), GetEntitySpeed(GetVehiclePedIsIn(GetPlayerPed(-1), 0)) - 1.0)
										Wait(100)
									end
									pilot = false
									ClearPedTasks(GetPlayerPed(-1))
									SetVehicleDoorOpen(tesla, 0, false)
									minimap("Auto-Pilot disabled.")
								end
								if(IsControlPressed(27, 63) or IsControlPressed(27, 64) or IsControlPressed(27, 71) or IsControlPressed(27, 72) or IsControlPressed(27, 76)or IsControlPressed(27, 131)) then
									pilot = false
									ClearPedTasks(GetPlayerPed(-1))
									minimap("Auto-Pilot disabled.")
								end
							end
						end)
					end
				else
					minimap("No Waypoint was set.")
				end
			else
				minimap("Unknown action.")
			end
		elseif(tesla) then
			if(args[1] == "toggle" or args[1] == "on" or args[1] == nil) then
				if(tesla_pilot) then
					if(tesla_pilot_ped) then
						RemovePedElegantly(tesla_pilot_ped)
					end
					tesla_pilot = false
					tesla_pilot_ped = nil
					SetVehicleEngineOn(tesla, false, false, false)
					minimap("Auto-Pilot deactivated.")
				else
					RequestModel(225514697)
					while not HasModelLoaded(225514697) do
						Wait(5)
					end
					for i = 0, 6 do
						SetVehicleDoorShut(tesla, i, false) -- will close all doors from 0-6
					end
					minimap("Auto-Pilot activated.")
					tesla_pilot = true
					tesla_pilot_ped = CreatePed(0, 225514697, GetEntityCoords(tesla)["x"], GetEntityCoords(tesla)["y"], GetEntityCoords(tesla)["z"], 0.0, false, true)
					SetEntityAsMissionEntity(tesla_pilot_ped, true, true)
					SetPedIntoVehicle(tesla_pilot_ped, tesla, -1)
					SetEntityInvincible(tesla_pilot_ped, true)
					SetEntityVisible(tesla_pilot_ped, false, 0)
					player_coords = GetEntityCoords(GetPlayerPed(-1))
					TaskVehicleDriveToCoord(tesla_pilot_ped, tesla, player_coords.x, player_coords.y, player_coords.z, 120.0, 0.0, GetHashKey(tesla),525116, 1.0, 1)
					Citizen.CreateThread(function()
						while tesla_pilot do
							Wait(100)
							if(GetDistanceBetweenCoords(GetEntityCoords(tesla)["x"], GetEntityCoords(tesla)["y"], GetEntityCoords(tesla)["z"], player_coords.x, player_coords.y, player_coords.z, 0) < 10.0) then
								while GetEntitySpeed(tesla) - 1.0 > 0.0 do
									SetVehicleForwardSpeed(tesla, GetEntitySpeed(tesla) - 1.0)
									Wait(100)
								end
								tesla_pilot = false
								RemovePedElegantly(tesla_pilot_ped)
								tesla_pilot_ped = nil
								SetVehicleDoorOpen(tesla, 0, false, true)
								SetVehicleEngineOn(tesla, false, false, false)
								minimap("Auto-Pilot arrived.")
								
							end
						end
					end)
				end
			end
			
		else
			minimap("Unknown vehicle.")
		end
	end
end, false)

function minimap(text)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(text)
	DrawNotification(0,1)
end
