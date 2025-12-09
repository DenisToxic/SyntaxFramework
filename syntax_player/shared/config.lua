-- syntax_player/shared/config.lua
-- Shared config for Syntax player module (spawn + character rules)

Syntax = Syntax or {}

-- How many characters a single account can have
-- Most servers want 1; if you ever want multichar, change this to 2/3/4...
Syntax.PlayerConfig = {
    maxCharacters = 1
}

-- Basic spawn configuration for Syntax
Syntax.SpawnConfig = {
    -- default freemode model, replaced later by clothing/character system
    defaultModel = "mp_m_freemode_01",

    -- You can add as many spawn points as you want here
    points = {
        -- Legion Square
        { x = 195.17,  y = -933.74,  z = 30.69,  heading = 145.0 },

        -- LSIA (airport parking)
        { x = -1037.52, y = -2737.46, z = 20.17, heading = 330.0 },
    }
}
