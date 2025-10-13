fx_version 'cerulean'
game 'gta5'

description ' Shoulder Cam'
author 'Lonely Wolf'
version '2.0.1'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_scripts {
    --'@qbx_core/modules/playerdata.lua', -- for QBox ONLY
    'client.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua',
}

lua54 'yes'
