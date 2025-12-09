-- syntax_ui/client/nui.lua
-- NUI bridge + open/close of Vue character creator

-- NUI -> Server bridge for character creation
RegisterNUICallback("syntax_char:create", function(data, cb)
    TriggerServerEvent("syntax_char:create", data)
    cb("ok")
end)

-- Open Vue creator from server
RegisterNetEvent("syntax_char:openCreatorNUI", function()
    -- Kill the default loading screen so we don't get stuck on "Awaiting scripts"
    ShutdownLoadingScreenNui()
    ShutdownLoadingScreen()

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "openCreator",
        payload = {}
    })
end)

-- Close Vue creator from server
RegisterNetEvent("syntax_char:closeCreatorNUI", function()
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = "closeCreator"
    })
end)
