stringtoboolean={ ["true"]=true, ["false"]=false }
local postalcodes = {}
local wasPaused = false
local isMovingPostal = false
local postalhidden = false

Citizen.CreateThread(function()
    local file = LoadResourceFile(GetCurrentResourceName(), "postalcodes.json")
    if file then
        postalcodes = json.decode(file)
        if postalcodes then
        else
        end
    else
    end
end)

function getNearestPostal()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local px, py = playerCoords.x, playerCoords.y

    local nearest = nil
    local shortestDist = math.huge

    for _, postal in pairs(postalcodes) do
        local dist = #(vector2(px, py) - vector2(postal.x, postal.y))
        if dist < shortestDist then
            shortestDist = dist
            nearest = postal.code
        end
    end

    return nearest or "Loading..."
end

Citizen.CreateThread(function()
    while true do
        local nearest = getNearestPostal()
        SendNUIMessage({
            action = "updatePostal",
            postal = nearest
        })
        Citizen.Wait(1000)
    end
end)

Citizen.CreateThread(function()
    local lastHour = -1
    local lastMinute = -1
    
    while true do
        local hour = GetClockHours()
        local minute = GetClockMinutes()
        
        if hour ~= lastHour or minute ~= lastMinute then
            SendNUIMessage({
                action = "updateTimeTheme",
                hour = hour,
                minute = minute
            })
            lastHour = hour
            lastMinute = minute
        end
        
        Citizen.Wait(1000) 
    end
end)

Citizen.CreateThread(function()
    while true do
        local isPaused = IsPauseMenuActive()

        if isPaused and not wasPaused then
            SendNUIMessage({
                action = "hidePostal"
            })
            wasPaused = true
        elseif not isPaused and wasPaused then
            SendNUIMessage({
                action = "showPostal"
            })
            wasPaused = false
        end
        
        Citizen.Wait(300)
    end
end)

AddEventHandler('onClientResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    SendNUIMessage({
        action = "disableMove",
        showSave = false
    })
    TriggerServerEvent('postal:loadPositionClient')
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    TriggerServerEvent('postal:loadPositionClient')
    postalhidden = stringtoboolean[GetResourceKvpString("postalUIHidden")]
    if postalhidden == true then
        SendNUIMessage({
            action = "hidePostal"
        })
    else
        SendNUIMessage({
            action = "showPostal"
        })
    end
end)

RegisterNetEvent('postal:setPosition')
AddEventHandler('postal:setPosition', function(x, y)
    SendNUIMessage({
        action = "setPosition",
        x = x,
        y = y
    })
end)

TriggerEvent('chat:addSuggestion', '/movepostal', 'Move the postal code UI')

RegisterCommand('movepostal', function()
    isMovingPostal = not isMovingPostal
    if isMovingPostal then
        SetNuiFocus(true, true)
    else
        SetNuiFocus(false, false)
    end
    SendNUIMessage({
        action = isMovingPostal and "enableMove" or "disableMove",
        showSave = isMovingPostal
    })
    lib.notify({
        title = "Postal Code",
        description = isMovingPostal and "Drag the postal UI to move it. Click Save to store position or press ESC to cancel." or "Postal UI movement disabled.",
        type = "info",
        duration = 10000
    })
end, false)

TriggerEvent('chat:addSuggestion', '/hidepostal', 'Hide or unhide the postal code UI')

RegisterCommand('hidepostal', function()
    if postalhidden == false then
        SendNUIMessage({
            action = "hidePostal"
        })
        postalhidden = true
        SetResourceKvp("postalUIHidden", "true")
    lib.notify({
        title = "Postal Code",
        description = "Postal hidden.",
        type = "info",
        duration = 5000
    })
    elseif postalhidden == true then
        SendNUIMessage({
            action = "showPostal"
        })
        postalhidden = false
        SetResourceKvp("postalUIHidden", "false")
    lib.notify({
        title = "Postal Code",
        description = "Postal unhidden.",
        type = "info",
        duration = 5000
    })
    end
end)

RegisterNUICallback('savePosition', function(data, cb)
    TriggerServerEvent('postal:savePositionClient', data.x, data.y)
    isMovingPostal = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = "disableMove",
        showSave = false
    })
    cb('ok')
end)

RegisterNUICallback('cancelMove', function(data, cb)
    print("Cancel move callback received")
    isMovingPostal = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = "disableMove",
        showSave = false
    })
    lib.notify({
        title = "Postal Code",
        description = "Postal UI movement cancelled, reverting to last saved position.",
        type = "error",
        duration = 5000
    })
    TriggerServerEvent('postal:loadPositionClient')
    cb('ok')
end)

TriggerEvent('chat:addSuggestion', '/postal', 'Set a waypoint to a postal code', {
    { name = 'postal', help = 'Postal code to set a waypoint to' }
})

RegisterCommand('postal', function(_, args)
    local targetCode = args[1]

    if not targetCode then
        lib.notify({
            title = "Postal Code",
            description = "Please provide a postal code.",
            type = "error",
            duration = 5000
        })
        return
    end

    local found = false
    for _, postal in pairs(postalcodes) do
        if postal.code == targetCode then
            SetNewWaypoint(postal.x + 0.0, postal.y + 0.0)
            lib.notify({
                title = "Postal Code",
                description = "Waypoint set to postal code: " .. targetCode,
                type = "success",
                duration = 5000
            })
            found = true
            break
        end
    end

    if not found then
        lib.notify({
            title = "Postal Code",
            description = "Postal code not found: " .. targetCode,
            type = "error",
            duration = 5000
        })
    end
end, false)