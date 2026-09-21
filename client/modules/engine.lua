local engineStates = {}

--[[
    By default GTA will auto-start a vehicle's engine when the accelerate
    input is pressed while it's off. Re-asserting `disableAutoStart` on the
    (already off) engine is what suppresses that.
]]
local function enforceAutoStartDisabled(vehicleHandle)
    if not Config["Engine"]["DisableAutoStart"] then
        return
    end

    SetVehicleEngineOn(vehicleHandle, false, true, true)
end


local function getEngineThreadState(vehicleHandle)
    local state = engineStates[vehicleHandle]
    if nil == state then
        state = {
            wasRunning = GetIsVehicleEngineRunning(vehicleHandle),
            manuallyTurnedOff = false,
        }

        engineStates[vehicleHandle] = state

        if not state.wasRunning then
            enforceAutoStartDisabled(vehicleHandle)
        end
    end

    return state
end


local function onToggleEnginePress()
    logger:trace("toggle engine press")

    if not isClientInVehicle() then
        logger:trace("client not in vehicle, cannot toggle engine")
        return
    end

    if not isClientInDriverSeat() then
        logger:trace("client not vehicle driver, cannot toggle engine")
        return
    end

    if not Input.isPressed("toggle_engine_modifier") then
        logger:trace("toggle engine modifier not held, ignoring")
        return
    end

    local vehHandle = getCurrentVehHandle()
    local engineRunning = GetIsVehicleEngineRunning(vehHandle)

    if engineRunning then
        if
            Config["GearShift"]["RequireParkToTurnOffEngine"]
            and Gears.Park ~= getVehicleGearState(vehHandle)
        then
            logger:debug("cannot turn engine off while not in park")
            return
        end

        if not canTurnEngineOff(vehHandle) then
            logger:debug("turning engine off denied by canTurnEngineOff hook")
            return
        end

        logger:debug("turning engine off")
        SetVehicleEngineOn(vehHandle, false, false, Config["Engine"]["DisableAutoStart"])
        getEngineThreadState(vehHandle).manuallyTurnedOff = true
    else
        if not canTurnEngineOn(vehHandle) then
            logger:debug("turning engine on denied by canTurnEngineOn hook")
            return
        end

        logger:debug("turning engine on")
        SetVehicleEngineOn(vehHandle, true, true, false)
        getEngineThreadState(vehHandle).manuallyTurnedOff = false
    end
end


--[[
    Vanilla GTA turns a vehicle's engine off automatically after its driver
    leaves it. Whenever we notice a controlled vehicle's engine turn off, for
    any reason, force it into park so it doesn't roll away unattended.
]]
local function engineWatcherThread()
    while true do
        local controlledVehicles = {}

        for _, vehicleHandle in ipairs(GetGamePool("CVehicle")) do
            if not NetworkGetEntityIsNetworked(vehicleHandle) then
                goto continue
            end
            
            if not NetworkHasControlOfEntity(vehicleHandle) then
                goto continue
            end
            
            if
                not isVehicleDrivenByClient(vehicleHandle)
                and doesVehicleHaveDriver(vehicleHandle)
            then
                goto continue
            end

            if not canControlEngine(vehicleHandle) then
                goto continue
            end


            controlledVehicles[vehicleHandle] = true

            local state = getEngineThreadState(vehicleHandle)
            local engineRunning = GetIsVehicleEngineRunning(vehicleHandle)

            if state.wasRunning and not engineRunning then
                if
                    Config["Engine"]["KeepEngineOnExit"]
                    and not state.manuallyTurnedOff
                    and canTurnEngineOn(vehicleHandle)
                then
                    logger:debug("restarting auto-shutoff engine, KeepEngineOnExit enabled [handle: %d]", vehicleHandle)

                    SetVehicleEngineOn(vehicleHandle, true, true, false)
                    engineRunning = true
                else
                    enforceAutoStartDisabled(vehicleHandle)

                    if Config["GearShift"]["Enabled"] then
                        logger:debug("vehicle engine turned off, forcing into park [handle: %d]", vehicleHandle)
                        setVehicleGearState(vehicleHandle, Gears.Park)
                    end
                end
            end

            state.wasRunning = engineRunning

            ::continue::
        end

        for vehicleHandle in pairs(engineStates) do
            if not controlledVehicles[vehicleHandle] then
                engineStates[vehicleHandle] = nil
            end
        end

        Citizen.Wait(0)
    end
end


function initEngineModule()
    if not Config["Engine"]["Enabled"] then
        logger:debug("engine module disabled")
        return
    end

    local ctrlToggleEngine = Config["Engine"]["Controls"]["ToggleEngine"]
    local ctrlToggleEngineMod = Config["Engine"]["Controls"]["ToggleEngineModifier"]

    Input.registerInput(
        "toggle_engine",
        ctrlToggleEngine["Command"],
        {
            description = "Toggles the vehicle's engine on/off",
            mapper = ctrlToggleEngine["Mapper"],
            defaultPrimary = ctrlToggleEngine["DefaultPrimary"]
        }
    )

    Input.registerInput(
        "toggle_engine_modifier",
        ctrlToggleEngineMod["Command"],
        {
            description = "Must be held to toggle the engine",
            mapper = ctrlToggleEngineMod["Mapper"],
            defaultPrimary = ctrlToggleEngineMod["DefaultPrimary"]
        }
    )

    Citizen.CreateThread(engineWatcherThread)
    Input.onPressed("toggle_engine", onToggleEnginePress)
end
