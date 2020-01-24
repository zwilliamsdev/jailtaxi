local ply = GetPlayerPed(-1) -- Player Ped ID

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local plyPos = GetEntityCoords(ply) -- returns vector3
        
        -- If player is within 10 units of the marker make it visible
        if Vdist2(plyPos.x, plyPos.y, plyPos.z, Config.taxiMarker.x, Config.taxiMarker.y, Config.taxiMarker.z) <= 10 then
            DrawMarker(25, Config.taxiMarker.x, Config.taxiMarker.y, Config.taxiMarker.z - 0.99, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 2.0, 2.0, 2.0, 255, 255, 0, 50, false, true, 2, nil, nil, false)
            -- If player is within 1 unit of the marker allow them to call a taxi
            if Vdist2(plyPos.x, plyPos.y, plyPos.z, Config.taxiMarker.x, Config.taxiMarker.y, Config.taxiMarker.z) <= 1 then
                alert('~y~Press ~INPUT_PICKUP~ to call a taxi you scumbag.')
                if IsControlJustReleased(0, 38) then
                    callTaxi()
                end
            end
        end
    end
end)

RegisterCommand("taxidebug", function()
    callTaxi()
end, false)

function callTaxi()
    local taxiModel = GetHashKey(Config.taxiModel) -- Get hash for taxi
    local driverModel = GetHashKey(Config.driverModel) -- Get hash for driver
    createModel(taxiModel) -- load the taxi model
    createModel(driverModel) -- load the driver model
    -- spawn the taxi
    local taxi = CreateVehicle(taxiModel, Config.taxiSpawn.x, Config.taxiSpawn.y, Config.taxiSpawn.z, 260.0, true, true)
    -- put the ped in the taxi
    local driver = CreatePedInsideVehicle(taxi, 4, driverModel, -1, true, true)
    driveToPickup(taxi, driver)
end

function driveToPickup(vehicle, driver)
    TaskVehicleDriveToCoord(driver, vehicle, Config.taxiPickup.x, Config.taxiPickup.y, Config.taxiPickup.z, 40.0, 447, 1.0)
end

function createModel(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(0)
    end
    SetModelAsNoLongerNeeded(model)
end


function alert(msg)
    SetTextComponentFormat("STRING")
    AddTextComponentString(msg)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end
