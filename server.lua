-- Safezone Server Script (Advanced)
local safezones = {}
local safezoneFile = 'safezones.json'

-- Utility: Load safezones from file
local function loadSafezones()
    local file = io.open(safezoneFile, 'r')
    if file then
        local content = file:read('*a')
        file:close()
        if content and content ~= '' then
            safezones = json.decode(content) or {}
        end
    end
end

-- Utility: Save safezones to file
local function saveSafezones()
    local file = io.open(safezoneFile, 'w+')
    if file then
        file:write(json.encode(safezones))
        file:close()
    end
end

-- Utility: Sync safezones to all clients
local function syncSafezones()
    TriggerClientEvent('safezone:update', -1, safezones)
end

-- On resource start, load safezones and sync
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    loadSafezones()
    syncSafezones()
end)

-- On player join, sync safezones
AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local src = source
    TriggerClientEvent('safezone:update', src, safezones)
end)

-- Admin command: /addsafezone [radius]
RegisterCommand('addsafezone', function(source, args, raw)
    if IsPlayerAceAllowed(source, 'safezone.admin') then
        local radius = tonumber(args[1]) or 50.0
        local ped = GetPlayerPed(source)
        local coords = GetEntityCoords(ped)
        table.insert(safezones, {x = coords.x, y = coords.y, z = coords.z, radius = radius})
        saveSafezones()
        syncSafezones()
        TriggerClientEvent('chat:addMessage', source, {args = {'Safezone', 'Added safezone at your location (radius: '..radius..')'}})
    else
        TriggerClientEvent('chat:addMessage', source, {args = {'Safezone', '^1You do not have permission.'}})
    end
end, false)

-- Admin command: /removesafezone
RegisterCommand('removesafezone', function(source, args, raw)
    if IsPlayerAceAllowed(source, 'safezone.admin') then
        local ped = GetPlayerPed(source)
        local coords = GetEntityCoords(ped)
        local removed = false
        for i, zone in ipairs(safezones) do
            local dist = #(vector3(zone.x, zone.y, zone.z) - coords)
            if dist <= (zone.radius + 10.0) then -- 10m leeway
                table.remove(safezones, i)
                saveSafezones()
                syncSafezones()
                removed = true
                TriggerClientEvent('chat:addMessage', source, {args = {'Safezone', 'Removed nearest safezone.'}})
                break
            end
        end
        if not removed then
            TriggerClientEvent('chat:addMessage', source, {args = {'Safezone', '^1No safezone found nearby.'}})
        end
    else
        TriggerClientEvent('chat:addMessage', source, {args = {'Safezone', '^1You do not have permission.'}})
    end
end, false)

-- Admin command: /listsafezones
RegisterCommand('listsafezones', function(source, args, raw)
    if IsPlayerAceAllowed(source, 'safezone.admin') then
        if #safezones == 0 then
            TriggerClientEvent('chat:addMessage', source, {args = {'Safezone', 'No safezones set.'}})
        else
            for i, zone in ipairs(safezones) do
                TriggerClientEvent('chat:addMessage', source, {args = {'Safezone', string.format('Zone %d: (%.2f, %.2f, %.2f), radius: %.1f', i, zone.x, zone.y, zone.z, zone.radius)}})
            end
        end
    else
        TriggerClientEvent('chat:addMessage', source, {args = {'Safezone', '^1You do not have permission.'}})
    end
end, false)

-- Allow manual reload (optional)
RegisterCommand('reloadsafezones', function(source, args, raw)
    if IsPlayerAceAllowed(source, 'safezone.admin') then
        loadSafezones()
        syncSafezones()
        TriggerClientEvent('chat:addMessage', source, {args = {'Safezone', 'Safezones reloaded from file.'}})
    end
end, false) 