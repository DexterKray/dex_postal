fx_version 'cerulean'
game 'gta5'

author 'DexterKray'
description 'Postal Script'

version '1.0.0'

lua54 'yes'

shared_script '@ox_lib/init.lua'

client_script {
    'client.lua'
}

server_script {
    'server.lua'
}

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'postalcodes.json'
}

ui_page 'html/index.html'