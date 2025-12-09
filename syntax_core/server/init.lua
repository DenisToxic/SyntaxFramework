-- Syntax core boot
print("^2[syntax_core] Loaded^0")

-- example secure event: server prints a ping
Syntax.Events.RegisterSecure("syntax:debug:ping", {
    schema = {
        msg = { type = "string", required = false },
    },
}, function(src, payload)
    print(("^3Syntax ping from %s: %s^0"):format(src, payload.msg or "no msg"))
end)
