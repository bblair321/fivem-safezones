local towing = false
local towedVehicle = nil
local ropeHandle = nil
local ropeObject = nil

-- List of allowed tow trucks
local validTowTrucks = {
    ["flatbed"] = true,
    ["flatbed2"] = true,
    ["flatbed3"] = true,
    ["towtruck"] = true,
    ["towtruck2"] = true
}

RegisterCommand("tow", function()
    local ped = PlayerPedId()
    local towTruck = GetVehiclePedIsIn(ped, true)

    if towTruck == 0 then
        Notify("~r~You must be in a tow truck.")
        return
    end

    local modelName = GetDisplayNameFromVehicleModel(GetEntityModel(towTruck)):lower()
    if not validTowTrucks[modelName] then
        Notify("~r~This is not a tow truck.")
        return
    end

    local targetVeh = GetVehicleInDirection(ped)
    if not towing and targetVeh ~= 0 then
        StartTowAnimation(ped)

        -- Attach with rope
        local towPos = GetEntityCoords(towTruck)
        local targetPos = GetEntityCoords(targetVeh)

        ropeHandle = AddRope(towPos.x, towPos.y, towPos.z + 1.0, 0.0, 0.0, 0.0, 10.0, 1, 0.0, 10.0, 0.0, false, false, true, 10.0, false)
        ropeObject = CreateObject(`prop_tool_hook`, towPos.x, towPos.y, towPos.z + 1.0, true, true, true)

        AttachEntitiesToRope(ropeHandle, towTruck, targetVeh, towPos.x, towPos.y, towPos.z + 1.0, targetPos.x, targetPos.y, targetPos.z + 0.5, 10.0, false, false, nil, nil)
        RopeLoadTextures()

        AttachEntityToEntity(targetVeh, towTruck, 20, 0.0, -3.5, 1.0, 0.0, 0.0, 0.0, false, false, true, false, 2, true)

        towing = true
        towedVehicle = targetVeh

        Notify("~g~Vehicle attached with winch.")
    elseif towing then
        DetachEntity(towedVehicle, true, true)
        PlaceObjectOnGroundProperly(towedVehicle)

        if DoesRopeExist(ropeHandle) then
            DeleteRope(ropeHandle)
            ropeHandle = nil
        end

        if DoesEntityExist(ropeObject) then
            DeleteEntity(ropeObject)
            ropeObject = nil
        end

        towing = false
        towedVehicle = nil

        Notify("~y~Vehicle detached.")
    else
        Notify("~r~No vehicle to tow.")
    end
end)

function GetVehicleInDirection(ped)
    local coords = GetEntityCoords(ped)
    local forward = GetOffsetFromEntityInWorldCoords(ped, 0.0, 5.0, 0.0)
    local ray = StartShapeTestRay(coords.x, coords.y, coords.z, forward.x, forward.y, forward.z, 10, ped, 0)
    local _, _, _, _, vehicle = GetShapeTestResult(ray)
    return vehicle
end

function StartTowAnimation(ped)
    local dict = "amb@world_human_vehicle_mechanic@male@base"
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(10)
    end

    TaskPlayAnim(ped, dict, "base", 8.0, -8.0, 2500, 1, 0, false, false, false)
    Wait(2500)
    ClearPedTasks(ped)
end

function Notify(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(false, true)
end