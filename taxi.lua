local ply = GetPlayerPed(-1) -- Player Ped ID

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local plyPos = GetEntityCoords(ply) -- returns vector3
        
        -- If player is within 10 units of the marker make it visible
        if Vdist2(plyPos.x, plyPos.y, plyPos.z, Config.taxiMarker.x, Config.taxiMarker.y, Config.taxiMarker.z) <= 10 then
            DrawMarker(25, Config.taxiMarker.x, Config.taxiMarker.y, Config.taxiMarker.z - 0.99, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 2.0, 2.0, 2.0, 255, 255, 0, 50, false, true, 2, nil, nil, false)
        end
    end
end)
