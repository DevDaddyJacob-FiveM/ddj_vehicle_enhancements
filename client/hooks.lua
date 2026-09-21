--[[
    Server owners: edit the functions below to add your own logic for
    whether this script is allowed to control a vehicle's engine. This is
    useful for things like key/theft/ignition scripts that need final say
    over a vehicle.

    Return false to deny the action, true to allow it. For example, to
    defer to another resource you run:

        function canControlEngine(vehicleHandle)
            if "started" == GetResourceState("my_other_script") then
                return exports["my_other_script"]:isVehicleUnlocked(vehicleHandle)
            end

            return true
        end
]]

--[[
    Gates ALL engine module behavior for a vehicle.
]]
function canControlEngine(vehicleHandle)
    return true
end


--[[
    Gates turning a vehicle's engine on.
]]
function canTurnEngineOn(vehicleHandle)
    return true
end


--[[
    Gates turning a vehicle's engine off.
]]
function canTurnEngineOff(vehicleHandle)
    return true
end
