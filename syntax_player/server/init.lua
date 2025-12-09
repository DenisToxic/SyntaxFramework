-- syntax_player server init

AddEventHandler("playerJoining", function()
    local src = source
    Syntax.Player.Create(src)
end)

AddEventHandler("playerDropped", function()
    local src = source
    Syntax.Player.Drop(src)
end)
