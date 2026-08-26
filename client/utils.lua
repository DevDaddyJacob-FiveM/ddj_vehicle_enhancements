local isInVehicle = false
local currentVehicleHandle = 0
local currentVehicleNetId = 0
local currentVehicleSeat = 0


-- Data init, useful for restarts
local function initData()
    local ped = PlayerPedId()

    isInVehicle = IsPedInAnyVehicle(ped, false)
    currentVehicleHandle = GetVehiclePedIsIn(ped, false)
    currentVehicleNetId = VehToNet(currentVehicleHandle)
    
    currentVehicleSeat = -2
    for i = -2, GetVehicleMaxNumberOfPassengers(currentVehicleHandle) do
        if GetPedInVehicleSeat(currentVehicleHandle, i) == ped then
            currentVehicleSeat = i
        end
    end
end

initData()


local function resetVehicleData()
    isInVehicle = false
    currentVehicleHandle = 0
    currentVehicleNetId = 0
    currentVehicleSeat = 0
end


RegisterNetEvent("DevDaddyJacob:Lib:Events:Client:OnEnteredVehicle", function(vehicle, seat, _3, vehNetId)
    isInVehicle = true
    currentVehicleHandle = vehicle
    currentVehicleSeat = seat
    currentVehicleNetId = vehNetId
end)


RegisterNetEvent("DevDaddyJacob:Lib:Events:Client:OnLeftVehicle", function(_1, _2, _3, _4)
    resetVehicleData()
end)


function isClientInVehicle()
    return isInVehicle
end


function isClientInDriverSeat()
    return isInVehicle and -1 == currentVehicleSeat
end


function getCurrentVehHandle()
    return currentVehicleHandle
end


function getCurrentVehNetId()
    return currentVehicleNetId
end


function getCurrentVehSeatId()
    return currentVehicleSeat
end
