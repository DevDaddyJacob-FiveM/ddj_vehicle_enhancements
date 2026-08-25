fx_version "cerulean"
lua54 "yes"
game "gta5"
use_experimental_fxv2_oal "yes"

author "DevDaddyJacob"
description "A FiveM script which provides various enhancements to vehicles"
version "1.0.0"

dependencies {
	"ddj_lib", -- version >= 1.4.0
}

shared_scripts {
	"@ddj_lib/shared/logging.lua",
	"@ddj_lib/imports/rpc.lua",
	"config.lua",
	"shared/utils.lua",
}

client_scripts {
	"@ddj_lib/client/input.lua",
	"client/utils.lua",
	"client/main.lua",
}

server_scripts {
	"server/main.lua",
}
