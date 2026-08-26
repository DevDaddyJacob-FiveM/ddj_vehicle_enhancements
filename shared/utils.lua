Gears = {
    Invalid = -1,
    Drive = 1,
    Neutral = 2,
    Reverse = 3,
    Park = 4,
}


function gearToString(gear)
    for key, value in pairs(Gears) do
        if value == gear then 
            return key
        end
    end

    return nil
end


function getNextGear(currentGear, shiftUp)
    if true == shiftUp then
        return getNextGearUp(currentGear)
    end
    
    return getNextGearDown(currentGear)
end


function getNextGearDown(currentGear)
    -- In drive
    if Gears.Drive == currentGear then
        if Config.GearShift.EnableNeutral then
            return Gears.Neutral
        end

        if Config.GearShift.EnableReverse then
            return Gears.Reverse
        end

        return Gears.Park
    end
    

    -- In neutral
    if Gears.Neutral == currentGear then
        if Config.GearShift.EnableReverse then
            return Gears.Reverse
        end

        return Gears.Park
    end
    

    -- In reverse
    if Gears.Reverse == currentGear then
        return Gears.Park
    end
    

    -- In park
    if Gears.Park == currentGear then
        return nil
    end


    logger:error(
        "illegal argument provided to 'getNextGearDown'! Argument: %s",
        tostring(currentGear)
    )

    return nil
end


function getNextGearUp(currentGear)
    -- In drive
    if Gears.Drive == currentGear then
        return nil
    end
    

    -- In neutral
    if Gears.Neutral == currentGear then
        return Gears.Drive
    end
    

    -- In reverse
    if Gears.Reverse == currentGear then
        if Config.GearShift.EnableNeutral then
            return Gears.Neutral
        end

        return Gears.Drive
    end
    

    -- In park
    if Gears.Park == currentGear then
        if Config.GearShift.EnableReverse then
            return Gears.Reverse
        end

        if Config.GearShift.EnableNeutral then
            return Gears.Neutral
        end

        return Gears.Drive
    end


    logger:error(
        "illegal argument provided to 'getNextGearUp'! Argument: %s",
        tostring(currentGear)
    )

    return nil
end
