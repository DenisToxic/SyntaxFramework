-- syntax_char/client/init.lua
-- Only responsible for spawn-at-saved-position.
-- All character creation UI is handled by syntax_ui (Vue NUI).

RegisterNetEvent("syntax_char:spawnAtPosition", function(data)
    if not data or not data.x then return end

    local ped = PlayerPedId()

    DoScreenFadeOut(0)
    while not IsScreenFadedOut() do Wait(0) end

    -- Make sure loading screen is gone on this path as well
    ShutdownLoadingScreenNui()
    ShutdownLoadingScreen()
    SetNuiFocus(false, false)

    SetEntityCoordsNoOffset(ped, data.x, data.y, data.z, false, false, false)
    SetEntityHeading(ped, data.h or 0.0)

    FreezeEntityPosition(ped, false)
    ClearPedTasksImmediately(ped)
    SetEntityInvincible(ped, false)

    DoScreenFadeIn(1000)
end)
