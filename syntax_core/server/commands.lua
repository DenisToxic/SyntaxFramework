-- syntax_core/server/commands.lua
Syntax = Syntax or {}
Syntax.Commands = {}

--- Register a secure command
---@param name string Command name
---@param perm string|nil Required permission node (e.g. "admin.noclip"). nil = everyone.
---@param help string Help text
---@param arguments table Argument definitions for suggestions
---@param callback fun(src:number, args:table, raw:string)
function Syntax.Commands.Add(name, perm, help, arguments, callback)
    RegisterCommand(name, function(source, args, raw)
        if source == 0 then
            callback(source, args, raw)
            return
        end

        if perm then
            if not Syntax.Permissions or not Syntax.Permissions.Has then
                -- Fallback if permissions aren't loaded yet
                print("^1[syntax_core] Permissions module missing^0")
                return
            end

            if not Syntax.Permissions.Has(source, perm) then
                TriggerClientEvent("chat:addMessage", source, {
                    color = {255, 0, 0},
                    multiline = true,
                    args = {"System", "You do not have permission ("..perm..")"}
                })
                print(("[syntax_audit] Failed command '%s' by %s (missing %s)"):format(name, source, perm))
                return
            end
        end

        local ok, err = pcall(callback, source, args, raw)
        if not ok then
            print("^1[syntax_core] Command Error ("..name.."):^0", err)
        end
    end, false)
end

-- Export for other resources
exports("RegisterCommand", Syntax.Commands.Add)