-- quick test command to verify RPC + events

RegisterCommand("syntax_ping", function()
    TriggerServerEvent("syntax:debug:ping", { msg = "Hello from client" })
end, false)
