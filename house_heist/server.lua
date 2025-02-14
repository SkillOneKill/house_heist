ESX = exports['es_extended']:getSharedObject()
local lastOpened = {}

local currentVersion = "1.0.2" -- Deine aktuelle Version
local resourceName = GetCurrentResourceName() -- Holt den Namen des Skripts

-- GitHub-Infos (Ersetze mit deinen Daten)
local githubUser = "SkillOneKill"
local githubRepo = "house_heist"
local versionURL = "https://raw.githubusercontent.com/" .. githubUser .. "/" .. githubRepo .. "/main/version.txt"
local scriptURL = "https://github.com/" .. githubUser .. "/" .. githubRepo

-- Funktion zum Abrufen der neuesten Version von GitHub
PerformHttpRequest(versionURL, function(statusCode, newVersion, headers)
    if statusCode == 200 then
        newVersion = newVersion:gsub("%s+", "") -- Entfernt Leerzeichen/Zeilenumbrüche

        if newVersion == currentVersion then
            print("[^2" .. resourceName .. "^7] ✓ Resource is Up to Date - Current Version: " .. currentVersion)
        else
            print("[^3" .. resourceName .. "^7] ⚠ UPDATE AVAILABLE - New Version: " .. newVersion)
            print("[^3" .. resourceName .. "^7] 🔗 Download the latest version here: " .. scriptURL)
        end
    else
        print("[^1" .. resourceName .. "^7] ❌ ERROR - Could not check for updates. Check GitHub URL!")
    end
end, "GET", "", {})

RegisterNetEvent("breakin:attemptBreakIn")
AddEventHandler("breakin:attemptBreakIn", function(houseIndex)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not houseIndex or not Config.Houses[houseIndex] then
        return
    end

    if not xPlayer then
        return
    end

    if Config.Houses[houseIndex].robbed then
        TriggerClientEvent("ox_lib:notify", src, {
            title = "Fehler",
            description = "Dieses Haus wurde bereits ausgeraubt!",
            type = "error"
        })
        return
    end

    if lastOpened[houseIndex] and (GetGameTimer() - lastOpened[houseIndex]) < (Config.Cooldown * 1000) then
        TriggerClientEvent("ox_lib:notify", src, {
            title = "Fehler",
            description = "Dieses Haus wurde kürzlich ausgeraubt! Bitte warte.",
            type = "error"
        })
        return
    end

    if math.random(1, 100) <= Config.AlarmChance then
        TriggerClientEvent("breakin:policeAlert", -1, houseIndex, Config.Houses[houseIndex].coords)
    end

    TriggerClientEvent("breakin:startBreakIn", src, houseIndex)
end)

RegisterNetEvent("breakin:success")
AddEventHandler("breakin:success", function(houseIndex)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not houseIndex or not Config.Houses[houseIndex] then
        return
    end

    if not xPlayer then
        return
    end

    Config.Houses[houseIndex].robbed = true
    lastOpened[houseIndex] = GetGameTimer()

    TriggerClientEvent("breakin:updateHouseStatus", -1, Config.Houses)

    SetTimeout(Config.Cooldown * 1000, function()
        Config.Houses[houseIndex].robbed = false
        TriggerClientEvent("breakin:updateHouseStatus", -1, Config.Houses)
        TriggerClientEvent("breakin:removePoliceBlip", -1, houseIndex)
    end)

    local rewardType = math.random(1, 2)
    local rewardMessage = "Du hast erhalten: "

    if rewardType == 1 then
        local randomItem = Config.Rewards.items[math.random(#Config.Rewards.items)]
        local amount = math.random(randomItem.amount[1], randomItem.amount[2])

        if randomItem.name == "money" then
            xPlayer.addMoney(amount)
            rewardMessage = rewardMessage .. amount .. "$ Bargeld"
        elseif randomItem.name == "black_money" then
            xPlayer.addAccountMoney("black_money", amount)
            rewardMessage = rewardMessage .. amount .. "$ Schwarzgeld"
        else
            exports.ox_inventory:AddItem(xPlayer.source, randomItem.name, amount)
            rewardMessage = rewardMessage .. amount .. "x " .. randomItem.name
        end
    else
        local randomWeapon = Config.Rewards.weapons[math.random(#Config.Rewards.weapons)]
        exports.ox_inventory:AddItem(xPlayer.source, randomWeapon.name, 1)
        rewardMessage = rewardMessage .. randomWeapon.name
    end

    TriggerClientEvent("ox_lib:notify", src, { 
        title = "Erfolg", 
        description = rewardMessage, 
        type = "success" 
    })
end)

SetTimeout(Config.Cooldown * 1000, function()
    for houseIndex, _ in pairs(Config.Houses) do
        Config.Houses[houseIndex].robbed = false
        TriggerClientEvent("breakin:updateHouseStatus", -1, Config.Houses)
        TriggerClientEvent("breakin:removePoliceBlip", -1, houseIndex)
    end
end)
