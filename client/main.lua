-- Init
Citizen.CreateThread(function()
    if Config["GearShift"]["Enabled"] then
        initGearShiftModule()
    end

    if Config["Engine"]["Enabled"] then
        initEngineModule()
    end
end)
