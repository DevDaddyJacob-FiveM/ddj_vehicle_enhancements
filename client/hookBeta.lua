--[[
    PINNED FOR LATER - NOT WIRED UP

    This is the original approach for the engine permission hooks: instead
    of server owners editing functions directly in this resource (see
    client/hooks.lua), other resources would register themselves in
    Config.Engine.PermissionResources and implement any of the exports
    below, and this resource would consult them via `exports[...]`.

    Shelved in favor of the simpler direct-edit hooks.lua approach for now,
    but keeping this around in case we want to revisit it. This file is
    intentionally NOT added to fxmanifest.lua, so it does nothing as-is.

    To bring this back:
        1. Add this file to the client_scripts list in fxmanifest.lua,
           in place of (or alongside) client/hooks.lua.
        2. Add the config block below into Config.Engine in config.lua.
        3. Remove client/hooks.lua (or make sure only one of the two
           provides canControlEngine/canTurnEngineOn/canTurnEngineOff, since
           both declare them as globals).
]]

local CheckedResources = {}

--[[
    Consults every resource in CheckedResources for the
    given export, returning false the moment one denies. A resource that
    isn't running, or doesn't implement the export, is treated as allowing
    the action.
]]
local function isEngineActionAllowed(exportName, vehicleHandle)
    for _, resourceName in ipairs(CheckedResources) do
        if "started" == GetResourceState(resourceName) then
            local ok, result = pcall(function()
                return exports[resourceName][exportName](exports[resourceName], vehicleHandle)
            end)

            if ok and false == result then
                logger:debug(
                    "engine action '%s' denied by resource '%s' [handle: %d]",
                    exportName,
                    resourceName,
                    vehicleHandle
                )

                return false
            end
        end
    end

    return true
end


function canControlEngine(vehicleHandle)
    return isEngineActionAllowed("canControlEngine", vehicleHandle)
end


function canTurnEngineOn(vehicleHandle)
    return canControlEngine(vehicleHandle) and isEngineActionAllowed("canTurnEngineOn", vehicleHandle)
end


function canTurnEngineOff(vehicleHandle)
    return canControlEngine(vehicleHandle) and isEngineActionAllowed("canTurnEngineOff", vehicleHandle)
end
