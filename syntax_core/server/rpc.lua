-- resources/[syntax]/syntax_core/server/rpc.lua

Syntax = Syntax or {}
Syntax.RPC = Syntax.RPC or {}

local Handlers = {}

function Syntax.RPC.Register(name, handler)
    Handlers[name] = handler
end

RegisterNetEvent("syntax:rpc:request", function(id, name, payload)
    local src = source
    local handler = Handlers[name]
    if not handler then return end

    local ok, result = pcall(handler, src, payload or {})
    if not ok then
        print("^1Syntax RPC error:^0", result)
        result = { error = true, message = "internal" }
    end

    TriggerClientEvent("syntax:rpc:response", src, id, result)
end)
