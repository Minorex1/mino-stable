fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

author 'Mino'
description 'Mino-Stable'
version '1.0.0'

shared_scripts {
	'config.lua'
}
client_scripts {
    'horse_comp.lua',
    'client/main.lua'
}
server_scripts {
    '@ghmattimysql/lib/MySQL.lua',
    'server/main.lua'
}
ui_page 'html/index.html'
files {
	'html/*',
	'html/css/*',
	'html/fonts/*',
	'html/img/*'
}