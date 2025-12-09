-- syntax_core/server/events.lua
-- Secure server event wrapper for Syntax

Syntax = Syntax or {}
Syntax.Events = Syntax.Events or {}

local EventRegistry = {}
local RateLimiter = {}

local function nowMs()
    return GetGameTimer()
end

local function getPlayerId(src)
    -- Later we can map to license/identifier; src is enough for rate limiting
    return tostring(src)
end

local function isPayloadWhitelisted(payload, schema)
    if not schema then return true end
    if type(payload) ~= "table" then return false, "payload_not_table" end

    for key, rule in pairs(schema) do
        local v = payload[key]
        if rule.required and v == nil then
            return false, ("missing field %s"):format(key)
        end
        if v ~= nil and rule.type and type(v) ~= rule.type then
            return false, ("field %s expected %s got %s"):format(
                key, rule.type, type(v)
            )
        end
        if rule.enum and v ~= nil then
            local ok = false
            for _, allowed in ipairs(rule.enum) do
                if allowed == v then ok = true break end
            end
            if not ok then
                return false, ("field %s has invalid value"):format(key)
            end
        end
    end

    return true
end

local function checkRateLimit(name, src, windowMs, maxCalls)
    local pid = getPlayerId(src)
    local key = name .. ":" .. pid
    local now = nowMs()

    local entry = RateLimiter[key]
    if not entry or now - entry.windowStart > windowMs then
        RateLimiter[key] = { windowStart = now, count = 1 }
        return true
    end

    if entry.count >= maxCalls then
        return false
    end

    entry.count = entry.count + 1
    return true
end

---@param name string
---@param opts table
---@param handler fun(src:number, payload:table)
function Syntax.Events.RegisterSecure(name, opts, handler)
    opts = opts or {}
    opts.rateLimit = opts.rateLimit or { windowMs = 5000, max = 10 }
    opts.cooldownMs = opts.cooldownMs or 500

    local existing = EventRegistry[name]

    if existing then
        -- Event already exists (e.g. resource restart). Just update options + handler.
        existing.opts = opts
        existing.handler = handler
        -- Keep existing.lastCall so cooldown still works.
        return
    end

    -- First-time registration: create registry entry and hook NetEvent.
    local eventEntry = {
        opts = opts,
        handler = handler,
        lastCall = {},
    }

    EventRegistry[name] = eventEntry

    RegisterNetEvent(name, function(payload)
        local src = source
        local event = EventRegistry[name]
        if not event then return end
        if type(src) ~= "number" or src <= 0 then return end

        local eOpts = event.opts

        -- payload whitelist
        local ok, err = isPayloadWhitelisted(payload, eOpts.schema)
        if not ok then
            print(("^1[syntax_core] SEC payload violation (%s) from %s: %s^0"):format(
                name, src, err or "unknown"
            ))
            return
        end

        -- rate limit
        if eOpts.rateLimit then
            local allowed = checkRateLimit(
                name, src, eOpts.rateLimit.windowMs, eOpts.rateLimit.max
            )
            if not allowed then
                print(("^1[syntax_core] SEC rate limit (%s) from %s^0"):format(
                    name, src
                ))
                return
            end
        end

        -- cooldown per source
        local now = nowMs()
        local last = event.lastCall[src] or 0
        if now - last < eOpts.cooldownMs then
            return
        end
        event.lastCall[src] = now

        -- permission check (if syntax_permissions loaded)
        if eOpts.permission and Syntax.Permissions and Syntax.Permissions.Has then
            if not Syntax.Permissions.Has(src, eOpts.permission) then
                print(("^1[syntax_core] SEC permission denied (%s) from %s^0"):format(
                    name, src
                ))
                return
            end
        end

        event.handler(src, payload or {})
    end)
end

-- Export for other resources (e.g., syntax_char, syntax_player) to register secure events
exports("RegisterSecureServerEvent", function(name, opts, handler)
    Syntax.Events.RegisterSecure(name, opts, handler)
end)
