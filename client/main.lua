isInVehicle = false
currentVehicleHandle = -1
currentVehicleNetId = -1
currentVehicleSeat = -1

local function resetVehicleData()
    isInVehicle = false
    currentVehicleHandle = -1
    currentVehicleNetId = -1
    currentVehicleSeat = -1
end

RegisterNetEvent("DevDaddyJacob:Lib:Events:Client:OnEnteredVehicle", function(vehicle, seat, _3, vehNetId)
    isInVehicle = true
    currentVehicleHandle = vehicle
    currentVehicleNetId = seat
    currentVehicleSeat = vehNetId
end)

RegisterNetEvent("DevDaddyJacob:Lib:Events:Client:OnLeftVehicle", function(_1, _2, _3, _4)
    resetVehicleData()
end)