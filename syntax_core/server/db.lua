-- syntax_core/server/db.lua
-- Database wrapper for Syntax, exported so other resources can use it.

Syntax = Syntax or {}
Syntax.DB = Syntax.DB or {}

-- Async query returning full result set
function Syntax.DB.Query(sql, params, cb)
    exports.oxmysql:execute(sql, params or {}, function(result)
        if cb then
            cb(result)
        end
    end)
end

-- Async scalar (single value)
function Syntax.DB.Scalar(sql, params, cb)
    exports.oxmysql:scalar(sql, params or {}, function(result)
        if cb then
            cb(result)
        end
    end)
end

-- Exported wrappers so other resources (syntax_player, etc.) can call DB safely
exports("DB_Query", function(sql, params, cb)
    Syntax.DB.Query(sql, params, cb)
end)

exports("DB_Scalar", function(sql, params, cb)
    Syntax.DB.Scalar(sql, params, cb)
end)
