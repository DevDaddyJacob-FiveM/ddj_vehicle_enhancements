local GTA_1_MPH = 2.236936

local function vibrateController(key)
    if false == Config["GearShift"]["ControllerVibrations"]["Enabled"] then
        return
    end

    local cfg = Config["GearShift"]["ControllerVibrations"][key]
    if nil == cfg then
        return
    end

    if false == cfg["Enabled"] then
        return
    end

    Controls.shakePad(cfg["DurationMs"], cfg["Frequency"])
end

local function onChangeGearPress()
    logger:trace("change gear press")

    if not isClientInVehicle() then
        logger:trace("client not in vehicle, cannot change gears")
        return
    end

    if not isClientInDriverSeat() then
        logger:trace("client not vehicle driver, cannot change gears")
        return
    end


    local vehHandle = getCurrentVehHandle()
    local currentGear = getVehicleGearState(vehHandle)
    local shiftUp = Input.isPressed("change_gear_modifier")
    local nextGear = getNextGear(currentGear, shiftUp)

    if nil == nextGear then
        logger:debug(
            "no gear to shift to [currentGear: %d, shiftUp: %s]",
            currentGear,
            tostring(shiftUp)
        )

        vibrateController("ShiftGearFail")
        return
    end

    logger:debug(
        "shifting gear [currentGear: %d, shiftUp: %s, nextGear: %d]",
        currentGear,
        tostring(shiftUp),
        nextGear
    )

    setVehicleGearState(vehHandle, nextGear)

    if shiftUp then
        vibrateController("ShiftGearUp")
    else
        vibrateController("ShiftGearDown")
    end
end


local function debugThread()
    while true do
        if isClientInVehicle() then
            local vehicleHandle = getCurrentVehHandle()

            drawText2DThisFrame({
                text = GetVehicleCurrentGear(vehicleHandle),
                x = 0.025,
                y = 0.34,
                alignment = 1
            })


            drawText2DThisFrame({
                text = GetEntitySpeedVector(vehicleHandle, true).y,
                x = 0.025,
                y = 0.37,
                alignment = 1
            })

            drawText2DThisFrame({
                text = "normal(INPUT_VEH_BRAKE): " .. tostring(Controls.getNormal(ControlInputs.INPUT_VEH_BRAKE, false)),
                x = 0.025,
                y = 0.4,
                alignment = 1
            })

            drawText2DThisFrame({
                text = "disabledNormal(INPUT_VEH_BRAKE): " .. tostring(Controls.getDisabledNormal(ControlInputs.INPUT_VEH_BRAKE, false)),
                x = 0.025,
                y = 0.43,
                alignment = 1
            })

            drawText2DThisFrame({
                text = "normal(INPUT_VEH_ACCELERATE): " .. tostring(Controls.getNormal(ControlInputs.INPUT_VEH_ACCELERATE, false)),
                x = 0.025,
                y = 0.46,
                alignment = 1
            })

            drawText2DThisFrame({
                text = "disabledNormal(INPUT_VEH_ACCELERATE): " .. tostring(Controls.getDisabledNormal(ControlInputs.INPUT_VEH_ACCELERATE, false)),
                x = 0.025,
                y = 0.49,
                alignment = 1
            })
        end


        Citizen.Wait(0)
    end
end


local function integratedHUDThread()
    while Config["GearShift"]["UseIntegratedHUD"] do
        if isClientInVehicle() then
            local vehicleHandle = getCurrentVehHandle()
            local currentGear = getVehicleGearState(vehicleHandle)

            local names = {}
            for key, value in pairs(Gears) do
                if  Gears.Invalid ~= value then
                    names[value] = key
                end
            end

            local displayText = ""
            for value, key in ipairs(names) do
                if
                    Gears.Invalid == value
                    or (not Config["GearShift"]["EnableNeutral"] and Gears.Neutral == value)
                    or (not Config["GearShift"]["EnableReverse"] and Gears.Reverse == value)
                then
                    goto continue
                end

                if currentGear == value then
                    displayText = displayText .. "~w~"
                else
                    displayText = displayText .. "~c~"
                end

                displayText = displayText .. key .. "~s~~n~"

                ::continue::
            end

            drawText2DThisFrame({
                text = displayText,
                x = 0.025,
                y = 0.6
            })
        end


        Citizen.Wait(0)
    end
end


local vehicleGearStates = {}

local function getVehicleGearThreadState(vehicleHandle)
    local state = vehicleGearStates[vehicleHandle]
    if nil == state then
        state = {
            lastGear = nil,
            brakeFwd = false,
            brakeBwd = false,
        }

        vehicleGearStates[vehicleHandle] = state

        logger:debug("took control of gear shift logic for vehicle [handle: %d]", vehicleHandle)
    end

    return state
end


local function processVehicleGear(vehicleHandle, state, hasDriverInput)
    local currentGear = getVehicleGearState(vehicleHandle)


    -- Handle being in park
    if Gears.Park == currentGear then
        state.lastGear = Gears.Park

        SetVehicleControlsInverted(vehicleHandle, false)

        if hasDriverInput then
            Controls.disableThisFrame(ControlInputs.INPUT_VEH_BRAKE)
        end

        SetVehicleHandbrake(vehicleHandle, true)
        for i = 0, GetVehicleNumberOfWheels(vehicleHandle) - 1, 1 do
            SetVehicleWheelBrakePressure(vehicleHandle, i, 1.0)
        end

        if hasDriverInput and Controls.isPressed(ControlInputs.INPUT_VEH_BRAKE, true) then
            setVehicleBrakeLightsState(vehicleHandle, true)
        end

    elseif Gears.Park == state.lastGear then
        SetVehicleHandbrake(vehicleHandle, false)

        state.lastGear = nil
    end


    -- Handle being in Drive
    if Gears.Drive == currentGear then
        state.lastGear = Gears.Drive

        SetVehicleControlsInverted(vehicleHandle, false)

        -- Disable auto reverse
        if
            hasDriverInput
            and Config["GearShift"]["DisableAutoReverse"]
            and not Config["GearShift"]["EnableReverse"]
        then
            local speedVec = GetEntitySpeedVector(vehicleHandle, true)
            if 1.0 <= speedVec.y or -1.0 >= speedVec.y then
                local brakeVal = Controls.getValue(ControlInputs.INPUT_VEH_BRAKE)
                local accelVal = Controls.getValue(ControlInputs.INPUT_VEH_ACCELERATE)

                state.brakeFwd = 127 < brakeVal and 1.0 <= speedVec.y
                state.brakeBwd = 127 < accelVal and -1.0 >= speedVec.y
            end

            local speed = GetEntitySpeed(vehicleHandle)
            if 1.0 > speed and state.brakeFwd then
                Controls.disableThisFrame(ControlInputs.INPUT_VEH_BRAKE)
                SetVehicleForwardSpeed(speed * 0.95)
                setVehicleBrakeLightsState(vehicleHandle, true)

                if 0 == Controls.getDisabledNormal(ControlInputs.INPUT_VEH_BRAKE) then
                    state.brakeFwd = false
                end
            end

            if 1.0 > speed and state.brakeBwd then
                Controls.disableThisFrame(ControlInputs.INPUT_VEH_ACCELERATE)
                SetVehicleForwardSpeed(speed * 0.95)
                setVehicleBrakeLightsState(vehicleHandle, true)

                if 0 == Controls.getDisabledNormal(ControlInputs.INPUT_VEH_ACCELERATE) then
                    state.brakeBwd = false
                end
            end
        end


        if Config["GearShift"]["EnableReverse"] then
            -- Auto roll if not on gas
            if not hasDriverInput or not Controls.isPressed(ControlInputs.INPUT_VEH_ACCELERATE) then
                local rollSpeed = GetEntitySpeedVector(vehicleHandle, true).y
                local rollTarget = Config["GearShift"]["AutoRoll"]["Speed"]
                local rollStep = Config["GearShift"]["AutoRoll"]["RampStep"]

                if rollTarget > rollSpeed then
                    SetVehicleForwardSpeed(
                        vehicleHandle,
                        math.min(rollTarget, rollSpeed + rollStep)
                    )
                end
            end

            local speed = GetEntitySpeed(vehicleHandle)
            if
                hasDriverInput
                and GTA_1_MPH > speed
                and Controls.isPressed(ControlInputs.INPUT_VEH_BRAKE, true)
            then
                Controls.disableThisFrame(ControlInputs.INPUT_VEH_BRAKE)
                Controls.setNormal(ControlInputs.INPUT_VEH_ACCELERATE, 0.8)

                SetVehicleCurrentRpm(vehicleHandle, 0.0)
                SetVehicleBrake(vehicleHandle, true)
                SetVehicleForwardSpeed(vehicleHandle, 0)
            end
        end
    elseif Gears.Drive == state.lastGear then
        state.brakeFwd = false
        state.brakeBwd = false

        state.lastGear = nil
    end


    -- Handle being in neutral
    if Gears.Neutral == currentGear then
        state.lastGear = Gears.Neutral

        SetVehicleControlsInverted(vehicleHandle, false)

        if hasDriverInput then
            Controls.disableThisFrame(ControlInputs.INPUT_VEH_ACCELERATE)

            local accelNormal = Controls.getDisabledNormal(ControlInputs.INPUT_VEH_ACCELERATE)
            if 0 < accelNormal then
                local rpmNormal = accelNormal * 1.1

                SetVehicleCurrentRpm(vehicleHandle, rpmNormal)
            end
        end

        local speed = GetEntitySpeed(vehicleHandle)
        if
            hasDriverInput
            and GTA_1_MPH > speed
            and Controls.isPressed(ControlInputs.INPUT_VEH_BRAKE, true)
        then
            Controls.disableThisFrame(ControlInputs.INPUT_VEH_BRAKE)

            SetVehicleCurrentRpm(vehicleHandle, 0.0)
            SetVehicleBrake(vehicleHandle, true)
            SetVehicleForwardSpeed(vehicleHandle, 0)
        end
    elseif Gears.Neutral == state.lastGear then

        state.lastGear = nil
    end


    -- Handle being in reverse
    if Gears.Reverse == currentGear then
        state.lastGear = Gears.Reverse

        SetVehicleControlsInverted(vehicleHandle, true)


        -- Auto roll if not on gas
        if not hasDriverInput or not Controls.isPressed(ControlInputs.INPUT_VEH_BRAKE, true) then
            local rollSpeed = GetEntitySpeedVector(vehicleHandle, true).y
            local rollTarget = -1 * Config["GearShift"]["AutoRoll"]["Speed"]
            local rollStep = Config["GearShift"]["AutoRoll"]["RampStep"]

            if rollTarget < rollSpeed then
                SetVehicleForwardSpeed(
                    vehicleHandle,
                    math.max(rollTarget, rollSpeed - rollStep)
                )
            end
        end

        local speed = GetEntitySpeed(vehicleHandle)
        if
            hasDriverInput
            and GTA_1_MPH > speed
            and Controls.isPressed(ControlInputs.INPUT_VEH_BRAKE, true)
        then
            Controls.setNormal(ControlInputs.INPUT_VEH_ACCELERATE, 0.8)

            SetVehicleCurrentRpm(vehicleHandle, 0.0)
            SetVehicleBrake(vehicleHandle, true)
            SetVehicleForwardSpeed(vehicleHandle, 0)
        end
    elseif Gears.Reverse == state.lastGear then
        SetVehicleControlsInverted(vehicleHandle, false)

        state.lastGear = nil
    end
end


local function vehicleGearThread()
    while true do
        local controlledVehicles = {}

        for _, vehicleHandle in ipairs(GetGamePool("CVehicle")) do
            if NetworkHasControlOfEntity(vehicleHandle) then
                controlledVehicles[vehicleHandle] = true

                local hasDriverInput =
                    isClientInDriverSeat()
                    and vehicleHandle == getCurrentVehHandle()

                processVehicleGear(vehicleHandle, getVehicleGearThreadState(vehicleHandle), hasDriverInput)
            end
        end

        for vehicleHandle in pairs(vehicleGearStates) do
            if not controlledVehicles[vehicleHandle] then
                vehicleGearStates[vehicleHandle] = nil

                logger:debug("gave up control of gear shift logic for vehicle [handle: %d]", vehicleHandle)
            end
        end

        Citizen.Wait(0)
    end
end


function initGearShiftModule()
    if not Config.GearShift.Enabled then
        logger:debug("gear shift module disabled")
        return
    end

    local ctrlChangeGear = Config["GearShift"]["Controls"]["ChangeGear"]
    local ctrlChangeGearMod = Config["GearShift"]["Controls"]["ChangeGearModifier"]

    Input.registerInput(
        "change_gear",
        ctrlChangeGear["Command"],
        {
            description = "Shifts into the next gear down",
            mapper = ctrlChangeGear["Mapper"],
            defaultPrimary = ctrlChangeGear["DefaultPrimary"]
        }
    )

    Input.registerInput(
        "change_gear_modifier",
        ctrlChangeGearMod["Command"],
        {
            description = "When held, changing gears shifts up",
            mapper = ctrlChangeGearMod["Mapper"],
            defaultPrimary = ctrlChangeGearMod["DefaultPrimary"]
        }
    )

    Citizen.CreateThread(vehicleGearThread)
    Citizen.CreateThread(integratedHUDThread)
    Citizen.CreateThread(debugThread)
    Input.onPressed("change_gear", onChangeGearPress)
end