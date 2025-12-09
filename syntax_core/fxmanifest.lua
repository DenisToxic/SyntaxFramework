fx_version 'cerulean'
game 'gta5'

name 'syntax_core'
author 'SyntaxSolutions'
description 'Syntax RP core framework (security, RPC, DB)'
lua54 'yes'

shared_scripts {
    'shared/config.lua',
}

server_scripts {
    'server/db.lua',
    'server/events.lua',
    'server/rpc.lua',
    'server/init.lua',
    'server/commands.lua',
}

client_scripts {
    'client/rpc.lua',
    'client/init.lua',
}
