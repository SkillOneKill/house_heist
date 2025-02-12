local breakinTargets = {}
local policeBlips = {}

ESX = exports["es_extended"]:getSharedObject()


CreateThread(function()
    for index, house in ipairs(Config.Houses) do
        local targetOptions = {
            {
                name = "house_breakin_" .. index,
                event = "breakin:start",
                icon = "fas fa-door-open",
                label = "Haus aufbrechen",
                houseIndex = index,
                canInteract = function(entity, distance, coords, name)
                    return distance < 2.0 and not house.robbed -- Nur, wenn das Haus nicht ausgeraubt ist
                end
            }
        }

        breakinTargets[index] = exports.ox_target:addSphereZone({
            coords = house.coords,
            radius = 1.5,
            options = targetOptions
        })
    end
end)

RegisterNetEvent("breakin:updateHouseStatus", function(houses)
    Config.Houses = houses -- Aktualisiert die Häuser-Daten vom Server
end)

RegisterNetEvent("breakin:start", function(data)
    local houseIndex = data.houseIndex
    local ped = PlayerPedId()
    local weapon = GetSelectedPedWeapon(ped)

    -- Prüfen, ob das Haus ausgeraubt wurde
    if Config.Houses[houseIndex].robbed then
        lib.notify({ 
            title = "Fehler", 
            description = "Dieses Haus wurde bereits ausgeraubt! Warte, bis es wieder verfügbar ist.", 
            type = "error" 
        })
        return
    end

    -- Prüfen, ob der Spieler eine Brechstange hat
    if weapon ~= GetHashKey(Config.RequiredWeapon) then
        lib.notify({ 
            title = "Fehler", 
            description = "Du musst eine Brechstange in der Hand halten!", 
            type = "error" 
        })
        return
    end

    -- Polizei benachrichtigen
    TriggerServerEvent("breakin:alertPolice", houseIndex)

    -- Einbruch beim Server anfragen
    TriggerServerEvent("breakin:attemptBreakIn", houseIndex)
end)

RegisterNetEvent("breakin:startBreakIn", function(houseIndex)
    local ped = PlayerPedId()

    -- Animation starten
    RequestAnimDict("missheistfbisetup1")
    while not HasAnimDictLoaded("missheistfbisetup1") do
        Wait(10)
    end
    TaskPlayAnim(ped, "missheistfbisetup1", "hassle_intro_loop_f", 8.0, -8, -1, 1, 0, false, false, false)

    -- Progress-Bar für Einbruch
    local success = lib.progressCircle({
        duration = Config.BreakInTime,
        label = "Haus aufbrechen...",
        useWhileDead = false,
        canCancel = true,
        position = "middle",
        disable = { car = true, move = true, combat = true },
    })

    -- Animation beenden
    ClearPedTasks(ped)

    -- Falls erfolgreich, Einbruch abschließen
    if success then
        TriggerServerEvent("breakin:success", houseIndex)
    else
        lib.notify({ 
            title = "Abgebrochen", 
            description = "Du hast den Einbruch abgebrochen.", 
            type = "error" 
        })
        TriggerServerEvent("breakin:removePoliceBlip", houseIndex) -- Blip entfernen
    end
end)

local policeBlips = {}

-- Funktion, um zu prüfen, ob der Spieler ein Polizist ist
function isPlayerPolice()
    local playerData = ESX.GetPlayerData()
    return playerData and playerData.job and playerData.job.name == "police"
end

-- Blip für die Polizei hinzufügen (wird nach 30 Sekunden entfernt)
RegisterNetEvent("breakin:policeAlert")
AddEventHandler("breakin:policeAlert", function(houseIndex, coords)
    if isPlayerPolice() then
        -- Falls es schon einen Blip gibt, entferne ihn vorher
        if policeBlips[houseIndex] then
            RemoveBlip(policeBlips[houseIndex])
            policeBlips[houseIndex] = nil
        end

        -- Neuen Blip für den Einbruch erstellen
        local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite(blip, 161) -- Warn-Symbol
        SetBlipScale(blip, 1.2)  -- Größe des Blips
        SetBlipColour(blip, 1)   -- Rot für Alarm
        SetBlipFlashes(blip, true) -- Blip blinkt
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Einbruch in ein Haus!")
        EndTextCommandSetBlipName(blip)

        -- Blip speichern
        policeBlips[houseIndex] = blip

        -- Blip nach 30 Sekunden automatisch entfernen
        Citizen.SetTimeout(60000, function()
            if policeBlips[houseIndex] then
                RemoveBlip(policeBlips[houseIndex])
                policeBlips[houseIndex] = nil
            end
        end)
    end
end)


-- Blip für die Polizei entfernen
RegisterNetEvent("breakin:removePoliceBlip")
AddEventHandler("breakin:removePoliceBlip", function(houseIndex)
    if isPlayerPolice() and policeBlips[houseIndex] then
        RemoveBlip(policeBlips[houseIndex])
        policeBlips[houseIndex] = nil
    end
end)