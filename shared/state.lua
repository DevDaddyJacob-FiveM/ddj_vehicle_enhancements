local KEY_VEHICLE_GEAR = "DevDaddyJacob:VehicleEnhancements:Vehicle:Gear"
local KEY_VEHICLE_BRAKE_LIGHTS = "DevDaddyJacob:VehicleEnhancements:Vehicle:BrakeLights"

function getVehicleGearState(vehicleHandle)
    local state = Entity(vehicleHandle).state

    if nil == state[KEY_VEHICLE_GEAR] then
        return Gears.Park
    end

    return state[KEY_VEHICLE_GEAR]
end


function setVehicleGearState(vehicleHandle, gear)
    local state = Entity(vehicleHandle).state

    state:set(KEY_VEHICLE_GEAR, gear, true)
end


function getVehicleBrakeLightsState(vehicleHandle)
    local state = Entity(vehicleHandle).state

    if nil == state[KEY_VEHICLE_BRAKE_LIGHTS] then
        return false
    end

    return state[KEY_VEHICLE_BRAKE_LIGHTS]
end


function setVehicleBrakeLightsState(vehicleHandle, enabled)
    local state = Entity(vehicleHandle).state

    state:set(KEY_VEHICLE_BRAKE_LIGHTS, enabled, true)
end

if not IsDuplicityVersion() then
    AddStateBagChangeHandler(KEY_VEHICLE_BRAKE_LIGHTS, nil, function(bagName, key, value)
        Citizen.Wait(0)

        local vehicle = GetEntityFromStateBagName(bagName)
        if vehicle == 0 then
            return
        end

        SetVehicleBrakeLights(vehicle, true == value)
    end)
end

