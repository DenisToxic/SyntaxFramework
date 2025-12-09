fx_version 'cerulean'
game 'gta5'

name 'syntax_ui'
description 'Unified Syntax Framework NUI (Vue 3 + Vite)'
author 'syntax'
lua54 'yes'

ui_page 'dist/index.html'

files {
    'dist/index.html',
    'dist/assets/*.js',
    'dist/assets/*.css',
}

client_scripts {
    'client/nui.lua',
}
