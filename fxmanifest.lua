-----------------For support, scripts, and more----------------
--------------- https://discord.gg/wasabiscripts  -------------
---------------------------------------------------------------
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

description 'Wasabi ESX/QBCore Evidence System'
author 'wasabirobby#5110'
version '1.0.3'

shared_scripts { '@ox_lib/init.lua', 'configuration/*.lua' }

client_scripts { 'bridge/**/client.lua', 'client/*', }

server_scripts { '@oxmysql/lib/MySQL.lua', 'bridge/**/server.lua', 'server/*.lua' }

dependencies { 'oxmysql', 'ox_lib' }