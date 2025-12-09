-- resources/[syntax]/syntax_core/client/rpc.lua

Syntax = Syntax or {}
Syntax.RPC = Syntax.RPC or {}

local pending = {}
local nextId = 0

function Syntax.RPC.Call(name, payload, cb, timeoutMs)
    timeoutMs = timeoutMs or 5000
    nextId = (nextId + 1) % 100000000
    local id = nextId

    pending[id] = {
        cb = cb,
        expire = GetGameTimer() + timeoutMs
    }

    TriggerServerEvent("syntax:rpc:request", id, name, payload or {})
end

RegisterNetEvent("syntax:rpc:response", function(id, result)
    local entry = pending[id]
    if not entry then return end
    pending[id] = nil
    entry.cb(result)
end)

CreateThread(function()
    while true do
        local now = GetGameTimer()
        for id, p in pairs(pending) do
            if now > p.expire then
                p.cb({ error = true, message = "timeout" })
                pending[id] = nil
            end
        end
        Wait(100)
    end
end)
