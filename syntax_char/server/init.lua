-- resources/[syntax]/syntax_char/server/init.lua

Syntax = Syntax or {}
local CharState = {}  -- [src] = { accountId = x, characterId = y }

---------------------------------------------------
-- Handle accountLoaded from syntax_player
---------------------------------------------------

AddEventHandler("syntax:player:accountLoaded", function(src, accountId)
    if not accountId then
        print(("^1[syntax_char] syntax:player:accountLoaded without accountId for src %s^0"):format(src))
        return
    end

    -- Ensure Syntax.Char exists before we try to use it
    if not Syntax.Char then
        print("^1[syntax_char] CRITICAL: Syntax.Char is nil. Check fxmanifest load order!^0")
        return
    end

    CharState[src] = CharState[src] or {}
    CharState[src].accountId = accountId

    -- Try to find an existing character for this account
    Syntax.Char.LoadCharacter(accountId, function(char)
        -- Validate player is still connected
        if not GetPlayerName(src) then
            CharState[src] = nil
            return
        end

        if char then
            -- Character exists → remember it and spawn
            CharState[src].characterId = char.id

            print(("[syntax_char] Loaded character %s %s (id=%s)"):format(char.first_name, char.last_name, char.id))

            -- Ensure any creator UI is closed
            TriggerClientEvent("syntax_char:closeCreatorNUI", src)

            -- Tell the Player Module that the character is selected
            local player = exports.syntax_player:GetPlayer(src)
            if player then
                player:SetCharacter(char)
                TriggerEvent("syntax:player:selected", src, player)
            end

            -- Spawn Logic
            if char.position then
                -- Position is likely a JSON string from DB, parse it if needed or if LoadCharacter didn't
                local pos = type(char.position) == "string" and json.decode(char.position) or char.position
                
                TriggerClientEvent("syntax:char:spawn", src, {
                    coords = pos,
                    model = char.gender == "male" and "mp_m_freemode_01" or "mp_f_freemode_01",
                    skin = char.skin or {}
                })
            else
                -- Fallback spawn
                TriggerEvent("syntax:player:accountLoaded_forceSpawn", src)
            end
        else
            -- No character yet → ask client to open Vue creator UI
            print(("[syntax_char] No character for account %s, requesting creation"):format(accountId))
            TriggerClientEvent("syntax_char:openCreatorNUI", src)
        end
    end)
end)

---------------------------------------------------
-- Secure character creation event
---------------------------------------------------

CreateThread(function()
    -- Wait for Core to be ready
    while GetResourceState("syntax_core") ~= "started" do Wait(100) end

    exports.syntax_core:RegisterSecureServerEvent("syntax_char:create", {
        rateLimit = { windowMs = 10000, max = 3 },
        cooldownMs = 5000,
        schema = {
            first_name = { type = "string", required = true },
            last_name  = { type = "string", required = true },
            gender     = { type = "string", required = true },
            dob        = { type = "string", required = true },
        }
    }, function(src, payload)
        local state = CharState[src]
        
        -- Security: Must have a valid account loaded
        if not state or not state.accountId then
            print(("^1[syntax_char] create called but no account state for src %s^0"):format(src))
            return
        end

        -- Security: Cannot create if already has a character (Enforce 1 char limit for now)
        if state.characterId then
            print(("^1[syntax_char] src %s tried to create character but already has one^0"):format(src))
            return
        end

        Syntax.Char.CreateCharacter(state.accountId, {
            first_name = payload.first_name,
            last_name  = payload.last_name,
            gender     = payload.gender,
            dob        = payload.dob,
        }, function(char, err)
            if not GetPlayerName(src) then return end

            if not char then
                TriggerClientEvent("syntax_char:createFailed", src, err or "unknown")
                return
            end

            state.characterId = char.id

            print(("[syntax_char] Created character %s %s (id=%s)"):format(char.first_name, char.last_name, char.id))

            -- Close Vue creator
            TriggerClientEvent("syntax_char:closeCreatorNUI", src)

            -- Bind to Player Object
            local player = exports.syntax_player:GetPlayer(src)
            if player then
                player:SetCharacter(char)
                TriggerEvent("syntax:player:selected", src, player)
            end

            -- Initial Spawn
            TriggerClientEvent("syntax:char:spawn", src, {
                coords = {x = -1037.74, y = -2738.04, z = 20.169}, -- Airport default
                model = char.gender == "male" and "mp_m_freemode_01" or "mp_f_freemode_01",
                skin = {}
            })
        end)
    end)
end)

---------------------------------------------------
-- Save position on drop
---------------------------------------------------

AddEventHandler("playerDropped", function(reason)
    local src = source
    local state = CharState[src]
    
    if state and state.characterId then
        local ped = GetPlayerPed(src)
        if ped and ped ~= 0 then
            local coords = GetEntityCoords(ped)
            local heading = GetEntityHeading(ped)
            
            Syntax.Char.SavePosition(state.characterId, {
                x = coords.x, y = coords.y, z = coords.z, h = heading
            })
        end
    end

    CharState[src] = nil
end)