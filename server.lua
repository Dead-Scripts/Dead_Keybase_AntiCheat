-------------------------------
--- Fivem-Keybase-Anticheat ---
-------------------------------

-- Change 'KEY-FOR-EVENT' to your secret keys, only trigger these from server-side
ProtectedServerEvents = {
    {'KB-AC:UnprotectedExample:OOC', 'KEY-FOR-EVENT'},
    -- Add more protected events here
}

BlacklistedServerEvents = {
    "antilynxr4:detect",
    "ynx8:anticheat",
    "antilynx8r4a:anticheat",
    "lynx8:anticheat",
}

-- Track verified events per player
ProperlyVerified = {}

-- Protected server event handler
RegisterNetEvent('KB-AC:TriggerServerEvent')
AddEventHandler('KB-AC:TriggerServerEvent', function(eventKey, eventName, ...)
    local src = source or 0
    for i = 1, #ProtectedServerEvents do
        local protectedEvent = ProtectedServerEvents[i]
        if protectedEvent[1] == eventName then
            if protectedEvent[2] == eventKey then
                -- Valid trigger: mark as verified for this player
                ProperlyVerified[eventName..tostring(src)] = true
                TriggerEvent(eventName, ...)
            end
        end
    end
end)

-- Test command for protected events
RegisterCommand('testKBAnticheatProtected', function(source, args, rawCommand)
    TriggerEvent('KB-AC:TriggerServerEvent', 'KEY-FOR-EVENT', 'KB-AC:UnprotectedExample:OOC', table.concat(args, ' '))
end)

-- Example protected event
RegisterNetEvent('KB-AC:UnprotectedExample:OOC')
AddEventHandler('KB-AC:UnprotectedExample:OOC', function(msg)
    TriggerClientEvent('chatMessage', -1, '[OOC] ' .. msg)
end)

-- Auto-check verification for all protected events
for i = 1, #ProtectedServerEvents do
    local eventName = ProtectedServerEvents[i][1]
    AddEventHandler(eventName, function()
        local src = source or 0
        if ProperlyVerified[eventName..tostring(src)] then
            -- Verified, clear flag
            ProperlyVerified[eventName..tostring(src)] = nil
        else
            -- Not verified: player triggered without key
            if src > 0 then
                TriggerClientEvent('chatMessage', -1, 'Player ' .. src .. ' triggered a protected event without verification!')
                -- Optionally ban here
            end
        end
    end)
end

-- Blacklisted events: auto-ban/alert
for i = 1, #BlacklistedServerEvents do
    local eventName = BlacklistedServerEvents[i]
    AddEventHandler(eventName, function()
        local src = source or 0
        if src > 0 then
            TriggerClientEvent('chatMessage', -1, 'Player ' .. GetPlayerName(src) .. ' triggered a blacklisted event!')
            -- Optionally ban here
        end
    end)
end
