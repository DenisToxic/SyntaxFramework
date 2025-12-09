-- syntax_player/client/init.lua

---------------------------------------
-- Duty state (placeholder for now)
---------------------------------------

RegisterNetEvent("syntax:player:updateDuty", function(role, state)
    print(("Duty update: %s = %s"):format(role, tostring(state)))
    -- later: update HUD / NUI state instead of print
end)

---------------------------------------
-- Spawn handling
---------------------------------------

local function loadModel(hash)
    if not HasModelLoaded(hash) then
        RequestModel(hash)
        while not HasModelLoaded(hash) do
            Wait(0)
        end
    end
end

local function spawnPlayerAt(data)
    local modelName = data.model or "mp_m_freemode_01"
    local modelHash = GetHashKey(modelName)

    -- Fade out + loading screen cleanup
    DoScreenFadeOut(0)
    while not IsScreenFadedOut() do
        Wait(0)
    end

    ShutdownLoadingScreenNui()
    ShutdownLoadingScreen()

    -- Just in case any NUI kept focus
    SetNuiFocus(false, false)

    loadModel(modelHash)

    SetPlayerModel(PlayerId(), modelHash)
    local ped = PlayerPedId()
    SetPedDefaultComponentVariation(ped)

    -- Position
    SetEntityCoordsNoOffset(ped, data.x + 0.0, data.y + 0.0, data.z + 0.0, false, false, false)
    SetEntityHeading(ped, data.heading or 0.0)

    -- Basic health / cleanup
    SetEntityHealth(ped, 200)
    SetPedArmour(ped, 0)
    FreezeEntityPosition(ped, false)
    SetEntityInvincible(ped, false)
    ClearPedTasksImmediately(ped)

    -- Let other scripts know (compat with older stuff)
    TriggerEvent("playerSpawned", data)

    -- Fade in
    DoScreenFadeIn(1000)
end

RegisterNetEvent("syntax:player:spawn", function(spawnData)
    if type(spawnData) ~= "table" then return end
    if not spawnData.x or not spawnData.y or not spawnData.z then
        print("^1[syntax_player] Invalid spawn data received^0")
        return
    end
    spawnPlayerAt(spawnData)
end)

---------------------------------------
-- Commands (debug / dev)
---------------------------------------

-- /respawn: ask server to respawn us at a Syntax spawn point
RegisterCommand("respawn", function()
    TriggerServerEvent("syntax:player:requestRespawn", {})
end, false)
