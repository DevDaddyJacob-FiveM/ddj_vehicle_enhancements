fx_version "cerulean"
lua54 "yes"
game "gta5"
use_experimental_fxv2_oal "yes"

author "DevDaddyJacob"
description "A FiveM script which provides various enhancements to vehicles"
version "0.2.0"

dependencies {
	"ddj_lib", -- version >= 1.4.0
}

shared_scripts {
	"@ddj_lib/shared/logging.lua",
	
	"config.lua",
	"shared/utils.lua",
	"shared/state.lua",
}

client_scripts {
	"@ddj_lib/client/input.lua",
	"@ddj_lib/client/controls.lua",
	"@ddj_lib/client/drawText2DThisFrame.lua",

	"client/utils.lua",
	"client/modules/brakeLights.lua",
	"client/modules/gearShift.lua",
	"client/main.lua",
}

server_scripts {
	"server/main.lua",
}
