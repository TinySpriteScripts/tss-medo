fx_version 'cerulean'
game 'gta5'
lua54 'yes'

description 'tss-medo'
author 'TinySpriteScripts'
version '1.0.0'

shared_scripts {
    'shared/config.lua',
    '@jim_bridge/starter.lua',
}

client_script {
    'client/main.lua'
}

server_script {
    'server/main.lua'
}

dependency 'jim_bridge'