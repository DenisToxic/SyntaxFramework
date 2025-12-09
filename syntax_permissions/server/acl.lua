Syntax = Syntax or {}
Syntax.Permissions = {}

local Roles = {
    ["user"]   = {},
    ["police"] = { "police.actions.cuff" },
    ["admin"]  = { "*" },
}

local UserRoles = {}

-- TODO: load from DB; for now everyone is "user"
AddEventHandler("playerJoining", function()
    local src = source
    local identifier = ("src:%s"):format(src)
    UserRoles[identifier] = { "user" }
end)

local function hasPerm(identifier, perm)
    local roles = UserRoles[identifier]
    if not roles then return false end
    for _, role in ipairs(roles) do
        local perms = Roles[role]
        if perms then
            for _, p in ipairs(perms) do
                if p == "*" or p == perm then
                    return true
                end
            end
        end
    end
    return false
end

function Syntax.Permissions.Has(src, perm)
    local player = Syntax.Player.GetBySource(src)
    if not player then return false end
    return hasPerm(player:GetIdentifier(), perm)
end
