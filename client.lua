-- Safezone Client Script
local safezones = {}
local playerInSafezone = false
local currentSafezone = nil

-- Load safezones from server
RegisterNetEvent('safezone:update')
AddEventHandler('safezone:update', function(zones)
    safezones = zones or {}
end)

-- Main thread for safezone detection and effects
Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local inSafezone = false
        local nearestZone = nil
        
        -- Check if player is in any safezone
        for i, zone in ipairs(safezones) do
            local distance = #(playerCoords - vector3(zone.x, zone.y, zone.z))
            if distance <= zone.radius then
                inSafezone = true
                nearestZone = zone
                break
            end
        end
        
        -- Handle safezone entry/exit
        if inSafezone and not playerInSafezone then
            -- Player entered safezone
            playerInSafezone = true
            currentSafezone = nearestZone
            EnterSafezone()
        elseif not inSafezone and playerInSafezone then
            -- Player exited safezone
            playerInSafezone = false
            currentSafezone = nil
            ExitSafezone()
        end
        
        -- Apply safezone effects
        if playerInSafezone then
            ApplySafezoneEffects(playerPed)
        end
        
        Citizen.Wait(100) -- Check every 100ms
    end
end)

-- Thread for drawing safezone markers
Citizen.CreateThread(function()
    while true do
        if #safezones > 0 then
            for i, zone in ipairs(safezones) do
                -- Draw marker on ground
                DrawMarker(1, zone.x, zone.y, zone.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
                    zone.radius * 2.0, zone.radius * 2.0, 1.0, 0, 255, 0, 50, false, true, 2, false, nil, nil, false)
                
                -- Draw 3D marker in air
                DrawMarker(1, zone.x, zone.y, zone.z + 2.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
                    zone.radius * 2.0, zone.radius * 2.0, 1.0, 0, 255, 0, 30, false, true, 2, false, nil, nil, false)
            end
        end
        Citizen.Wait(0)
    end
end)

-- Function called when player enters safezone
function EnterSafezone()
    local playerPed = PlayerPedId()
    
    -- Show notification
    TriggerEvent('chat:addMessage', {
        args = {'Safezone', '^2You have entered a safezone. Combat is disabled.'}
    })
    
    -- Play sound effect (optional)
    PlaySoundFrontend(-1, "CHECKPOINT_PERFECT", "HUD_MINI_GAME_SOUNDSET", 1)
    
    -- Set player invincible
    SetEntityInvincible(playerPed, true)
    
    -- Disable weapons
    SetCurrentPedWeapon(playerPed, GetHashKey("WEAPON_UNARMED"), true)
    
    -- Clear any current weapon
    RemoveAllPedWeapons(playerPed, true)
end

-- Function called when player exits safezone
function ExitSafezone()
    local playerPed = PlayerPedId()
    
    -- Show notification
    TriggerEvent('chat:addMessage', {
        args = {'Safezone', '^3You have left the safezone. Combat is re-enabled.'}
    })
    
    -- Play sound effect (optional)
    PlaySoundFrontend(-1, "CHECKPOINT_MISSED", "HUD_MINI_GAME_SOUNDSET", 1)
    
    -- Remove invincibility
    SetEntityInvincible(playerPed, false)
end

-- Function to apply safezone effects while player is inside
function ApplySafezoneEffects(playerPed)
    -- Keep player invincible
    SetEntityInvincible(playerPed, true)
    
    -- Disable weapon switching
    DisableControlAction(0, 24, true) -- Attack
    DisableControlAction(0, 25, true) -- Aim
    DisableControlAction(0, 37, true) -- Weapon wheel
    DisableControlAction(0, 44, true) -- Cover
    DisableControlAction(0, 45, true) -- Reload
    DisableControlAction(0, 140, true) -- Melee attack
    DisableControlAction(0, 141, true) -- Melee attack 2
    DisableControlAction(0, 142, true) -- Melee attack alternate
    DisableControlAction(0, 257, true) -- Attack 2
    DisableControlAction(0, 263, true) -- Melee attack 1
    DisableControlAction(0, 264, true) -- Melee attack 2
    
    -- Disable vehicle attacks
    DisableControlAction(0, 69, true) -- Vehicle attack
    DisableControlAction(0, 70, true) -- Vehicle attack 2
    DisableControlAction(0, 92, true) -- Vehicle attack
    DisableControlAction(0, 114, true) -- Vehicle attack
    DisableControlAction(0, 140, true) -- Vehicle attack
    DisableControlAction(0, 141, true) -- Vehicle attack 2
    DisableControlAction(0, 142, true) -- Vehicle attack alternate
    DisableControlAction(0, 257, true) -- Vehicle attack
    DisableControlAction(0, 263, true) -- Vehicle attack 2
    DisableControlAction(0, 264, true) -- Vehicle attack alternate
    
    -- Remove any weapons that might have been given
    RemoveAllPedWeapons(playerPed, true)
end

-- Debug command to show safezone info (admin only)
RegisterCommand('safezoneinfo', function()
    if #safezones == 0 then
        TriggerEvent('chat:addMessage', {
            args = {'Safezone', 'No safezones configured.'}
        })
    else
        TriggerEvent('chat:addMessage', {
            args = {'Safezone', '^2Active safezones: ' .. #safezones}
        })
        for i, zone in ipairs(safezones) do
            TriggerEvent('chat:addMessage', {
                args = {'Safezone', string.format('Zone %d: (%.2f, %.2f, %.2f) - Radius: %.1f', i, zone.x, zone.y, zone.z, zone.radius)}
            })
        end
    end
end, false)