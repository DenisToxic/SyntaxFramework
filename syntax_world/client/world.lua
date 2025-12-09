-- syntax_world/client/world.lua
-- Applies world config (NPC density, traffic, cops, etc.) on the client

-- Use defaults from shared config, but allow overrides via server cfg ConVars.

local cfg = SyntaxWorldConfig or {}

local function getBoolConvar(name, default)
    local defStr = default and "1" or "0"
    local v = GetConvar(name, defStr)
    v = string.lower(v or defStr)
    return v == "1" or v == "true" or v == "yes"
end

local function getFloatConvar(name, default)
    local v = GetConvar(name, tostring(default))
    v = tonumber(v)
    if not v then return default end
    if v < 0.0 then v = 0.0 end
    if v > 1.0 then v = 1.0 end
    return v
end

local WorldState = {
    populationEnabled = getBoolConvar("syntax_world_populationEnabled", cfg.populationEnabled),
    pedDensity        = getFloatConvar("syntax_world_pedDensity",      cfg.pedDensity),
    vehicleDensity    = getFloatConvar("syntax_world_vehicleDensity",  cfg.vehicleDensity),
    parkedDensity     = getFloatConvar("syntax_world_parkedDensity",   cfg.parkedDensity),
    scenarioDensity   = getFloatConvar("syntax_world_scenarioDensity", cfg.scenarioDensity),
    randomCops        = getBoolConvar("syntax_world_randomCops",       cfg.randomCops),
    randomTrains      = getBoolConvar("syntax_world_randomTrains",     cfg.randomTrains),
    randomBoats       = getBoolConvar("syntax_world_randomBoats",      cfg.randomBoats),
    idleCops          = getBoolConvar("syntax_world_idleCops",         cfg.idleCops),
}

-------------------------------------------------
-- Ambient services (cops, trains, boats)
-------------------------------------------------

CreateThread(function()
    -- Dispatch / cops
    if not WorldState.randomCops then
        for i = 1, 15 do
            EnableDispatchService(i, false)
        end

        SetCreateRandomCops(false)
        SetCreateRandomCopsOnScenarios(false)
        SetCreateRandomCopsNotOnScenarios(false)
    end

    -- Trains
    if not WorldState.randomTrains then
        SetRandomTrains(false)
    end

    -- Boats & garbage trucks
    if not WorldState.randomBoats then
        SetRandomBoats(false)
        SetGarbageTrucks(false)
    end

    -- We still want cops to react to crimes normally, so we don't ignore the player here.
end)

-------------------------------------------------
-- Densities & budgets (runs every frame)
-------------------------------------------------

CreateThread(function()
    while true do
        if WorldState.populationEnabled then
            -- Normal reduced population
            SetPedDensityMultiplierThisFrame(WorldState.pedDensity)
            SetScenarioPedDensityMultiplierThisFrame(WorldState.scenarioDensity, WorldState.scenarioDensity)

            SetVehicleDensityMultiplierThisFrame(WorldState.vehicleDensity)
            SetRandomVehicleDensityMultiplierThisFrame(WorldState.vehicleDensity)
            SetParkedVehicleDensityMultiplierThisFrame(WorldState.parkedDensity)

            SetPedPopulationBudget(3)       -- 0..3, higher = more peds
            SetVehiclePopulationBudget(3)   -- 0..3, higher = more vehicles
        else
            -- Hard disable AI population
            SetPedDensityMultiplierThisFrame(0.0)
            SetScenarioPedDensityMultiplierThisFrame(0.0, 0.0)

            SetVehicleDensityMultiplierThisFrame(0.0)
            SetRandomVehicleDensityMultiplierThisFrame(0.0)
            SetParkedVehicleDensityMultiplierThisFrame(0.0)

            SetPedPopulationBudget(0)
            SetVehiclePopulationBudget(0)
        end

        Wait(0) -- must be per-frame for density natives
    end
end)
