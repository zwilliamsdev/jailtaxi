-- Todos:
-- Stop player from stealing taxi
-- Once player is in taxi prompt them to set a location
-- Once location is selected player will accept and the taxi will drive to the location
-- Rate limit how often you can request a taxi

local ply = GetPlayerPed(-1) -- Player Ped ID

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local plyPos = GetEntityCoords(ply) -- returns vector3
        
        -- If player is within 30 units of the marker make it visible
        if Vdist2(plyPos.x, plyPos.y, plyPos.z, Config.taxiMarker.x, Config.taxiMarker.y, Config.taxiMarker.z) <= 30 then
            DrawMarker(25, Config.taxiMarker.x, Config.taxiMarker.y, Config.taxiMarker.z - 0.99, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 2.0, 2.0, 2.0, 255, 255, 0, 50, false, true, 2, nil, nil, false)
            -- If player is within 1 unit of the marker allow them to call a taxi
            if Vdist2(plyPos.x, plyPos.y, plyPos.z, Config.taxiMarker.x, Config.taxiMarker.y, Config.taxiMarker.z) <= 1 then
                alert('~y~Press ~INPUT_PICKUP~ to call a taxi you scumbag.')
                if IsControlJustReleased(0, 38) then
                    log('Player made a taxi callout')
                    callTaxi()
                    Citizen.Wait(6000) -- @TODO: Temporary solution to throttling issue
                end
            end
        end
    end
end)

RegisterCommand("taxidebug", function()
    callTaxi()
end, false)

function callTaxi()
    log('Starting to call the taxi')
    local taxiModel = GetHashKey(Config.taxiModel) -- Get hash for taxi
    local driverModel = GetHashKey(Config.driverModel) -- Get hash for driver
    createModel(taxiModel) -- load the taxi model
    createModel(driverModel) -- load the driver model
    -- spawn the taxi
    local taxi = CreateVehicle(taxiModel, Config.taxiSpawn.x, Config.taxiSpawn.y, Config.taxiSpawn.z, 260.0, true, true)
    -- put the ped in the taxi
    local driver = CreatePedInsideVehicle(taxi, 4, driverModel, -1, true, true)
    driveToPickup(taxi, driver)
    notify("~g~A taxi driver has been alerted please be patient!")
end

function driveToPickup(vehicle, driver)
    log('Taxi driver heading to pickup location now')
    SetDriverAbility(driver, 1.0) -- Make AI a smart driver
    SetDriverAggressiveness(driver, 0.0) -- Make AI non aggressive
    -- Make driver go to the pickup point
    TaskVehicleDriveToCoordLongrange(driver, vehicle, Config.taxiPickup.x, Config.taxiPickup.y, Config.taxiPickup.z, 20.0, 447, 10.0)
    Citizen.CreateThread(function()
        local isTaxiDriving = true -- Is the taxi driving to the location still or at the pickup point
        while isTaxiDriving do -- While the taxi is driving
            Citizen.Wait(0) -- Prevent crashes and freezing
            local taxiPos = GetEntityCoords(vehicle) -- Get vehicles position
            -- If the vehicle is within the pickup zone
            if Vdist2(taxiPos.x, taxiPos.y, taxiPos.z, Config.taxiPickup.x, Config.taxiPickup.y, Config.taxiPickup.z) <= 10 then
                isTaxiDriving = false -- Tell the script the taxi is no longer driving and kill the the loop
                putPlayerInTaxi(vehicle) -- Call the next stage of the script
            end
        end
    end)
end

function putPlayerInTaxi(vehicle)
    log('Awaiting player entering the vehicle')
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)

            local taxiPos = GetEntityCoords(vehicle)
            local plyPos = GetEntityCoords(ply)
            
            if Vdist2(plyPos.x, plyPos.y, plyPos.z, taxiPos.x, taxiPos.y, taxiPos.z) <= 4 then
                alert('~y~Press ~INPUT_PICKUP~ to get in the taxi.')
                if IsControlJustReleased(0, 38) then
                    log('Attempting to place player in the taxi')
                    if AreAnyVehicleSeatsFree(vehicle) then
                        log('Seats available')
                    else
                        log('Seats not available')
                    end
                end
            end
        end
    end)
end

function createModel(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(0)
    end
    SetModelAsNoLongerNeeded(model)
end

function notify(msg)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(msg)
    DrawNotification(true, false)
end

function alert(msg)
    SetTextComponentFormat("STRING")
    AddTextComponentString(msg)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

function log(message)
    print('[jailtaxi]: '..message)
end
