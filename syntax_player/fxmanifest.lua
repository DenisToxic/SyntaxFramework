fx_version 'cerulean'
game 'gta5'

name 'syntax_player'
description 'Syntax core player system'
author 'syntax'
lua54 'yes'

shared_scripts {
    'shared/config.lua',
}

server_scripts {
    'server/player.lua',
    'server/spawn.lua',
    'server/init.lua',
}

client_scripts {
    'client/init.lua',
}
