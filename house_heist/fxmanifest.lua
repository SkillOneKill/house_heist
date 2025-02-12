fx_version 'cerulean'
game 'gta5'

author 'SkillOneKIl'
description 'Einbruchssystem für FiveM mit ESX'
version '1.0.2'

shared_scripts {
    '@ox_lib/init.lua', -- ox_lib für Benachrichtigungen & ProgressBars
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@es_extended/imports.lua', -- ESX Kompatibilität
    'server.lua'
}

dependencies {
    'es_extended',  -- Erforderlich für ESX
    'ox_target',    -- Erforderlich für Interaktion mit Häusern
    'ox_inventory', -- Erforderlich für Item-Verwaltung
    'ox_lib'        -- Erforderlich für UI & Benachrichtigungen
}

lua54 'yes'
