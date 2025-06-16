local oxmysql = exports.oxmysql

RegisterServerEvent('postal:savePositionClient')
AddEventHandler('postal:savePositionClient', function(x, y)
    local src = source
    local license = GetPlayerIdentifier(src, 0) -- Use the first identifier type (e.g., license)
    print("Received savePositionClient event for source: " .. tostring(src) .. ", license: " .. tostring(license) .. ", x: " .. tostring(x) .. ", y: " .. tostring(y))
    if license and x and y then
        oxmysql:execute('INSERT INTO dex_postal_positions (license, x, y) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE x = ?, y = ?', 
            { license, x, y, x, y }, function(result)
                if result.affectedRows > 0 then
                    TriggerClientEvent('ox_lib:notify', src, {
                        title = 'Postal Code',
                        description = 'Position saved successfully.',
                        type = 'success',
                        duration = 5000
                    })
                else
                    TriggerClientEvent('ox_lib:notify', src, {
                        title = 'Postal Code',
                        description = 'Failed to save position.',
                        type = 'error',
                        duration = 5000
                    })
                end
            end)
    else
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Postal Code',
            description = 'Failed to save position due to invalid data.',
            type = 'error',
            duration = 5000
        })
        print("Invalid data: license=" .. tostring(license) .. ", x=" .. tostring(x) .. ", y=" .. tostring(y))
    end
end)

RegisterServerEvent('postal:loadPositionClient')
AddEventHandler('postal:loadPositionClient', function()
    local src = source
    local license = GetPlayerIdentifier(src, 0)
    if license then
        oxmysql:fetch('SELECT x, y FROM dex_postal_positions WHERE license = ?', { license }, function(result)
            if result[1] then
                TriggerClientEvent('postal:setPosition', src, result[1].x, result[1].y)
            else
                TriggerClientEvent('postal:setPosition', src, 47.5, 95)
            end
        end)
    else
        print("Failed to load position: No license identifier for source " .. tostring(src))
        TriggerClientEvent('postal:setPosition', src, 47.5, 95)
    end
end)

RegisterServerEvent('postal:loadPosition')
AddEventHandler('postal:loadPosition', function(license)
    local src = source
    oxmysql:fetch('SELECT x, y FROM player_postal_positions WHERE license = ?', { license }, function(result)
        if result[1] then
            TriggerClientEvent('postal:setPosition', src, result[1].x, result[1].y)
        else
            TriggerClientEvent('postal:setPosition', src, 47.5, 95)
        end
    end)
end)