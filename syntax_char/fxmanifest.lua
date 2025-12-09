fx_version 'cerulean'
game 'gta5'
lua54 'yes'

shared_scripts {
    'shared/config.lua'
}

server_scripts {
    'server/char.lua', -- MUST BE FIRST
    'server/init.lua'  -- DEPENDS ON char.lua
}

client_scripts {
    'client/init.lua'
}