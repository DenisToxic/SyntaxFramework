-- syntax_player/server/spawn.lua
-- Server-side spawn logic for Syntax

Syntax = Syntax or {}
Syntax.Player = Syntax.Player or {}

local SpawnConfig = Syntax.SpawnConfig or {}

local function chooseSpawnPoint()
    local points = SpawnConfig.points or {}
    if type(points) ~= "table" or #points == 0 then
        -- Fallback: LSIA parking, safe and above ground
        return {
            x = -1037.92,
            y = -2737.76,
            z = 20.17,
            heading = 330.0
        }
    end

    local idx = math.random(1, #points)
    return points[idx]
end

-- Core spawn function, server-authoritative
function Syntax.Player.SpawnInitial(src)
    local point = chooseSpawnPoint()

    TriggerClientEvent("syntax:player:spawn", src, {
        x = point.x + 0.0,
        y = point.y + 0.0,
        z = point.z + 0.0,
        heading = point.heading or point.h or 0.0,
        model = SpawnConfig.defaultModel or "mp_m_freemode_01",
    })
end

-- Called by syntax_char when it wants Syntax to handle spawning
AddEventHandler("syntax:player:accountLoaded_forceSpawn", function(src)
    Syntax.Player.SpawnInitial(src)
end)

-- Secure respawn intent from client (rate limited)
CreateThread(function()
    -- Wait until syntax_core is fully started so the export exists
    while GetResourceState("syntax_core") ~= "started" do
        Wait(100)
    end

    exports.syntax_core:RegisterSecureServerEvent("syntax:player:requestRespawn", {
        rateLimit = { windowMs = 10000, max = 3 }, -- 3 requests / 10s
        cooldownMs = 10000,                        -- 10s per-player cooldown
        schema = {},                               -- no payload expected
    }, function(src, payload)
        Syntax.Player.SpawnInitial(src)
    end)
end)
