Syntax = Syntax or {}
Syntax.Player = Syntax.Player or {}

local Players = {}

-------------------------------------------------
-- DB helper (use exports from syntax_core)
-------------------------------------------------
local DB = {}
function DB.Query(sql, params, cb) exports.syntax_core:DB_Query(sql, params, cb) end
function DB.Scalar(sql, params, cb) exports.syntax_core:DB_Scalar(sql, params, cb) end

-------------------------------------------------
-- Identifier helpers
-------------------------------------------------
local function getPrimaryIdentifier(src)
    local identifiers = GetPlayerIdentifiers(src)
    if not identifiers then return nil end

    for _, id in ipairs(identifiers) do
        if id:sub(1, 8) == "license:" then return id end
        if id:sub(1, 9) == "license2:" then return id end
    end
    return identifiers[1]
end

-------------------------------------------------
-- Player Class (Character Aware)
-------------------------------------------------
local Player = {}
Player.__index = Player

function Player:new(src, identifier, accountId)
    local self = setmetatable({}, Player)
    self.source = src
    self.identifier = identifier
    self.accountId = accountId
    self.characterId = nil
    self.charData = {} 
    self.position = vector3(0,0,0)
    self.data = {
        duty = { police = false, ems = false, doj = false }
    }
    return self
end

-- Account Getters
function Player:GetIdentifier() return self.identifier end
function Player:GetAccountId() return self.accountId end

-- Character Getters
function Player:GetCharacterId() return self.characterId end
function Player:GetFullName() 
    if not self.characterId then return "Unknown" end
    return self.charData.first_name .. " " .. self.charData.last_name 
end
function Player:GetJob() return self.charData.job or "unemployed" end
function Player:GetJobGrade() return self.charData.job_grade or 0 end

-- Duty System
function Player:SetDuty(role, state)
    state = not not state
    self.data.duty[role] = state
    TriggerClientEvent("syntax:player:updateDuty", self.source, role, state)
end

function Player:HasDuty(role) return self.data.duty[role] == true end

-- Character Loading
function Player:SetCharacter(charData)
    self.characterId = charData.id
    self.charData = charData
    
    if type(charData.position) == "string" then
        self.position = json.decode(charData.position)
    end
    
    -- Global State Bag for Client Access
    Player(self.source).state:set("character_id", charData.id, true)
    
    print(("[syntax_player] Character Loaded: %s (ID: %s)"):format(self:GetFullName(), self.characterId))
end

function Player:Save()
    if not self.characterId then return end
    local ped = GetPlayerPed(self.source)
    local coords = GetEntityCoords(ped)
    local posJson = json.encode({x = coords.x, y = coords.y, z = coords.z})
    
    DB.Query("UPDATE syntax_characters SET position = ?, job = ?, job_grade = ? WHERE id = ?", {
        posJson, self.charData.job, self.charData.job_grade, self.characterId
    })
end

-------------------------------------------------
-- Player Manager (The missing part)
-------------------------------------------------

function Syntax.Player.Create(src)
    local identifier = getPrimaryIdentifier(src)
    if not identifier then
        DropPlayer(src, "[Syntax] No valid identifier found.")
        return
    end

    DB.Query("SELECT id FROM syntax_accounts WHERE identifier = ?", { identifier }, function(rows)
        if not GetPlayerName(src) then return end -- Player disconnected

        if rows[1] then
            -- Existing Account
            local accountId = rows[1].id
            DB.Query("UPDATE syntax_accounts SET last_seen = NOW() WHERE id = ?", { accountId })
            
            local p = Player:new(src, identifier, accountId)
            Players[src] = p
            TriggerEvent("syntax:player:accountLoaded", src, accountId)
        else
            -- New Account
            DB.Query("INSERT INTO syntax_accounts (identifier) VALUES (?)", { identifier }, function()
                DB.Query("SELECT id FROM syntax_accounts WHERE identifier = ?", { identifier }, function(rows2)
                    if not rows2[1] then return end
                    local accountId = rows2[1].id
                    
                    local p = Player:new(src, identifier, accountId)
                    Players[src] = p
                    TriggerEvent("syntax:player:accountLoaded", src, accountId)
                end)
            end)
        end
    end)
end

function Syntax.Player.Drop(src)
    local p = Players[src]
    if p then p:Save() end
    Players[src] = nil
end

function Syntax.Player.GetBySource(src)
    return Players[src]
end

-- Export for external use
exports("GetPlayer", function(src)
    return Syntax.Player.GetBySource(src)
end)