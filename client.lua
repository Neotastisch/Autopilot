--- Script by Neotastisch


local vehicles = "" -- let empty
local tesla = nil
local tesla_blip = nil
local tesla_pilot = false
local tesla_pilot_ped = nil
local pilot = false

TriggerEvent('chat:addSuggestion', '/autopilot', 'Autopilot funktionen', {{name="on|mark", help="Aktiviere Autopilot oder makiere dein Fahrzeug."}})
RegisterCommand("autopilot", function(source, args)
	if(args[1] == "mark") then
		if IsPedInAnyVehicle(PlayerPedId(), false) then
			--Is in a vehicle
		else
			minimap("Set as nearest vehicle")
		local pos = GetEntityCoords(GetPlayerPed(-1),true)
		local veh = GetClosestVehicle(pos.x,pos.y,pos.z,100.00,0)
		if IsEntityAVehicle(veh) then
			tesla = veh
			
				SetEntityAsMissionEntity(veh, true, true)
				tesla_blip = AddBlipForEntity(veh)
				if(DoesBlipExist(tesla_blip)) then
					RemoveBlip(tesla_blip)
				end
			SetBlipSprite(tesla_blip, 79)
			SetBlipColour(tesla_blip, 25)
			BeginTextCommandSetBlipName("STRING")
      		AddTextComponentString("Car")
			EndTextCommandSetBlipName(tesla_blip)
			return
		end
	end

		if(IsPedInAnyVehicle(GetPlayerPed(-1)) and GetPedInVehicleSeat(GetVehiclePedIsIn(GetPlayerPed(-1), false), -1) == GetPlayerPed(-1) and (vehicles:find(GetDisplayNameFromVehicleModel(GetEntityModel(GetVehiclePedIsIn(GetPlayerPed(-1), false)))) or vehicles == "")) then
			tesla = GetVehiclePedIsIn(GetPlayerPed(-1), false)
			SetEntityAsMissionEntity(tesla, true, true)
			minimap("Dein Fahrzeug wurde makiert.")
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
			minimap("Das Fahrzeug wurde entfernt.")
			if(DoesBlipExist(tesla_blip)) then
				RemoveBlip(tesla_blip)
			end
			tesla_blip = nil
		end
	else
		if(IsPedInAnyVehicle(GetPlayerPed(-1), false) and GetPedInVehicleSeat(GetVehiclePedIsIn(GetPlayerPed(-1), false), -1) == GetPlayerPed(-1) and (vehicles:find(GetDisplayNameFromVehicleModel(GetEntityModel(GetVehiclePedIsIn(GetPlayerPed(-1), false)))) or vehicles == "")) then
			if(args[1] == "on") then
				waypoint = Citizen.InvokeNative(0xFA7C7F0AADF25D09, GetFirstBlipInfoId(8), Citizen.ResultAsVector())
				if(IsWaypointActive()) then
					if(pilot) then
						pilot = false
						minimap("Auto-Pilot abgebrochen.")
						ClearPedTasks(GetPlayerPed(-1))
					else
						pilot = true
						minimap("Auto-Pilot aktiviert.")
						TaskVehicleDriveToCoord(GetPlayerPed(-1), GetVehiclePedIsIn(GetPlayerPed(-1), 0), waypoint["x"], waypoint["y"], waypoint["z"], 100.0, 1.0, GetHashKey(GetVehiclePedIsIn(GetPlayerPed(-1), 0)), 786603, 0, true)
						SetDriveTaskDrivingStyle(GetPlayerPed(-1), 786603)
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
									minimap("Auto-Pilot deaktiviert.")
								end
								if(IsControlPressed(27, 63) or IsControlPressed(27, 64) or IsControlPressed(27, 71) or IsControlPressed(27, 72) or IsControlPressed(27, 76)or IsControlPressed(27, 131)) then
									pilot = false
									ClearPedTasks(GetPlayerPed(-1))
									minimap("Auto-Pilot deaktiviert.")
								end
							end
						end)
					end
				else
					minimap("Kein Ziel gesetzt.")
				end
			else
				minimap("Unknown action.")
			end
		elseif(tesla) then
			if(args[1] == "on") then
				if(tesla_pilot) then
					if(tesla_pilot_ped) then
						RemovePedElegantly(tesla_pilot_ped)
					end
					tesla_pilot = false
					tesla_pilot_ped = nil
					SetVehicleEngineOn(tesla, false, false, false)
					minimap("Auto-Pilot abgebrochen.")
				else
					RequestModel(225514697)
					while not HasModelLoaded(225514697) do
						Wait(5)
					end
					minimap("Auto-Pilot aktiviert.")
					tesla_pilot = true
					tesla_pilot_ped = CreatePed(0, 225514697, GetEntityCoords(tesla)["x"], GetEntityCoords(tesla)["y"], GetEntityCoords(tesla)["z"], 0.0, false, true)
					SetEntityAsMissionEntity(tesla_pilot_ped, true, true)
					SetPedIntoVehicle(tesla_pilot_ped, tesla, -1)
					SetEntityInvincible(tesla_pilot_ped, true)
					SetEntityVisible(tesla_pilot_ped, false, 0)
					player_coords = GetEntityCoords(GetPlayerPed(-1))
					TaskVehicleDriveToCoord(tesla_pilot_ped, tesla, player_coords.x, player_coords.y, player_coords.z, 100.0, 1.0, GetHashKey(tesla), 786603, 1.0, 1)
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
								SetVehicleEngineOn(tesla, false, false, false)
								minimap("Auto-Pilot angekommen.")
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
