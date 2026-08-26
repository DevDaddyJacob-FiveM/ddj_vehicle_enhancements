-- Init
Citizen.CreateThread(function()
    if Config["GearShift"]["Enabled"] then
        initGearShiftModule()
    end
end)
